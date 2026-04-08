# Skill Update Suggestions — 2026-04-09

**Source**: Analysis 2026-04-09 + Discussion 2026-04-09
**Author**: agentic-ai-researcher (Mode 2c: L4 Strategic Planning)

---

## 1. All 8 Daily Scripts — Add `effort_level` to Performance JSON (P1 — ADOPT #6)

**Files affected**: `scripts/daily_factory_steward.sh`, `scripts/daily_research_sweep.sh`, `scripts/daily_android_sw_steward.sh`, `scripts/daily_arm_mrs_steward.sh`, `scripts/daily_bsp_knowledge_steward.sh`, `scripts/daily_project_reviewer.sh`

**Change**: In each script's performance JSON block, add:
```bash
"effort_level": "${CLAUDE_CODE_EFFORT:-default}",
```

**Why**: Enables data-driven correlation between effort level and duration/cost. Without this field, the 3-day monitoring window for the effort level change produces only duration data (noisy proxy for cost).

---

## 2. All 8 Daily Scripts — Prepare Commented-Out Effort Config (P1 — ADOPT #1)

**Files affected**: Same 6 scripts as above, plus the two additional factory-steward time slots.

**Change**: Add near the top of each script (after `unset TERMINAL` and `export CLAUDE_INITIATOR_TYPE`):
```bash
# Per-agent effort level (uncomment to override default 'high'):
# Reasoning-heavy agents (factory, researcher, reviewer): keep high
# Routine stewards (android-sw, arm-mrs, bsp-knowledge): can use medium
# export CLAUDE_CODE_EFFORT=medium  # Uncomment if cost ceiling alerts fire
```

For factory-steward, researcher, reviewer scripts:
```bash
# export CLAUDE_CODE_EFFORT=high  # Already the default; uncomment only to make explicit
```

**Why**: Prepares the remediation path so it can be activated in 5 minutes if cost monitoring reveals >50% cost increase within the 3-day window.

---

## 3. Three Steward Scripts — Cross-Project Deprecation Check (P1 — ADOPT #7)

**Files affected**: `scripts/daily_android_sw_steward.sh`, `scripts/daily_arm_mrs_steward.sh`, `scripts/daily_bsp_knowledge_steward.sh`

**Change**: Add pre-flight check after existing setup:
```bash
# Cross-project deprecation check (warning only)
if [ -x "eval/model_deprecation_check.sh" ]; then
  if ! eval/model_deprecation_check.sh "$TARGET_REPO/.claude/" 2>/dev/null; then
    echo "WARNING: Deprecated models found in $TARGET_REPO/.claude/" | tee -a "$LOG_FILE"
    # Steward will add to steering notes during its run
  fi
fi
```

**Constraints**:
- Warning only, not blocking — stewards don't own external repos' model choices
- Only scan `.claude/` subdirectory — model IDs in docs/tests are not functional references
- Log warning and let steward add to steering notes during its run

---

## 4. `agentic-ai-researcher.md` — No Changes Needed

The researcher agent already has:
- Automated `deprecated_models.json` maintenance (added 2026-04-08)
- Google I/O-specific sweep queries (added 2026-04-08)
- Managed Agents, `ant` CLI, and context compression are covered in today's sweep/analysis

No description or capability changes required.

---

## 5. `factory-steward.md` — No Changes Needed

The factory steward's description and capabilities already cover acting on ADOPT items from research discussions. Today's ADOPT items (effort config, perf JSON fields, deprecation checks) fall within its existing scope.

---

## 6. Deprecated Models Verification — Immediate Check (P0 — ADOPT #2)

**File**: `eval/deprecated_models.json`

**Action**: Verify that the following entry exists:
```json
{
  "model_id": "claude-3-haiku-20240307",
  "retirement_date": "2026-04-19",
  "replacement": "claude-haiku-4-5-20251001",
  "source": "anthropic.com/docs/model-deprecations"
}
```

Also verify that `eval/model_deprecation_check.sh` grep pattern handles both old-format IDs (date-suffixed: `claude-3-haiku-20240307`) and new-format IDs (version-suffixed: `claude-opus-4-6`). The 10-day countdown to April 19 makes this verification urgent.

---

## Deferred Skill Changes

| Change | Reason | Revisit |
|--------|--------|---------|
| `estimated_tokens` field in perf JSONs | No parseable token output from Claude Code | When session summaries become machine-readable |
| Managed Agents adapter script | Beta API, will change | Phase 7 start |
| Cross-platform format comparison | Gemini CLI skills format is preview | Phase 7 start |

---

*Generated 2026-04-09 by agentic-ai-researcher (Mode 2c: L4 Strategic Planning)*
