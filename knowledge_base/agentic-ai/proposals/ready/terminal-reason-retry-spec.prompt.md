# Ready-to-Execute: terminal_reason Retry Spec + SDK Migration Notes

**Source proposal**: `knowledge_base/agentic-ai/proposals/2026-04-06-terminal-reason-retry-spec.md`
**Priority**: P1
**Target agent**: factory-steward (spec addition to migration runbook)
**Generated**: 2026-04-06

---

## Prompt for factory-steward

Add two items to `eval/model_migration_runbook.md`:

### Addition 1: terminal_reason Differentiated Retry Logic

Add a new section "Closed-Loop State Machine: terminal_reason Retry Table" with this content:

```markdown
## Closed-Loop State Machine: terminal_reason Retry Table

When migrating from CLI-based invocation to Agent SDK, the closed-loop state machine
should use the `terminal_reason` field (added in Agent SDK v0.2.91) for differentiated
retry logic:

| `terminal_reason` | Action | Rationale |
|---|---|---|
| `completed` | Proceed to next state | Normal completion |
| `max_turns` | Retry with `--max-turns` doubled, up to 3 retries | May indicate reasoning budget exhaustion, not misrouting |
| `aborted_tools` | Log tool failure, skip to REPORT_FAILURE (don't retry) | Tool is broken — retrying won't help |
| `blocking_limit` | Exponential backoff (30s, 60s, 120s), then REPORT_FAILURE | Rate limit or resource contention |

**Diagnostic note**: `max_turns` termination on positive prompts may indicate reasoning
budget exhaustion rather than genuine misrouting. Cross-reference with routing regression
diagnosis before concluding the description is wrong.
```

### Addition 2: SDK v0.2.91 Strict Sandbox Default

Add to the SDK migration checklist:

```markdown
### Agent SDK v0.2.91: Strict Sandbox Default

As of v0.2.91, `failIfUnavailable` defaults to `true` for sandbox environments.
When migrating:
- In production: keep the default (`failIfUnavailable: true`) for security
- In development/CI: explicitly set `failIfUnavailable: false` to avoid false failures
  when sandbox infrastructure is not provisioned
```

### Validation

Read back `eval/model_migration_runbook.md` after editing to confirm both sections are present and correctly formatted.
