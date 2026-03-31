#!/usr/bin/env python3
"""Anomaly alerter for the Agent Legion.

Monitors lifecycle events and deployment logs for:
- Trigger rate regressions (>10% drop vs deployment baseline)
- Pipeline stalls (skills stuck in non-terminal state >24h)
- Cost anomalies (duration >2x fleet average)

Usage:
    python3 scripts/anomaly_alerter.py [--output eval/anomaly_log.json]
"""

import argparse
import json
import os
import sys
from datetime import datetime, timezone, timedelta

REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
EVAL_DIR = os.path.join(REPO_ROOT, "eval")


def load_json(path):
    if os.path.exists(path):
        with open(path) as f:
            return json.load(f)
    return None


def check_trigger_regressions(lifecycle_data):
    """Detect skills where trigger rate dropped >10% from deployment baseline."""
    anomalies = []
    if not lifecycle_data:
        return anomalies

    for skill, info in lifecycle_data.items():
        events = info.get("events", [])
        deploy_rate = None
        latest_rate = None

        for e in events:
            if e.get("stage") == "deployed" and e.get("trigger_rate") is not None:
                deploy_rate = e["trigger_rate"]
            if e.get("trigger_rate") is not None:
                latest_rate = e["trigger_rate"]

        if deploy_rate is not None and latest_rate is not None:
            if deploy_rate > 0 and (deploy_rate - latest_rate) / deploy_rate > 0.10:
                anomalies.append({
                    "type": "trigger_regression",
                    "skill": skill,
                    "deploy_rate": deploy_rate,
                    "current_rate": latest_rate,
                    "drop_pct": round((deploy_rate - latest_rate) / deploy_rate * 100, 1),
                    "severity": "CRITICAL"
                })

    return anomalies


def check_pipeline_stalls(lifecycle_data):
    """Detect skills stuck in non-terminal state for >24 hours."""
    anomalies = []
    if not lifecycle_data:
        return anomalies

    now = datetime.now(timezone.utc)
    terminal_stages = {"deployed", "deprecated", "failed"}

    for skill, info in lifecycle_data.items():
        events = info.get("events", [])
        if not events:
            continue
        last = events[-1]
        if last.get("stage") in terminal_stages:
            continue

        try:
            ts = datetime.fromisoformat(last["timestamp"])
            if ts.tzinfo is None:
                ts = ts.replace(tzinfo=timezone.utc)
            age = now - ts
            if age > timedelta(hours=24):
                anomalies.append({
                    "type": "pipeline_stall",
                    "skill": skill,
                    "stage": last["stage"],
                    "stuck_hours": round(age.total_seconds() / 3600, 1),
                    "severity": "WARNING"
                })
        except (KeyError, ValueError):
            pass

    return anomalies


def check_cost_anomalies(stress_log):
    """Detect skills with duration >2x the fleet average."""
    anomalies = []
    if not stress_log or len(stress_log) < 3:
        return anomalies

    durations = [e.get("duration_seconds", 0) for e in stress_log if e.get("duration_seconds", 0) > 0]
    if not durations:
        return anomalies

    avg = sum(durations) / len(durations)

    for e in stress_log:
        d = e.get("duration_seconds", 0)
        if d > 2 * avg and d > 60:  # only flag if >1min
            anomalies.append({
                "type": "cost_anomaly",
                "skill": e.get("skill_name", "unknown"),
                "duration_seconds": d,
                "fleet_avg_seconds": round(avg, 0),
                "ratio": round(d / avg, 1),
                "severity": "WARNING"
            })

    return anomalies


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", default=os.path.join(EVAL_DIR, "anomaly_log.json"),
                        help="Output path for anomaly log")
    args = parser.parse_args()

    lifecycle = load_json(os.path.join(EVAL_DIR, "skill_lifecycle.json"))
    stress_log = load_json(os.path.join(EVAL_DIR, "stress_test_log.json"))

    all_anomalies = []
    all_anomalies.extend(check_trigger_regressions(lifecycle))
    all_anomalies.extend(check_pipeline_stalls(lifecycle))
    all_anomalies.extend(check_cost_anomalies(stress_log))

    # Add timestamp to each anomaly
    now = datetime.now(timezone.utc).isoformat()
    for a in all_anomalies:
        a["detected_at"] = now

    # Print to stderr
    if all_anomalies:
        print(f"ANOMALIES DETECTED: {len(all_anomalies)}", file=sys.stderr)
        for a in all_anomalies:
            print(f"  [{a['severity']}] {a['type']}: {a.get('skill', '?')} — "
                  f"{json.dumps({k:v for k,v in a.items() if k not in ('type','severity','skill','detected_at')})}",
                  file=sys.stderr)
    else:
        print("No anomalies detected.", file=sys.stderr)

    # Append to log file
    existing = load_json(args.output) or []
    existing.extend(all_anomalies)
    with open(args.output, "w") as f:
        json.dump(existing, f, indent=2)

    # Exit 1 if critical anomalies found
    if any(a["severity"] == "CRITICAL" for a in all_anomalies):
        sys.exit(1)


if __name__ == "__main__":
    main()
