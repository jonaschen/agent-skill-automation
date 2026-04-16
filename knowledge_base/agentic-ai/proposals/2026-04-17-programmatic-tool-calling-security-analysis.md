# Skill Proposal: Programmatic Tool Calling Security Analysis (Pre-Pilot Blocker)

**Date**: 2026-04-17
**Triggered by**: Programmatic Tool Calling GA on Opus 4.7 via `code_execution_20260120`. Intermediate tool results don't count toward input/output tokens — real efficiency gain, but tools invoked inside the code-execution container could silently bypass our harness-level `post-tool-use.sh` hooks (cmd_chain_monitor, metachar detection, mcp_depth monitor). Analysis §1.5 + §3.5; Discussion A7 (ADOPT P1).
**Priority**: **P1** (high — BLOCKS all programmatic-tool-calling pilots; security-architecture question)
**Target Phase**: Phase 4 (security closed loop) / Phase 2 (validator pipeline)

## Rationale

`code_execution_20260120` is a new tool-invocation transport that runs tool calls inside an
Anthropic-managed container. Our post-tool-use.sh hook fires on harness-level Bash/Write
invocations. The security question: **does it fire on container-internal tool calls?**

If it does NOT, our entire security envelope (CVE-2026-35020 mitigation, cmd_chain_monitor, metachar
detection, MCP depth monitor, prototype collision audit, cost ceiling, fleet version check) is
silently bypassed when an agent uses programmatic tool calling. This is a silent regression vector
— no symptom until an actual attack lands.

**L11 in Lessons Learned** (ROADMAP): "security layers are cumulative, not simplifiable." Bypassing
them at a new transport layer violates L11.

**Discussion consensus (2026-04-17 Round 3)**:
- Analysis is **blocking** for any pilot (researcher or factory)
- ~2 hours of work; cost of skipping is catastrophic
- Also audit whether `settings.local.json` supports granular tool-name denies for container-internal tools, or only at outer `code_execution_20260120` level — this affects the minimal deny rule answer

## Proposed Specification

- **Name**: Programmatic Tool Calling Security Analysis
- **Type**: Evaluation Document (pre-pilot blocker)
- **Location**: `knowledge_base/agentic-ai/evaluations/programmatic-tool-calling-security.md`
- **Owner**: factory-steward

**Three-Question Analysis**:

**Q1: Does `.claude/hooks/post-tool-use.sh` fire when tools are invoked inside the `code_execution_20260120` container?**
- Method: WebFetch official Anthropic docs for `code_execution_20260120` hook semantics
- Cross-check: search for `stream_events` or container-event emission in Anthropic SDK / Claude Code docs
- Empirical test (if docs inconclusive): write minimal Skill that uses code_execution with a Bash call that triggers cmd_chain_monitor; observe whether monitor logs fire
- **Expected outcomes**:
  - YES (hooks fire) → safe to pilot; document container instrumentation; proceed
  - NO (hooks don't fire) → BLOCK all pilots; proceed to Q2
  - UNCLEAR → BLOCK pilots pending empirical verification

**Q2: If hooks don't fire at harness level, what container-level instrumentation exists?**
- Method: Anthropic docs for container event streams, audit logs, or structured output
- Check for `stream_events`, `container_audit_log`, or equivalent first-class primitives
- **Expected outcomes**:
  - Container-level hook / event stream exists → document integration path; may require new instrumentation code
  - No container-level hook → proceed to Q3

**Q3: If no container-level instrumentation, what's the minimal deny rule to gate `code_execution_20260120`?**
- Method: Test `.claude/settings.local.json` deny entries for `code_execution_20260120`
- Determine whether deny granularity is:
  - Tool-level only (block all container tool invocations) → blunt but safe
  - Parameter-level (block certain tool-name patterns inside container) → fine-grained, preferred
- **Expected deliverable**: exact `settings.local.json` deny entry that blocks the tool pending future instrumentation

**Deliverable Document Structure**:
```markdown
# Programmatic Tool Calling Security Analysis
**Date**: 2026-04-18
**Blocker for**: researcher pilot, factory pilot
**Status**: PASS | BLOCK_WITH_DENY | BLOCK_PENDING_INSTRUMENTATION

## Q1: Harness-Level Hook Coverage
<findings>

## Q2: Container-Level Instrumentation
<findings>

## Q3: Minimal Deny Rule
<exact settings.local.json snippet>

## Recommendation
<PASS/BLOCK with specific actions>
```

**Tools Required**: WebFetch (Anthropic docs), Read (settings.local.json, post-tool-use.sh), Bash (test execution if empirical needed)

## Implementation Notes

**Dependencies**:
- Access to Anthropic `code_execution_20260120` documentation (public)
- Ability to write a minimal test Skill if empirical verification needed
- Opus 4.7 compatibility for empirical test (shadow-eval proposal A1 may not have cascaded yet — use human-operator manual test if factory-steward still on 4.6)

**Risk**:
- Analysis inconclusive → conservative default: BLOCK with deny rule until instrumentation confirmed
- Incomplete hook coverage: if post-tool-use.sh fires for some container tool types but not others, partial bypass is still a vulnerability. Mitigation: treat as BLOCK unless coverage is **complete**.

**Do NOT**:
- Start any programmatic-tool-calling pilot (researcher, factory, or other) before this analysis is committed
- Trust docs alone if they're ambiguous — require empirical test
- Apply partial coverage ("fires most of the time") as sufficient

## Estimated Impact

- **Blocks silent security regression**: catches a potential envelope bypass before any fleet agent opens the attack surface
- **Establishes analysis pattern** for future novel tool transports (MCP Triggers & Events, future container-like primitives)
- **L11 discipline**: preserves "security layers are cumulative, not simplifiable" by validating layer coverage at new transport boundary
- **Unblocks P2 pilot**: programmatic-tool-calling pilot (researcher first, factory second) is deferred pending this analysis — landing the analysis unblocks downstream efficiency work (10× intermediate-token reduction per researcher sweep)
- **Cost**: ~2 hours; avoids potentially-catastrophic silent regression
