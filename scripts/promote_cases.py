#!/usr/bin/env python3
"""Promote real-world skill usage cases to the eval test set.

Reads skill_usage_log.jsonl from a target project, shows each case,
and lets the user decide whether to add it as a positive or negative
eval test case for a specific skill.

Usage:
    python3 scripts/promote_cases.py <log-file> [--skill meta-agent-factory]
    python3 scripts/promote_cases.py <log-file> --stats
    python3 scripts/promote_cases.py --audit              # Auto-discover logs, report readiness
    python3 scripts/promote_cases.py --audit --verbose     # Show individual log entries
"""

import argparse
import glob
import json
import os
import sys
from collections import Counter
from pathlib import Path

REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))

# Known instrumented project directories (skill_logger_hook.sh installed)
INSTRUMENTED_PROJECTS = [
    os.path.expanduser("~/gemini-home/long-term-care-expert"),
    os.path.expanduser("~/gemini-home/The-King-s-Hand"),
]
PROMPTS_DIR = os.path.join(REPO_ROOT, "eval", "prompts")
EXPECTED_DIR = os.path.join(REPO_ROOT, "eval", "expected")
SPLITS_PATH = os.path.join(REPO_ROOT, "eval", "splits.json")


def load_log(path):
    """Load log file — supports both JSONL (one object per line) and
    concatenated pretty-printed JSON objects."""
    entries = []
    with open(path) as f:
        content = f.read()

    # Try JSONL first (one JSON object per line)
    lines = content.strip().splitlines()
    if lines and lines[0].strip().startswith("{") and lines[0].strip().endswith("}"):
        for line in lines:
            line = line.strip()
            if line:
                try:
                    entries.append(json.loads(line))
                except json.JSONDecodeError:
                    continue
        if entries:
            return entries

    # Fall back to concatenated pretty-printed JSON objects
    # Use JSONDecoder to parse successive objects from the string
    decoder = json.JSONDecoder()
    idx = 0
    while idx < len(content):
        # Skip whitespace
        while idx < len(content) and content[idx] in " \t\n\r":
            idx += 1
        if idx >= len(content):
            break
        try:
            obj, end_idx = decoder.raw_decode(content, idx)
            entries.append(obj)
            idx = end_idx
        except json.JSONDecodeError:
            idx += 1

    return entries


def get_next_test_id():
    """Find the next available test ID."""
    existing = set()
    for f in os.listdir(PROMPTS_DIR):
        if f.startswith("test_") and f.endswith(".txt"):
            try:
                tid = int(f.split("_")[1].split(".")[0])
                existing.add(tid)
            except ValueError:
                pass
    return max(existing) + 1 if existing else 1


def add_test_case(prompt, expect_trigger, skill_name, test_id=None):
    """Write a new test case to eval/prompts/ and eval/expected/."""
    if test_id is None:
        test_id = get_next_test_id()

    prompt_path = os.path.join(PROMPTS_DIR, f"test_{test_id}.txt")
    expected_path = os.path.join(EXPECTED_DIR, f"test_{test_id}.txt")

    with open(prompt_path, "w") as f:
        f.write(prompt.strip() + "\n")

    if expect_trigger:
        with open(expected_path, "w") as f:
            f.write(f"EXPECT_TRIGGER=yes\nEXPECT_TYPE=Sub-agent\nEXPECT_CONTAINS=Tools granted:\n")
    else:
        with open(expected_path, "w") as f:
            f.write(f"EXPECT_TRIGGER=no\n")

    # Add to training split
    with open(SPLITS_PATH) as f:
        splits = json.load(f)
    if test_id not in splits["train"]:
        splits["train"].append(test_id)
        splits["train"].sort()
    with open(SPLITS_PATH, "w") as f:
        json.dump(splits, f, indent=2)

    return test_id


def show_stats(entries):
    """Show summary statistics of logged usage."""
    skills = {}
    for e in entries:
        skill = e.get("skill_triggered", "unknown")
        skills[skill] = skills.get(skill, 0) + 1

    print(f"\n{'='*50}")
    print(f"  SKILL USAGE LOG STATS ({len(entries)} entries)")
    print(f"{'='*50}")
    print(f"\n  {'Skill':<30s} {'Count':<10s}")
    print(f"  {'-'*30} {'-'*10}")
    for skill, count in sorted(skills.items(), key=lambda x: -x[1]):
        print(f"  {skill:<30s} {count}")

    # Show unique prompts
    unique_prompts = set(e.get("prompt", "") for e in entries if e.get("prompt"))
    print(f"\n  Unique prompts: {len(unique_prompts)}")
    print(f"  Total entries:  {len(entries)}")


def interactive_review(entries, target_skill=None):
    """Interactive review of logged cases."""
    # Deduplicate by prompt
    seen = set()
    unique = []
    for e in entries:
        prompt = e.get("prompt", "").strip()
        if not prompt or prompt in seen:
            continue
        seen.add(prompt)
        unique.append(e)

    if target_skill:
        # Show cases where target_skill triggered (or should have)
        relevant = [e for e in unique if e.get("skill_triggered") == target_skill]
        other = [e for e in unique if e.get("skill_triggered") != target_skill]
    else:
        relevant = unique
        other = []

    print(f"\nReviewing {len(relevant)} cases" +
          (f" for skill '{target_skill}'" if target_skill else "") +
          f" ({len(other)} other cases available)")

    promoted = 0

    for i, entry in enumerate(relevant):
        prompt = entry.get("prompt", "").strip()
        skill = entry.get("skill_triggered", "unknown")
        ts = entry.get("timestamp", "?")

        print(f"\n--- Case {i+1}/{len(relevant)} ---")
        print(f"  Prompt:    {prompt[:120]}")
        print(f"  Triggered: {skill}")
        print(f"  Time:      {ts}")

        while True:
            choice = input("  Action: [p]ositive, [n]egative, [s]kip, [q]uit? ").strip().lower()
            if choice in ("p", "n", "s", "q"):
                break
            print("  Invalid choice. Use p/n/s/q.")

        if choice == "q":
            break
        elif choice == "s":
            continue
        elif choice == "p":
            tid = add_test_case(prompt, expect_trigger=True, skill_name=target_skill or skill)
            print(f"  Added as test_{tid}.txt (EXPECT_TRIGGER=yes, added to training set)")
            promoted += 1
        elif choice == "n":
            tid = add_test_case(prompt, expect_trigger=False, skill_name=target_skill or skill)
            print(f"  Added as test_{tid}.txt (EXPECT_TRIGGER=no, added to training set)")
            promoted += 1

    # Offer to review "other" cases (where the skill DIDN'T trigger)
    if other and target_skill:
        print(f"\n--- {len(other)} cases where '{target_skill}' was NOT triggered ---")
        review_other = input("  Review these as potential false negatives? [y/n] ").strip().lower()
        if review_other == "y":
            for i, entry in enumerate(other):
                prompt = entry.get("prompt", "").strip()
                skill = entry.get("skill_triggered", "unknown")

                print(f"\n--- Other {i+1}/{len(other)} ---")
                print(f"  Prompt:    {prompt[:120]}")
                print(f"  Triggered: {skill} (NOT {target_skill})")

                while True:
                    choice = input(f"  Should '{target_skill}' have triggered? [y]es=positive, [n]o=negative, [s]kip, [q]uit? ").strip().lower()
                    if choice in ("y", "n", "s", "q"):
                        break

                if choice == "q":
                    break
                elif choice == "s":
                    continue
                elif choice == "y":
                    tid = add_test_case(prompt, expect_trigger=True, skill_name=target_skill)
                    print(f"  Added as test_{tid}.txt (EXPECT_TRIGGER=yes — false negative caught!)")
                    promoted += 1
                elif choice == "n":
                    tid = add_test_case(prompt, expect_trigger=False, skill_name=target_skill)
                    print(f"  Added as test_{tid}.txt (EXPECT_TRIGGER=no — correct non-trigger)")
                    promoted += 1

    print(f"\n{'='*50}")
    print(f"  Promoted {promoted} cases to eval set")
    print(f"{'='*50}")

    if promoted > 0:
        print(f"\n  Next steps:")
        print(f"  1. Run eval: python3 eval/run_eval_async.py .claude/agents/{target_skill or 'SKILL'}.md --verbose --no-cache")
        print(f"  2. If score drops, run optimizer to adapt the description")
        print(f"  3. Updated eval/splits.json — new cases added to training set")


def discover_log_files():
    """Auto-discover skill_usage_log.jsonl files from instrumented projects."""
    found = []
    for project_dir in INSTRUMENTED_PROJECTS:
        log_path = os.path.join(project_dir, ".claude", "skill_usage_log.jsonl")
        project_name = os.path.basename(project_dir)
        if os.path.exists(log_path):
            size = os.path.getsize(log_path)
            entries = load_log(log_path)
            found.append({
                "project": project_name,
                "path": log_path,
                "size_bytes": size,
                "entry_count": len(entries),
                "entries": entries,
            })
        else:
            found.append({
                "project": project_name,
                "path": log_path,
                "size_bytes": 0,
                "entry_count": 0,
                "entries": [],
            })
    return found


def get_existing_prompts():
    """Load all existing eval prompts to detect duplicates."""
    existing = set()
    for f in os.listdir(PROMPTS_DIR):
        if f.startswith("test_") and f.endswith(".txt"):
            path = os.path.join(PROMPTS_DIR, f)
            with open(path) as fh:
                existing.add(fh.read().strip().lower())
    return existing


def audit_logs(verbose=False):
    """Auto-discover logs, report volume, and identify promotion candidates.

    Returns exit code:
        0 — sufficient data, promotion candidates identified
        1 — insufficient data (below threshold)
        2 — no log files found
    """
    PROMOTION_THRESHOLD = 50  # minimum invocations to proceed with promotion
    MIN_USEFUL = 20  # minimum to report anything useful

    print(f"\n{'='*60}")
    print(f"  EVAL SUITE EXPANSION AUDIT")
    print(f"  Auto-discovering skill usage logs from instrumented projects")
    print(f"{'='*60}\n")

    log_files = discover_log_files()
    all_entries = []
    has_any_log = False

    for lf in log_files:
        status = "FOUND" if lf["entry_count"] > 0 else ("EMPTY" if os.path.exists(lf["path"]) else "MISSING")
        icon = "✅" if lf["entry_count"] > 0 else ("⚠️" if status == "EMPTY" else "❌")
        print(f"  {icon} {lf['project']}: {lf['entry_count']} entries ({status})")
        if lf["entry_count"] > 0:
            has_any_log = True
            all_entries.extend(lf["entries"])

    total = len(all_entries)
    print(f"\n  Total entries across all projects: {total}")
    print(f"  Promotion threshold: {PROMOTION_THRESHOLD}")
    print(f"  Current eval suite: {len(os.listdir(PROMPTS_DIR))} test cases")

    if not has_any_log:
        print(f"\n  STATUS: NO LOGS FOUND")
        print(f"  The skill logger hook is installed but no invocations have been logged yet.")
        print(f"  Ensure skill_logger_hook.sh is active in project settings.json hooks.")
        print(f"\n  Instrumented projects:")
        for p in INSTRUMENTED_PROJECTS:
            exists = os.path.isdir(p)
            print(f"    {'✅' if exists else '❌'} {p}")
        return 2

    if total < MIN_USEFUL:
        print(f"\n  STATUS: INSUFFICIENT DATA ({total} < {MIN_USEFUL} minimum)")
        print(f"  Deferring eval expansion until more usage data accumulates.")
        return 1

    # Analyze entries for promotion candidates
    existing_prompts = get_existing_prompts()

    skills_triggered = Counter()
    unique_prompts = {}
    duplicates = 0
    novel = 0

    for entry in all_entries:
        prompt = entry.get("prompt", "").strip()
        skill = entry.get("skill_triggered", "unknown")
        if not prompt:
            continue
        skills_triggered[skill] += 1
        normalized = prompt.lower().strip()
        if normalized in existing_prompts:
            duplicates += 1
        elif normalized not in unique_prompts:
            unique_prompts[normalized] = {
                "prompt": prompt,
                "skill": skill,
                "timestamp": entry.get("timestamp", "?"),
            }
            novel += 1

    print(f"\n  --- Skill Distribution ---")
    for skill, count in skills_triggered.most_common():
        print(f"    {skill}: {count}")

    print(f"\n  --- Promotion Analysis ---")
    print(f"    Already in eval suite:  {duplicates}")
    print(f"    Novel (promotable):     {novel}")
    print(f"    Total unique prompts:   {len(unique_prompts)}")

    if verbose and unique_prompts:
        print(f"\n  --- Novel Prompts (top 10) ---")
        for i, (_, info) in enumerate(list(unique_prompts.items())[:10]):
            print(f"    {i+1}. [{info['skill']}] {info['prompt'][:100]}")

    if total >= PROMOTION_THRESHOLD and novel >= 5:
        print(f"\n  STATUS: READY FOR PROMOTION")
        print(f"  {novel} novel cases available. Run with a log file for interactive review:")
        for lf in log_files:
            if lf["entry_count"] > 0:
                print(f"    python3 scripts/promote_cases.py {lf['path']} --skill meta-agent-factory")
        return 0
    elif total >= MIN_USEFUL:
        print(f"\n  STATUS: APPROACHING THRESHOLD ({total}/{PROMOTION_THRESHOLD})")
        print(f"  {novel} novel cases found but total volume below promotion threshold.")
        print(f"  Continue accumulating usage data.")
        return 1
    else:
        print(f"\n  STATUS: INSUFFICIENT DATA ({total} < {MIN_USEFUL})")
        return 1


def main():
    parser = argparse.ArgumentParser(description="Promote real-world skill usage to eval test set")
    parser.add_argument("log_file", nargs="?", help="Path to skill_usage_log.jsonl (optional with --audit)")
    parser.add_argument("--skill", help="Filter to specific skill name (e.g., meta-agent-factory)")
    parser.add_argument("--stats", action="store_true", help="Show usage stats only")
    parser.add_argument("--audit", action="store_true", help="Auto-discover logs, report volume and readiness")
    parser.add_argument("--verbose", action="store_true", help="Show individual entries in audit mode")
    args = parser.parse_args()

    if args.audit:
        sys.exit(audit_logs(verbose=args.verbose))

    if not args.log_file:
        parser.error("log_file is required unless using --audit mode")

    if not os.path.exists(args.log_file):
        print(f"Error: Log file not found: {args.log_file}", file=sys.stderr)
        sys.exit(1)

    entries = load_log(args.log_file)
    if not entries:
        print("No entries found in log file.", file=sys.stderr)
        sys.exit(1)

    if args.stats:
        show_stats(entries)
    else:
        interactive_review(entries, args.skill)


if __name__ == "__main__":
    main()
