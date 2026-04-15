#!/usr/bin/env python3
"""
Runs the eval suite and writes a structured JSON + Markdown report.

Usage:
    python eval/write_test_report.py SKILL_PATH [--split train|validation] [--output DIR]

Output:
    logs/test-reports/report-YYYY-MM-DDTHH-MM-SS.json
    logs/test-reports/report-YYYY-MM-DDTHH-MM-SS.md
"""

import asyncio
import argparse
import json
import os
import sys
import time
from datetime import datetime, timezone

# Add eval/ to path so imports work
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from run_eval_async import AsyncEvalRunner
from bayesian_eval import get_stats


async def run_and_collect(skill_path, split_filter=None, no_cache=False, engine="claude"):
    """Run the eval suite and return per-test results + stats."""
    runner = AsyncEvalRunner(skill_path, verbose=True, no_cache=no_cache)
    repo_root = runner.repo_root
    prompts_dir = os.path.join(repo_root, "eval/prompts")
    expected_dir = os.path.join(repo_root, "eval/expected")

    test_files = sorted(
        [f for f in os.listdir(prompts_dir) if f.startswith("test_")],
        key=lambda x: int(x.split("_")[1].split(".")[0]),
    )

    if split_filter:
        allowed = runner.splits.get(split_filter, [])
        test_files = [f for f in test_files if int(f.split("_")[1].split(".")[0]) in allowed]

    per_test = []
    results_list = []
    start = time.monotonic()

    for f in test_files:
        tid = int(f.split("_")[1].split(".")[0])
        with open(os.path.join(prompts_dir, f)) as pf:
            prompt = pf.read().strip()
        with open(os.path.join(expected_dir, f)) as ef:
            expect_trigger = "yes" if "EXPECT_TRIGGER=yes" in ef.read() else "no"

        t0 = time.monotonic()
        result = await runner.run_test(tid, prompt, expect_trigger, engine)
        elapsed = round(time.monotonic() - t0, 2)

        entry = {
            "test_id": tid,
            "prompt_file": f,
            "expect_trigger": expect_trigger,
            "result": result,
            "passed": result == "PASS",
            "elapsed_s": elapsed,
        }
        # Categorize the split
        if tid in runner.splits.get("train", []):
            entry["split"] = "train"
        elif tid in runner.splits.get("validation", []):
            entry["split"] = "validation"
        else:
            entry["split"] = "unknown"

        per_test.append(entry)
        results_list.append(result)

    total_elapsed = round(time.monotonic() - start, 2)

    # Compute stats
    all_stats = get_stats(results_list)
    train_results = [e["result"] for e in per_test if e["split"] == "train"]
    val_results = [e["result"] for e in per_test if e["split"] == "validation"]
    train_stats = get_stats(train_results) if train_results else None
    val_stats = get_stats(val_results) if val_results else None

    failures = [e for e in per_test if not e["passed"]]

    return {
        "per_test": per_test,
        "failures": failures,
        "stats": {
            "overall": all_stats,
            "train": train_stats,
            "validation": val_stats,
        },
        "total_elapsed_s": total_elapsed,
    }


def build_report(skill_path, data, split_filter):
    """Build the final report dict."""
    now = datetime.now(timezone.utc).isoformat(timespec="seconds")
    failures = data["failures"]
    stats = data["stats"]

    # Classify failures
    false_positives = [f for f in failures if "false-positive" in f["result"]]
    not_triggered = [f for f in failures if "not-triggered" in f["result"]]
    other_failures = [f for f in failures if f not in false_positives and f not in not_triggered]

    overall = stats["overall"]
    gate_pass = overall["posterior_mean"] >= 0.90 and overall["ci_lower"] >= 0.80

    return {
        "report_version": "1.0",
        "generated_at": now,
        "skill_path": os.path.abspath(skill_path),
        "split_filter": split_filter,
        "summary": {
            "total_tests": overall["passes"] + (overall["total_non_skipped"] - overall["passes"]) + overall["skipped"],
            "passed": overall["passes"],
            "failed": overall["total_non_skipped"] - overall["passes"],
            "skipped": overall["skipped"],
            "pass_rate_raw": round(overall["passes"] / max(overall["total_non_skipped"], 1), 4),
            "posterior_mean": overall["posterior_mean"],
            "ci_lower": overall["ci_lower"],
            "ci_upper": overall["ci_upper"],
            "deployment_gate": "PASS" if gate_pass else "FAIL",
        },
        "split_stats": {
            "train": stats["train"],
            "validation": stats["validation"],
        },
        "failure_breakdown": {
            "false_positives": [{"test_id": f["test_id"], "prompt_file": f["prompt_file"]} for f in false_positives],
            "not_triggered": [{"test_id": f["test_id"], "prompt_file": f["prompt_file"]} for f in not_triggered],
            "other": [{"test_id": f["test_id"], "prompt_file": f["prompt_file"], "result": f["result"]} for f in other_failures],
        },
        "per_test_results": data["per_test"],
        "total_elapsed_s": data["total_elapsed_s"],
    }


def render_markdown(report):
    """Render the JSON report as a human-readable Markdown string."""
    s = report["summary"]
    lines = [
        "# Test Suite Report",
        "",
        f"**Generated**: {report['generated_at']}",
        f"**Skill**: `{report['skill_path']}`",
        f"**Split filter**: {report['split_filter'] or 'ALL'}",
        "",
        "## Summary",
        "",
        f"| Metric | Value |",
        f"|--------|-------|",
        f"| Tests run | {s['total_tests']} |",
        f"| Passed | {s['passed']} |",
        f"| Failed | {s['failed']} |",
        f"| Skipped | {s['skipped']} |",
        f"| Raw pass rate | {s['pass_rate_raw']:.1%} |",
        f"| Posterior mean | {s['posterior_mean']:.3f} |",
        f"| 95% CI | [{s['ci_lower']:.3f}, {s['ci_upper']:.3f}] |",
        f"| **Deployment gate** | **{s['deployment_gate']}** |",
        "",
    ]

    # Split stats
    for split_name in ["train", "validation"]:
        ss = report["split_stats"].get(split_name)
        if ss:
            lines.append(f"### {split_name.capitalize()} split")
            lines.append(f"- Posterior mean: {ss['posterior_mean']:.3f} CI [{ss['ci_lower']:.3f}, {ss['ci_upper']:.3f}]")
            lines.append(f"- {ss['passes']}/{ss['total_non_skipped']} passed")
            lines.append("")

    # Failures
    fb = report["failure_breakdown"]
    if fb["false_positives"] or fb["not_triggered"] or fb["other"]:
        lines.append("## Failures")
        lines.append("")

        if fb["not_triggered"]:
            lines.append("### Not triggered (expected trigger, got none)")
            lines.append("")
            for f in fb["not_triggered"]:
                lines.append(f"- Test {f['test_id']} (`{f['prompt_file']}`)")
            lines.append("")

        if fb["false_positives"]:
            lines.append("### False positives (should NOT have triggered)")
            lines.append("")
            for f in fb["false_positives"]:
                lines.append(f"- Test {f['test_id']} (`{f['prompt_file']}`)")
            lines.append("")

        if fb["other"]:
            lines.append("### Other failures")
            lines.append("")
            for f in fb["other"]:
                lines.append(f"- Test {f['test_id']} (`{f['prompt_file']}`): {f['result']}")
            lines.append("")
    else:
        lines.append("## Failures")
        lines.append("")
        lines.append("None — all tests passed.")
        lines.append("")

    # Per-test table
    lines.append("## Per-test results")
    lines.append("")
    lines.append("| Test | Split | Expect | Result | Time (s) |")
    lines.append("|------|-------|--------|--------|----------|")
    for t in report["per_test_results"]:
        mark = "PASS" if t["passed"] else t["result"]
        lines.append(f"| {t['test_id']:3d} | {t['split']:5s} | {t['expect_trigger']:3s} | {mark} | {t['elapsed_s']:.1f} |")
    lines.append("")
    lines.append(f"**Total time**: {report['total_elapsed_s']:.1f}s")

    return "\n".join(lines)


async def main():
    parser = argparse.ArgumentParser(description="Run eval suite and write structured report")
    parser.add_argument("skill_path", help="Path to the SKILL.md file to evaluate")
    parser.add_argument("--split", choices=["train", "validation"], help="Run only a specific split")
    parser.add_argument("--output", default=None, help="Output directory (default: logs/test-reports/)")
    parser.add_argument("--no-cache", action="store_true", help="Disable prompt cache")
    parser.add_argument("--engine", default="claude", help="AI engine (default: claude)")
    args = parser.parse_args()

    repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    output_dir = args.output or os.path.join(repo_root, "logs", "test-reports")
    os.makedirs(output_dir, exist_ok=True)

    print(f"Running eval suite for {args.skill_path} ...")
    data = await run_and_collect(args.skill_path, args.split, args.no_cache, args.engine)
    report = build_report(args.skill_path, data, args.split)

    timestamp = datetime.now().strftime("%Y-%m-%dT%H-%M-%S")
    json_path = os.path.join(output_dir, f"report-{timestamp}.json")
    md_path = os.path.join(output_dir, f"report-{timestamp}.md")

    with open(json_path, "w") as f:
        json.dump(report, f, indent=2)
    with open(md_path, "w") as f:
        f.write(render_markdown(report))

    print(f"\nReport written to:")
    print(f"  JSON: {json_path}")
    print(f"  MD:   {md_path}")
    print(f"\nGate verdict: {report['summary']['deployment_gate']}")
    print(f"Posterior mean: {report['summary']['posterior_mean']:.3f} "
          f"CI [{report['summary']['ci_lower']:.3f}, {report['summary']['ci_upper']:.3f}]")

    if report["failure_breakdown"]["not_triggered"] or report["failure_breakdown"]["false_positives"]:
        print(f"\nFailures: {report['summary']['failed']}")
        for f in report["failure_breakdown"]["not_triggered"]:
            print(f"  NOT-TRIGGERED: test {f['test_id']}")
        for f in report["failure_breakdown"]["false_positives"]:
            print(f"  FALSE-POSITIVE: test {f['test_id']}")

    sys.exit(0 if report["summary"]["deployment_gate"] == "PASS" else 2)


if __name__ == "__main__":
    asyncio.run(main())
