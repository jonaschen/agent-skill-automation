# Skill Update Recommendations — 2026-04-23 (Night)

**Source**: Analysis 2026-04-23-night + Discussion 2026-04-23-night
**Author**: agentic-ai-researcher (Mode 2c)

---

## No Skill Description Updates Required

Tonight's sweep was dominated by Cloud Next 2026 announcements and CC v2.1.118 release. These are platform-level developments that affect Phase 5 architecture and design references, not current skill trigger patterns.

### Rationale

1. **CC v2.1.118 features are additive**: MCP tool hooks, vim mode, themes, merged /usage — none of these change how users describe agent creation tasks. No trigger pattern impact.

2. **Cloud Next terminology**: "Gemini Enterprise Agent Platform" replaces "Vertex AI" in our KB but is not a term users would type when requesting skill creation. No trigger pattern impact.

3. **SDK v0.1.65 changes are API-level**: ThinkingConfig.display, ServerToolUseBlock surfacing, SessionStore batch summaries — these are developer API changes, not user-facing vocabulary that affects trigger descriptions.

4. **Eval suite expanded**: G20 (test_60-64 MCP false-positive tests) was implemented in the afternoon factory session. Suite now at 64 tests (T=44, V=20). No skill description changes needed — the tests validated that current descriptions already correctly reject MCP ecosystem prompts.

5. **ADOPT throttle**: 2 net-new ADOPTs tonight (A1 MCP hooks design note, A2 Cloud Next governance mapping). Both are design documents, not skill modifications. Factory queue at ~17 items.

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

1. **Post-CC-upgrade trigger validation**: After Jonas upgrades to CC v2.1.118, the shadow eval re-run will test trigger patterns under the new runtime. If SendMessage cwd fix or agent-type hooks fix changes routing behavior, skill descriptions may need adjustment. Gated on human upgrade action.

2. **Post-I/O terminology (26 days)**: Google I/O may introduce new agent framework terminology ("Agent Studio", "Gemini Enterprise Agent Platform" workflows, ADK v2.0 GA node types) that enters developer vocabulary. If users start requesting "create an Agent Studio skill" or "build an ADK node", meta-agent-factory's description may need new trigger patterns or exclusions.

3. **A2A v1.2 vocabulary**: If A2A v1.2 introduces new inter-agent concepts beyond current Agent Card vocabulary, cross-cutting skills may need terminology updates. Monitor for tagged GitHub release.

4. **MCP tool hooks vocabulary**: CC v2.1.118's `type: "mcp_tool"` hook type creates a new concept. If users start requesting "create a hook that calls an MCP tool" or "build an MCP tool hook skill", we may need to distinguish this from meta-agent-factory's scope. Low probability — MCP tool hooks are developer configuration, not agent creation.

### Researcher Agent — Operational Note

The `agentic-ai-researcher.md` agent definition's event-driven sweep queries section already includes Google I/O tracking queries (added 2026-04-08). No update needed. Cloud Next findings are captured in the KB files updated during this sweep (7 Google/DeepMind files + 6 Anthropic files).
