# Skill Proposal: MCP Argument Profile Extraction
**Date**: 2026-04-20
**Triggered by**: Analysis Finding 2 — MCP STDIO systemic vulnerability (10+ CVEs, family #2 argument-blind allowlist bypass); 30-day baseline data available in `logs/security/metachar_alert.jsonl`
**Priority**: P3 (nice-to-have) — Phase 5 design input, no immediate enforcement
**Target Phase**: Phase 5.5 (Defensive architecture)
**Discussion ID**: A6

## Rationale

Our `cmd_chain_monitor.sh` checks binary names against a 60+ item allowlist but is blind to argument patterns. Exploitation family #2 (OX Security report) bypasses binary allowlists via argument injection: `npx -c "malicious"`, `node -e "code"`, `python3 -c "exec(...)". The allowlist says "npx is safe" — it doesn't check what flags follow.

We have 30 days of clean baseline data in `logs/security/metachar_alert.jsonl` — every Bash tool invocation logged with binary name and full argument string. This data contains the empirical answer to "which binaries use which argument patterns in normal operation."

This proposal extracts that data into a structured allowlist, NOT a blocking validator. The extraction is Phase 5 prep work — producing the empirical profiles that Phase 5.5's PreToolUse hook will need for argument validation. Done now while we have clean baseline data and before the vendor freeze breaks (which may change operational patterns).

## Proposed Specification

- **Name**: Data extraction task (not a Skill)
- **Type**: One-time analysis script + output file
- **Output**: `eval/argument_allowlist.json` — structured allowlist of (binary, argument_pattern) pairs
- **Key Capabilities**:
  - Parse 30 days of `metachar_alert.jsonl`
  - Extract unique (binary, argument_pattern) pairs
  - Identify which binaries use `-c`, `-e`, `--eval`, `-exec`, `--command` flags
  - Classify: legitimate (seen in normal ops) vs. never-seen (suspicious)
  - Human-reviewed output — Jonas must sign off before any future enforcement
- **Tools Required**: Python/jq for JSONL parsing

## Implementation Notes

- **No enforcement**: This produces a data file. Nothing reads it until Phase 5.5.
- **Human review required**: The allowlist draft must be reviewed by Jonas. Some legitimate operations DO use `-c` (e.g., `bash -c "echo test"`). The allowlist needs context-aware entries, not blanket blocks.
- **Data freshness**: 30 days is a good baseline window. If operational patterns change significantly (new agents, new tools), the extraction should be re-run.
- **Phase 5.5 integration**: When PreToolUse blocking is implemented, it reads `argument_allowlist.json` and blocks Bash tool calls with flagged (binary, argument) combinations not in the allowlist.

## Estimated Impact

- **Security**: Turns raw JSONL into structured security intelligence for Phase 5
- **Phase 5 acceleration**: Argument validation design starts with empirical data, not guesswork
- **Cost**: ~4 hours including data analysis and allowlist draft; near-zero runtime cost
