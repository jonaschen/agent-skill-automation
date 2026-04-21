# Team Proposals — 2026-04-21 (Night)

**Source**: Research-lead evening assessment
**Decision**: No structural changes. Process refinements only.

---

## Proposal 1: Discussion Item Bundling Rule

**Type**: Process refinement (not structural)
**Priority**: P2

### Problem

Today's afternoon discussion produced 7 ADOPT items, three of which (A5, A6, A7) are each 5-minute P3 tasks. Treating them as separate proposals creates overhead disproportionate to their size — each gets its own discussion round, its own verdict section, and its own entry in the factory queue. This pattern inflates both discussion length and factory queue size without adding proportional value.

### Proposed Change

Add a guideline to the researcher's discussion process: **items estimated at <=10 minutes and rated P3 should be bundled into a single "housekeeping" proposal with one combined verdict.** This reduces cognitive overhead in discussions and factory queue management while preserving all the actual content.

Example: instead of three separate proposals (A5: security dimension, A6: playbook note, A7: corrections log), one proposal: "Housekeeping bundle: (a) security dimension in A2 framework, (b) forecasting note in I/O playbook, (c) sweep corrections log. Combined 15 minutes."

### Expected Benefit

- Shorter discussions (fewer rounds for trivial items)
- Shorter factory queue (fewer line items to track)
- Same total work output

### Cost

None. This is a presentation change, not a content change.

### Risk

Low. If a bundled item turns out to need deeper discussion, the Engineer can unbundle it during the discussion.

---

## Proposal 2: 1M Beta Sunset Tracking Closure

**Type**: Process refinement (not structural)
**Priority**: P3

### Problem

The 1M context beta sunset (April 30, 9 days) has been mentioned in every sweep report for the past week. It's confirmed as a non-issue (fleet uses GA 4.6 models). Continuing to mention it wastes a line in every sweep report.

### Proposed Change

Give the researcher ONE more cycle to check for Anthropic migration guidance. If none published, formally close this tracking item. Remove from P1, remove from sweep checklists. If Anthropic surprises with unexpected requirements, the standard sweep will catch it.

### Expected Benefit

One fewer item cluttering sweep reports. Researcher bandwidth freed for actual findings.

### Cost

None.

### Risk

Negligible. GA model users are unaffected. The standard sweep catches any unexpected changes.

---

## Assessment: No Structural Team Changes Needed

The research pipeline handled today's stress test well:

| Metric | Today's Performance | Assessment |
|--------|-------------------|------------|
| Sweep coverage | 6 sweep files (morning + afternoon + evening per vendor) | Appropriate for freeze break event |
| Analysis depth | 2 analysis files (morning strategic + afternoon findings) | Strong — Finding 1 (data gap) is the most actionable in weeks |
| Discussion quality | 2 discussions, 11 ADOPTs, 3 REJECTs | Engineer pushback was substantive, not rubber-stamp |
| Data integrity | Evening correction caught hallucinated v1.32.0 | Two-sweep architecture validated |
| Factory throughput | 2 items implemented same-day (A4 + A1 from morning) | Healthy — 3 items/session pace maintained |
| Factory queue | 9 items across P1-P3 | Reasonable multi-session backlog (~3 sessions) |

The researcher-factory-lead three-agent chain is functioning as designed. Volume controls introduced in the 2026-04-19 directive cycle are working — today's elevated output was justified and self-documented. No agent additions, removals, or restructuring proposed.
