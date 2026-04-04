# Skill Update Recommendations — 2026-04-05

**Author**: agentic-ai-researcher (Mode 2c: Strategic Planning)
**Input**: Analysis 2026-04-05, Discussion 2026-04-05

---

## 1. meta-agent-factory — MCP Allowlist Instruction (P1, ADOPT)

**Current state**: Generates `.mcp.json` configs for Skills that reference MCP servers. No awareness of server trustworthiness.

**Proposed change**: Add one sentence to `.claude/agents/meta-agent-factory.md` instructions:

> "When generating .mcp.json configs, prefer servers from eval/mcp_server_allowlist.json and include a `// WARNING: Server not in allowlist — validate tool descriptions before deploying` comment for servers not on the list."

**Rationale**: MCP tool poisoning is P0. The factory is the entry point for MCP configs into our pipeline. A one-sentence instruction costs zero context budget and establishes the allowlist pattern.

**Risk**: The meta-agent-factory description is already dense (550 chars). Adding allowlist logic risks pushing past the model's instruction-following threshold. Keep to ONE sentence. Do NOT add detailed scanning logic to the factory — that belongs in the CI/CD gate.

**Discussion verdict**: ADOPT P1 — "Keep it to one sentence" (Engineer, Round 1)

---

## 2. agentic-cicd-gate — Content Validation Awareness (P1)

**Current state**: References `mcp_config_validator.sh` for JSON structure validation. Not aware of content-level scanning.

**Proposed change**: Update `.claude/agents/agentic-cicd-gate.md` to reference the expanded MCP validation:

> After structural MCP validation, the gate also runs content scanning for tool description injection patterns, length limits, and credential keywords. Servers on the allowlist (`eval/mcp_server_allowlist.json`) bypass content scanning.

**Rationale**: The CI/CD gate agent needs to know about the expanded validation to correctly interpret and report results.

**Risk**: Low — this is documentation of existing pipeline behavior, not a capability change.

---

## 3. agentic-ai-researcher — Updated Sweep Focus (P1)

**Current state**: Sweep focus list in agent definition covers broad Anthropic + Google topics.

**Proposed change**: Add to the researcher's priority watch list (either in agent definition or as a persistent note):

- **Capybara/Mythos broader access** — immediate eval re-baseline trigger
- **MCP tool poisoning mitigations** — community responses, spec-level defenses
- **MCP SDK V2 alpha drop** — highest-risk near-term protocol event (71+ day freeze)
- **Agent payment protocol convergence** — which protocol(s) gain enterprise traction
- **Gemini CLI hooks/eval additions** — tracks erosion of our competitive moat

**Rationale**: Analysis section 7 ("Next Analysis Focus") identifies these as the highest-priority tracking items. Embedding them in the researcher's persistent state ensures they're covered in every sweep.

**Risk**: Low — additive, doesn't modify existing tracking topics.

---

## 4. autoresearch-optimizer — Model Migration Awareness (P2)

**Current state**: Optimizes descriptions against the current model (Opus 4.6). No awareness that model changes could invalidate optimized descriptions.

**Proposed change**: When the model migration runbook is created, add a cross-reference:

> "If a new Claude model is released (e.g., Opus 4.7, Capybara/Mythos), descriptions optimized for the previous model should be re-evaluated before further optimization. See `eval/model_migration_runbook.md`."

**Rationale**: The optimizer could waste iterations optimizing against a stale model baseline. A runbook reference ensures the operator checks model compatibility first.

**Risk**: Low — informational addition only.

---

## 5. factory-steward — ADOPT Items as Action Queue (P0-P1)

**Current state**: The factory-steward implements ADOPT items from research discussions.

**Proposed change**: The discussion's "Action Items for factory-steward" section (6 items, priority-ordered) should be the factory-steward's next work queue:

1. **P0**: MCP content validator extension
2. **P1**: Dependency pinning (`pip freeze` + `npm audit`)
3. **P1**: Allowlist instruction in meta-agent-factory
4. **P1**: Model migration runbook creation
5. **P2**: Closed-loop state machine refactor
6. **P2**: ROADMAP task 7.7 + risk entries

**Rationale**: This is the standard handoff from researcher (L4 planning) to factory-steward (L5 implementation). The discussion already prioritized and scoped each item.

**Risk**: The factory-steward's next session (tonight 9pm or tomorrow noon) will pick these up. No structural change needed to the agent — just queue awareness.

---

## No Updates Recommended

The following agents were evaluated and need NO changes at this time:

| Agent | Reason |
|-------|--------|
| `skill-quality-validator` | No new validation patterns needed beyond what the CI/CD gate handles |
| `changeling-router` | No new role definitions triggered by today's findings |
| `topology-aware-router` | Phase 5 not active; A2A evaluation is pre-implementation research |
| `android-sw-steward` | No Android/AOSP-specific findings today |
| `arm-mrs-steward` | No ARM architecture findings today |
| `bsp-knowledge-steward` | No BSP/kernel findings today |
| `project-reviewer` | No process changes needed |
