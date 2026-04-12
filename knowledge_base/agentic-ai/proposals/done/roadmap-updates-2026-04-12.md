# ROADMAP Update Recommendations — 2026-04-12

**Source**: Analysis 2026-04-12 + Discussion 2026-04-12
**Author**: agentic-ai-researcher (Mode 2c: Strategic Planning)

---

## PROPOSED CHANGE 1: Bump fleet_min_version.txt to >=2.1.101

**Section**: Phase 4.4 (Security Hardening)
**Priority**: P1
**Action**: Add new completed task after the existing `>=2.1.98` entry

```markdown
- [x] **Fleet minimum version bump to >=2.1.101**: Updated `fleet_min_version.txt`. v2.1.101 adds memory leak fix (historical message copies in long sessions), `permissions.deny` override protection, subagent MCP tool inheritance, and POSIX `which` command injection fix. Dashboard enhanced with version status display and days-since-escalation counter. Human upgrade pending — P1 ✅ 2026-04-12
```

**Justification**: Three security-relevant fixes over v2.1.98 (already in ROADMAP). The
memory leak fix is operationally critical for multi-hour steward sessions.

---

## PROPOSED CHANGE 2: Add session state logging task to Phase 4.3

**Section**: Phase 4.3 (Observability)
**Priority**: P2
**Action**: Add new task

```markdown
- [ ] **Structured session event logging**: Create `scripts/lib/session_log.sh` — shared library with `log_event(agent, event_type, payload)` writing append-only JSONL to `logs/sessions/{agent}-{date}.jsonl`. Event types: TASK_START, TASK_COMPLETE, TASK_SKIP, ERROR, CHECKPOINT. Integrate into all 7 daily scripts. Foundation for Phase 5.3.2 task-level workflow state tracking. Crash-recovery-on-resume deferred to Phase 5 — P2
```

**Justification**: Provides structured observability data for project-reviewer and
establishes the event log format that Phase 5.3.2 will build upon. Informed by Managed
Agents append-only Session log pattern.

---

## PROPOSED CHANGE 3: Add lazy provisioning task to Phase 4.3

**Section**: Phase 4.3 (Observability)
**Priority**: P2
**Action**: Add new task

```markdown
- [ ] **Researcher lazy provisioning**: Add GitHub API pre-flight to `daily_research_sweep.sh` — check tracked repos (claude-code, agent-sdk, A2A, adk-python) for new releases since last sweep. Skip full Claude session if no new releases; write SKIP performance JSON. Add consecutive-skip counter to all performance JSONs — alert if any agent skips >3 consecutive runs. Steward lazy provisioning deferred until event-driven activation exists — P2
```

**Justification**: Strongest ROI candidate for lazy provisioning. Clear skip criteria,
30-60 minute sessions saved on quiet days. Informed by Managed Agents 60% TTFT reduction
from lazy container provisioning.

---

## PROPOSED CHANGE 4: Add hybrid scheduling design note to Phase 5.4

**Section**: Phase 5.4 (Watchdog Circuit Breaker) — or create Phase 5.4.1
**Priority**: P3
**Action**: Add design note after Phase 5.4 tasks

```markdown
> **Design note (2026-04-12)**: Agent classification for future hybrid scheduling (cron + event triggers). Event-reactive agents (activate on external events): `agentic-ai-researcher` (new releases), `arm-mrs-steward` (ARM spec updates), `bsp-knowledge-steward` (Linux kernel/ARM TRM releases). Schedule-driven agents (periodic autonomous work): `factory-steward` (ROADMAP advancement), `project-reviewer` (quality audits), `ltc-steward` (phase work). Hybrid agents (both): `android-sw-steward` (AOSP tracking + phase work). MCP Triggers & Events (spec expected ~June 2026) is the target transport for event-driven activation. Full design document deferred until spec draft appears.
```

**Justification**: Captures the agent classification while it's fresh. Avoids premature
design doc that would need rewriting when the MCP spec lands.

---

## PROPOSED CHANGE 5: Add credential isolation to Phase 5.3 requirements

**Section**: Phase 5.3 (`scrum-team-orchestrator` agent + A2A bus)
**Priority**: P1 (for Phase 5 design; P2 for current implementation)
**Action**: Add design note

```markdown
> **Security requirement (2026-04-12)**: Credential isolation for Phase 5 multi-agent execution. When Phase 5 tests generated skills in sandboxes, those sandboxes must NOT inherit parent agent credentials. Reference architecture: Managed Agents' two patterns — (1) resource-bundled auth (initialize resources during setup, sandbox operates without direct credential access), (2) vault-based MCP proxy (OAuth tokens in secure vaults, accessed only via MCP proxy servers). Design document: `knowledge_base/agentic-ai/evaluations/credential-isolation-design.md`. Full implementation required for Phase 7 multi-tenant AaaS.
```

**Justification**: Current single-machine threat model is low risk, but Phase 5 sandbox
execution of untrusted generated code creates a credential exposure surface. Design-time
consideration prevents bolt-on security later.

---

## PROPOSED CHANGE 6: Add external session state to Phase 5.3.2

**Section**: Phase 5.3.2 (Task-level workflow state tracking)
**Priority**: P1 (architectural)
**Action**: Append to existing task description

```markdown
> **Design note (2026-04-12)**: External session state design required for stateless router pattern. Managed Agents' brain-hands architecture demonstrates: stateless harness reads task state from append-only event log, invokes agents via `execute(name, input) → string`, resumes via `wake(sessionId)` + `getSession(id)`. Our topology-aware-router should adopt this pattern: read task state from external log on startup, invoke agents as tool calls, treat agent failures as retryable tool errors (not fatal), support resume from any pending task ID. Session state logging (Phase 4.3 task) establishes the event log format.
```

**Justification**: The brain-hands decoupling from Managed Agents maps directly to our
Phase 5 topology-aware-router design. Adding it as a design note ensures implementers
reference this pattern.

---

## PROPOSED CHANGE 7: Update status line

**Section**: Top-level status
**Priority**: P0 (bookkeeping)
**Action**: Update when changes are applied

```markdown
**Status as of 2026-04-12: Phase 4 in progress. Fleet version BLOCKER: running v2.1.87, minimum v2.1.101 — human upgrade pending (Day 3 of escalation). Phase 4 completion ~85% — 50-skill stress test is blocking deliverable (May 9 deadline, 27 days). Security: PASS. Changeling: 8/8 PASS. Countdowns: Haiku 3 retirement 7d (Apr 19), 1M context beta sunset 18d (Apr 30), Google I/O 37d (May 19-20), Phase 4 deadline 27d (May 9). Metachar baseline: Day 2/30.**
```

---

## PROPOSED CHANGE 8: Update workflow convergence design note

**Section**: Phase 4.3 (Observability) — existing workflow convergence note
**Priority**: P3
**Action**: Update reference in ROADMAP Phase 5.3.2

```markdown
> **Design reference update (2026-04-12)**: Workflow convergence note (`knowledge_base/agentic-ai/evaluations/workflow-state-convergence.md`) extended with fourth pattern: Managed Agents append-only session log with `getEvents()` retrieval. Four-way comparison: ADK (graph-node dedup) vs. WDK (deterministic replay) vs. Managed Agents (event log retrieval) vs. our pipeline (JSON state machine). Recommended Phase 5 approach: adopt Managed Agents event log pattern — closest to our existing JSON approach but adds crash safety.
```

**Justification**: Completes the convergence analysis with the third vendor pattern.
Directly informs Phase 5.3.2 design decisions.
