#!/usr/bin/env python3
"""Bayesian flaky test detector for Agent Skill evaluation.

Tracks historical pass/fail results for each test case and identifies tests
with unstable outcomes caused by LLM non-determinism or environmental factors.

Usage:
    flaky_detector.py record <skill-name> <test-id> <pass|fail>
    flaky_detector.py check  <skill-name> [--threshold 0.3]
    flaky_detector.py report <skill-name>
    flaky_detector.py quarantine <skill-name> <test-id>
    flaky_detector.py unquarantine <skill-name> <test-id>

Data is stored in eval/flaky_history.json.
"""

import json
import os
import sys
from datetime import datetime, timezone

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
HISTORY_FILE = os.path.join(SCRIPT_DIR, "flaky_history.json")
MIN_HISTORY = 5  # Minimum runs before making a flaky determination


def load_history():
    """Load the flaky test history from disk."""
    if os.path.exists(HISTORY_FILE):
        with open(HISTORY_FILE, "r") as f:
            return json.load(f)
    return {"skills": {}}


def save_history(data):
    """Save the flaky test history to disk."""
    with open(HISTORY_FILE, "w") as f:
        json.dump(data, f, indent=2)


def record_result(skill_name, test_id, passed):
    """Record a test result for flaky analysis.

    Args:
        skill_name: Name of the skill being tested.
        test_id: Identifier for the test case (e.g., "test_1").
        passed: Boolean indicating whether the test passed.
    """
    data = load_history()

    if skill_name not in data["skills"]:
        data["skills"][skill_name] = {"tests": {}, "quarantined": []}

    skill_data = data["skills"][skill_name]
    if test_id not in skill_data["tests"]:
        skill_data["tests"][test_id] = {"results": [], "first_seen": None}

    test_data = skill_data["tests"][test_id]
    if test_data["first_seen"] is None:
        test_data["first_seen"] = datetime.now(timezone.utc).isoformat()

    test_data["results"].append({
        "passed": passed,
        "timestamp": datetime.now(timezone.utc).isoformat()
    })

    save_history(data)
    print(f"Recorded: {skill_name}/{test_id} = {'PASS' if passed else 'FAIL'}")


def is_flaky(results, threshold=0.3):
    """Determine if a test is flaky based on its result history.

    A test is flaky if its historical failure rate is between `threshold`
    and `1 - threshold`. This means:
    - > 90% failure rate is a real bug (not flaky)
    - < 10% failure rate is acceptable noise (not flaky)
    - Between 10% and 90% is unstable (flaky)

    Args:
        results: List of result dicts with 'passed' boolean.
        threshold: Lower bound for flaky classification (default 0.3 = 30%).

    Returns:
        Tuple of (is_flaky: bool, failure_rate: float, sample_size: int).
    """
    if len(results) < MIN_HISTORY:
        return False, 0.0, len(results)

    passes = sum(1 for r in results if r["passed"])
    failure_rate = 1 - (passes / len(results))

    return threshold <= failure_rate <= (1 - threshold), failure_rate, len(results)


def check_skill(skill_name, threshold=0.3):
    """Check all tests for a skill and identify flaky ones.

    Args:
        skill_name: Name of the skill to check.
        threshold: Flaky classification threshold.

    Returns:
        Dict with flaky test IDs and their failure rates.
    """
    data = load_history()
    skill_data = data.get("skills", {}).get(skill_name)

    if not skill_data:
        print(f"No history found for skill: {skill_name}")
        return {"flaky_tests": [], "quarantined": []}

    flaky_tests = []
    for test_id, test_data in skill_data["tests"].items():
        flaky, failure_rate, sample_size = is_flaky(
            test_data["results"], threshold
        )
        if flaky:
            flaky_tests.append({
                "test_id": test_id,
                "failure_rate": round(failure_rate, 3),
                "sample_size": sample_size,
                "quarantined": test_id in skill_data.get("quarantined", [])
            })

    result = {
        "skill_name": skill_name,
        "flaky_tests": flaky_tests,
        "quarantined": skill_data.get("quarantined", []),
        "total_tests": len(skill_data["tests"]),
        "flaky_count": len(flaky_tests)
    }

    return result


def report_skill(skill_name):
    """Print a detailed report of test history for a skill."""
    data = load_history()
    skill_data = data.get("skills", {}).get(skill_name)

    if not skill_data:
        print(f"No history found for skill: {skill_name}")
        return

    quarantined = set(skill_data.get("quarantined", []))

    print(f"Flaky Test Report: {skill_name}")
    print("─" * 60)
    print(f"{'Test ID':<15} {'Runs':<6} {'Pass%':<8} {'Fail%':<8} {'Status':<12}")
    print("─" * 60)

    for test_id in sorted(skill_data["tests"].keys()):
        test_data = skill_data["tests"][test_id]
        results = test_data["results"]
        total = len(results)
        passes = sum(1 for r in results if r["passed"])
        pass_rate = passes / total if total > 0 else 0
        fail_rate = 1 - pass_rate

        flaky, _, _ = is_flaky(results)
        status = "QUARANTINED" if test_id in quarantined else (
            "FLAKY" if flaky else (
                "INSUFFICIENT" if total < MIN_HISTORY else "STABLE"
            )
        )

        print(
            f"{test_id:<15} {total:<6} {pass_rate*100:>5.1f}%  "
            f"{fail_rate*100:>5.1f}%  {status:<12}"
        )

    print("─" * 60)


def quarantine_test(skill_name, test_id):
    """Quarantine a flaky test to exclude it from deployment decisions."""
    data = load_history()

    if skill_name not in data.get("skills", {}):
        print(f"No history found for skill: {skill_name}")
        return False

    skill_data = data["skills"][skill_name]
    if "quarantined" not in skill_data:
        skill_data["quarantined"] = []

    if test_id not in skill_data["quarantined"]:
        skill_data["quarantined"].append(test_id)
        save_history(data)
        print(f"Quarantined: {skill_name}/{test_id}")
        return True

    print(f"Already quarantined: {skill_name}/{test_id}")
    return False


def unquarantine_test(skill_name, test_id):
    """Remove a test from quarantine."""
    data = load_history()

    skill_data = data.get("skills", {}).get(skill_name)
    if not skill_data:
        print(f"No history found for skill: {skill_name}")
        return False

    if test_id in skill_data.get("quarantined", []):
        skill_data["quarantined"].remove(test_id)
        save_history(data)
        print(f"Unquarantined: {skill_name}/{test_id}")
        return True

    print(f"Not quarantined: {skill_name}/{test_id}")
    return False


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        sys.exit(1)

    command = sys.argv[1]
    skill_name = sys.argv[2]

    if command == "record":
        if len(sys.argv) < 5:
            print("Usage: flaky_detector.py record <skill-name> <test-id> <pass|fail>")
            sys.exit(1)
        test_id = sys.argv[3]
        result_str = sys.argv[4].lower()
        if result_str not in ("pass", "fail"):
            print("Result must be 'pass' or 'fail'")
            sys.exit(1)
        record_result(skill_name, test_id, result_str == "pass")

    elif command == "check":
        threshold = 0.3
        if len(sys.argv) >= 5 and sys.argv[3] == "--threshold":
            threshold = float(sys.argv[4])
        result = check_skill(skill_name, threshold)
        print(json.dumps(result, indent=2))

    elif command == "report":
        report_skill(skill_name)

    elif command == "quarantine":
        if len(sys.argv) < 4:
            print("Usage: flaky_detector.py quarantine <skill-name> <test-id>")
            sys.exit(1)
        quarantine_test(skill_name, sys.argv[3])

    elif command == "unquarantine":
        if len(sys.argv) < 4:
            print("Usage: flaky_detector.py unquarantine <skill-name> <test-id>")
            sys.exit(1)
        unquarantine_test(skill_name, sys.argv[3])

    else:
        print(f"Unknown command: {command}")
        print(__doc__)
        sys.exit(1)


if __name__ == "__main__":
    main()
