# Deferred and Rejected Items — 2026-04-17

Items from the 2026-04-17 discussion that were explicitly DEFERRED or REJECTED.
factory-steward should NOT act on these without re-evaluation.

---

## DEFERRED Items

### D1: Programmatic Tool Calling Pilot (Researcher First, Factory Second)
**Reason**: Blocked by security analysis (proposal `2026-04-17-programmatic-tool-calling-security-analysis.md`).
The 10× intermediate-token reduction is attractive, but our post-tool-use.sh hook coverage over
container-internal tool calls is unverified. Pilot without that analysis risks silent security-envelope bypass.
**Revisit when**: Programmatic tool calling security analysis clears with PASS or BLOCK_WITH_DENY recommendation. Researcher pilot first (read-only tool surface, low blast radius); factory pilot only after researcher pilot stable for ≥7 days.

### D2: 4-Axis Validator Scoring (Originality + Craft Axes)
**Reason**: The Three-Agent Harness blog's Playwright evaluator scores 4 axes (design quality, originality,
craft, functionality). Our validator today scores trigger rate + security + permissions — we have no
equivalent to "originality" or "craft." Expanding scoring axes is premature while Phase 4 pilot is not yet
stabilized at 80% deployment rate (ROADMAP §Phase 4.2a gate work ongoing).
**Revisit when**: Phase 4 pilot stable at ≥80% deployment rate for ≥3 consecutive nightly runs, AND post-I/O stability confirmed.

### D3: Full JSON Schema Enforcement on Factory↔Validator Contracts
**Reason**: v0 documented-object is sufficient today (proposal `2026-04-17-sprint-contract-manifest-v0.md`).
Schema-validated v1.0 adds ~2 days of careful design (version evolution rules, additive-only enforcement,
legacy manifest handling). That discipline is only earned when the first real agent swap forces it.
**Revisit when**: First Phase 5 agent swap lands (e.g., Mythos GA and validator replacement, or A2A transport
integration post-I/O), OR 4+ manifest consumers exist.

### D4: MCP Triggers & Events WG Adoption as Cron Replacement
**Reason**: No SEP draft has emerged from the Transports Working Group even after AWS Sr. Principal
Engineer (Clare Liguori) joined Core Maintainers on Apr 8. The 2026 MCP roadmap places Triggers & Events
in "On the Horizon" tier (below Server Cards, Tasks primitive, Governance Maturation). Cron-driven fleet
remains optimal for phase-driven autonomous work (factory-steward, ltc-steward). Event-driven is Phase 6+
for high-frequency reactive agents.
**Revisit when**: First SEP draft lands (expected May–June 2026 earliest).

### D5: Routines CLI Primitive Adoption
**Reason**: Routines is research preview only, Anthropic-hosted (Claude Code Desktop App), no CLI primitive
exposed yet. Our shell-script fleet has 3+ months of Bayesian eval + rollback + performance tracking that
a net-new Routines reimplementation would not inherit.
**Revisit when**: CLI-native Routines lands (e.g., `claude routine create --cron ... --trigger ...`). Prototype
a single steward (factory-steward) as a Routine; compare against shell wrapper on reliability, observability,
cost accounting, rollback ergonomics.

### D6: Formal ZDR Policy Matrix (vs. Running Log)
**Reason**: Product surface is still shifting (Computer Use only 3 weeks past ZDR-eligible; Mythos public
API not announced). Writing a comprehensive matrix today risks stale documentation before Phase 7 consumes it.
Running-log format (proposal `2026-04-17-zdr-policy-running-log.md`) is the active scope.
**Revisit when**: Phase 7 kickoff. Running log will have 3-6 months of raw material by then.

### D7: Drop Optimizer Iteration Ceiling from 50 → 20
**Reason**: REJECTED outright in discussion (see R1 below). Listed here for cross-reference.

---

## REJECTED Items

### R1: Drop Optimizer Iteration Ceiling from 50 → 20 Post-Opus-4.7
**Reason**: No failure-mode test. The Three-Agent Harness blog reports 5-15 iterations as *typical* for
Anthropic's task distribution, not a ceiling. Our task distribution includes multilingual (zh-TW test_55),
cross-domain disambiguation (test_41-44), and stewards-as-routing-competition scenarios — all genuinely
harder than "generate a Playwright test."

Lowering the ceiling to 20 before measuring the distribution would falsely report failure for genuinely
hard refinements (e.g., a description needing 22 iterations) and we'd lose signal about which skills are
intrinsically harder.

**Alternative adopted**: Track `iterations_to_converge` as a reported output in `experiment_log.json`.
After 3+ weeks of post-4.7 optimizer data, revisit ceiling with empirical distribution. This aligns with
the `xhigh` effort pilot (proposal `2026-04-17-xhigh-effort-optimizer-pilot.md`) which requires the same
instrumentation as a side effect.

### R2: Modify ROADMAP.md Directly for Phase 5.2 Three-Track Update
**Reason**: Action Safety rules explicitly prohibit ROADMAP.md modification by agentic-ai-researcher.
Proposed change written to `roadmap-updates-2026-04-17.md` for human review (per three-track topology
dispatch proposal `2026-04-17-three-track-topology-dispatch-design.md` Deliverable 2).

### R3: Email-Based Alerting for Post-Haiku-3 Retirement Audit
**Reason**: No verified mail daemon in cron environment. Existing structured alert pattern
(JSONL + `scripts/agent_review.sh` dashboard surfacing) already covers fleet version, cost, mcp depth.
Adopted alternative: `logs/security/deprecation_audit.jsonl` consistent with existing pattern
(proposal `2026-04-17-post-haiku3-retirement-audit.md`).

---

## Cross-Reference Table

| ID | Related Adopted Proposal | Status |
|----|-------------------------|--------|
| D1 | `2026-04-17-programmatic-tool-calling-security-analysis.md` | DEFER until security analysis clears |
| D2 | `2026-04-17-sprint-contract-manifest-v0.md` | DEFER axes expansion to post-Phase-4 stabilization |
| D3 | `2026-04-17-sprint-contract-manifest-v0.md` | DEFER schema enforcement to first agent swap |
| D4 | — | DEFER until first SEP draft |
| D5 | — | DEFER until CLI-native Routines |
| D6 | `2026-04-17-zdr-policy-running-log.md` | DEFER formal matrix to Phase 7 |
| R1 | `2026-04-17-xhigh-effort-optimizer-pilot.md` | REJECT ceiling change; adopt instrumentation |
| R2 | `2026-04-17-three-track-topology-dispatch-design.md` | REJECT direct edit; use roadmap-updates-2026-04-17.md |
| R3 | `2026-04-17-post-haiku3-retirement-audit.md` | REJECT email; adopt JSONL + dashboard |
