# ROADMAP Update Recommendations — 2026-04-23 (Night)

**Source**: Analysis 2026-04-23-night + Discussion 2026-04-23-night + Sweep 2026-04-23-night
**Author**: agentic-ai-researcher (Mode 2c)

---

## PROPOSED CHANGE 1: Update ROADMAP Status Line

**Section**: Top-level status paragraph
**Priority**: P1
**Rationale**: CC v2.1.118 shipped (breaking the quiet period), Cloud Next 2026 rebranded Vertex AI to Gemini Enterprise Agent Platform, eval suite expanded to 64 tests. Status paragraph references stale version (v2.1.117).

**Current** (excerpt):
> Status as of 2026-04-23 (night factory session): ...Shadow eval NO-GO for claude-opus-4-7 (0.683, CI [0.535, 0.814]) — awaiting clean re-run after CC upgrade...

**Proposed update** (next factory session):
> CC v2.1.118 shipped Apr 23 — MCP tool hooks, SDK v0.1.65 thinking display, 8+ OAuth fixes. Google Cloud Next 2026 rebranded Vertex AI to Gemini Enterprise Agent Platform (SPIFFE identity, governance stack, managed MCP servers, outcome-based pricing). P0 human action: upgrade CC to v2.1.118 (was v2.1.117). Factory queue ~17 items.

---

## PROPOSED CHANGE 2: Update P0 Human Action — CC Version

**Section**: Phase 4.4 / General references
**Priority**: P0
**Rationale**: CC v2.1.118 is now the target version (was v2.1.117). Shadow eval re-run should use v2.1.118 which includes MCP tool hooks + SendMessage cwd fix + agent-type hooks fix. The version change was flagged as correction C1 in the discussion.

**Action**: Update all references from "v2.1.117" to "v2.1.118" in:
- ROADMAP status line
- Any directive references to the P0 human action item
- `fleet_min_version.txt` should be bumped to >=2.1.118 at next factory session

---

## PROPOSED CHANGE 3: Phase 5 — Cloud Next Governance Reference

**Section**: Phase 5 Tasks
**Priority**: P2
**Rationale**: Google Cloud Next 2026 revealed the most complete enterprise multi-agent governance framework published: Agent Identity (SPIFFE), Agent Gateway, Agent Registry, Agent Observability, Model Armor. This is a concrete design reference for Phase 5 subsystems. Discussion A2 adopted this as a design note.

**Proposed addition** (to Phase 5 tasks, when Phase 5 section is expanded):
```
#### 5.X Cloud Next Design References (pre-I/O)
- [ ] **Cloud Next → Phase 5 governance mapping**: Map Gemini Enterprise Agent Platform governance components (Identity, Gateway, Registry, Observability, Model Armor) to Phase 5 subsystems. Include "relevance for our scale" assessment column. Add SPIFFE paragraph to Phase 5 security design. Source: discussion 2026-04-23-night A2 — P2
```

---

## PROPOSED CHANGE 4: Phase 5 Security — SPIFFE Agent Identity Reference

**Section**: Phase 5 (security subsystem)
**Priority**: P2
**Rationale**: Finding 6 — Google's SPIFFE-based Agent Identity is the first production cryptographic identity system for agents. Our Phase 5 design has no agent identity model. Discussion Round 6 adopted a paragraph-level addition to Phase 5 security design (bundled with governance mapping note).

**Proposed addition** (bundled into Change 3 document):
> Phase 5 security design should evaluate SPIFFE-based agent identity or equivalent as the reference standard for inter-agent delegation. For our current scale (7 agents, cron-orchestrated), process identity via PID + CLAUDE.md is sufficient. However, Phase 5 dynamic agent spawning via SDK would require cryptographic identity. SPIFFE is CNCF standard — cloud-native-compatible, not Google-proprietary.

---

## PROPOSED CHANGE 5: S3 Tool Portability — Formal Downgrade to Tracking

**Section**: Strategic Research Themes / S3
**Priority**: P2
**Rationale**: Finding 7 — Both vendors simultaneously deepened MCP integration on Apr 22-23 (Anthropic: MCP tool hooks in CC v2.1.118; Google: managed MCP servers + Apigee bridge at Cloud Next). S3 tool portability is now confirmed converging from both directions. Discussion Round 7 consensus: move S3 tool access from "active research" to "one-sentence monitoring." Remaining S3 gaps: agent definition format + orchestration protocol.

**Proposed text** (for `strategic-priorities.md` S3 section update):
> **S3 Problem Decomposition Update (2026-04-23)**: Tool portability via MCP now confirmed solved for major vendors — Anthropic CC v2.1.118 MCP tool hooks + Google Cloud Next managed MCP servers + Apigee bridge, both shipping within 24h of each other. Tool access monitoring moves to one-sentence-per-sweep. Remaining S3 research surface: agent definition format (SKILL.md vs Gemini Skills vs ADK BaseNode) and orchestration protocol (SDK subagents vs ADK vs A2A). Four agent definition paradigms now tracked: CC SKILL.md, Gemini CLI Skills, ADK v2.0 BaseNode, A2A Agent Card.

---

## PROPOSED CHANGE 6: Update "Vertex AI" References

**Section**: Multiple Phase 5 design documents
**Priority**: P3
**Rationale**: Google rebranded Vertex AI to "Gemini Enterprise Agent Platform" at Cloud Next 2026. All Phase 5 and KB references using "Vertex AI" for agent platform context need updating. This is a terminology correction, not a design change. Discussion DR2.

**Files to update** (factory steward task, not ROADMAP change):
- `knowledge_base/agentic-ai/google-deepmind/vertex-ai-agents.md` (already updated in sweep)
- Phase 5 design documents referencing "Vertex AI" as an agent platform
- `fleet_manifest.json` if it references Vertex AI
- TCI comparison framework document

---

## PROPOSED CHANGE 7: Fleet Minimum Version Bump to >=2.1.118

**Section**: Phase 4.4 (fleet version)
**Priority**: P1
**Rationale**: CC v2.1.118 includes: MCP tool hooks, SendMessage cwd restoration fix (affects subagent routing), agent-type hooks "Messages are required" fix, prompt hooks re-firing fix on verifier subagent tool calls, 8+ MCP OAuth fixes. The cwd fix is operationally relevant — our pipeline uses SendMessage for subagent delegation.

**Proposed addition** to Phase 4.4:
```
- [ ] **Fleet minimum version bump to >=2.1.118**: CC v2.1.118 adds MCP tool hooks, SendMessage cwd restoration for subagents, agent-type hooks fix, prompt hooks verifier fix, 8+ MCP OAuth fixes. SendMessage cwd fix is operationally relevant for subagent routing. Human upgrade pending (P0) — P1
```

---

## PROPOSED CHANGE 8: A2A Version Divergence Tracking

**Section**: Phase 5 (A2A hold section)
**Priority**: P2
**Rationale**: Cloud Next announced A2A "upgrade" with signed agent cards and 50+ enterprise partners. TheNextWeb reports "A2A Protocol v1.2" but GitHub still shows v1.0.0 tagged release (verified via gh api). Spec version and GitHub tag are now divergent. This affects the Phase 5 gate-removal criteria which references "A2A v1.1 wire format."

**Proposed update** to Phase 5 A2A hold section:
```
> **A2A version note (2026-04-23)**: Cloud Next announced A2A upgrades including signed agent cards and 50+ enterprise partners. Press reports A2A v1.2; GitHub release tag remains v1.0.0. Gate-removal criterion (2) should reference the actual tagged release version, not press-reported version. Monitor for tagged release matching Cloud Next capabilities.
```

---

## No New Risks Identified

Existing risks remain accurately calibrated:
- ADK v2.0 beta instability → mitigated by post-I/O hold (unchanged)
- #49562 token burn → day 7, downgrade to P2 if silent by Apr 28 (unchanged)
- Factory queue → ~17 items after tonight's +2, below 20 alert threshold
- Cloud Next announcements are design references, not operational threats

## Day Counts (for next status update)

| Item | Days | Date |
|------|------|------|
| CC v2.1.118 | 0 (today) | Apr 23 |
| Opus 4.7 | 7 | Apr 16 |
| #49562 | 7 (no staff response) | Apr 16 |
| Phase 4 deadline | 16 | May 9 |
| Google I/O | 26 | May 19-20 |
| Opus 4/Sonnet 4 retirement | 53 | Jun 15 |
