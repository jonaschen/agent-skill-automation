# Eval Proposal: MCP Ecosystem False-Positive Test Cases (test_60-64)
**Date**: 2026-04-16
**Triggered by**: 10,000+ MCP servers now registered — MCP vocabulary is mainstream language. Growing risk of false-positive triggers on "configure/debug/update MCP server" prompts that share vocabulary with legitimate meta-agent-factory triggers.
**Priority**: P2 (medium)
**Target Phase**: Phase 2-3 (eval infrastructure maintenance)

## Rationale

The MCP ecosystem has grown to 10,000+ registered servers. As MCP vocabulary becomes mainstream,
user prompts increasingly contain MCP-adjacent language ("configure my MCP server", "debug MCP tool
calls") that partially overlaps with legitimate meta-agent-factory triggers ("create an MCP agent",
"build a new MCP integration").

Current eval coverage:
- test_40-44: cross-domain conflict cases (meta-agent-factory vs. autoresearch-optimizer)
- test_55-59: real-world negative controls (promoted from usage logs)
- **Gap**: No MCP-specific false-positive coverage

Discussion consensus (2026-04-16 Round 2, Engineer): "Five targeted test cases, all T-set additions,
no architecture change required. The 'I need an MCP integration' test case is the most important
because it's the exact near-miss that's hardest to classify."

**Critical process note (Engineer's Round 2)**: The implementation sequence matters to avoid
false regressions on the regression baseline:
1. Add test_60-64 to `eval/prompts/` and `eval/expected/`
2. Update `eval/splits.json` (T=44, V=20)
3. Run `regression_test.sh --update-baseline` to absorb new tests
4. Verify new negatives pass with current description BEFORE committing
5. Commit all together

## Proposed Test Cases

### test_60.txt — "Add MCP authentication to my existing server"
```
I need to add OAuth2 authentication to my existing MCP server. The server currently handles
tool calls but doesn't verify caller identity. Can you help me add authentication?
```
**Expected**: NOT meta-agent-factory (modifying existing server — not creating a new agent)
**Label**: `no-trigger`

### test_61.txt — "Debug failing MCP tool calls"
```
My MCP server's tool calls are failing intermittently. The error is "tool not found" even
though the tool is defined. Can you help me debug why the tool registration isn't working?
```
**Expected**: NOT meta-agent-factory (debugging existing system)
**Label**: `no-trigger`

### test_62.txt — "Update MCP server tool list"
```
I need to update the list of tools my MCP server exposes. I want to add two new tools and
remove one deprecated tool from the server's tool manifest.
```
**Expected**: NOT meta-agent-factory (updating existing server config, not creating new agent)
**Label**: `no-trigger`

### test_63.txt — "Configure MCP server rate limiting"
```
How do I configure rate limiting for my MCP server? I'm getting too many requests from
clients and need to throttle them to 10 requests per minute per client.
```
**Expected**: NOT meta-agent-factory (configuring existing server)
**Label**: `no-trigger`

### test_64.txt — "I need an MCP integration for my GitHub workflow"
```
I need an MCP integration for my project's GitHub workflow. Currently our CI pipeline
doesn't have MCP support and I want to add it.
```
**Expected**: NOT meta-agent-factory (ambiguous — "adding to existing workflow", not creating new agent; "I need an X" usually triggers but context suggests modifying existing system)
**Label**: `no-trigger`
**Note**: This is the hardest edge case. "I need an X" phrasing tends to trigger meta-agent-factory,
but "integration for my GitHub workflow" implies modifying an existing system. This test case
validates the exclusion rules around "modifying existing systems" vs. "creating new agents."

## Implementation Notes

**File locations**:
- `eval/prompts/test_60.txt` through `eval/prompts/test_64.txt`
- `eval/expected/test_60.txt` through `eval/expected/test_64.txt` (content: `no-trigger`)
- `eval/splits.json` update: T from 39 → 44 (all 5 added to Training set)

**Regression baseline update** (mandatory before commit):
```bash
python eval/run_eval_async.py --skill .claude/agents/meta-agent-factory.md
# → verify test_60-64 all return no-trigger with current description
eval/regression_test.sh --update-baseline
# → absorb new tests into baseline
```

**If any of test_60-64 FAILS** (current description triggers on them):
- Do NOT commit the failing tests without fixing the description first
- Use autoresearch-optimizer to refine exclusion rules before adding to eval set
- This is expected for test_64 which is deliberately ambiguous

## Estimated Impact

- Closes MCP ecosystem vocabulary gap in eval suite
- Prevents false-positive trigger rate from degrading as MCP vocabulary becomes more mainstream
- eval set grows from 59 → 64 tests (T=44, V=20)
- Establishes precedent for ecosystem-vocabulary false-positive reviews every 30 days as MCP grows
