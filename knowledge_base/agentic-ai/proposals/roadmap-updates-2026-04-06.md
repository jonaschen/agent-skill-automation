# ROADMAP Update Recommendations — 2026-04-06

**Source**: Analysis 2026-04-06, Discussion 2026-04-06 (7 ADOPT items, 4 DEFER items)
**Author**: agentic-ai-researcher (L4 strategic planning)

---

## PROPOSED CHANGE 1: Update Status Line (CRITICAL)

**Current**:
> Status as of 2026-04-05: Phase 4 in progress. Security hardening expanded...

**Proposed**:
> Status as of 2026-04-06: Phase 4 in progress. CRITICAL: routing regression (T=0.658) is top priority — stabilization window provides ideal fix opportunity. OWASP MCP Top 10 deepened threat model — coverage at ~30%, targeting ~40% with hash-pinning. Google I/O 2026 (May 19-20) monitoring protocol established. 7 new ADOPT items from discussion.

**Rationale**: Reflects current priorities and the shift from "security hardening" to "routing fix + security deepening".

---

## PROPOSED CHANGE 2: Add Tasks to Phase 4.4 Security Hardening

**Add after** the existing `eval/mcp_config_validator.sh` content scanning task:

```markdown
- [ ] Integrate `mcp-scan` hash-based tool pinning into CI/CD gate for rug pull detection (OWASP MCP03 variant 3) — P1 (see proposal 2026-04-06-mcp-scan-hash-pinning.md)
- [ ] Add `terminal_reason` retry logic spec and SDK v0.2.91 strict sandbox default to `eval/model_migration_runbook.md` — P1 (see proposal 2026-04-06-terminal-reason-retry-spec.md)
- [ ] Create `eval/assumption_registry.md` — centralized model-assumption mapping for stress testing during model migration — P2 (see proposal 2026-04-06-assumption-registry.md)
```

**Rationale**: These are concrete, scoped security and infrastructure tasks that emerged from OWASP analysis and Agent SDK updates.

---

## PROPOSED CHANGE 3: Add Task to Phase 4.2 Closed-Loop

**Add to** Phase 4.2 End-to-end closed-loop stress test section:

```markdown
- [ ] Implement sprint contract (simplified manifest): factory outputs `manifest.json` with permission_model + target_domain; validator consumes for structural checks — P2 (see proposal 2026-04-06-sprint-contract-manifest.md)
```

**Rationale**: Inter-agent protocol improvement that reduces false failures and establishes a pattern for Phase 5 multi-agent orchestration.

---

## PROPOSED CHANGE 4: Add Task to Phase 3.2 Optimizer

**Add to** Phase 3.2 `autoresearch-optimizer` section:

```markdown
- [ ] Implement optimizer state persistence: extend `eval/experiment_log.json` with `best_so_far` + `current_description` fields; add resume-from-log logic — P2 (see proposal 2026-04-06-optimizer-state-persistence.md)
```

**Rationale**: Prevents loss of optimization progress on interruption (crash recovery for Phase 4 autonomy).

---

## PROPOSED CHANGE 5: Update Phase 6.4 Model Packaging Pipeline

**Change** the Phase 6 approach to reflect Gemma 4 zero-shot findings:

**Current** (implicit assumption): Fine-tune Gemma 4 for function calling → package for edge

**Proposed**: Add note:
```markdown
- [ ] Package SKILL.md + Gemma 4 E2B/E4B for edge deployment with zero-shot function calling (86.4% τ2-bench — fine-tuning NOT production-ready as of 2026-04-06, QLoRA blockers in HuggingFace/PEFT)
- [ ] Evaluate if fine-tuning improves accuracy >5% over zero-shot before investing in fine-tuning tooling
```

**Rationale**: Analysis §4.4 confirmed Gemma 4 fine-tuning is not production-ready (QLoRA blockers). Zero-shot function calling (86.4%) is sufficient for initial deployment. This simplifies Phase 6 significantly.

---

## PROPOSED CHANGE 6: Add New Risk to Risk Table

**Add**:

| Risk | Phase | Mitigation | Status |
|------|-------|-----------|--------|
| OWASP MCP Top 10: 84.2% attack success rate, 34/100 avg security score; our coverage is ~30% (4/10 categories) | 2-4 | Static content scanning (MCP03), dependency pinning (MCP04), hash-pinning for rug pulls (P1). Gaps: MCP01 (tokens), MCP06 (return injection), MCP09 (shadow servers), MCP10 (data exposure) | New — P1 mitigation in progress |
| Google I/O 2026 (May 19-20) may announce Gemini 4, ADK v2.0 stable, Astra hardware — any of which could shift Phase 5-6 architecture | 5-6 | Monitoring protocol established; tracking file at `knowledge_base/agentic-ai/events/google-io-2026.md`; focused sweeps starting May 5 | New — P0 monitoring |

**Rationale**: OWASP quantified the MCP threat far beyond our initial assessment. Google I/O is a known inflection point that warrants formal risk tracking.

---

## PROPOSED CHANGE 7: Add Lesson Learned

**Add to Lessons Learned**:

| # | Lesson | Context |
|---|--------|---------|
| L9 | Every pipeline component encodes a model limitation assumption — stress-test and simplify as models improve | Anthropic harness engineering blog (2026-04-06). Our validator assumes factory can't self-evaluate; our optimizer assumes descriptions need iteration; our router assumes models can't auto-identify roles. Create `eval/assumption_registry.md` to track and stress-test these on each model release. Prevents the "complexity ratchet" where components accumulate but never get removed. |

**Rationale**: This is a strategic design principle that should inform all future pipeline decisions.

---

## PROPOSED CHANGE 8: Update Immediate Next Actions

**Replace** current action #4 with:

```markdown
4. **CRITICAL**: Fix routing regression (T=0.658) during stabilization window — two-pronged approach:
   a. Deconflict all 11 agent descriptions (replace competing verbs: "implements"→"acts on", "generates"→"produces", "creates"→"writes")
   b. Reinforce meta-agent-factory routing anchor with explicit ROUTING RULE
   c. Re-run full T+V eval to confirm recovery to ≥0.895
   (see proposal 2026-04-06-routing-regression-fix.md)
```

**Add**:
```markdown
9. **P0 monitoring**: Create Google I/O 2026 tracking file (see proposal 2026-04-06-google-io-monitoring.md)
10. **P1**: Spike `mcp-scan` compatibility + implement hash pinning (see proposal 2026-04-06-mcp-scan-hash-pinning.md)
11. **P1**: Add `terminal_reason` retry spec to model migration runbook (see proposal 2026-04-06-terminal-reason-retry-spec.md)
```

**Rationale**: Reflects the prioritized implementation order from today's discussion.

---

## Summary: Implementation Priority

| Order | Action | Priority | Proposal |
|---|---|---|---|
| 1 | Fix routing regression (deconflict + anchor) | CRITICAL | `2026-04-06-routing-regression-fix.md` |
| 2 | Create Google I/O tracking file | P0 monitoring | `2026-04-06-google-io-monitoring.md` |
| 3 | `mcp-scan` compatibility spike + hash pinning | P1 | `2026-04-06-mcp-scan-hash-pinning.md` |
| 4 | `terminal_reason` retry spec in migration runbook | P1 | `2026-04-06-terminal-reason-retry-spec.md` |
| 5 | Sprint contract manifest | P2 | `2026-04-06-sprint-contract-manifest.md` |
| 6 | Optimizer state persistence | P2 | `2026-04-06-optimizer-state-persistence.md` |
| 7 | Assumption registry | P2 | `2026-04-06-assumption-registry.md` |
