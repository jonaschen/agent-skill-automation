# Deep Analysis — 2026-04-21 (Afternoon)

## Context

Both vendor freezes broke today. Anthropic shipped CC v2.1.115 + v2.1.116 (ending a ~130h freeze). Google shipped ADK v1.31.1 (selective — CLI, A2A, Vertex remain frozen). The afternoon sweep also attempted the directive's P1 one-time task: Opus 4.7 failure pattern characterization. Result: data gap blocks analysis.

This analysis covers five findings from the afternoon/evening sweeps, then maps cross-pollination and threats. It builds on the morning analysis (2026-04-21.md) which covered freeze signals, A2A production scale, Gemma 4 Phase 6 de-risk, Mariner absorption, and Haiku 3 guard validation.

## Gap Analysis Findings

### Finding 1: Opus 4.7 Failure Characterization — Data Gap Blocks S1 Determination

**Observation**: The directive's P1 task was to characterize the 12/39 shadow eval failures on Opus 4.7 — specifically, whether they concentrate in positive tests (routing regression, potentially fixable) or negative tests (false triggers, potentially fundamental). Investigation found: zero `opus-4-7` entries in `experiment_log.json`, no shadow eval logs on disk, no performance JSONs for shadow eval runs.

**Root cause**: The shadow eval that produced the NO-GO verdict (posterior mean 0.683, 27/39 pass) ran via the dedicated `daily_shadow_eval.sh` script, but that script writes only aggregate results — total pass count and Bayesian posterior — without per-test pass/fail detail. The prompt cache model-blindness fix (2026-04-19) prevents cross-contamination but doesn't add per-test logging.

**S1 impact — SIGNIFICANT**: This is the sharpest S1 gap identified since the shadow eval infrastructure was built. The entire S1 posture for the next month depends on a binary determination:

| Failure pattern | Interpretation | S1 action |
|----------------|---------------|-----------|
| Concentrated in positive tests (1-22) | Routing regression — 4.7's adaptive reasoning routes differently | Recoverable: description tuning for 4.7's routing behavior |
| Concentrated in negative tests (23-59) | False triggers — 4.7 triggers on hallucination traps | Potentially fundamental: 4.7's reasoning disrupts our negative test design |
| Mixed across both | Multiple issues | Likely needs both description tuning + Anthropic patch |

Without per-test data, we default to "wait for patch" — which is safe but potentially wasteful if the failures are concentrated and fixable.

**Action (factory-steward, P1)**: Add per-test result logging to `daily_shadow_eval.sh`. Specifically: capture the per-test pass/fail output from `run_eval_async.py` and write it to `experiment_log.json` as part of the shadow eval entry. The `run_eval_async.py` script already produces per-test output — it just isn't captured by the shadow eval wrapper. This must be in place before the next Opus 4.7 patch triggers a re-run.

### Finding 2: Anthropic Freeze Break — CC v2.1.116 Operational Improvements

**Observation**: After ~130h, CC v2.1.115 (bridge) and v2.1.116 (major) shipped. Key improvements:
- `/resume` 67% faster on 40MB+ sessions
- MCP startup faster (deferred template listing)
- Thinking progress indicators
- **Security fix**: sandbox rm/rmdir safety for `/`, `$HOME`, system dirs

**Pipeline impact — MEDIUM**: The `/resume` speedup directly benefits our steward sessions. The factory-steward session (44-min average) and researcher session (both process large transcripts from prior context) would see measurable improvement on session resume after interruption. The security fix closes a sandbox escape vector relevant to our autonomous execution model.

**Gap**: Fleet is on v2.1.114. Two versions behind. The fleet version check (`check_fleet_version.sh`, minimum >=2.1.111) will NOT trigger — threshold is below both current and latest. This is a policy gap: the check warns on version mismatch but the threshold was last bumped 4 days ago.

**Action (Jonas, P1)**: Upgrade CC to v2.1.116. Bump `fleet_min_version.txt` to >=2.1.116 after upgrade.

### Finding 3: Agent SDK v0.1.64 — SessionStore Production Adapters (Phase 5 Infrastructure)

**Observation**: Python Agent SDK v0.1.64 ships production-ready SessionStore with conformance tests and three reference adapters: S3, Redis, Postgres.

**Phase 5 significance — HIGH**: This is the first time the Python SDK has shipped production-grade session persistence. Our Phase 5.3.3 (CLI to Agent SDK Migration) specifically requires session persistence for crash recovery and checkpoint-rewind behavior. Previously, the TypeScript SDK was advancing faster on session features — the Python SDK was a Phase 5 risk factor. This release materially de-risks the migration path.

**Cross-reference with ROADMAP**: Phase 5.3.2 (external session state store) calls for append-only `logs/phase5_task_state.jsonl`. SessionStore offers a higher-abstraction alternative: rather than custom JSONL + resume logic, we could delegate session persistence to the SDK's built-in SessionStore with a Postgres adapter (already in our infra stack). This would simplify crash recovery from "parse JSONL, find last checkpoint, rebuild context" to "call `getSession(id)` + `resume()`."

**Trade-off**: Adopting SessionStore couples Phase 5 to the Agent SDK migration (5.3.3). If we build the custom JSONL approach first, it works with current `claude -p` CLI invocations and can be replaced later. If we go directly to SessionStore, we must complete 5.3.3 first.

**Recommendation**: No change to Phase 5 task ordering. SessionStore de-risks the target architecture but doesn't change the critical path. Note in Phase 5.3.2 design docs that SessionStore is now available as the target implementation.

### Finding 4: ADK v1.31.1 RCE Fix — Security Posture Comparison Point

**Observation**: ADK v1.31.1 patches a critical RCE via nested YAML configurations (unsafe deserialization). Also disables `mcp_tool` bound tokens and improves OAuth flow. Evening sweep corrected a hallucinated v1.32.0 report — only v1.31.1 exists.

**Security analysis**: The nested YAML RCE is in the same vulnerability class as PyYAML `unsafe_load` — a well-known attack vector that has affected multiple Python agent frameworks. The fix confirms ADK was using some form of YAML deserialization for agent configurations that allowed code execution. This is relevant to our security posture:

| Dimension | ADK (pre-fix) | Our Pipeline |
|-----------|--------------|--------------|
| Config format | YAML (with nested deserialization) | YAML frontmatter (parsed by Claude, not Python YAML loader) |
| Execution risk | RCE via crafted YAML | Low — SKILL.md YAML is read by the LLM, not `yaml.load()` |
| Auth surface | Bound tokens + OAuth | API keys only (`ANTHROPIC_API_KEY`) |

**Pipeline impact — LOW (direct), MEDIUM (S2 comparison)**: We don't use ADK directly. However, the A2 ADOPT item (ADK v2.0 comparison framework) should include this security incident as a comparison dimension. Our YAML handling is architecturally safer because SKILL.md frontmatter is parsed by the LLM, not by a YAML library with execution capabilities.

**Action**: Note in A2 comparison framework that ADK v1.31.1+ should be the minimum version for any Phase 5 integration, and document the YAML security design difference.

### Finding 5: Selective Freeze Break Pattern — Release Cadence Intelligence

**Observation**: Anthropic broke fully (CC + SDK). Google broke selectively (ADK only — CLI, A2A, Vertex remain frozen day 4-62+). This is the first observed selective freeze break on the Google side.

**Interpretation**: ADK operates on an independent release cadence from Gemini CLI and Vertex. The RCE fix forced an out-of-band release regardless of broader freeze. This tells us:
1. ADK security patches are not held for coordinated releases
2. Gemini CLI freeze is likely I/O-driven (accumulating features for the May 19 keynote)
3. A2A v1.0.0 is genuinely stable (day 42 — not frozen, just done)

**Forecasting value**: When I/O arrives, expect ADK and CLI to unfreeze simultaneously but with different release sizes. ADK will likely jump to v2.0 (alpha3 has been staged since Apr 9). CLI may jump to v0.39+ with significant feature additions. A2A v1.1 timing is independent of both.

**Action**: None. Update mental model of Google release cadence for I/O preparation.

## Cross-Pollination Opportunities

### 1. SessionStore ↔ Workflow State Convergence (S2)

The morning analysis identified four convergent workflow patterns (ADK lazy scan, WDK replay, Managed Agents event log, our state machine). SessionStore v0.1.64 adds a fifth reference implementation — SDK-native session persistence with pluggable backends. This strengthens the "Managed Agents event log" recommendation from `workflow-state-convergence.md` because SessionStore IS an event log with SDK-level crash recovery built in.

**S2 paper relevance**: The heterogeneous multi-agent paper can cite SessionStore's three-adapter design (S3/Redis/Postgres) as evidence that the industry is converging on pluggable session persistence for multi-agent systems. This aligns with our Finding 3 from the `workflow-state-convergence.md` analysis.

### 2. ADK YAML Security ↔ Our MCP Config Validation (Security)

ADK's YAML RCE validates our investment in `mcp_config_validator.sh` (static content scanning, injection detection). Our MCP config is JSON, which has no deserialization-based code execution risk, but the same class of attack (injecting executable content into configuration) motivates our existing injection phrase detection. The ADK incident provides a concrete case study for our S2 paper's security section.

### 3. CC v2.1.116 `/resume` Speedup ↔ Steward Session Efficiency

The 67% `/resume` speedup is a direct improvement for our daily agent fleet. All steward sessions start by loading context from prior work (ROADMAP, directives, knowledge base). Faster `/resume` means the steward agents spend less time in context loading and more time in productive work. This is an S1 operational improvement — the platform improved, and our agents automatically benefit without any pipeline changes. This is the kind of "platform capability automatically benefiting agents" that S1 envisions, though it required no pipeline adaptation (just an upgrade).

## Threats to Architecture

### 1. Shadow Eval Data Gap (MEDIUM, S1-blocking)

The inability to characterize Opus 4.7 failures means we cannot make an informed S1 decision about whether to invest in description tuning for 4.7 compatibility. The factory-steward's per-test logging addition (Finding 1) is the mitigation. Until it's in place, any Opus 4.7 patch that ships will trigger a re-run that produces another aggregate-only result — better than nothing, but suboptimal for diagnosis.

### 2. Fleet Version Drift (LOW, Operational)

Two versions behind (v2.1.114 vs v2.1.116). The security fix in v2.1.116 (sandbox escape) is relevant to autonomous execution. Risk is bounded — our agents don't typically rm system directories — but the principle of running latest stable applies. Upgrade is manual (Jonas action).

### 3. Post-Freeze Release Acceleration (MEDIUM, Tactical)

Now that both vendors have broken their freezes, release cadence may accelerate. Anthropic in particular tends to ship daily after a freeze break. The research sweep cadence (2x/day) handles this, but the factory steward's 3-items-per-session throughput becomes the bottleneck if many releases require integration work. The directive's 5-ADOPT cap naturally rate-limits this.

### 4. Evening Sweep Self-Correction (LOW, Process)

The evening sweep caught and corrected a hallucinated v1.32.0 ADK release from the afternoon Google sweep. This is the data integrity loop working correctly — but it flags that hallucinated version numbers are a recurring risk in sweep reports. The correction was caught by verification against `gh api` and PyPI — tools the researcher already uses. No process change needed, but the evening consolidation pattern should continue.

## Strategic Priority Status

| Priority | Status | Change from Morning Analysis |
|----------|--------|----------------------------|
| S1 | **Data gap identified**: shadow eval per-test logging missing. Blocks failure characterization. Infrastructure works but under-instruments. | New finding — morning analysis didn't cover data gap (freeze hadn't broken yet) |
| S2 | SessionStore v0.1.64 de-risks Phase 5.3.2. ADK YAML security case study for paper. | SessionStore finding is new. S2 paper gains a concrete citation |
| S3 | No change from morning. Fleet manifest + A2A Agent Card alignment still the cheapest S3 progress | Unchanged |

## Summary

The freeze break revealed three actionable findings: (1) shadow eval per-test logging gap blocks S1 failure characterization (P1 factory-steward action), (2) CC v2.1.116 upgrade benefits fleet operations (P1 Jonas action), (3) SessionStore v0.1.64 de-risks Phase 5 session persistence. The ADK RCE fix validates our security posture and provides S2 paper material. No new ADOPT items proposed — findings map to existing factory queue (per-test logging) and human actions (CC upgrade). Volume controls respected.
