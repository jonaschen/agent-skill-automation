#!/usr/bin/env python3
"""Promote real-world skill usage cases to the eval test set.

Reads skill_usage_log.jsonl from a target project, shows each case,
and lets the user decide whether to add it as a positive or negative
eval test case for a specific skill.

Usage:
    python3 scripts/promote_cases.py <log-file> [--skill meta-agent-factory]
    python3 scripts/promote_cases.py <log-file> --auto-review
    python3 scripts/promote_cases.py <log-file> --stats
"""

import argparse
import json
import os
import sys

REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
PROMPTS_DIR = os.path.join(REPO_ROOT, "eval", "prompts")
EXPECTED_DIR = os.path.join(REPO_ROOT, "eval", "expected")
SPLITS_PATH = os.path.join(REPO_ROOT, "eval", "splits.json")


def load_log(path):
    """Load JSONL log file."""
    entries = []
    with open(path) as f:
        for line in f:
            line = line.strip()
            if line:
                try:
                    entries.append(json.loads(line))
                except json.JSONDecodeError:
                    continue
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


def main():
    parser = argparse.ArgumentParser(description="Promote real-world skill usage to eval test set")
    parser.add_argument("log_file", help="Path to skill_usage_log.jsonl")
    parser.add_argument("--skill", help="Filter to specific skill name (e.g., meta-agent-factory)")
    parser.add_argument("--stats", action="store_true", help="Show usage stats only")
    args = parser.parse_args()

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
