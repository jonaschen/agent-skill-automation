# Skill Update Suggestions — 2026-04-20

**Source**: Sunday sweep analysis + Innovator/Engineer discussion
**Author**: agentic-ai-researcher (Mode 2c)

---

## Update 1: factory-steward.md — Shadow Eval Time Budget Awareness

**File**: `.claude/skills/steward/configs/factory.yaml` (or `daily_factory_steward.sh`)
**Priority**: P1
**Trigger**: Analysis Finding 1 — A1 gate-first contract works but session timeout prevents eval completion

**Current behavior**: Factory steward prompt includes gate-first preamble that launches shadow eval inline. Eval runs ~88 minutes, session budget ~44 minutes.

**Suggested change**: Once `daily_shadow_eval.sh` (proposal A2) exists, remove the inline eval launch from the factory steward's gate-first preamble. Instead, the gate-first check should:
1. Check `experiment_log.json` for results (as now)
2. If results exist: read go/no-go assessment
3. If NO results: log "shadow eval not yet run, skipping" (NOT launch the eval inline)

This eliminates the time budget conflict. The dedicated cron job handles the eval; the factory session handles ADOPT work.

**Dependency**: Proposal A2 (dedicated shadow eval cron) must be implemented first. Until then, the current A1 behavior is correct (attempt the eval even if it may time out).

---

## Update 2: agentic-ai-researcher.md — Stop Tracking EAGLE3 as Development

**File**: `.claude/agents/agentic-ai-researcher.md`
**Priority**: P3
**Trigger**: Directive instruction — "Stop tracking EAGLE3 as a development. It's merged."

**Current behavior**: EAGLE3 may still appear in sweep reports as a tracked development.

**Suggested change**: In the researcher's cross-cutting topics or Google/DeepMind track, note that EAGLE3 is fully merged and available. Future references should be "EAGLE3 is available" not "EAGLE3 status." Only mention if new benchmarks or performance data emerge. This is a minor documentation cleanup — no behavior change needed since the directive already instructs this.

---

## Update 3: cmd_chain_monitor.sh — Note Argument-Blind Gap

**File**: `scripts/cmd_chain_monitor.sh`
**Priority**: P3 (documentation only, enforcement deferred to Phase 5.5)
**Trigger**: Analysis Finding 2 — MCP STDIO exploitation family #2

**Current behavior**: Binary-level allowlist (60+ safe binaries). Does not inspect argument patterns.

**Suggested change**: Add a comment block documenting the known gap:
```bash
# KNOWN GAP (2026-04-20): This allowlist checks binary names only.
# Exploitation family #2 (OX Security MCP STDIO advisory) bypasses binary
# allowlists via argument injection: npx -c, node -e, python3 -c.
# Phase 5.5 will add argument-pattern validation using empirical profiles
# from eval/argument_allowlist.json (proposal 2026-04-20 A6).
# See: knowledge_base/agentic-ai/analysis/2026-04-20.md Finding 2
```

No functional change — this documents the gap for Phase 5 implementors.

---

## No Skill Description Changes Needed

No changes to any agent's `description` field are indicated by today's findings. The current trigger descriptions are performing well (0.95 uniform trigger rate). The vendor freeze means no new terminology or capabilities have emerged that would require description updates.

---

*These suggestions do NOT modify skill files directly. They are proposals for factory-steward implementation.*
