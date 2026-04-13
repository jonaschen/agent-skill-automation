# Ready-to-Execute: Eval Suite Expansion from Real-World Logs

**Source proposal**: `knowledge_base/agentic-ai/proposals/2026-04-10-eval-suite-expansion.md`
**Priority**: P1
**Target**: factory-steward

## Task for factory-steward

Audit accumulated skill usage logs and promote informative cases to the eval suite.

### Step 1: Prerequisite check
Count logged invocations across instrumented projects:
```bash
# Check long-term-care-expert logs
wc -l /home/jonas/gemini-home/long-term-care-expert/.claude/skill_usage.log 2>/dev/null || echo "No log found"

# Check The-King-s-Hand logs
wc -l /home/jonas/gemini-home/The-King-s-Hand/.claude/skill_usage.log 2>/dev/null || echo "No log found"
```

**Gate**: If total invocations < 20, defer until more data accumulates. Log the count and stop.

### Step 2: Run audit (if gate passes)
```bash
python scripts/promote_cases.py --audit
```
Identify top 10 most informative real-world triggers not already in eval.

### Step 3: Promote cases
Add selected cases as `eval/prompts/test_55.txt` through `test_64.txt` (or fewer).
Each case needs a corresponding `eval/expected/test_N.txt` with expected trigger/no-trigger.

### Step 4: Update splits
Modify `eval/splits.json` to assign new cases to Training or Validation.
Maintain >= 30% negative controls per set.

### Step 5: Re-baseline
```bash
./scripts/regression_test.sh --update-baseline
```

### Important constraints
- Include both positive (should trigger) and negative (should not trigger) real-world examples
- Maintain T/V split invariant: >= 30% negative controls per set
- Run full eval after expansion to establish new baseline before any optimization
