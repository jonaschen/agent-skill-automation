# Skill Proposal: passive-case-extractor
**Date**: 2026-04-16
**Triggered by**: Gemini CLI v0.39.0-preview.0 passive skill lifecycle (background memory → inbox → approval → activation); cross-pollination opportunity to automate our promote_cases.py triage step.
**Priority**: P2 (medium)
**Target Phase**: Phase 4 / Phase 5 (eval infrastructure continuous improvement)

## Rationale

Our eval set grows by manual promotion: `promote_cases.py` runs occasionally, a human reviews 49+
logged skill invocation entries, and new tests get added. The tedious step is *triage* — deciding
which of the logged entries represent genuinely novel eval cases vs. paraphrases of existing tests.

Gemini CLI's passive skill lifecycle (v0.39.0-preview.0) validates that background observation →
candidate queue → human review → activation is a production-viable pattern. We already have the raw
material: `skill_logger_hook.sh` logs every skill invocation in instrumented projects.

**Discussion consensus (2026-04-16 Round 2)**:
- Adopt passive extraction, but use **eval-runner behavioral novelty detection** (not TF-IDF similarity)
- TF-IDF on 10-30 word prompts has poor discriminative power; sentence-transformers adds 400MB+ dependency
- Behavioral novelty = run candidate through `run_eval_async.py`; if model outcome disagrees with logged
  label, the case is definitionally novel (the model doesn't already handle it correctly)
- Keep human judgment at the activation gate — auto-promotion quality collapse is a real risk

## Proposed Specification

- **Name**: `scripts/passive_case_extractor.py`
- **Type**: Pipeline Script (not a Skill — eval infrastructure tooling)
- **Location**: `scripts/passive_case_extractor.py`

**Key Capabilities**:
1. Read `logs/skill_usage.jsonl` (skill logger hook output)
2. For each logged prompt + observed trigger/no-trigger label:
   a. Run through `eval/run_eval_async.py --single-test` with current SKILL.md
   b. If model response disagrees with observed outcome → flag as "behavioral novelty" candidate
3. Write flagged candidates to `pending_cases/YYYY-MM-DD/` directory with structured metadata
4. Human reviews `pending_cases/` weekly; runs `promote_cases.py` on approved entries

**`pending_cases/` Entry Format** (spec this first, per Engineer's Round 2 requirement):
```json
{
  "prompt": "<text of the prompt>",
  "observed_label": "trigger|no-trigger",
  "model_label": "trigger|no-trigger",
  "disagreement_type": "false_positive|false_negative",
  "source_project": "<project name>",
  "logged_at": "YYYY-MM-DDTHH:MM:SSZ",
  "extracted_at": "YYYY-MM-DDTHH:MM:SSZ",
  "skill": "meta-agent-factory",
  "status": "pending_review"
}
```

**`pending_cases/README.md`** must be written BEFORE the extractor code (per Engineer's note):
- Documents format spec above
- Explains review workflow (weekly, human decides promote/reject)
- Documents `promote_cases.py` integration (how to feed approved entries)
- States what "behavioral novelty" means and why we use it instead of similarity

**Tools Required**: Python 3, asyncio (reuses `run_eval_async.py` infrastructure)

## Implementation Notes

**Dependencies**:
- `logs/skill_usage.jsonl` must exist (it does — skill logger hook is installed in 2 projects)
- `eval/run_eval_async.py` must accept `--single-test <prompt>` flag (verify before implementing)
- `pending_cases/` directory must be created with `README.md` first

**Implementation sequence**:
1. Write `pending_cases/README.md` (format spec)
2. Verify `eval/run_eval_async.py` supports `--single-test` mode
3. Write `scripts/passive_case_extractor.py`
4. Test against existing `logs/skill_usage.jsonl` entries (49 logged)
5. Add `pending_cases/` count to `health_dashboard.py` (per proposal 2.3 / 2026-04-16 discussion)

**Do NOT implement**:
- TF-IDF or sentence-transformers similarity (REJECTED — see discussion)
- Automatic promotion to eval set (keep human at gate)
- Integration into factory-steward session prompt (REJECTED — use health_dashboard.py instead)

**Estimated API cost**: Each candidate evaluation = ~1 API call to eval runner. With 49 logged entries
and ~20% expected novelty rate, initial run = ~10 API calls. Minimal cost.

## Estimated Impact

- Removes tedious manual triage from promote_cases.py workflow
- Eval set grows continuously from real usage rather than ad hoc promotion
- Expected: eval set grows from 59 to 70-80 tests within 60 days from natural usage alone
- Closes the eval set automation gap identified in Phase 4 closed-loop design
- Validates that passive extraction approach is production-viable (Gemini CLI cross-pollination)
