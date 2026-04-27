# Skill Update Recommendations — 2026-04-28

**Source**: Analysis 2026-04-28 + Discussion 2026-04-28 + 3 sweeps
**Author**: agentic-ai-researcher (Mode 2c)

---

## No Skill Description Updates Required

Today produced two architecturally significant findings (subagent resumability, dispatch verdict) and a cluster of low-severity ops items. **None of them are user-vocabulary changes that would affect skill trigger patterns.** The deliverables are documentation, design notes, schema, and registry updates — not skill modifications.

### Rationale

1. **Subagent resumability (Finding 2)**: Developer-facing primitive (agentId + resume:sessionId). Users don't say "create a resumable agent" — this is internal architecture, not trigger vocabulary.

2. **Dispatch-primitive comparison (Finding 6)**: Comparative analysis output. Both `Agent(subagent_type=X, prompt=Y)` and `invoke_subagent(agent=X, prompt=Y)` are CLI/SDK internals, not user vocabulary that affects our skill triggers.

3. **CC v2.1.119/.120 + 8 regressions (Finding 1)**: Operational version pin advisory. Affects upgrade target (target v2.1.119, avoid v2.1.120), not skill descriptions.

4. **#49562 postmortem (Finding 4)**: Root cause of degradation explained. Resolves a 2-week investigative loop. No vocabulary impact.

5. **Task→Agent partial rename (Finding 5)**: SDK still emits both names. Code-level pattern-match fix in operational-hygiene Item 1; not a skill description change.

6. **A2A misreport recurrence (Finding 8)**: Research integrity issue. KB rebuttal note (operational-hygiene Item 3); no trigger impact.

### Discussion ADOPTs Are All Refinements (Not Skill Modifications)

| ID | Change | Target | Type |
|----|--------|--------|------|
| Adopt #1 | Inspect-Resume Phase 5.4 section | Phase 5 design index | Design artifact |
| Adopt #2 | Task↔Agent dual-name validator pass | eval/scripts/hooks code | Code-level fix |
| Adopt #3 | Canonical skill schema | tools/dispatch-transpiler/ | New artifact |
| Adopt #4 | CC version advisory section | model_migration_runbook.md | Documentation |
| Adopt #5 | A2A misreport rebuttal note | google-deepmind/a2a-protocol.md KB | Documentation |
| Adopt #6 | I/O Sensitivity registry update | Phase 5 design index | Registry update |
| Adopt #7 | S2 paper anchor surfacing | agent_review.sh dashboard | Tooling |

None modify a skill's `description` field or trigger pattern.

### Skills Monitored (No Changes Needed)

| Skill | Last Updated | Current State | Change Needed |
|-------|-------------|---------------|---------------|
| meta-agent-factory | 2026-04-13 (G8 Iter 2) | 0.95 trigger rate, 64-test suite | None |
| autoresearch-optimizer | 2026-04-06 | Specialized agent | None |
| agentic-cicd-gate | 2026-04-08 | Specialized agent | None |
| changeling-router | 2026-04-09 | 23-role library | None |
| agentic-ai-researcher | 2026-04-08 | Sweep + analysis + planning | None |
| agentic-ai-research-lead | 2026-04-18 | Strategic director | None |
| steward | 2026-04-17 | 6 configs (3 active) | None |

### Potential Future Updates (Monitor, Not Actionable)

1. **Post-CC-v2.1.119-upgrade trigger validation**: When Jonas upgrades, shadow eval re-run will test trigger patterns under new runtime. SDK still emits both `"Task"` and `"Agent"` for dispatch — operational-hygiene Item 1 closes the latent code-level bug, not a skill description issue. No description change anticipated.

2. **Post-Gemini-CLI-install trigger validation**: When Gemini CLI installed, the canonical skill schema's round-trip test runs against existing 23 Claude agents. If round-trip reveals semantic ambiguity in some skill descriptions (e.g., wildcards confusing the schema), targeted skill description tweaks may follow. Speculative.

3. **Post-I/O terminology (21 days)**: ADK v2.0 GA, A2A v1.1 (if shipped), Gemini 4 may introduce vocabulary that creates new cross-domain conflict cases for `meta-agent-factory`. Monitor for trigger pattern impact.

4. **Inspect-Resume vocabulary**: If "inspect-resume" or "pause-resume" enters user vocabulary as a request pattern (e.g., "create an agent that supports inspect-resume"), `meta-agent-factory` description may need extension. Speculative — current usage is Phase 5 design only.

5. **Subagent resumability vocabulary**: Same as #4. If users start saying "create a resumable subagent," watch for trigger ambiguity. Currently zero signal.

---

## Researcher Process Improvements (Not Skill Updates)

These were not adopted as discussion items today, but the analysis surfaced operational improvements worth noting for future researcher cycles:

- **Documentation lag at both vendors** (CP3 in analysis): Both Anthropic (v2.1.120 silent release) and Google (gemini-cli web changelog 4 days behind tags) are shipping faster than rendered docs. Researcher's existing practice (use `gh api` + `npm view` as authoritative) is the correct posture. No process change needed.
- **Postmortem cadence as a signal channel**: The Apr 23 #49562 postmortem is the third public Anthropic postmortem this year. Press articles (VentureBeat, Yahoo Finance) often surface the explanation faster than the GitHub issue itself. Researcher's existing practice (treat press as secondary source) is fine.

Both are reinforcements of existing discipline, not new procedure.
