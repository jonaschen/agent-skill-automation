# ROADMAP Update Recommendations — 2026-04-24

**Source**: Analysis 2026-04-24 + Discussion 2026-04-24 + Sweep 2026-04-24
**Author**: agentic-ai-researcher (Mode 2c)

---

## PROPOSED CHANGE 1: Update ROADMAP Status Line

**Section**: Top-level status paragraph
**Priority**: P1
**Rationale**: Day counts updated. A2A version divergence resolved (v1.0.0 confirmed, media "v1.2" was incorrect). Gemini CLI v0.39.0 stable released. Eval suite stable at 64 tests.

**Current** (excerpt):
> Status as of 2026-04-23 (night factory session): ...Countdowns: 1M context beta sunset 7d (Apr 30), Google I/O 26d (May 19-20)...

**Proposed update** (next factory session):
> Status as of 2026-04-24: Phase 4 core complete. Eval suite at 64 tests (T=44, V=20). Shadow eval NO-GO for claude-opus-4-7 (0.683) — awaiting CC upgrade to v2.1.118. A2A version confirmed v1.0.0 (media "v1.2" was incorrect — TheNextWeb error). Gemini CLI v0.39.0 stable released — S3 comparison target available. 8/10 DEPLOYED (80%), 0.95 uniform trigger rate. Countdowns: 1M context beta sunset 6d (Apr 30), Google I/O 25d (May 19-20), Phase 4 deadline 15d (May 9). Factory queue ~15 items (~4-5 sessions to clear).

---

## PROPOSED CHANGE 2: A2A Version Clarification in Phase 5

**Section**: Phase 5 A2A hold section
**Priority**: P1
**Rationale**: Analysis Finding 5 — triple verification (GitHub, a2a-protocol.org, spec content) confirms A2A is v1.0.0. TheNextWeb's "v1.2" was incorrect reporting. Signed agent cards are v1.0.0 features. The prior ROADMAP update (2026-04-23-night Change 8) added a version divergence tracking note that should now be replaced with the resolution.

**Proposed update** to Phase 5 A2A hold section — replace Change 8 note with:
```
> **A2A version confirmed (2026-04-24)**: Triple-verified — GitHub tag v1.0.0, a2a-protocol.org spec v1.0.0, signed agent cards documented as v1.0.0 features. TheNextWeb "v1.2" reporting was incorrect. Gate-removal criterion (2) references "A2A v1.1 wire format" — if no v1.1 ships at I/O, reassess whether v1.0.0 is sufficient for Phase 5 inter-agent communication. Phase 5 design notes should cite A2A v1.0.0 as canonical version.
```

---

## PROPOSED CHANGE 3: Phase 5 Design Index — I/O Sensitivity Section

**Section**: Phase 5.6 Design Freeze
**Priority**: P1
**Rationale**: Discussion A4 — I/O is T-25 days. Analysis Threat T3 identifies 4+ concurrent I/O signals (ADK v2.0 GA, A2A updates, Gemini 4, CLI format changes). A pre-built assumptions checklist enables systematic triage instead of ad-hoc response. Adopted as section within Phase 5 design index (factory P1 item #1), not standalone file.

**Proposed addition** to Phase 5 design freeze section or Phase 5 design index:
```
> **I/O Sensitivity (2026-04-24)**: Phase 5 design assumptions that may change at Google I/O (May 19-20). Format: assumption | current value | dependent design note | impact if changed.
> - A2A version: v1.0.0 | Phase 5.2, 5.3 | If v1.1+ ships, review signed agent card implementation + wire format changes
> - ADK Workflow API: v2.0.0b1 (BaseNode) | Phase 5 TCI comparison framework | If v2.0 GA changes node API, rewrite comparison
> - Gemini CLI agent format: v0.39.0 Skills | S3 format comparison matrix | If v0.40+ changes skill format, redo comparison
> - MCP tool hooks: CC v2.1.118 `type: "mcp_tool"` | S1 design note (factory P3 #14) | If hooks API changes, revisit design note
> - Gemini model: Gemini 2.5 Pro | eval assumption registry | If Gemini 4 announced, update assumption registry + edge readiness (Phase 6)
```

---

## PROPOSED CHANGE 4: Phase 5 Security — Layered Auth+Authz Design Reference

**Section**: Phase 5.3 or Phase 5.5 security
**Priority**: P1
**Rationale**: Discussion A3 + Analysis CP3 — Anthropic does authorization (what can an agent do?), Google does authentication (who is this agent?). Neither vendor combines both. Our Phase 5 should layer: per-agent identity (lightweight SPIFFE equivalent — GPG keys for git commits) atop existing `check-permissions.sh` tool authorization. This combined model is novel and citable in S2 paper.

**Proposed design note** (add to Phase 5 security section):
```
> **Design note (2026-04-24)**: Layered security model — authentication + authorization. Anthropic's model = authorization (tool allow-lists, `check-permissions.sh`, mutually exclusive permission classes). Google's model = authentication (SPIFFE IDs, X.509 certs, DPoP token binding, Auth Manager). Neither vendor combines both. Phase 5 design should layer: agent identity (authentication) atop permission scoping (authorization). For our local fleet scale: per-agent GPG keys for git commit attribution (lightweight identity) + existing permission infrastructure (authorization). For cloud deployment (Phase 7): evaluate SPIFFE/X.509 (CNCF standard, not Google-proprietary). This combined model doesn't exist in either vendor's published framework — citable in S2 paper governance section. Reference: SPIFFE architecture in `knowledge_base/agentic-ai/google-deepmind/vertex-ai-agents.md`, permission design in `knowledge_base/agentic-ai/evaluations/permission-cache-design.md`.
```

---

## PROPOSED CHANGE 5: S3 Format Comparison Sharpening

**Section**: Strategic Research Themes / S3 or Phase 5.3 design notes
**Priority**: P2
**Rationale**: Discussion A2 + Analysis CP1 — Both vendors independently converged on a unified sub-agent dispatch primitive: Claude Code `Agent(subagent_type=X, prompt=Y)` and Gemini CLI `invoke_subagent(agent=X, prompt=Y)`. This convergence should be the centerpiece of the S3 format comparison. Refines existing factory queue P2 item #6 — no new queue entry.

**Proposed update** to S3 section or factory queue item #6 description:
> S3 format comparison should focus on **dispatch-primitive comparison** as the narrowest feasibility test. Both vendors converged on `dispatch(type, prompt) → result` semantics. If dispatch is portable, the remaining S3 format differences (identity, description, tool permissions) become tractable as transpiler problems. If dispatch semantics diverge, S3 needs a different architecture. Compare: `Agent(subagent_type, prompt)` vs `invoke_subagent(agent, prompt)` — parameter naming, return type, error handling, context inheritance, tool permission propagation. This is citable as convergent evolution in the S2 paper.

---

## PROPOSED CHANGE 6: Human Action Blocker Day-7 Pivot Rule

**Section**: General operational protocol (Phase 4 or research pipeline notes)
**Priority**: P3
**Rationale**: Discussion A5 — After 7 days of unresolved human blockers, research-lead should switch from escalation to work-around strategies in the next directive. For S3 specifically: documentation-based `invoke_subagent` vs `Agent` comparison can proceed without CLI install. For shadow eval: fully instrumented, nothing more possible until upgrade.

**Proposed note** (for directive template or ROADMAP operational section):
> **Day-7 pivot rule (2026-04-24)**: When a human action item remains unresolved for 7+ days, the research-lead directive should pivot from escalation to work-around strategies. Example: S3 Gemini CLI install blocked day 7+ → directive instructs documentation-based format comparison instead of waiting. This prevents repeated escalation from becoming noise.

---

## No New Risks Identified

Existing risks accurately calibrated. Key updates:
- A2A version divergence: **RESOLVED** — v1.0.0 confirmed. Remove from risk tracking.
- Gemini CLI blocker: **May lift** — v0.39.0 stable released. Re-escalated as human action.
- #49562: Day 8. Approaching P2 downgrade threshold (day 10, Apr 28).
- I/O readiness: T-25 days. I/O Sensitivity section proposed (Change 3).
- Factory queue: ~15 items, healthy. 0 net-new ADOPTs this cycle.

## Day Counts (for next status update)

| Item | Days | Date |
|------|------|------|
| CC v2.1.118 release | 1 | Apr 23 |
| CC upgrade blocker | 5+ | human action |
| Gemini CLI blocker | 7+ | human action |
| Opus 4.7 | 8 | Apr 16 |
| #49562 (no staff response) | 8 | Apr 16 |
| #49562 P2 downgrade threshold | 10 | Apr 28 |
| 1M context beta sunset | 6 | Apr 30 |
| Phase 4 deadline | 15 | May 9 |
| Google I/O | 25 | May 19-20 |
| Opus 4/Sonnet 4 retirement | 52 | Jun 15 |
