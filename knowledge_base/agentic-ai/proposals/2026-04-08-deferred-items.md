# Deferred Proposals — 2026-04-08
**Source**: Discussion 2026-04-08
**Author**: agentic-ai-researcher (Mode 2c: Strategic Planning)

---

## 1. Security Orchestrator Agent (CodeMender-Inspired)
**Deferred to**: Phase 5
**Priority**: P2
**Triggered by**: Google CodeMender multi-agent security pattern (72 upstream fixes)

**What**: Promote the `security-auditor` Changeling role to a full agent with Read/Glob/Grep/Bash tools (review-class permissions). Orchestrates existing security scripts with LLM reasoning to detect gaps between tools and generate coherent security assessments.

**Why deferred**: Current 7-script stack is manageable without LLM orchestration. The cost/latency overhead of an agent isn't justified until the stack exceeds ~15 tools. The `eval/security_suite.sh` aggregator (ADOPT) covers the immediate need.

**Trigger for re-evaluation**: When the security stack exceeds 15 components OR when a security gap is missed that an orchestrating agent would have caught.

---

## 2. Cross-Platform SKILL.md Export (Gemini CLI Distribution)
**Deferred to**: Phase 5 (research task)
**Priority**: P2
**Triggered by**: CLI architectural convergence between Claude Code and Gemini CLI confirmed complete

**What**: Write `scripts/skill_export.sh` that converts `.claude/skills/<name>/SKILL.md` to `.gemini/skills/<name>/SKILL.md` format with a distribution manifest and checksums.

**Why deferred**: Format compatibility not verified. The "virtually identical" claim is about architectural patterns, not byte-level format compatibility. Needs hands-on `.gemini/skills/` inspection first. Building a converter without verified format specs produces broken output.

**Pre-requisite research task**: Create a Gemini CLI project, inspect actual `.gemini/skills/` format, document exact field mappings and incompatibilities. Add this as a Phase 5 research task.

---

## 3. Orchestrator-Delegated Initiator Tier
**Deferred to**: Phase 5
**Priority**: P2
**Triggered by**: Initiator-type permission context design (ADOPT #3)

**What**: Add a third `orchestrator-delegated` initiator type to the permission context for subagent delegation, with intermediate restrictions between `cron-automated` and `human-interactive`.

**Why deferred**: No subagent delegation exists in our pipeline yet. Building permission tiers for non-existent execution contexts is speculative complexity. Implement when Phase 5 multi-agent orchestration makes it real.

---

## 4. Qwen 3.6 Plus for Phase 3 Distillation
**Rejected** (not deferred)
**Triggered by**: Qwen 3.6 Plus achieving 78.8% SWE-bench at ~3x Opus speed

**Why rejected**:
1. Free preview pricing won't last — building on free tiers is building on sand
2. Phase 3.5 training data (100 Opus outputs) not yet collected — premature
3. Already tracked as Phase 6 candidate (P2) in the model evaluation matrix

**Alternative**: Qwen 3.6 Plus remains in the Phase 6 model evaluation matrix alongside Gemma 4 variants. Evaluate when Phase 6 begins and production pricing exists.
