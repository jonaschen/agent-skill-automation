# Skill Update Recommendations — 2026-04-24

**Source**: Analysis 2026-04-24 + Discussion 2026-04-24
**Author**: agentic-ai-researcher (Mode 2c)

---

## No Skill Description Updates Required

Today was a post-Cloud Next normalization day. Both vendor tracks are stabilizing. Zero new Anthropic releases. Google track produced CLI v0.39.0 stable and SPIFFE deep docs — both are platform/architecture developments, not user-facing vocabulary changes that affect trigger patterns.

### Rationale

1. **Zero Anthropic releases**: CC v2.1.118, SDK v0.1.65, SDK TS v0.2.118 all remain latest. No new features that change how users describe agent creation tasks.

2. **Gemini CLI v0.39.0 features are developer-facing**: `invoke_subagent` unification, `/memory inbox`, MCP auth blocks — these are CLI internals, not user vocabulary that affects our skill triggers.

3. **A2A version resolution is metadata**: Confirming v1.0.0 (vs media-reported "v1.2") is a citation correction, not a terminology change affecting triggers.

4. **SPIFFE/Agent Identity is Phase 5 design input**: Users don't say "create a SPIFFE agent" — this doesn't enter trigger vocabulary.

5. **Discussion ADOPTs are template changes**: A1 (Unresolved Questions section), A5 (day-7 pivot rule), A6 (Continuity Notes formalization) are researcher process improvements, not skill modifications.

### Template Changes (from Discussion — not skill descriptions)

These ADOPT items modify the researcher's output format, not any skill's trigger description:

| ID | Change | Target | Effort |
|----|--------|--------|--------|
| A1 | Add `## Unresolved Questions` section to sweep file format | Sweep template | 5 min |
| A6 | Formalize `## Continuity Notes` as required section in analysis template | Analysis template | 2 min |

Both are operational improvements adopted from the discussion. They should be implemented by the factory-steward as template updates to the researcher agent definition or sweep/analysis template notes.

### Skills Monitored (No Changes Needed)

| Skill | Last Updated | Current State | Change Needed |
|-------|-------------|---------------|---------------|
| meta-agent-factory | 2026-04-13 (G8 Iter 2) | 0.95 trigger rate, 64-test suite | None |
| autoresearch-optimizer | 2026-04-06 | Specialized agent | None |
| agentic-cicd-gate | 2026-04-08 | Specialized agent | None |
| changeling-router | 2026-04-09 | 23-role library | None |
| agentic-ai-researcher | 2026-04-08 | Sweep + analysis + planning | Template changes only (A1, A6) |
| agentic-ai-research-lead | 2026-04-18 | Strategic director | Directive template note (A5) |
| steward | 2026-04-17 | 6 configs (3 active) | None |

### Potential Future Updates (Monitor, Not Actionable)

1. **Post-CC-upgrade trigger validation**: Shadow eval re-run on v2.1.118 will test trigger patterns under new runtime. SendMessage cwd fix may affect subagent routing behavior. Gated on human upgrade.

2. **Post-I/O terminology (25 days)**: ADK v2.0 GA node types, Agent Studio, Gemini Enterprise Agent Platform workflows may enter developer vocabulary. Monitor for trigger pattern impact.

3. **S3 format convergence vocabulary**: If Gemini CLI v0.40+ introduces new agent definition format terms that overlap with SKILL.md concepts, cross-domain conflict tests may need expansion.

4. **#49562 resolution**: If day 10 P2 downgrade happens (Apr 28), remove from active monitoring. If staff responds with a fix, evaluate whether thinking control features create new user vocabulary for agent requests.
