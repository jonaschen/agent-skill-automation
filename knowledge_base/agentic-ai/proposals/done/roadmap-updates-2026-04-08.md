# ROADMAP Update Recommendations — 2026-04-08
**Source**: Analysis 2026-04-08 + Discussion 2026-04-08
**Author**: agentic-ai-researcher (Mode 2c: Strategic Planning)

---

## PROPOSED CHANGES

### 1. Phase 4 — CVE-2026-35020 Mitigation (P0)

**PROPOSED CHANGE**: Add to Phase 4.4 (Security hardening):

```markdown
- [x] **CVE-2026-35020 mitigation**: Add `unset TERMINAL` preamble to all 8 daily scripts — defense-in-depth against CVSS 8.4 OS command injection via TERMINAL env var — P0 (2026-04-08 analysis)
```

**Rationale**: Active vulnerability. All 8 nightly cron scripts are exposed. The `unset` neutralizes the attack vector regardless of Claude Code patch status.

---

### 2. Phase 4 — Initiator-Type Permission Context (P1)

**PROPOSED CHANGE**: Add to Phase 4.4 (Security hardening):

```markdown
- [ ] **Initiator-type env var (Phase 1)**: Export `CLAUDE_INITIATOR_TYPE=cron-automated` in all daily scripts; read and log in `post-tool-use.sh`. Visibility only, no enforcement — P1 (2026-04-08 discussion: AWS IAM context key pattern)
- [ ] **Initiator-type enforcement (Phase 2)**: Block destructive git ops (`push --force`, `reset --hard`, `branch -D`) for `cron-automated` initiator type in `post-tool-use.sh` — P1 (2026-04-08 discussion)
```

**Rationale**: AWS IAM context keys now provide a production reference pattern for agent/human action differentiation. Our automated cron environment has a different threat surface than interactive sessions (demonstrated by CVE-2026-35020). Phase 7 AaaS will require this as enterprise table-stakes.

---

### 3. Phase 4 — Model Deprecation Guard (P1)

**PROPOSED CHANGE**: Add to Phase 4.4 (Security hardening):

```markdown
- [ ] **Model deprecation guard**: Implement `eval/model_deprecation_check.sh` + `eval/deprecated_models.json` (append-only, researcher-maintained). Grep agent configs for deprecated model IDs; fail pre-deploy gate when referenced model retires within 30 days — P1 (2026-04-08 discussion: 4 deprecation deadlines within 95 days)
```

**Rationale**: Four model retirement dates converge within 95 days. While our agents use current models, no automated check prevents accidental references to deprecated IDs. Low effort, high safety value.

---

### 4. Phase 4 — Security Suite Aggregator (P1)

**PROPOSED CHANGE**: Add to Phase 4.4 (Security hardening):

```markdown
- [ ] **Security suite aggregator**: Implement `eval/security_suite.sh` — runs all security checks in sequence, outputs versioned JSON report. Wire into `pre-deploy.sh` as single entry point replacing individual script invocations — P1 (2026-04-08 discussion: simpler alternative to full security orchestrator agent)
```

**Rationale**: 7+ security scripts with different output formats. A unified runner simplifies the pre-deploy gate and makes results machine-parseable for the reviewer agent. 90% of orchestration benefit at 10% of agent cost.

---

### 5. Phase 4 — Hard Deadline Before Google I/O (P2)

**PROPOSED CHANGE**: Add a note to Phase 4 overview:

```markdown
**Deadline (2026-04-08)**: All Phase 4 tasks must be complete or explicitly deferred by **May 9, 2026** (Friday before Google I/O week May 19-20). I/O will trigger a cascade of required updates — Phase 4 should be stress-tested before then.
```

**Rationale**: Google I/O (May 19-20, 41 days out) will bring ADK v2.0, potentially Gemini 4, A2A v1.1, Android XR. Absorbing these announcements while Phase 4 is still open creates schedule risk. A hard deadline forces prioritization.

---

### 6. Phase 5 — Cross-Platform SKILL.md Research Task (P2)

**PROPOSED CHANGE**: Add to Phase 5 tasks:

```markdown
#### 5.3.2 Cross-platform Skill distribution (research)
- [ ] **Gemini CLI skills format verification**: Create a Gemini CLI project, inspect `.gemini/skills/` format, document exact field mappings vs `.claude/skills/`. Prerequisite for cross-platform SKILL.md export — P2 (2026-04-08 discussion: CLI convergence confirmed but byte-level format compatibility unverified)
```

**Rationale**: CLI architectural convergence is complete (analysis §4.1), making cross-platform SKILL.md distribution a Phase 7 opportunity. But the converter can't be built without verified format specs. This research task is the prerequisite.

---

### 7. Phase 6 — Add Qwen 3.6 Plus to Model Evaluation Matrix (P2)

**PROPOSED CHANGE**: Update Phase 6.4 description to include:

```markdown
- [ ] **Model evaluation matrix**: Evaluate three server-side candidates: Gemma 4 31B (quality), Qwen 3.6 Plus (speed, 78.8% SWE-bench at ~3x Opus speed), Gemma 4 26B MoE (balance). On-device remains Gemma 4 E2B/E4B exclusively — P2 (2026-04-08 analysis: Qwen 3.6 Plus as competitive new entrant)
```

**Rationale**: Qwen 3.6 Plus achieves near-Opus quality at dramatically higher speed. When Phase 6 begins, it should be evaluated alongside Gemma 4 variants. Free preview ensures zero-cost experimentation.

---

### 8. Phase 7 — Agent/Human Action Differentiation Note (P2)

**PROPOSED CHANGE**: Add to Phase 7 design notes:

```markdown
**Design requirement (2026-04-08)**: Agent/human action differentiation is now an enterprise table-stakes requirement. AWS IAM context keys (`aws:ViaAWSMCPService`, `aws:CalledViaAWSMCP`) provide the reference implementation. Phase 7 permission model must distinguish automated agent actions from human-initiated actions at the policy level.
```

**Rationale**: AWS is the first cloud provider with production-grade agent/human differentiation. Enterprise AaaS customers will expect this capability. The Phase 4 initiator-type implementation provides our internal prototype.

---

### 9. New Risk Entry — CVE-2026-35020 (P0)

**PROPOSED CHANGE**: Add to Key Risks table (if one exists; otherwise create):

```markdown
| CVE-2026-35020: OS command injection via TERMINAL env var in Claude Code CLI (CVSS 8.4) | 5 | `unset TERMINAL` preamble in all 8 daily scripts; verify Claude Code version; audit cron environment for env var injection paths | New — P0, mitigated 2026-04-08 |
```

---

### 10. New Risk Entry — Converging Deprecation Deadlines

**PROPOSED CHANGE**: Add to Key Risks table:

```markdown
| Four model deprecation deadlines within 95 days (Haiku 3: Apr 19, Sonnet 3.7: May 11, 1M beta: Apr 30, Haiku 3.5: Jul 5) | 2 | No direct dependency (we use Opus 4.6/Sonnet 4.6); model deprecation guard script + JSON in pre-deploy gate; migration runbook exists | New — P1, guard proposed 2026-04-08 |
```

---

### 11. Update ROADMAP Status Line

**PROPOSED CHANGE**: Update the status line at top of ROADMAP.md:

```markdown
**Status as of 2026-04-08: Phase 4 in progress. CVE-2026-35020 mitigation (P0): TERMINAL env var sanitization for all 8 daily scripts. New security proposals: initiator-type permission context (AWS IAM pattern), model deprecation guard, security suite aggregator. Phase 4 hard deadline set: May 9 (before Google I/O May 19-20). Previous: cost & security guardrails added to all steward agent definitions.**
```

---

## Summary

| # | Change | Priority | Phase |
|---|--------|----------|-------|
| 1 | CVE-2026-35020 `unset TERMINAL` mitigation | P0 | 4 |
| 2 | Initiator-type permission context (2-phase) | P1 | 4 |
| 3 | Model deprecation guard script + JSON | P1 | 4 |
| 4 | Security suite aggregator | P1 | 4 |
| 5 | Phase 4 hard deadline: May 9 | P2 | 4 |
| 6 | Cross-platform SKILL.md format research | P2 | 5 |
| 7 | Qwen 3.6 Plus in Phase 6 model matrix | P2 | 6 |
| 8 | Agent/human differentiation design note | P2 | 7 |
| 9 | CVE-2026-35020 risk entry | P0 | Risks |
| 10 | Converging deprecation deadlines risk entry | P1 | Risks |
| 11 | ROADMAP status line update | — | Top |
