# Skill Update Suggestions — 2026-04-18

**Produced by**: agentic-ai-researcher (Mode 2c, L4 Strategic Planning)
**Based on**: Deep Analysis 2026-04-18 + Discussion 2026-04-18
**Status**: **ADVISORY** — no skill files are modified by the researcher.

---

## Update 1: `steward` Skill — Opus 4.7 Delegation Prompting Hardening

**Skill**: `.claude/skills/steward/SKILL.md`
**Trigger**: Opus 4.7 "fewer subagents spawned by default" behavioral change (Analysis §1.5)
**Priority**: P2 (contingent — only apply if delegation regression detected during 4.7 rollout)

**Current state**: Steward skill uses "Use the meta-agent-factory agent to..." pattern per L13. This should override 4.7's default preference.

**Proposed change** (only if delegation drops >30% during rollout):
- Strengthen delegation instructions with explicit MUST language
- Add: "You MUST delegate skill generation to meta-agent-factory. Do NOT attempt to write SKILL.md files yourself. You MUST delegate quality validation to skill-quality-validator. Do NOT attempt to evaluate trigger rates yourself."
- Rationale: 4.7's stronger reasoning preference may cause it to believe it can do these tasks better than delegating

**Monitoring trigger**: factory-steward duration:commit ratio >2x 4.6 baseline during graduated 4.7 rollout

---

## Update 2: `agentic-ai-researcher` Agent — Add Task Budgets Research Topic

**Skill**: `.claude/agents/agentic-ai-researcher.md`
**Trigger**: Task Budgets entered public beta (Analysis §1.4); CLI availability unknown
**Priority**: P2 (add to next sweep cycle)

**Proposed change**: Add to Anthropic Track research topics table:
```markdown
| Task Budgets | docs.anthropic.com, anthropic.com/news | "task budgets" agentic, token ceiling, advisory budget |
```

**Rationale**: Task Budgets are deferred (Discussion D1) pending CLI availability verification. Adding this to the researcher's sweep topics ensures the CLI availability question is automatically checked in future sweeps rather than requiring manual investigation.

---

## Update 3: `factory-steward` Config — Cost Ceiling Window Reset

**Skill**: `.claude/skills/steward/configs/factory.yaml`
**Trigger**: New tokenizer 1.0-1.35x inflation will drift cost ceiling baselines (Analysis §3.1)
**Priority**: P2 (apply after 4.7 fleet rollout completes)

**Proposed change**: Add a task to factory.yaml for the post-4.7-rollout period:
- Reset `cost_ceiling.sh` `ROLLING_WINDOW_DAYS` from 30 to 7
- After 30 days: expand back to 30
- Rationale: prevents false cost alerts from tokenizer inflation contaminating the 30-day rolling average

---

## Update 4: `topology-aware-router` Agent — Four-Topology Reference Note

**Skill**: `.claude/agents/topology-aware-router.md`
**Trigger**: Anthropic's official four multi-agent pattern taxonomy (Analysis §2.5)
**Priority**: P3 (reference only — do NOT modify dispatch logic)

**Proposed change**: Add a reference note (NOT implementation change):
```markdown
> **Reference (2026-04-18)**: Anthropic officially documents four multi-agent patterns: Teams, Subagents, Three-Agent Harness, Orchestrator-Worker. Our current two-track (A/B) model is adequate for Phase 4. Expansion to match the four-pattern taxonomy deferred to Phase 5 §5.1 50-task benchmark, which will reveal whether our task distribution warrants 4 dispatch targets or clusters in 2-3. See `knowledge_base/agentic-ai/analysis/2026-04-18.md` §2.5 for the proposed TCI-to-pattern mapping.
```

**Rationale**: Documents the industry taxonomy alignment without prematurely changing the dispatch model. The 2026-04-17 three-track proposal and today's four-track discussion both converge on "validate against actual task distribution first."

---

## Summary

| # | Skill | Change | Priority | Condition |
|---|-------|--------|----------|-----------|
| 1 | steward | Harden delegation prompting | P2 | Only if delegation regression detected |
| 2 | agentic-ai-researcher | Add Task Budgets to research topics | P2 | Next sweep cycle |
| 3 | factory-steward config | Cost ceiling window reset task | P2 | After 4.7 rollout completes |
| 4 | topology-aware-router | Four-topology reference note | P3 | Reference only |

---

*No changes require immediate action. Updates 1 and 3 are contingent on Opus 4.7 rollout progress. Update 2 improves future research coverage. Update 4 is documentation alignment.*
