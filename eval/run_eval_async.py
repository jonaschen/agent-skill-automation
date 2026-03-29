import asyncio
import argparse
import os
import sys
import subprocess
import json
import time
import random
from prompt_cache import PromptCache
from bayesian_eval import get_stats

CONCURRENCY_LIMIT = 1  # Sequential: avoids burst rate-limiting on free-tier quota
MAX_RETRIES = 5
TIMEOUT = 150 # seconds per test

class AsyncEvalRunner:
    def __init__(self, skill_path, verbose=False, no_cache=False):
        self.skill_path = os.path.abspath(skill_path)
        self.verbose = verbose
        self.no_cache = no_cache
        self.cache = PromptCache()
        self.semaphore = asyncio.Semaphore(CONCURRENCY_LIMIT)
        self.repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
        self.description = self._get_description()
        self.splits = self._get_splits()

    def _get_description(self):
        try:
            with open(self.skill_path, 'r') as f:
                content = f.read()
                if content.startswith('---'):
                    import yaml
                    parts = content.split('---')
                    if len(parts) >= 2:
                        return yaml.safe_load(parts[1]).get("description", "")
            return ""
        except: return ""

    def _get_splits(self):
        splits_path = os.path.join(self.repo_root, "eval/splits.json")
        if os.path.exists(splits_path):
            with open(splits_path) as f: return json.load(f)
        return {"train": [], "validation": []}

    async def call_claude(self, prompt):
        cmd = ["claude", "--dangerously-skip-permissions", "-p", prompt]
        try:
            proc = await asyncio.create_subprocess_exec(
                *cmd,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.STDOUT,
                cwd=self.repo_root
            )
            stdout, _ = await asyncio.wait_for(proc.communicate(), timeout=TIMEOUT)
            return stdout.decode()
        except asyncio.TimeoutError:
            return "TIMEOUT_ERROR"
        except Exception as e:
            return f"EXECUTION_ERROR: {e}"

    async def run_test(self, test_id, prompt, expect_trigger):
        if not self.no_cache:
            cached = self.cache.get(prompt, self.description, expect_trigger)
            if cached:
                if self.verbose: print(f"  ⚡ Test {test_id}: CACHE HIT")
                return cached["result"]

        async with self.semaphore:
            for attempt in range(MAX_RETRIES):
                output = await self.call_claude(prompt)
                
                # Rate limit detection
                if any(x in output for x in ["rate_limit_error", "overloaded_error", "Overloaded.", "hit your limit", "resets 9pm"]):
                    wait = (2 ** attempt) + random.uniform(0, 1)
                    if self.verbose: print(f"    (Test {test_id} rate-limited, retry {attempt+1}/{MAX_RETRIES} in {wait:.1f}s)", file=sys.stderr)
                    await asyncio.sleep(wait)
                    continue
                
                result = self._evaluate(output, expect_trigger)
                if not self.no_cache:
                    self.cache.set(prompt, self.description, expect_trigger, result)
                
                # Cleanup disk pollution (safe because we only grep stdout/stderr)
                self._cleanup()
                
                return result
            
            return "SKIP:rate-limit"

    def _evaluate(self, output, expect_trigger):
        trigger_patterns = ["skill-quality-validator", "Agent generation complete", "Tools granted:", "Tools denied:"]
        triggered = any(p in output for p in trigger_patterns)
        
        if expect_trigger == "yes":
            return "PASS" if triggered else "FAIL:not-triggered"
        else:
            return "FAIL:false-positive" if triggered else "PASS"

    def _cleanup(self):
        try:
            # 1. Remove untracked files/dirs identified by git
            # We use --directory to get the root of untracked dirs
            res = subprocess.run(
                ["git", "ls-files", "--others", "--exclude-standard", "--directory", "--", ".claude/agents/", ".claude/skills/"],
                cwd=self.repo_root, capture_output=True, text=True
            )
            
            import shutil
            for item in res.stdout.strip().split('\n'):
                if not item: continue
                full_path = os.path.join(self.repo_root, item)
                if not os.path.exists(full_path): continue
                
                # Protect core directories themselves
                if item in [".claude/agents/", ".claude/skills/"]: continue
                
                if self.verbose: print(f"    (Cleaning up {item})", file=sys.stderr)
                
                if os.path.isdir(full_path):
                    shutil.rmtree(full_path)
                else:
                    os.remove(full_path)

            # 2. Remove untracked Changeling roles (usually in ~/.claude/@lib/agents/)
            home = os.path.expanduser("~")
            lib_agents_dir = os.path.join(home, ".claude/@lib/agents")
            if os.path.isdir(lib_agents_dir):
                core_roles = ["security-auditor", "perf-analyst", "database-administrator"]
                for f in os.listdir(lib_agents_dir):
                    if f.endswith(".md"):
                        name = f[:-3]
                        if name not in core_roles:
                            try:
                                os.remove(os.path.join(lib_agents_dir, f))
                            except: pass
        except Exception as e:
            if self.verbose: print(f"Cleanup error: {e}", file=sys.stderr)

    async def run_all(self, prompts_dir=None, expected_dir=None):
        if not prompts_dir:
            prompts_dir = os.path.join(self.repo_root, "eval/prompts")
        if not expected_dir:
            expected_dir = os.path.join(self.repo_root, "eval/expected")
        
        test_files = sorted([f for f in os.listdir(prompts_dir) if f.startswith("test_")], 
                            key=lambda x: int(x.split('_')[1].split('.')[0]))
        
        tasks = []
        test_ids = []
        for f in test_files:
            tid = int(f.split('_')[1].split('.')[0])
            with open(os.path.join(prompts_dir, f)) as pf: prompt = pf.read().strip()
            with open(os.path.join(expected_dir, f)) as ef: 
                exp = "yes" if "EXPECT_TRIGGER=yes" in ef.read() else "no"
            tasks.append(self.run_test(tid, prompt, exp))
            test_ids.append(tid)

        print(f"📊 Running Async Eval: {os.path.basename(self.skill_path)}")
        results = await asyncio.gather(*tasks)
        
        # Split analysis
        train_results = [r for tid, r in zip(test_ids, results) if tid in self.splits.get("train", [])]
        val_results = [r for tid, r in zip(test_ids, results) if tid in self.splits.get("validation", [])]
        
        full_stats = get_stats(results)
        train_stats = get_stats(train_results)
        val_stats = get_stats(val_results)

        print("\n" + "="*40)
        print(f"OVERALL: {full_stats['posterior_mean']:.3f} CI [{full_stats['ci_lower']:.3f}, {full_stats['ci_upper']:.3f}]")
        print(f"TRAIN:   {train_stats['posterior_mean']:.3f} CI [{train_stats['ci_lower']:.3f}, {train_stats['ci_upper']:.3f}]")
        print(f"VAL:     {val_stats['posterior_mean']:.3f} CI [{val_stats['ci_lower']:.3f}, {val_stats['ci_upper']:.3f}]")
        print("="*40)
        
        if self.verbose:
            for tid, res in zip(test_ids, results):
                print(f"Test {tid:2d}: {res}")

        # Final exit code logic
        if full_stats['posterior_mean'] >= 0.9 and full_stats['ci_lower'] >= 0.8: return 0
        return 2

async def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("skill_path")
    parser.add_argument("--verbose", action="store_true")
    parser.add_argument("--no-cache", action="store_true")
    parser.add_argument("--prompts-dir", help="Custom prompts directory")
    parser.add_argument("--expected-dir", help="Custom expected directory")
    args = parser.parse_args()
    
    runner = AsyncEvalRunner(args.skill_path, args.verbose, args.no_cache)
    sys.exit(await runner.run_all(args.prompts_dir, args.expected_dir))

if __name__ == "__main__":
    asyncio.run(main())
