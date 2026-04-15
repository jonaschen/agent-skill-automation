# Deferred Items — 2026-04-16

Items from the 2026-04-16 discussion that were explicitly DEFERRED or REJECTED.
Documented here for reference; factory-steward should not act on these without re-evaluation.

---

## DEFERRED Items

### D1: Full Passive Skill Lifecycle (Auto-Promotion)
**Reason**: We explicitly want human review at the activation gate — our quality pipeline depends on it.
The *discovery* half (passive_case_extractor.py, proposal 2026-04-16-passive-case-extractor.md) is adopted.
The *auto-activation* half (no human review, automatic eval set promotion) is permanently deferred.
**Revisit when**: Never fully automate; keep human review at the gate.

### D2: ADK/A2A Inter-Agent Communication for Phase 5
**Reason**: Explicitly blocked until post-I/O (see proposal 2026-04-16-adk-io-decision-gate.md).
ADK v2.0 and A2A v1.1 announcements at Google I/O (May 19-20) may change the calculus entirely.
**Revisit when**: After 2026-05-20, post-I/O research sweep confirms stability.

### D3: MCP Triggers & Events as Cron Replacement
**Reason**: No working draft from Transports Working Group. Cron-based fleet is optimal for our
autonomous phase-driven work (factory-steward, android-sw-steward); event-driven is Phase 6+ for
high-frequency reaction agents (researcher). Prior analysis (2026-04-12) reached same conclusion.
**Revisit when**: 2026-05-01 or after I/O announcement.

### D4: Phase 5 External Session State Store (Crash Recovery Full Implementation)
**Reason**: Groundwork laid (`session_log.sh` exists, `workflow-state-convergence.md` written).
Full crash-recovery contract needs Phase 5 design to specify resume semantics.
TCI calibration anchors proposal (2026-04-16) documents the requirement; implementation is Phase 5.3.
**Revisit when**: Phase 5.3 design sprint.

### D5: Gemini CLI-Style Explicit Context Checkpointing for Steward Sessions
**Reason**: P3 — only needed if steward quality metrics show degradation in multi-hour sessions.
Not currently observed. Claude Code implicit compaction (PostCompact hook) handles this adequately.
**Revisit when**: If factory-steward or ltc-steward quality metrics show degradation in back-half
of multi-hour sessions.

### D6: Mythos Model (`claude-mythos-preview-*`) at Current Stage
**Reason**: No public API. Project Glasswing is invitation-only for 11 defensive cybersecurity orgs.
Nothing to implement. When public API ships, benchmark with `--model` flag (see P3 item in skill-updates).
**Revisit when**: Mythos public API announced.

### D7: ADK Parameter Manager Pattern for Phase 7
**Reason**: Phase 7 (AaaS) is 12+ months away. Credential isolation is noted as a Phase 7 security
requirement (ADK v1.30.0 Auth Provider as reference). Not urgent until Phase 7 planning begins.
**Revisit when**: Phase 7 planning sprint.

---

## REJECTED Items

### R1: TF-IDF-Based Similarity for Passive Case Extractor
**Reason**: Poor discriminative power on 10-30 word prompts; sentence-transformers adds 400MB+ dependency.
Replaced by eval-runner behavioral novelty detection in adopted proposal 2026-04-16-passive-case-extractor.md.

### R2: Adding Pending Cases Review to Factory-Steward Session Prompt
**Reason**: Creates dead code until passive_case_extractor.py ships; adds fragility to already-long
session prompt. `health_dashboard.py` is the correct integration point (5 lines of Python vs. conditional
directory check in shell prompt).

### R3: agents_registry.json as Second Canonical Source
**Reason**: Creates a second canonical source that diverges from .md files over time (maintenance tax).
The discovery-interface abstraction (2026-04-16-server-cards-discovery-interface.md) achieves the same
forward-compatibility without the maintenance tax.

### R4: Adopting Mythos at Current Invitation-Only Stage
**Reason**: No public API. Standard action: wait for public API, then benchmark with --model flag.
Adopted as P3 routine task in skill-updates-2026-04-16.md.
