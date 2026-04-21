# Post-Google I/O Response Playbook

**Created**: 2026-04-12
**Event**: Google I/O 2026 (May 19-20)
**Phase 4 Deadline**: May 9, 2026 (10 days before I/O)
**I/O Monitoring Window**: April 25 - May 20, 2026

## Purpose

Maps expected Google I/O announcement categories to pipeline response actions,
preventing reactive scrambling. Organized by announcement *category* (not specific
predictions) since exact product names may differ from expectations.

---

## Pre-I/O Preparation Checklist (by May 9)

- [ ] Phase 4 stress test complete (50-skill closed loop)
- [ ] Knowledge base snapshot: `git tag pre-io-snapshot-2026-05-09` on this repo
- [ ] Researcher agent: verify I/O-specific sweep queries active (ADK, Gemini, A2A)
- [ ] All eval baselines current: `scripts/regression_test.sh --update-baseline`
- [ ] ROADMAP Phase 4 status finalized — all tasks marked complete or explicitly deferred

**Intelligence note (2026-04-22)**: Google Deep Research (Apr 21) shipped as API-only
(Interactions API), not Agent Builder. I/O announcements may follow this API-first
pattern. Monitor Gemini API changelog alongside Agent Builder release notes.

## I/O Day Actions (May 19-20)

- [ ] Manual researcher trigger: `./scripts/daily_research_sweep.sh` after keynote
- [ ] Second manual trigger after Day 2 developer sessions if major announcements
- [ ] Factory steward: I/O-WATCH mode active (log observations, no implementation)

---

## Response Matrix by Announcement Category

### Category 1: New Foundation Model Release
**Expected**: Gemini 4, Gemini 3.5 Pro, or similar
**Affects**: Eval model targets, knowledge base, Phase 6 edge model candidates

| Action | Owner | Priority | Timeline |
|--------|-------|----------|----------|
| Update `knowledge_base/agentic-ai/google-deepmind/` with model capabilities | researcher | P0 | Day 1 |
| Evaluate as eval runner model (cost vs. accuracy tradeoff) | factory-steward | P1 | Week 1 |
| Update Phase 6 edge model targets if new small models announced | factory-steward | P2 | Week 2 |
| Run model migration runbook (`eval/model_migration_runbook.md`) if adopting | factory-steward | P1 | Week 2 |
| Update `eval/deprecated_models.json` if older models deprecated | researcher | P0 | Day 1 |

### Category 2: Agent Framework Version (ADK v2.0 GA/beta)
**Expected**: ADK v2.0 GA or expanded beta
**Affects**: Phase 5 topology design, A2A integration, TCI router

| Action | Owner | Priority | Timeline |
|--------|-------|----------|----------|
| Update `knowledge_base/agentic-ai/google-deepmind/adk-*.md` | researcher | P0 | Day 1 |
| Validate Phase 5 topology-aware-router alignment with ADK patterns | factory-steward | P1 | Week 1 |
| Update workflow convergence note with any new ADK state patterns | factory-steward | P2 | Week 2 |
| Re-evaluate lazy scan dedup if ADK v2.0 changes approach | factory-steward | P3 | Week 3 |

### Category 3: Inter-Agent Protocol Update (A2A v1.1)
**Expected**: A2A v1.1 with SDK improvements, possibly new transport
**Affects**: Phase 5.3 scrum-team-orchestrator, A2A bus design

| Action | Owner | Priority | Timeline |
|--------|-------|----------|----------|
| Update `knowledge_base/agentic-ai/evaluations/a2a-sdk-eval.md` | researcher | P0 | Day 1 |
| Re-evaluate A2A SDK integration patterns for our 6-message bus | factory-steward | P1 | Week 1 |
| Update ROADMAP Phase 5.3.0 with new SDK details | factory-steward | P1 | Week 1 |
| Begin A2A SDK evaluation (was deferred to post-I/O) | factory-steward | P2 | Week 2-3 |

### Category 4: Platform Rebrand / Restructure
**Expected**: "AI Applications" rebrand, Vertex AI Agents restructure
**Affects**: Knowledge base organization, deployment target evaluation

| Action | Owner | Priority | Timeline |
|--------|-------|----------|----------|
| Rewrite affected KB files to reflect new naming/structure | researcher | P1 | Week 1 |
| Evaluate as Phase 7 deployment target if new managed agent service | factory-steward | P2 | Week 2 |
| Update ROADMAP Phase 7 deployment targets if applicable | factory-steward | P3 | Week 3 |

### Category 5: Edge/On-Device Model Release
**Expected**: Gemma 4 updates, new small models, on-device tooling
**Affects**: Phase 6 edge model targets, inference SLA planning

| Action | Owner | Priority | Timeline |
|--------|-------|----------|----------|
| Update Phase 6 edge model candidates and inference benchmarks | researcher | P1 | Week 1 |
| Re-evaluate EAGLE3 / MTP compatibility if runtime changes | factory-steward | P2 | Week 2 |
| Update `eval/edge_readiness.py` model size thresholds if needed | factory-steward | P3 | Week 3 |

### Category 6: MCP / Tool Use Protocol Changes
**Expected**: MCP spec updates, new Google MCP servers
**Affects**: MCP security scanning, tool definition pinning

| Action | Owner | Priority | Timeline |
|--------|-------|----------|----------|
| Update `knowledge_base/agentic-ai/` with protocol changes | researcher | P0 | Day 1 |
| Validate `mcp_config_validator.sh` against new patterns | factory-steward | P1 | Week 1 |
| Update MCP server allowlist if new official servers | factory-steward | P1 | Week 1 |

---

## Post-I/O Stabilization (May 21-31)

1. **Diff against snapshot**: `git diff pre-io-snapshot-2026-05-09..HEAD -- knowledge_base/`
2. **Validate no regressions**: `scripts/regression_test.sh`
3. **Close I/O monitoring window**: Update ROADMAP status, remove I/O-WATCH tags
4. **Prioritize unblocked Phase 5 tasks**: A2A evaluation, topology validation
5. **Update this playbook**: Record what actually happened vs. predictions for future events
