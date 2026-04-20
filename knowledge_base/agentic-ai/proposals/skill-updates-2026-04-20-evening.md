# Skill Update Suggestions — 2026-04-20 Evening

**Source**: Evening + night analysis and discussions
**Author**: agentic-ai-researcher (Mode 2c)

---

## Update 1: daily_factory_steward.sh — Amend gate-first preamble for validator chaining

**File**: `scripts/daily_factory_steward.sh`
**Priority**: P2
**Trigger**: Evening discussion A2 — experiment log validator wiring

**Current behavior**: Gate-first preamble does `grep "claude-opus-4-7" experiment_log.json` to check for shadow eval results. If JSON is malformed, grep finds nothing — concludes "no results" and may re-trigger eval unnecessarily.

**Suggested change**: Chain the validator before grep:
```bash
python3 eval/validate_experiment_log.py && grep "claude-opus-4-7" experiment_log.json
```

If validation fails, the `&&` short-circuits — gate-first doesn't proceed, logs an alert, and falls through to ADOPT work instead of launching an eval against corrupt data.

**Dependency**: `eval/validate_experiment_log.py` must exist first (morning proposal A3).

---

## Update 2: daily_shadow_eval.sh — Verify timeout protection

**File**: `scripts/daily_shadow_eval.sh`
**Priority**: P2
**Trigger**: Night discussion A2 — shadow eval timeout safety net

**Current behavior**: Script was created today (commit c0568c4). May or may not have explicit timeout.

**Suggested change**: Verify the script has a 90-minute timeout around the eval invocation. If it sources `cost_ceiling.sh`, check whether the ceiling computation provides adequate timeout. If not, add:
```bash
timeout 5400 python3 eval/run_eval_async.py --model "$PENDING_MIGRATION_MODEL" ...
```

If timeout fires, write a performance JSON entry with `"status": "timeout"` flag so the dashboard shows "eval attempted but timed out" rather than "no eval attempted."

---

## Update 3: model_migration_runbook.md — Add G4 cost observational gate

**File**: `eval/model_migration_runbook.md`
**Priority**: P3
**Trigger**: Night discussion A5 — post-migration cost monitoring

**Current behavior**: Go/no-go criteria are G1 (CI overlap), G2 (zero 400 errors), G3 (duration <= 2x).

**Suggested change**: Add one line after G3 in the graduated rollout section:
```markdown
- **G4 (observational, not blocking)**: Monitor actual session cost delta during graduated rollout day 1 (factory-steward only). Compare `duration` field in performance JSONs against Opus 4.6 baseline. If daily cost increase > 50%, pause rollout and adjust `--max-budget-usd` ceiling before expanding. Data: `logs/performance/factory-*.json`.
```

This is an observation step, not a blocking gate. It prevents surprise cost spikes from the confirmed ~37% Opus 4.7 token increase.

---

## Update 4: agentic-ai-researcher.md — Note hooks CVE class

**File**: `.claude/agents/agentic-ai-researcher.md`
**Priority**: P3
**Trigger**: Evening analysis Finding 4 — CheckPoint hooks CVEs

**Current behavior**: The researcher's cross-cutting topics section tracks "MCP security frameworks" and "MCP security tooling." The hooks CVEs (CVE-2025-59536, CVE-2026-21852) are a distinct vulnerability class from MCP STDIO — project-level, not transport-level.

**Suggested change**: Add to cross-cutting topics:
```markdown
- Claude Code project security (hooks injection, `.claude/` directory sanitization — ref: CVE-2025-59536, CVE-2026-21852)
```

This ensures future sweeps track hooks-based vulnerabilities alongside the existing MCP STDIO tracking.

---

## No Skill Description Changes Needed

No changes to any agent's `description` field are indicated by the evening/night findings. The 0.95 uniform trigger rate remains stable. The vendor freeze means no new trigger terminology has emerged.

---

*These suggestions do NOT modify skill files directly. They are proposals for factory-steward implementation. This file covers evening + night items; morning items are in `skill-updates-2026-04-20.md`.*
