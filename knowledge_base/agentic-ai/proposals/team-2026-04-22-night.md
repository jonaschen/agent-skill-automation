# Team Proposals — 2026-04-22 (Night, Research Lead)

**Source**: Research-lead assessment of 2026-04-22 full day (morning + afternoon cycles)
**Decision**: No structural changes. Two process refinements.

---

## Assessment: Pipeline Healthy, Queue at Capacity

The pipeline produced its most information-dense day in weeks — CC v2.1.117 (25+ changes), Gemini CLI preview unfreeze, triple S3 convergence signal. The three-agent structure handled the load well: researcher produced two justified cycles, factory cleared 3 items, research-lead issued one directive (morning) and now this night session.

However, the factory queue has grown to its largest size (~16 items, ~5-6 sessions to clear). This is not a structural problem — the factory's 3 items/session throughput is healthy. The issue is that an information-dense day generates more ADOPTs than the factory can absorb in one cycle. The correct response is not to add factory capacity but to throttle ADOPT generation during queue peaks.

| Component | Status | Concern Level |
|-----------|--------|---------------|
| Researcher | Strong analysis, minor sweep duplication | Low (addressed in directive) |
| Factory-steward | 3 items/session, cleared S1 critical path | None |
| Research-lead | Directive + team proposal pipeline working | None |
| S1 pipeline | Architecturally complete, waiting on CC upgrade | Blocked on Jonas |
| S2 research | Three new Phase 5 design inputs | None |
| S3 research | Strongest evidence yet, first artifact adopted | Blocked on Gemini CLI |

## Proposal 1: ADOPT Generation Throttle During Queue Peaks

**Type**: Process refinement (not structural)
**Priority**: P2

### Problem

The factory queue grew from 13 to ~16 items in one day despite the factory clearing 3 items (commit 6e70617). The afternoon discussion generated 6 ADOPTs, net-adding 3 items after the factory's clearance. At this rate, a single information-dense day can add a full factory session's worth of queue.

### Proposed Change

When the factory queue exceeds 12 items:
- Raise the ADOPT bar to P1+ or strategic critical path (S1/S2/S3 direct). P2/P3 items with ≤10 min effort should be bundled into composite entries (one verdict, one queue slot).
- Target ≤3 ADOPTs per discussion.
- The throttle lifts when the queue drops below 10 items.

### Expected Benefit

- Prevents queue from growing without bound during information-dense periods
- Forces the discussion to prioritize genuinely high-impact items
- Gives the factory breathing room to clear backlog

### Cost

Some low-priority items may not get adopted individually. They can be bundled or held for the next cycle.

### Risk

Low. The throttle only activates when the queue is already large. If an urgent item (S1 critical path, security issue) emerges, it bypasses the throttle.

## Proposal 2: Same-Day Sweep Deduplication Rule

**Type**: Process refinement (not structural)
**Priority**: P2

### Problem

The afternoon sweep (2026-04-22-afternoon.md) was substantially duplicative of the morning sweep (2026-04-22.md). Both covered CC v2.1.117 in full detail — the afternoon sweep re-wrote nearly all the same content (changelog items, source links, gap analysis tables). This produces a larger-than-needed knowledge base footprint and costs ~$2 of API budget for duplicate content.

### Proposed Change

When a second sweep runs on the same day as a prior sweep:
- If no NEW releases shipped since the morning sweep: produce ~300 words confirming morning coverage is current. No full re-write.
- If NEW releases shipped: cover only the new releases. Reference the morning sweep for previously covered items. Do not re-write morning content.

### Expected Benefit

- ~50% reduction in API cost on two-cycle days
- Cleaner knowledge base (one authoritative sweep per release, not two)
- Faster afternoon cycle (~15 min vs ~45 min)

### Cost

None. The morning sweep already provides comprehensive coverage. Deduplication loses nothing.

### Risk

None. If something material changes between morning and afternoon (e.g., a release is retracted or corrected), the incremental sweep captures it.

## No Structural Changes Needed

The three-agent pipeline handles current workload at steady state. The two process refinements above address the only observed friction: queue growth during dense days and sweep duplication. No agent additions, removals, or role changes are needed.

The Google I/O window (May 19-20, 27 days) is the next likely stress test. Pre-I/O assessment should happen in the May 18 directive, not now.
