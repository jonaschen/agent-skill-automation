#!/usr/bin/env python3
"""Validate experiment_log.json schema and data integrity.

Checks:
  1. Valid JSON parse
  2. Top-level structure has 'experiments' list
  3. Each entry has required fields (timestamp, posterior_mean, ci_lower, ci_upper, outcome)
  4. Timestamps are ISO 8601 format
  5. Numerical fields are within valid ranges
  6. No duplicate (branch, timestamp) pairs

Exit code 0 = valid, 1 = invalid (structured error on stderr).
"""

import json
import sys
from datetime import datetime
from pathlib import Path

REQUIRED_FIELDS = {"timestamp", "posterior_mean", "ci_lower", "ci_upper", "outcome"}
NUMERIC_FIELDS = {"posterior_mean": (0.0, 1.0), "ci_lower": (0.0, 1.0), "ci_upper": (0.0, 1.0)}


def validate(path: str) -> list[str]:
    errors = []
    p = Path(path)
    if not p.exists():
        return [f"File not found: {path}"]

    try:
        data = json.loads(p.read_text())
    except json.JSONDecodeError as e:
        return [f"Invalid JSON: {e}"]

    if not isinstance(data, dict):
        return ["Top-level must be a JSON object"]

    experiments = data.get("experiments")
    if not isinstance(experiments, list):
        return ["Missing or invalid 'experiments' array"]

    seen = set()
    for i, entry in enumerate(experiments):
        if not isinstance(entry, dict):
            errors.append(f"Entry {i}: not a JSON object")
            continue

        missing = REQUIRED_FIELDS - set(entry.keys())
        if missing:
            errors.append(f"Entry {i}: missing fields: {', '.join(sorted(missing))}")

        for field, (lo, hi) in NUMERIC_FIELDS.items():
            val = entry.get(field)
            if val is not None and isinstance(val, (int, float)):
                if not (lo <= val <= hi):
                    errors.append(f"Entry {i}: {field}={val} outside [{lo}, {hi}]")

        ts = entry.get("timestamp", "")
        if ts:
            try:
                datetime.fromisoformat(ts.replace("Z", "+00:00"))
            except ValueError:
                errors.append(f"Entry {i}: invalid timestamp '{ts}'")

        key = (entry.get("branch", ""), entry.get("timestamp", ""))
        if key in seen:
            errors.append(f"Entry {i}: duplicate (branch={key[0]}, timestamp={key[1]})")
        seen.add(key)

    return errors


if __name__ == "__main__":
    path = sys.argv[1] if len(sys.argv) > 1 else "eval/experiment_log.json"
    errors = validate(path)
    if errors:
        for e in errors:
            print(f"ERROR: {e}", file=sys.stderr)
        sys.exit(1)
    print("experiment_log.json: VALID")
    sys.exit(0)
