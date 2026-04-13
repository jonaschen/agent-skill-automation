# Skill Update Suggestions — 2026-04-12

**Source**: Analysis 2026-04-12 + Discussion 2026-04-12
**Author**: agentic-ai-researcher (Mode 2c: Strategic Planning)

---

## 1. agentic-ai-researcher — Add Managed Agents Tracking (P2)

**Current state**: Tracks Claude Code, Agent SDK, MCP, tool use, computer use, multi-agent patterns, model releases.

**Suggested update**: Add "Managed Agents" as a tracked topic under the Anthropic track.

```markdown
| Managed Agents | anthropic.com, docs.anthropic.com | Managed Agents, brain-hands, stateless harness, sandbox |
```

**Rationale**: Managed Agents is now the most detailed Anthropic disclosure of their
production agent hosting architecture. It introduces patterns (brain-hands decoupling,
session logs, lazy provisioning, credential isolation) that directly affect our Phase 5/7
design. Tracking this as a first-class topic ensures we catch GA announcements, API
releases, and SDK integration guidance.

**Risk**: Very low — adds one more search query per sweep.

---

## 2. project-reviewer — Consume Session Event Logs (P2, after session logging lands)

**Current state**: Reviews steward work by reading git logs, performance JSONs, and
ROADMAP/CLAUDE.md alignment.

**Suggested update**: When session event logs exist (`logs/sessions/{agent}-{date}.jsonl`),
read them as a primary data source for task-level review instead of inferring from git log.

**Rationale**: Session event logs provide structured `TASK_START`/`TASK_COMPLETE`/`ERROR`
events that are more reliable and detailed than git-log mining. The project-reviewer
currently must infer task progression from commit messages — explicit event data is more
accurate.

**Dependency**: Session state logging proposal (2026-04-12-session-state-logging.md) must
be implemented first.

**Risk**: Low — additive data source, doesn't replace existing review methods.

---

## 3. factory-steward — Act on Fleet Version Alerts (P1)

**Current state**: Factory steward acts on ADOPT items from researcher discussions,
tunes underperforming agents, refines eval/pipeline, advances ROADMAP.

**Suggested update**: Add fleet version check to the factory steward's action scope.
When `logs/security/fleet_version.jsonl` shows a mismatch, the factory steward should:
1. Update `fleet_min_version.txt` if the researcher's analysis justifies a bump
2. Enhance `check_fleet_version.sh` with any new reporting capabilities
3. NOT attempt to upgrade Claude Code itself (human action)

**Rationale**: The fleet version bump from `>=2.1.98` to `>=2.1.101` is a P1 action
identified today. The factory steward is the natural owner of pipeline infrastructure
changes, but it currently has no instruction to monitor or act on fleet version alerts.

**Risk**: Very low — factory steward already modifies pipeline scripts.

---

## 4. topology-aware-router — Design Notes for Stateless Harness Pattern (P1, Phase 5)

**Current state**: Routes tasks to parallel (Track A) or sequential (Track B) topology
based on TCI score. Stores all state in-conversation.

**Suggested update**: When Phase 5 implementation begins, redesign as a stateless harness:
- Read task state from external log on startup (not conversation context)
- Invoke agents via `execute(name, input) → string` tool-call pattern
- Treat agent failures as retryable tool errors (not fatal crashes)
- Support `wake(taskId)` for resume-after-crash

**Rationale**: Managed Agents' brain-hands architecture demonstrates that the harness
(router) should be stateless and resumable. Our current design couples all task state to
the conversation context, making crash recovery impossible.

**Dependency**: External session state (Phase 5.3.2) must be designed first.
**Note**: This is a Phase 5 design consideration, not a current agent change.

---

## 5. All Daily Scripts — Consecutive-Skip Monitoring (P2, after lazy provisioning)

**Current state**: Daily scripts either run or fail. No concept of "skip" (no work available).

**Suggested update**: Add `skip_count` field to performance JSONs. When lazy provisioning
is implemented, each skip increments the counter. Alert in `agent_review.sh` if any agent
exceeds 3 consecutive skips.

**Rationale**: Lazy provisioning (2026-04-12 proposal) introduces the risk of silent agent
death if the skip-detection logic has a bug. The consecutive-skip counter is the safety net.

**Dependency**: Lazy provisioning proposal must be implemented first.
