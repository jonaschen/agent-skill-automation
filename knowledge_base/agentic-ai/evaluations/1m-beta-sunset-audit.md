# 1M Context Beta Sunset Audit

**Date**: 2026-04-18
**Source**: Research-lead directive 2026-04-18 P1
**Status**: AUDIT COMPLETE — no code changes needed

---

## Question (from directive)

Does our fleet use 1M context headers or beta features? What replaces 1M beta?
Is extended context a GA feature on Opus 4.7, or does it require new API flags?

## Findings

### 1. Beta header grep — CLEAN

Searched all operational code (scripts/, eval/, .claude/) for:
- `anthropic-beta`
- `max-tokens-3-5-sonnet`
- `context-1m-*`
- `interleaved-thinking`
- `extended-context`

**Result: Zero hits in operational code.**

Our fleet uses `claude -p` CLI invocations exclusively. The CLI handles context
window negotiation internally — we never set beta headers directly. No API calls
use raw `anthropic-beta` header injection.

### 2. model_audit.sh already monitors

`scripts/model_audit.sh` (lines 105-140) already checks for three deprecated beta
patterns in scripts/, eval/, .claude/:
- `context-1m-2025-08-07`
- `interleaved-thinking`
- `max-tokens-3-5-sonnet`

This check runs as part of `pre-deploy.sh` and can be triggered manually. It's
warning-only until the sunset date (2026-04-30), then would fail the deploy gate.

### 3. What replaces 1M beta?

Per Anthropic model releases documentation:
- **Opus 4.6 and Sonnet 4.6**: 1M context is GA (no beta header needed)
- **Opus 4.7**: 1M context is GA (native support)
- **Sonnet 4 / Sonnet 4.5**: Required beta header `context-1m-2025-08-07` for 1M
  (these models are already being deprecated — Sonnet 4 retires Jun 15)

Our fleet runs on Opus 4.6 (orchestration) and Sonnet 4.6 (review). Both support
1M context natively. **No migration needed.**

### 4. Risk assessment

| Scenario | Risk | Mitigation |
|----------|------|-----------|
| Beta sunset breaks our fleet | **None** — fleet uses GA models with native 1M | N/A |
| Someone adds a legacy model reference | **Low** — model_audit.sh catches it in pre-deploy | Already active |
| CLI internally uses beta headers | **None** — CLI v2.1.111 handles this; Anthropic's responsibility | Fleet version check active |

## Conclusion

**No code changes needed for the 1M context beta sunset (Apr 30).** Our fleet is
entirely on GA models (Opus 4.6, Sonnet 4.6) that support 1M natively. The
`model_audit.sh` proactive check provides defense-in-depth against accidental
regression.

The research-lead can deprioritize this topic from P1 to P2/watch-only.
