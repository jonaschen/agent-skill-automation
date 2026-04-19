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
TIMEOUT = 300 # seconds per test (factory calls may use tools, taking 2-3 min)

class AsyncEvalRunner:
    def __init__(self, skill_path, verbose=False, no_cache=False, inter_test_delay=0, model=None):
        self.skill_path = os.path.abspath(skill_path)
        self.verbose = verbose
        self.no_cache = no_cache
        self.inter_test_delay = inter_test_delay
        self.model = model
        self.cache = PromptCache()
        self.semaphore = asyncio.Semaphore(CONCURRENCY_LIMIT)
        self.repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
        self.description = self._get_description()
        self.splits = self._get_splits()
        self._pre_run_roles = self._snapshot_roles()

    def _snapshot_roles(self):
        """Capture existing role files before eval run so cleanup only removes eval-generated ones."""
        home = os.path.expanduser("~")
        lib_agents_dir = os.path.join(home, ".claude/@lib/agents")
        if os.path.isdir(lib_agents_dir):
            return set(os.listdir(lib_agents_dir))
        return set()

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

    @staticmethod
    def _find_claude_binary():
        """Resolve the claude CLI binary path. Checks PATH first, then common locations."""
        import shutil
        found = shutil.which("claude")
        if found:
            return found
        # Common install locations
        for candidate in [
            os.path.expanduser("~/.local/bin/claude"),
            "/usr/local/bin/claude",
        ]:
            if os.path.isfile(candidate) and os.access(candidate, os.X_OK):
                return candidate
        return "claude"  # fallback — will fail with clear error

    async def _call_engine(self, prompt, engine="claude"):
        """
        Executes the prompt against the specified AI engine.
        Currently supports: claude (CLI)
        """
        if engine == "claude":
            claude_bin = self._find_claude_binary()
            cmd = [claude_bin, "--dangerously-skip-permissions"]
            if self.model:
                cmd.extend(["--model", self.model])
            cmd.extend(["-p", prompt])
        else:
            return f"ERROR: Unsupported engine: {engine}"

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

    async def run_test(self, test_id, prompt, expect_trigger, engine="claude"):
        if not self.no_cache:
            # Cache key now includes engine to distinguish performance profiles
            cached = self.cache.get(prompt, self.description, expect_trigger, self.model)
            if cached:
                if self.verbose: print(f"  ⚡ Test {test_id}: CACHE HIT")
                return cached["result"]

        async with self.semaphore:
            for attempt in range(MAX_RETRIES):
                output = await self._call_engine(prompt, engine)

                # Rate limit detection (engine-specific strings)
                rate_limit_hits = ["rate_limit_error", "overloaded_error", "Overloaded.", "hit your limit", "resets 9pm"]
                if any(x in output for x in rate_limit_hits):
                    wait = (2 ** attempt) + random.uniform(0, 1)
                    if self.verbose: print(f"    (Test {test_id} {engine} rate-limited, retry {attempt+1}/{MAX_RETRIES} in {wait:.1f}s)", file=sys.stderr)
                    await asyncio.sleep(wait)
                    continue

                result = self._evaluate(output, expect_trigger)
                if not self.no_cache:
                    self.cache.set(prompt, self.description, expect_trigger, result, self.model)

                self._cleanup()
                if self.inter_test_delay > 0:
                    if self.verbose: print(f"    (inter-test delay {self.inter_test_delay}s)", file=sys.stderr)
                    await asyncio.sleep(self.inter_test_delay)
                return result

            return f"SKIP:rate-limit:{engine}"

    def _evaluate(self, output, expect_trigger):
        import re
        # Trigger detection: identify if meta-agent-factory was activated.
        # The factory may produce varied output formats depending on whether
        # it completes generation, is blocked on permissions, or describes
        # what it will create. Patterns cover all known output variants.
        #
        # IMPORTANT: Patterns must NOT false-positive on general help output.
        # Tests 41-44 discuss existing agents/skills — Claude may reference
        # file paths in those responses. Patterns here target factory-specific
        # CREATE/GENERATE language, not general file path mentions.
        trigger_patterns = [
            # Original patterns (factory completes generation)
            r"skill-quality-validator",
            r"Agent generation complete",
            r"Tools granted\**[:\s]",
            r"Tools denied\**[:\s]",
            r"write permission",
            # Factory creation output — describing what it WILL create
            r"(?:created?|generat|writ(?:e|ing|ten)|built)\s+(?:at|to|in)\s+[`'\"]?\.claude/skills/",
            r"(?:created?|generat|writ(?:e|ing|ten)|built)\s+(?:at|to|in)\s+[`'\"]?\.claude/agents/",
            # Factory architectural analysis (unique to factory output)
            r"Permission class\**[:\s]",
            r"permission matrix",
            # Factory pipeline stage headers
            r"Stage [1-5]:\s*\w",
        ]

        triggered = False
        for p in trigger_patterns:
            if re.search(p, output, re.IGNORECASE):
                triggered = True
                break
        
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

            # 2. Remove ONLY eval-generated Changeling roles (not pre-existing ones)
            home = os.path.expanduser("~")
            lib_agents_dir = os.path.join(home, ".claude/@lib/agents")
            if os.path.isdir(lib_agents_dir):
                for f in os.listdir(lib_agents_dir):
                    if f.endswith(".md") and f not in self._pre_run_roles:
                        if self.verbose: print(f"    (Cleaning up eval-generated role: {f})", file=sys.stderr)
                        try:
                            os.remove(os.path.join(lib_agents_dir, f))
                        except: pass
        except Exception as e:
            if self.verbose: print(f"Cleanup error: {e}", file=sys.stderr)

    async def run_all(self, prompts_dir=None, expected_dir=None, split_filter=None, engine="claude"):
        if not prompts_dir:
            prompts_dir = os.path.join(self.repo_root, "eval/prompts")
        if not expected_dir:
            expected_dir = os.path.join(self.repo_root, "eval/expected")
        
        test_files = sorted([f for f in os.listdir(prompts_dir) if f.startswith("test_")], 
                            key=lambda x: int(x.split('_')[1].split('.')[0]))
        
        # Apply split filter if requested
        if split_filter:
            allowed_ids = self.splits.get(split_filter, [])
            if not allowed_ids:
                print(f"Error: Split '{split_filter}' not found or empty in splits.json.")
                return 1
            test_files = [f for f in test_files if int(f.split('_')[1].split('.')[0]) in allowed_ids]

        if not test_files:
            print("Error: No test prompts found matching criteria.")
            return 1

        print(f"📊 Running Async Eval: {os.path.basename(self.skill_path)} (Engine: {engine}, Split: {split_filter or 'ALL'})")
        
        tasks = []
        test_ids = []
        for f in test_files:
            tid = int(f.split('_')[1].split('.')[0])
            with open(os.path.join(prompts_dir, f)) as pf: prompt = pf.read().strip()
            with open(os.path.join(expected_dir, f)) as ef: 
                exp = "yes" if "EXPECT_TRIGGER=yes" in ef.read() else "no"
            tasks.append(self.run_test(tid, prompt, exp, engine))
            test_ids.append(tid)

        results = await asyncio.gather(*tasks)
        
        # Split analysis (only if running all, otherwise just show current set)
        if not split_filter:
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
        else:
            stats = get_stats(results)
            print("\n" + "="*40)
            print(f"SPLIT ({split_filter.upper()}): {stats['posterior_mean']:.3f} CI [{stats['ci_lower']:.3f}, {stats['ci_upper']:.3f}]")
            print("="*40)
            full_stats = stats # for threshold check

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
    parser.add_argument("--engine", default="claude", help="AI engine to use (default: claude)")
    parser.add_argument("--split", choices=["train", "validation"], help="Run only a specific split")
    parser.add_argument("--prompts-dir", help="Custom prompts directory")
    parser.add_argument("--expected-dir", help="Custom expected directory")
    parser.add_argument("--inter-test-delay", type=float, default=0,
                        help="Seconds to wait between tests (default 0). Use 30-60 on free-tier to avoid quota burst.")
    parser.add_argument("--model", help="Override model ID for claude CLI (e.g. claude-opus-4-7 for shadow eval)")
    args = parser.parse_args()

    runner = AsyncEvalRunner(args.skill_path, args.verbose, args.no_cache, args.inter_test_delay, args.model)
    sys.exit(await runner.run_all(args.prompts_dir, args.expected_dir, args.split, args.engine))

if __name__ == "__main__":
    asyncio.run(main())
