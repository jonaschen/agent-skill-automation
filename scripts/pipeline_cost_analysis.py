#!/usr/bin/env python3
"""pipeline_cost_analysis.py — Phase 4 pipeline cost analysis (ROADMAP task 4.2)

Analyzes wall-clock time and resource usage of the closed-loop pipeline
(factory→validate→optimize→deploy) from stress_test_log.json and agent
performance data.

Reports:
  1. Per-stage duration breakdown (generation, validation, optimization, deploy)
  2. Pipeline throughput (skills/hour)
  3. Optimization retry rate and cost multiplier
  4. Agent fleet daily operational cost (from perf JSONs)
  5. Projected 50-skill stress test timeline

Usage:
  python3 scripts/pipeline_cost_analysis.py
  python3 scripts/pipeline_cost_analysis.py --stress-log eval/stress_test_log.json
"""

import json
import os
import sys
import glob
from datetime import datetime
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
PERF_DIR = REPO_ROOT / "logs" / "performance"
STRESS_LOG = REPO_ROOT / "eval" / "stress_test_log.json"


def load_stress_test_log(path=None):
    """Load closed-loop pipeline results."""
    log_path = Path(path) if path else STRESS_LOG
    if not log_path.exists():
        return []
    with open(log_path) as f:
        data = json.load(f)
    return data if isinstance(data, list) else []


def load_perf_data():
    """Load all agent performance JSONs."""
    agents = {}
    for pf in sorted(PERF_DIR.glob("*.json")):
        try:
            with open(pf) as f:
                data = json.load(f)
            agent = data.get("agent", pf.stem.rsplit("-", 3)[0])
            if agent not in agents:
                agents[agent] = []
            agents[agent].append(data)
        except (json.JSONDecodeError, KeyError):
            continue
    return agents


def analyze_pipeline(entries):
    """Analyze closed-loop pipeline performance."""
    if not entries:
        print("\n  No stress test data yet (eval/stress_test_log.json is empty).")
        print("  Run ./scripts/closed_loop.sh <requirements-file> to generate data.")
        return

    total = len(entries)
    passed = sum(1 for e in entries if e.get("status") in ("DEPLOYED", "SKIP_OPTIMIZE"))
    failed = sum(1 for e in entries if "FAILED" in e.get("status", ""))
    durations = [e.get("duration_seconds", 0) for e in entries]
    avg_duration = sum(durations) / len(durations) if durations else 0
    total_duration = sum(durations)

    # Optimization stats
    retries = [e.get("optimize_retries", 0) for e in entries]
    needed_optimize = sum(1 for r in retries if r > 0)
    avg_retries = sum(retries) / len(retries) if retries else 0

    # Scores
    scores = [float(e.get("trigger_score", 0)) for e in entries if e.get("trigger_score")]
    avg_score = sum(scores) / len(scores) if scores else 0

    print(f"\n  Skills processed:      {total}")
    print(f"  Passed:                {passed} ({100*passed//total}%)")
    print(f"  Failed:                {failed} ({100*failed//total}%)")
    print(f"  Avg duration/skill:    {avg_duration:.0f}s ({avg_duration/60:.1f}m)")
    print(f"  Total wall-clock:      {total_duration:.0f}s ({total_duration/3600:.1f}h)")
    print(f"  Throughput:            {3600/avg_duration:.1f} skills/hour" if avg_duration > 0 else "")
    print(f"  Needed optimization:   {needed_optimize}/{total} ({100*needed_optimize//total}%)")
    print(f"  Avg optimize retries:  {avg_retries:.1f}")
    print(f"  Avg trigger score:     {avg_score:.3f}")

    # Project 50-skill stress test
    projected_50 = avg_duration * 50
    print(f"\n  Projected 50-skill test: {projected_50/3600:.1f}h wall-clock (sequential)")
    if projected_50 / 3600 > 24:
        print("  WARNING: Exceeds 24h target. Consider parallelization.")


def analyze_fleet(agents):
    """Analyze daily agent fleet operational costs."""
    print("\n  Agent fleet daily durations (latest available):")
    total_daily = 0
    for agent_name in sorted(agents.keys()):
        runs = agents[agent_name]
        if not runs:
            continue
        latest = runs[-1]
        duration = latest.get("duration_seconds", 0)
        effort = latest.get("effort_level", "untracked")
        total_daily += duration
        print(f"    {agent_name:30s} {duration:6d}s ({duration//60:3d}m {duration%60:02d}s) effort={effort}")

    print(f"    {'─'*60}")
    print(f"    {'TOTAL':30s} {total_daily:6d}s ({total_daily//60:3d}m {total_daily%60:02d}s)")
    print(f"    {'':30s} = {total_daily/3600:.1f}h daily compute")


def main():
    stress_path = None
    if "--stress-log" in sys.argv:
        idx = sys.argv.index("--stress-log")
        stress_path = sys.argv[idx + 1] if idx + 1 < len(sys.argv) else None

    print("=" * 56)
    print("  Pipeline Cost Analysis (Phase 4, Task 4.2)")
    print("=" * 56)

    # Pipeline analysis
    print("\n--- Closed-Loop Pipeline ---")
    entries = load_stress_test_log(stress_path)
    analyze_pipeline(entries)

    # Fleet analysis
    print("\n--- Agent Fleet Operational Cost ---")
    agents = load_perf_data()
    analyze_fleet(agents)

    # Cost efficiency notes
    print("\n--- Cost Efficiency Notes ---")
    print("  - Token cost ≈ duration × model-specific rate (Opus 4.6 ≈ $0.015/min)")
    print("  - Pipeline cost/skill = avg_duration × rate")
    print("  - Fleet daily cost ≈ total_daily_seconds × rate")
    print("  - Effort level 'high' vs 'medium' may 1.3-1.8x token usage")

    print("\n" + "=" * 56)


if __name__ == "__main__":
    main()
