# ROADMAP Update Recommendations — 2026-04-11

**Source**: Deep Analysis 2026-04-11 + Discussion 2026-04-11
**Author**: agentic-ai-researcher (Mode 2c: Strategic Planning)

---

## P0: Critical / Immediate

### R1: Fleet Claude Code Version Bump (Phase 4.4)

**Current ROADMAP text**: "Fleet version WARNING: running v2.1.87, minimum v2.1.97"

**Recommended update**: Elevate from WARNING to BLOCKER. The fleet is 11 versions behind with critical security fixes:
- v2.1.92: Bash tool permission bypass corrections
- v2.1.94: Bedrock auth hardening
- v2.1.97: MCP memory leak (50 MB/hr OOM risk), permission prototype collision, bash env/redirect validation
- v2.1.98: PID namespace isolation, compound command hardening, MCP OAuth metadata fix

**Action items**:
1. Human: `npm update -g @anthropic-ai/claude-code` on fleet host → >=v2.1.98
2. Factory steward: Update `scripts/lib/fleet_min_version.txt` from `>=2.1.97` to `>=2.1.98`
3. Post-upgrade: Run `scripts/agent_review.sh 1` on first nightly cycle, compare durations/exit codes against 7-day baseline
4. Update ROADMAP status line to reflect new fleet version

**Discussion verdict**: ADOPT (P0) — unanimous

---

## P2: Medium Priority

### R2: Advisor Tool as Fourth Topology Option (Phase 5.2)

**Add design note to Phase 5.2 section** (after the topology-aware-router task):

> **Design note (2026-04-11)**: The Anthropic Advisor Tool (`advisor_20260301`, public beta) creates a fourth topology option for medium-coupling tasks (TCI 0.35-0.65): a Sonnet executor consults Opus at 2-3 key decision points (approach planning, stuck recovery, completion verification). Cost: -11.9% vs pure Opus; quality: +2.7pp SWE-bench. Re-evaluate when advisor reaches GA and Phase 5 implementation begins. Do not hardcode TCI routing ranges until then.

**Rationale**: The medium-coupling band (TCI 0.35-0.65) currently defaults to Track B (sequential), which is overkill for tasks that only need occasional expert consultation. The advisor pattern fills this gap without the overhead of a full planner session.

### R3: Metacharacter Detection Baseline (Phase 4.4)

**Add new task to Phase 4.4**:

> - [ ] **Metacharacter pattern detection**: Add detect-only metacharacter pattern detection to `cmd_chain_monitor.sh`. Scope: Claude-generated Bash tool inputs only (not our scripts). Initial allowlist seeded from known-safe patterns (`grep | head`, `git log | sort`, `jq | wc`). Logs structured alerts to `logs/security/metachar_alert.jsonl`. Start 30-day baseline for Phase 5.5 PreToolUse allowlist calibration — P2

**Rationale**: ADK v1.29.0's BashTool blocks metacharacters pre-execution; our hook-based monitoring only detects post-execution. Detection-only mode builds the data needed to calibrate Phase 5.5 blocking without risking false-positive breakage of legitimate piped commands.

### R4: Thinking Mode Field in Performance JSONs (Phase 4.3)

**Add new task to Phase 4.3 (Observability)**:

> - [ ] **Thinking mode tracking**: Add `thinking_mode` field to all 6 daily script performance JSONs. Record `"default"` for current fleet config. Supports debugging future effort/duration anomalies if thinking configuration changes — P2

**Rationale**: Agent SDK v0.1.57 fixed a silent thinking configuration mapping bug. While our CLI agents aren't affected, recording the thinking mode in perf JSONs provides an audit trail for future configuration changes.

### R5: Task-Level Workflow State Tracking (Phase 5.3)

**Add new sub-task to Phase 5.3**:

> - [ ] **5.3.2 Task-level workflow state tracking (JSON)**: Extend `health_dashboard.py` with per-step state tracking (pending/running/completed/failed) for multi-agent workflows. Reference: ADK v2.0.0-alpha.3 lazy scan dedup + Vercel WDK deterministic replay. Output: structured JSON, not web UI (web visualization is Phase 7 observability chrome) — P2

**Rationale**: Three-way industry convergence (ADK lazy scan dedup + WDK deterministic replay + our state machine skip) confirms task-level state tracking is essential for production multi-agent debugging. JSON output enables downstream tooling without committing to a frontend in Phase 5.

### R6: MTP/Non-MTP Speed Differential Note (Phase 6.4)

**Add note to Phase 6.4** (after the EAGLE3 task):

> **Inference SLA note (2026-04-11)**: Gemma 4 MTP heads are stripped from public HuggingFace weights; MTP is only available via Google's proprietary LiteRT. Plan inference latency targets accordingly: AICore/LiteRT deployments get 1.8x MTP speedup; self-hosted (vLLM/Ollama/llama.cpp) gets 1.0x baseline without EAGLE3, ~1.72x with EAGLE3 draft head (277MB additional, 117 min training on 8xH200). Qwen 3.5 at 35 tok/s vs Gemma 4 at 11 tok/s on same hardware provides an alternative if latency dominates over open-weight control.

---

## P3: Nice-to-Have

### R7: Distillation Ladder Design Note (Phase 3.5)

**Add one-line note to Phase 3.5**:

> - [ ] Evaluate Sonnet+Opus advisor as intermediate distillation tier (Opus → Sonnet+advisor → Haiku+advisor → Haiku standalone). Advisor tool is beta (`advisor_20260301`); verify API stability before detailed experiment design — P3

### R8: Prompt Caching Architecture Pattern (Phase 5)

**Add design note to Phase 5 preamble or Phase 5.3**:

> **Design note (2026-04-11)**: When adopting Agent SDK for fleet execution, separate CLAUDE.md into static base (cacheable across agents) and dynamic session context (per-agent: git status, memory, date). Reference: Agent SDK `exclude_dynamic_sections` on `SystemPromptPreset`. Implementation consideration: current CLAUDE.md mixes static architecture descriptions with dynamic status — a structural split (`CLAUDE_BASE.md` + `CLAUDE_STATUS.md`) would be needed.

### R9: Billing Decomposition Reference (Phase 7.1)

**Add one-line note to Phase 7.1**:

> - [ ] Reference Anthropic's `usage.iterations[]` billing decomposition (from advisor tool responses) for per-component cost attribution design. Schema: separate token counts and costs for each inference iteration within a single API call. Mark as beta — verify schema stability at Phase 7 start — P3

---

## New Risk Entry

### R10: Fleet Version Gap as Active Security Risk

**Add to Key Risks table**:

| Risk | Phase | Mitigation | Status |
|------|-------|-----------|--------|
| Fleet running outdated Claude Code (11+ versions behind, missing PID namespace, MCP memory leak fix, permission hardening) | 4 | `check_fleet_version.sh` warns; human must upgrade; post-upgrade validation via `agent_review.sh` | ⚠️ P0 — upgrade pending |

---

## Countdown Updates for Status Line

Update ROADMAP status line to include:
- **Haiku 3 retirement**: 8 days (April 19) — guard verified, no action needed
- **1M context beta sunset**: 19 days (April 30) — monitor for pricing/availability changes
- **Google I/O 2026**: 38 days (May 19-20) — I/O-specific sweep queries active
- **Phase 4 deadline**: 28 days (May 9)
