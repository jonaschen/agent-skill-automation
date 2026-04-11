# Skill Update Suggestions — 2026-04-11

**Source**: Deep Analysis 2026-04-11 + Discussion 2026-04-11
**Author**: agentic-ai-researcher (Mode 2c: Strategic Planning)

---

## S1: `topology-aware-router` — Add Advisor Pattern as Fourth Routing Option (P2)

**File**: `.claude/agents/topology-aware-router.md`

**Triggered by**: Anthropic Advisor Tool (`advisor_20260301`) — Sonnet+Opus advisor achieves +2.7pp SWE-bench at -11.9% cost

**Current state**: Routes to three tracks: Track A (parallel, TCI < 0.35), Track B (sequential, TCI > 0.65), Changeling (single-domain tasks). Medium-coupling band (0.35-0.65) defaults conservatively to Track B.

**Proposed change**: Add a fourth routing option — "Advisor Pattern" — as a design-time note in the agent definition. Do NOT change routing logic until advisor reaches GA.

**Specific additions to agent definition**:
1. Add a row to the routing decision table:

| Topology | TCI Range | When | Cost | Quality |
|----------|-----------|------|------|---------|
| Advisor Pattern | 0.35-0.65 (medium) | Simple planning, quality amplification | Lowest | Near-high |

2. Add a note: "Advisor pattern is public beta (`advisor_20260301`). Do not route to advisor topology until GA. Current medium-coupling default remains Track B."

3. If `eval/tci_compute.py` outputs routing recommendations, add advisor as a commented-out option in the recommendation logic.

**Discussion verdict**: ADOPT (P2) — design note only, no routing changes until GA

---

## S2: `factory-steward` — Track Thinking Mode in Performance JSONs (P2)

**File**: `.claude/agents/factory-steward.md` (and all 6 daily scripts)

**Triggered by**: Agent SDK v0.1.57 thinking configuration mapping bug (`adaptive` → `max-thinking-tokens 32000` instead of `--thinking adaptive`)

**Current state**: Performance JSONs track `effort_level` but not `thinking_mode`.

**Proposed change**: Add `thinking_mode` field to the performance JSON schema in all 6 daily scripts. Value: `"default"` for current config. This provides an audit trail if thinking configuration ever changes or if we discover the CLI was affected by the SDK-side bug.

**Implementation**: ~5 lines per script — add `"thinking_mode": "default"` to the JSON object written by each daily script's EXIT trap.

**Discussion verdict**: ADOPT (P2)

---

## S3: `cmd_chain_monitor.sh` — Add Metacharacter Pattern Detection (P2)

**File**: `scripts/cmd_chain_monitor.sh`

**Triggered by**: ADK v1.29.0 BashTool metacharacter blocking — pre-execution blocking is strictly better than our post-execution detection

**Current state**: Monitors command-chain length (alert >30, block >45 subcommands). No metacharacter pattern detection.

**Proposed change**: Add `detect_metachar_patterns()` function:
- **Mode**: Detect-only (advisory), NOT blocking — avoids breaking legitimate piped commands
- **Patterns**: `;`, `&&`, `||`, backtick substitution (`` `...` ``), `$(...)` in Claude-generated Bash tool inputs
- **Allowlist**: Seed from known-safe patterns used by daily scripts (`grep | head`, `git log --format | sort`, `jq | wc -l`)
- **Scope**: Claude-generated Bash tool inputs ONLY (not our own scripts — the threat model is Claude generating dangerous metacharacters, not our scripts)
- **Output**: Structured JSON alerts to `logs/security/metachar_alert.jsonl`
- **Purpose**: Build 30-day baseline to calibrate Phase 5.5 PreToolUse blocking allowlist

**Discussion verdict**: ADOPT (P2) — detect-only with initial allowlist

---

## S4: `agentic-ai-researcher` — Update Knowledge Base Topics (P2)

**File**: `.claude/agents/agentic-ai-researcher.md`

**Triggered by**: New Anthropic primitives (Advisor Tool, PID namespace isolation, cross-user prompt caching)

**Current state**: Research domains table covers existing topics but doesn't mention advisor tool or PID namespace sandboxing.

**Proposed change**: Add to the Anthropic Track research topics table:

| Topic | Key Sources | Search Terms |
|-------|------------|-------------|
| Advisor Tool | docs.anthropic.com, anthropic.com/news | advisor tool, cost-quality tradeoff, executor-advisor pattern |
| Security & Sandboxing | docs.anthropic.com, github.com/anthropics | PID namespace, sandbox, permission hardening |

Also add to Cross-Cutting Topics:
- Agent cost optimization patterns (advisor tool, prompt caching, model distillation)

**Discussion verdict**: Implicit — these topics are already being tracked in sweeps; formalizing them in the agent definition ensures continuity.

---

## S5: `check_fleet_version.sh` — Update Minimum Version (P0)

**File**: `scripts/lib/fleet_min_version.txt`

**Triggered by**: Fleet running v2.1.87, now 11 versions behind with critical security fixes (PID namespace, MCP memory leak, permission bypass)

**Current state**: `>=2.1.97`

**Proposed change**: Update to `>=2.1.98` after human upgrades fleet. v2.1.98 adds PID namespace isolation and compound command hardening — both directly relevant to our autonomous agent security model.

**Prerequisites**: Human must first run `npm update -g @anthropic-ai/claude-code` on the fleet host.

**Post-upgrade validation**: Run `scripts/agent_review.sh 1` on first post-upgrade nightly cycle. Compare durations and exit codes against 7-day baseline to catch any behavioral regressions.

**Discussion verdict**: ADOPT (P0) — no debate, unanimous

---

## S6: Knowledge Base — Record Advisor Tool Billing Model (P3)

**File**: `knowledge_base/agentic-ai/anthropic/tool-use-and-function-calling.md`

**Triggered by**: Advisor tool `usage.iterations[]` billing decomposition — first real-world example of per-component cost attribution in a major API

**Proposed change**: Add "Advisor Tool Billing" section documenting the `usage.iterations[]` response schema — separate token counts for executor and advisor inference iterations. Mark as beta (`advisor_20260301`); verify schema stability before Phase 7 adoption.

**Discussion verdict**: ADOPT (P3) — straightforward knowledge capture

---

## Summary

| # | Skill/File | Change | Priority | Owner |
|---|-----------|--------|----------|-------|
| S1 | topology-aware-router | Add advisor pattern as fourth routing option (design note) | P2 | Factory steward |
| S2 | All 6 daily scripts | Add `thinking_mode` field to perf JSONs | P2 | Factory steward |
| S3 | cmd_chain_monitor.sh | Add detect-only metacharacter pattern detection | P2 | Factory steward |
| S4 | agentic-ai-researcher | Add advisor tool + security topics to research domains | P2 | Factory steward |
| S5 | fleet_min_version.txt | Update from >=2.1.97 to >=2.1.98 | P0 | Human + Factory steward |
| S6 | tool-use-and-function-calling.md | Record advisor tool billing model | P3 | Factory steward |
