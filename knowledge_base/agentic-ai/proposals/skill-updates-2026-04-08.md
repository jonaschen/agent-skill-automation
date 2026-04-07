# Skill Update Suggestions — 2026-04-08
**Source**: Analysis 2026-04-08 + Discussion 2026-04-08
**Author**: agentic-ai-researcher (Mode 2c: Strategic Planning)

---

## 1. All 8 Daily Scripts — CVE-2026-35020 `unset TERMINAL` Preamble (P0)

**Current state**: All `scripts/daily_*.sh` invoke `claude` without sanitizing the environment.

**Proposed update**: Add to the preamble of all 8 scripts (before any `claude` invocation):

```bash
# CVE-2026-35020 mitigation: neutralize TERMINAL env var injection
unset TERMINAL
```

**Why P0**: Active CVSS 8.4 vulnerability. The `unset` completely neutralizes the attack vector regardless of Claude Code patch status. No version assertion needed (discussion rejected version parsing as fragile).

**Files**: `scripts/daily_factory_steward.sh`, `scripts/daily_research_sweep.sh`, `scripts/daily_android_sw_steward.sh`, `scripts/daily_arm_mrs_steward.sh`, `scripts/daily_bsp_knowledge_steward.sh`, `scripts/daily_project_reviewer.sh` (plus any additional cron scripts).

---

## 2. All 8 Daily Scripts — `CLAUDE_INITIATOR_TYPE` Export (P1)

**Current state**: Daily scripts don't communicate their execution context to hooks. `post-tool-use.sh` treats all tool calls identically.

**Proposed update**: Add to each daily script preamble:

```bash
export CLAUDE_INITIATOR_TYPE=cron-automated
```

And in `post-tool-use.sh`, add logging:

```bash
initiator_type="${CLAUDE_INITIATOR_TYPE:-human-interactive}"
# Include in structured log output
```

**Phase 1** (this week): env var + logging only. **Phase 2** (next week): enforce restricted operations for `cron-automated`.

**Why P1**: Foundation for differentiated security policies. AWS IAM context key pattern validates the approach. Plumbing must be done before enforcement can follow.

**Files**: All `scripts/daily_*.sh` + `.claude/hooks/post-tool-use.sh`

---

## 3. `post-tool-use.sh` — Initiator-Type Enforcement (P1, Phase 2)

**Current state**: After Phase 1 logging, `post-tool-use.sh` will have `CLAUDE_INITIATOR_TYPE` visibility but no enforcement.

**Proposed update**: Add a policy block:

```bash
if [ "$initiator_type" = "cron-automated" ]; then
  # Block destructive git operations
  case "$tool_args" in
    *"push --force"*|*"reset --hard"*|*"branch -D"*|*"checkout --"*|*"clean -f"*)
      echo "BLOCKED: destructive git operation in cron-automated context" >&2
      exit 1
      ;;
  esac
fi
```

**Why P1**: Completes the initiator-type permission model. Cron environments should never execute destructive git operations — these are almost certainly bugs or injection attempts.

**Files**: `.claude/hooks/post-tool-use.sh`

---

## 4. `agentic-ai-researcher` Agent Definition — Automated Deprecation JSON + I/O Queries (P2)

**Current state**: Researcher tracks model releases in `knowledge_base/agentic-ai/anthropic/model-releases.md` but doesn't maintain a structured deprecation data file. Google I/O specific queries not in tracking list.

**Proposed update**: Two additions to the agent definition:

### 4a. Deprecation JSON maintenance
Add to Mode 2 (Sweep) output artifacts:
```markdown
6. **Update deprecated_models.json** — when a model retirement announcement is confirmed from official sources, append an entry to `eval/deprecated_models.json`:
   ```json
   {"model_id": "<id>", "retirement_date": "YYYY-MM-DD", "replacement": "<id>", "source": "<url>"}
   ```
   Append-only: never modify or remove existing entries.
```

### 4b. Google I/O sweep queries
Add to Research Domains > Google/DeepMind Track:
```markdown
| Google I/O 2026 | ai.google.dev, blog.google | "Google I/O 2026", "ADK v2.0", "Gemini 4", "A2A v1.1", "Android XR" |
```

**Why P2**: Closes the loop: researcher detects deprecation → updates JSON → pre-deploy gate enforces. The I/O queries ensure we're tracking pre-announcement signals. Low effort (agent definition text changes).

**Files**: `.claude/agents/agentic-ai-researcher.md`

---

## 5. `factory-steward` — Pick Up Today's ADOPT Items (P0, via normal consumption)

**Current state**: Factory steward reads discussions and implements ADOPT items.

**Today's ADOPT items for factory-steward consumption**:
1. CVE-2026-35020 `unset TERMINAL` preamble in all 8 daily scripts (P0)
2. Deprecated model audit: grep all agent configs for `haiku-3`, `sonnet-3.7`, `sonnet-4.5`, `sonnet-4` model IDs (P0)
3. Initiator-type env var: `CLAUDE_INITIATOR_TYPE` export + logging (P1)
4. Model deprecation guard: `eval/model_deprecation_check.sh` + `eval/deprecated_models.json` (P1)
5. Security suite aggregator: `eval/security_suite.sh` (P1)

**No skill definition change needed** — the steward reads discussions directly.

---

## 6. `agentic-cicd-gate` — Model Deprecation Check in Gate Logic (P1, after guard exists)

**Current state**: CI/CD gate evaluates trigger rate, security scans, and Bayesian deployment threshold.

**Proposed update**: After `eval/model_deprecation_check.sh` is implemented, add it to the gate's check sequence. Gate criterion: fail if any agent configuration references a model retiring within 30 days.

**Why after implementation**: Don't update agent definitions for features that don't exist yet.

**Files**: `.claude/agents/agentic-cicd-gate.md` — add model deprecation check to gate logic section.

---

## 7. Phase 7 Design Notes — Agent/Human Differentiation Requirement (P2)

**Current state**: Phase 7 design notes mention dual deployment models (2026-04-07).

**Proposed addition**: Record that agent/human action differentiation is now an enterprise table-stakes requirement, citing AWS IAM context keys as reference implementation. Our Phase 4 initiator-type system provides the internal prototype.

**Files**: Phase 7 overview section in ROADMAP.md.

---

## Summary

| # | Target | Change | Priority | Status |
|---|--------|--------|----------|--------|
| 1 | All daily scripts | `unset TERMINAL` CVE mitigation | P0 | Ready — implement today |
| 2 | All daily scripts + post-tool-use.sh | `CLAUDE_INITIATOR_TYPE` export + logging | P1 | Ready — implement this week |
| 3 | post-tool-use.sh | Initiator-type enforcement | P1 | After Phase 1 logging ships |
| 4 | agentic-ai-researcher | Deprecation JSON + I/O queries | P2 | Ready to implement |
| 5 | factory-steward | Consume today's ADOPT items | P0 | Via normal discussion reading |
| 6 | agentic-cicd-gate | Model deprecation check | P1 | After guard script exists |
| 7 | ROADMAP Phase 7 | Agent/human differentiation note | P2 | Ready to add |
