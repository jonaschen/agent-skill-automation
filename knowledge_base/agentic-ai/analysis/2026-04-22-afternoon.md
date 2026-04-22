# Deep Analysis — 2026-04-22 Afternoon

## Context

Both vendors broke their freezes on Apr 22 — the morning analysis's MODERATE burst forecast proved correct, arriving same-day rather than over days. CC v2.1.117 is a major release (25+ changes, 2-day turnaround) with the critical Opus 4.7 context window fix. Gemini CLI preview channel shipped aggressively (v0.39.0-preview.2) while stable remains frozen. This analysis covers four findings from the consolidated afternoon sweep, then maps convergence patterns and threats.

Directive compliance: single-cycle volume (one consolidated sweep, one analysis). Shadow eval one-sentence: per-test logging implemented, #49562 OPEN, zero staff responses.

**Shadow eval status**: Per-test logging implemented (commit 79c98c7). Prefix match implemented (commit 6e70617). #49562: OPEN, zero staff responses. CC v2.1.117 context window fix may change Opus 4.7 shadow eval results — re-run needed post-upgrade.

## Gap Analysis Findings

### Finding 1: CC v2.1.117 Context Window Fix — Shadow Eval Implications (S1)

**Observation**: CC v2.1.117 fixes a bug where Claude Code computed Opus 4.7's context window against 200K instead of 1M, causing premature autocompacting and inflated `/context` percentages. This is the most operationally significant fix for our fleet since the Opus 4.7 release (Apr 16).

**Why this matters for our pipeline**: Our entire agent fleet runs within Claude Code sessions. If CC was computing against 200K for Opus 4.7 sessions, our steward sessions (which average 44 minutes and generate substantial context) may have been silently autocompacting — losing context mid-session without any visible error. This could explain some of the unexplained shadow eval failures (0.683 pass rate) beyond the adaptive thinking cost increase.

**S1 impact — HIGH**: The shadow eval NO-GO (0.683, CI [0.535, 0.814]) was measured on a CC version with the broken context window. After upgrading to v2.1.117:
1. Re-running shadow eval may produce materially different results — the 200K→1M fix could recover some of the 12/39 failures if they were caused by context truncation rather than model behavior.
2. The per-test logging (commit 79c98c7) and prefix match (commit 6e70617) are ready to capture granular results.
3. **Critical question**: How many of the 12 shadow eval failures were caused by premature autocompacting (CC bug) vs. Opus 4.7 model behavior (#49562 adaptive thinking cost)? The re-run will disambiguate.

**Gap**: Upgrade CC to v2.1.117 is now **P0** — blocks clean shadow eval data. Jonas action required.

### Finding 2: Triple Convergence — Agent Definitions Carrying Tool Dependencies (S3)

**Observation**: Three independent moves toward self-contained agent definitions within 72 hours:
1. **CC v2.1.117**: Declarative `mcpServers` in agent frontmatter — agents specify their MCP server dependencies directly in the agent definition file.
2. **ADK Java 1.0**: App/Plugin architecture — agents declare their tool dependencies (ComputerUseTool, GoogleMapsTool, UrlContextTool) as part of their package.
3. **Deep Research** (Apr 21): MCP server integration with auth headers and tool restrictions baked into the agent configuration.

**S3 impact — HIGH**: This is the strongest convergence signal for agent definition format portability we've observed. All three approaches solve the same problem: "an agent should declare what tools it needs, and the runtime should provision them." The implementations differ:

| Aspect | CC v2.1.117 | ADK Java 1.0 | Deep Research |
|--------|-------------|-------------|---------------|
| Format | YAML frontmatter in .md | Java annotations/config | API configuration |
| Protocol | MCP (STDIO/SSE) | ADK tool classes | MCP (remote HTTP) |
| Scope | Per-agent | Per-app/plugin | Per-task |
| Runtime | Claude Code | ADK runtime | Interactions API |

**Design input for S3 format comparison study**: The portable agent definition format should include a `tools` or `dependencies` section that maps to vendor-specific tool provisioning. MCP is the common protocol layer; the format question is how to declare MCP servers (frontmatter vs. config file vs. API parameter).

**Gap**: No format comparison study started. Still blocked on Gemini CLI install for validation, but the analysis can proceed on documentation alone.

### Finding 3: Event Compaction Convergence — Context Management for Long Sessions (S2/Phase 5)

**Observation**: Two vendors independently solving the same context management problem:
- **ADK Java 1.0**: Event compaction via sliding window + summarization for long sessions. Older events are summarized to free context space while preserving key facts.
- **CC v2.1.117**: Context window fix (200K→1M) + existing autocompaction (summarizes prior turns when context fills).

Both are responses to the same fundamental constraint: long-running agent sessions exhaust context windows. ADK's approach is proactive (compact before hitting the limit); CC's is reactive (autocompact when full).

**Phase 5 impact — MEDIUM**: Our Phase 5 design for long-running orchestration sessions (sprint-orchestrator coordinating multi-agent work) needs a context management strategy. Options:
1. **Proactive compaction** (ADK model): Summarize completed tasks, keep only active task context. Prevents surprise truncation.
2. **Reactive compaction** (CC model): Let the runtime handle it. Simpler but less predictable.
3. **Hybrid**: Proactive for orchestrator state (task list, progress), reactive for sub-agent interactions.

**Gap**: Phase 5 design doesn't include a context management section. This is a design input for Phase 5.6 Design Freeze (May 22-26).

### Finding 4: Gemini CLI Preview — Subagent Architecture Alignment (S2/S3)

**Observation**: Gemini CLI v0.39.0-preview.0 unified multiple subagent invocation methods into a single `invoke_subagent` tool. This mirrors CC's existing single `Agent` tool pattern. The preview also adds `/memory inbox` (review extracted skills from conversations) and `useAgentStream` hook.

**S2 impact — MEDIUM**: The subagent tool unification validates our Phase 5 single-dispatch architecture. Both platforms converge on: one tool call → one subagent → results back. This is the correct abstraction level for our topology-aware-router (Phase 5.1).

**S3 impact — MEDIUM**: Subagent invocation is now structurally similar across both platforms:
- CC: `Agent(prompt, subagent_type)` → results
- Gemini CLI: `invoke_subagent(config)` → results

The dispatch interface is converging. The differences are in what metadata the subagent carries (CC: agent .md files; Gemini: skills/memory) — reinforcing that the S3 remaining gap is agent definition format, not invocation protocol.

**Note**: `/memory inbox` in Gemini CLI is functionally similar to our skill usage logger (installed in long-term-care-expert and The-King's-Hand). Both extract reusable patterns from conversation history. Different implementation (CLI built-in vs. hook-based), same intent.

## Cross-Pollination Opportunities

### 1. Declarative mcpServers → Our Agent Fleet (S1/S3)

CC v2.1.117's agent frontmatter `mcpServers` means our agent definition files (`.claude/agents/*.md`) can now declare their MCP dependencies directly. Currently, MCP server configuration lives in `.mcp.json` globally. Moving MCP dependencies into agent frontmatter would:
- Make agents self-contained (advancing S3 portability)
- Enable per-agent MCP server sets (some agents need different tools)
- Align with ADK Java's App/Plugin tool declaration pattern

**Concrete action**: Evaluate which agents need specific MCP servers and whether frontmatter declaration improves our architecture. Low priority — current `.mcp.json` global config works.

### 2. ADK Event Compaction → Phase 5 Orchestrator Design (S2)

ADK Java's sliding window + summarization is directly applicable to our sprint-orchestrator. For a multi-hour sprint planning session, the orchestrator should:
- Keep full context for the current sprint (active tasks, blockers)
- Summarize completed sprints into a compact state snapshot
- Maintain a fixed-size "hot context" window for sub-agent interactions

This is a Phase 5 Design Freeze input. Document in Phase 5 design index.

### 3. Forked Subagents → Agent Fleet Isolation (S2)

`CLAUDE_CODE_FORK_SUBAGENT=1` in CC v2.1.117 enables forked subagent execution on external builds. This could improve our cron-based pipeline:
- Currently: each agent runs in a fresh `claude -p` session (already isolated)
- With forked subagents: within a single session, sub-agents get process isolation
- Potential use: the factory-steward could fork research analysis into a subagent without polluting its main context

**Evaluation criteria**: Does forked subagent isolation reduce context interference in multi-step sessions? Test with factory-steward session.

## Threats to Architecture

### 1. CC Context Window Bug May Have Corrupted Historical Data (MEDIUM, S1)

If CC was computing Opus 4.7 context against 200K instead of 1M, all historical Opus 4.7 data collected before v2.1.117 is potentially compromised by premature autocompacting. This affects:
- Shadow eval results (0.683 NO-GO) — may have been measured under broken conditions
- Factory-steward sessions running on Opus 4.7 — may have lost context mid-session
- Research sweep quality — if any sweeps ran on Opus 4.7, their depth may have been silently reduced

**Mitigation**: Re-run shadow eval after upgrade. Compare pre/post-upgrade results to quantify the bug's impact. Our fleet currently runs Opus 4.6, so production sessions were likely unaffected — the shadow eval was the primary Opus 4.7 exposure.

### 2. Preview Channel Instability (LOW, S3)

Gemini CLI's preview channel (v0.39.0-preview.2) is shipping aggressively (3 releases in 8 days) while stable is frozen. If we install Gemini CLI for S3 work, we'd need to choose:
- **Stable (v0.38.2)**: Reliable but missing unified subagent tool
- **Preview**: Has the features we need for S3 comparison but may be unstable

This isn't a current threat (Gemini CLI isn't installed), but when Jonas installs it, the channel choice matters for S3 evaluation reliability.

### 3. OTEL Effort Attribute — Observability Opportunity (LOW, S1)

v2.1.117 adds `effort` attribute to OTEL cost/token events. This is a new signal dimension for our shadow eval — we could track whether adaptive thinking effort correlates with eval failures. Not a threat per se, but a missed opportunity if we don't integrate it. Low priority until the basic shadow eval re-run is complete.

## Factory Queue Clearance Tracking

Per directive: track factory queue clearance rate.

**Queue status**: 13 items entering today. Factory session (commit 6e70617) cleared 3 items:
1. Shadow eval prefix match — DONE
2. S3 problem decomposition update — DONE
3. I/O playbook update — DONE

**Remaining queue**: ~10 items. At 3 items/session throughput, ~3-4 sessions to clear. No throughput degradation observed. Next factory session (tonight) should target items #1-3 from the priority queue (remote MCP feasibility, async dispatch convergence, ADK TCI comparison).

## Strategic Priority Status

| Priority | Status | Change from Morning Analysis |
|----------|--------|------------------------------|
| S1 | **Context window bug discovered.** Shadow eval 0.683 NO-GO was measured under broken CC (200K instead of 1M). Re-run post-upgrade may produce materially different results. Per-test logging + prefix match both ready. #49562 still OPEN. | **Significant** — prior shadow eval data may be compromised. Upgrade CC v2.1.117 is now the single highest-priority action. |
| S2 | **Triple convergence on agent definitions carrying tool dependencies.** Event compaction convergence adds Phase 5 design input. Forked subagents available for fleet isolation testing. Unified subagent tool in Gemini CLI validates single-dispatch. | Strengthened — three new convergence patterns from a single day's releases. |
| S3 | **Agent definition convergence is the strongest S3 signal yet.** CC mcpServers + ADK App/Plugin + Deep Research MCP all embed tool deps in agent format. Subagent invocation converging (single-tool dispatch). Remaining S3 gap confirmed: agent format + orchestration. Gemini CLI still not installed. | Strengthened — format convergence evidence tripled in one cycle. |

## Summary

The headline finding is CC v2.1.117's Opus 4.7 context window fix (200K→1M), which may have silently corrupted our shadow eval baseline — the 0.683 NO-GO result was measured under broken conditions. This makes upgrading CC to v2.1.117 the single highest-priority action (P0, Jonas). Beyond that, a triple convergence signal on agent definitions carrying tool dependencies (CC mcpServers + ADK App/Plugin + Deep Research MCP) is the strongest S3 evidence to date. Event compaction convergence (ADK sliding window + CC autocompaction) provides Phase 5 context management design input. Gemini CLI preview unification of the subagent tool validates Phase 5 single-dispatch architecture. Factory queue at ~10 items remaining, 3 cleared this cycle, throughput healthy at 3/session.

Four findings, three cross-pollination opportunities, three threats identified. No new ADOPT items proposed — factory queue has sufficient work. Volume: one consolidated sweep, one analysis (this document). Directive-compliant.
