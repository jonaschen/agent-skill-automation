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


def run_tests() -> bool:
    """Inline tests for the validator. Returns True if all pass."""
    import tempfile
    import os

    passed = 0
    failed = 0

    # Test 1: Missing required field (model is optional, but outcome is required)
    with tempfile.NamedTemporaryFile(mode="w", suffix=".json", delete=False) as f:
        json.dump({"experiments": [{"timestamp": "2026-04-21T00:00:00Z",
                                     "posterior_mean": 0.9, "ci_lower": 0.8,
                                     "ci_upper": 0.95}]}, f)
        f.flush()
        errs = validate(f.name)
        os.unlink(f.name)
    if errs and any("missing fields" in e and "outcome" in e for e in errs):
        print("  PASS: Test 1 — missing required field detected")
        passed += 1
    else:
        print(f"  FAIL: Test 1 — expected missing field error, got: {errs}")
        failed += 1

    # Test 2: Duplicate (branch, timestamp) pair
    with tempfile.NamedTemporaryFile(mode="w", suffix=".json", delete=False) as f:
        entry = {"timestamp": "2026-04-21T00:00:00Z", "branch": "dup-test",
                 "posterior_mean": 0.9, "ci_lower": 0.8, "ci_upper": 0.95,
                 "outcome": "commit"}
        json.dump({"experiments": [entry, entry]}, f)
        f.flush()
        errs = validate(f.name)
        os.unlink(f.name)
    if errs and any("duplicate" in e for e in errs):
        print("  PASS: Test 2 — duplicate entry detected")
        passed += 1
    else:
        print(f"  FAIL: Test 2 — expected duplicate error, got: {errs}")
        failed += 1

    # Test 3: Valid entry passes
    with tempfile.NamedTemporaryFile(mode="w", suffix=".json", delete=False) as f:
        json.dump({"experiments": [{"timestamp": "2026-04-21T00:00:00Z",
                                     "branch": "valid-test",
                                     "posterior_mean": 0.9, "ci_lower": 0.8,
                                     "ci_upper": 0.95, "outcome": "commit"}]}, f)
        f.flush()
        errs = validate(f.name)
        os.unlink(f.name)
    if not errs:
        print("  PASS: Test 3 — valid entry accepted")
        passed += 1
    else:
        print(f"  FAIL: Test 3 — expected no errors, got: {errs}")
        failed += 1

    print(f"\nResults: {passed}/{passed + failed} passed")
    return failed == 0


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--test":
        print("Running inline tests...")
        success = run_tests()
        sys.exit(0 if success else 1)

    path = sys.argv[1] if len(sys.argv) > 1 else "eval/experiment_log.json"
    errors = validate(path)
    if errors:
        for e in errors:
            print(f"ERROR: {e}", file=sys.stderr)
        sys.exit(1)
    print("experiment_log.json: VALID")
    sys.exit(0)
