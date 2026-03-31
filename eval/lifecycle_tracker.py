#!/usr/bin/env python3
"""Skill lifecycle event tracker.

Logs lifecycle events (created, validated, optimized, deployed, deprecated)
to eval/skill_lifecycle.json for observability and audit.

Usage:
    python3 eval/lifecycle_tracker.py --skill <name> --stage <stage> [--note <note>] [--source <source>]
"""

import argparse
import json
import os
from datetime import datetime, timezone

LIFECYCLE_PATH = os.path.join(os.path.dirname(__file__), "skill_lifecycle.json")

VALID_STAGES = ["created", "validated", "optimizing", "optimized", "deployed", "deprecated", "failed"]


def load_lifecycle():
    if os.path.exists(LIFECYCLE_PATH):
        with open(LIFECYCLE_PATH) as f:
            return json.load(f)
    return {}


def save_lifecycle(data):
    with open(LIFECYCLE_PATH, "w") as f:
        json.dump(data, f, indent=2)


def log_event(skill_name, stage, source=None, note=None, trigger_rate=None, git_sha=None):
    if stage not in VALID_STAGES:
        raise ValueError(f"Invalid stage '{stage}'. Must be one of: {VALID_STAGES}")

    data = load_lifecycle()

    if skill_name not in data:
        data[skill_name] = {"events": []}

    event = {
        "stage": stage,
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }
    if source:
        event["source"] = source
    if note:
        event["note"] = note
    if trigger_rate is not None:
        event["trigger_rate"] = trigger_rate
    if git_sha:
        event["git_sha"] = git_sha

    data[skill_name]["events"].append(event)
    save_lifecycle(data)
    return event


def get_skill_history(skill_name):
    data = load_lifecycle()
    return data.get(skill_name, {}).get("events", [])


def get_all_skills():
    data = load_lifecycle()
    return list(data.keys())


def main():
    parser = argparse.ArgumentParser(description="Track skill lifecycle events")
    parser.add_argument("--skill", required=True, help="Skill name")
    parser.add_argument("--stage", choices=VALID_STAGES, help="Lifecycle stage")
    parser.add_argument("--source", help="Source agent (e.g., meta-agent-factory)")
    parser.add_argument("--note", help="Additional context")
    parser.add_argument("--trigger-rate", type=float, help="Trigger rate at this stage")
    parser.add_argument("--git-sha", help="Git SHA at this stage")
    parser.add_argument("--history", action="store_true", help="Show history for skill instead of logging")
    args = parser.parse_args()

    if args.history or not args.stage:
        events = get_skill_history(args.skill)
        if not events:
            print(f"No history for '{args.skill}'")
        else:
            for e in events:
                print(f"  {e['timestamp']} | {e['stage']:12s} | {e.get('source', '-'):20s} | {e.get('note', '')}")
    else:
        event = log_event(args.skill, args.stage, args.source, args.note, args.trigger_rate, args.git_sha)
        print(f"Logged: {args.skill} → {event['stage']} at {event['timestamp']}")


if __name__ == "__main__":
    main()
