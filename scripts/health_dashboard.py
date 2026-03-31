#!/usr/bin/env python3
"""Agent Legion Health Dashboard.

Reads deployment logs, experiment history, lifecycle events, and stress test
results to produce a text-based fleet health overview.

Usage:
    python3 scripts/health_dashboard.py
"""

import json
import os
import sys
from datetime import datetime, timezone

REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
EVAL_DIR = os.path.join(REPO_ROOT, "eval")


def load_json(path):
    if os.path.exists(path):
        with open(path) as f:
            return json.load(f)
    return None


def print_header(title):
    print(f"\n{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}")


def fleet_health(lifecycle_data):
    """Show per-skill current status and last trigger rate."""
    print_header("FLEET STATUS")

    if not lifecycle_data:
        print("  No lifecycle data found.")
        return

    print(f"  {'Skill':<30s} {'Stage':<15s} {'Trigger Rate':<15s} {'Last Event'}")
    print(f"  {'-'*30} {'-'*15} {'-'*15} {'-'*20}")

    for skill, info in sorted(lifecycle_data.items()):
        events = info.get("events", [])
        if not events:
            continue
        last = events[-1]
        stage = last.get("stage", "unknown")
        rate = last.get("trigger_rate", "—")
        if isinstance(rate, float):
            rate = f"{rate:.3f}"
        ts = last.get("timestamp", "—")
        if len(ts) > 19:
            ts = ts[:19]
        print(f"  {skill:<30s} {stage:<15s} {str(rate):<15s} {ts}")

    deployed = sum(1 for s in lifecycle_data.values()
                   if s.get("events") and s["events"][-1].get("stage") == "deployed")
    total = len(lifecycle_data)
    print(f"\n  Fleet: {deployed}/{total} deployed")


def deployment_history(deploy_log):
    """Show recent deployments."""
    print_header("RECENT DEPLOYMENTS")

    if not deploy_log:
        print("  No deployments recorded.")
        return

    recent = deploy_log[-10:]  # last 10
    print(f"  {'Skill':<30s} {'Timestamp':<22s} {'Git SHA':<10s} {'Status'}")
    print(f"  {'-'*30} {'-'*22} {'-'*10} {'-'*10}")
    for entry in recent:
        print(f"  {entry.get('skill','?'):<30s} {entry.get('timestamp','?'):<22s} "
              f"{entry.get('git_sha','?'):<10s} {entry.get('status','?')}")


def experiment_summary(exp_log):
    """Show optimization experiment trajectory."""
    print_header("OPTIMIZATION HISTORY")

    if not exp_log or not isinstance(exp_log, dict):
        print("  No experiment data found.")
        return

    entries = exp_log.get("iterations", exp_log.get("experiments", []))
    if isinstance(exp_log, list):
        entries = exp_log

    if not entries:
        print("  No iterations recorded.")
        return

    recent = entries[-5:]  # last 5
    print(f"  {'Iter':<6s} {'T-Post':<10s} {'V-Post':<10s} {'Outcome':<10s} {'Description'}")
    print(f"  {'-'*6} {'-'*10} {'-'*10} {'-'*10} {'-'*30}")
    for e in recent:
        t = e.get("train_posterior", "—")
        v = e.get("val_posterior", "—")
        if isinstance(t, float): t = f"{t:.3f}"
        if isinstance(v, float): v = f"{v:.3f}"
        it = str(e.get("iteration", "?"))
        outcome = e.get("outcome", "?")
        desc = e.get("change_description", "")[:40]
        print(f"  {it:<6s} {str(t):<10s} {str(v):<10s} {outcome:<10s} {desc}")


def stress_test_summary(stress_log):
    """Show stress test results."""
    print_header("STRESS TEST RESULTS")

    if not stress_log:
        print("  No stress test data found.")
        return

    total = len(stress_log)
    deployed = sum(1 for e in stress_log if "DEPLOYED" in e.get("status", ""))
    failed = sum(1 for e in stress_log if "FAILED" in e.get("status", ""))
    total_time = sum(e.get("duration_seconds", 0) for e in stress_log)
    avg_time = total_time / total if total > 0 else 0

    print(f"  Total skills:      {total}")
    print(f"  Deployed:          {deployed} ({deployed*100//total if total else 0}%)")
    print(f"  Failed:            {failed}")
    print(f"  Avg time/skill:    {avg_time:.0f}s ({avg_time/60:.1f}m)")
    print(f"  Total time:        {total_time/3600:.1f}h")

    if failed > 0:
        print(f"\n  Failed skills:")
        for e in stress_log:
            if "FAILED" in e.get("status", ""):
                print(f"    Line {e.get('line','?')}: {e.get('status','?')} — {e.get('requirement','?')[:50]}")


def main():
    print_header("AGENT LEGION HEALTH DASHBOARD")
    print(f"  Generated: {datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M:%S UTC')}")
    print(f"  Repo: {REPO_ROOT}")

    lifecycle = load_json(os.path.join(EVAL_DIR, "skill_lifecycle.json"))
    deploy_log = load_json(os.path.join(EVAL_DIR, "deploy_log.json"))
    exp_log = load_json(os.path.join(EVAL_DIR, "experiment_log.json"))
    stress_log = load_json(os.path.join(EVAL_DIR, "stress_test_log.json"))

    fleet_health(lifecycle)
    deployment_history(deploy_log)
    experiment_summary(exp_log)
    stress_test_summary(stress_log)

    print(f"\n{'='*60}")


if __name__ == "__main__":
    main()
