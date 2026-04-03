# Skill Proposal: x402 Agent Payment Evaluation
**Date**: 2026-04-04
**Triggered by**: x402 Foundation launch at MCP Dev Summit — universal agent payment protocol backed by Visa, Mastercard, Stripe, AWS, Google, Amex; embeds payments into HTTP
**Priority**: P3 (nice-to-have)
**Target Phase**: Phase 7 (AaaS pre-task)

## Rationale

Our Phase 7 `outcome-billing-engine` is designed around OpenTelemetry spans + Stripe subscription/invoice billing. x402 introduces a fundamentally different model: per-invocation HTTP-level payments where agents autonomously pay for API/MCP server access. This could:

1. **Simplify** our billing model for per-use agent payments (no billing agreements needed)
2. **Enable** agent-to-agent payments that our current tenant model doesn't account for
3. **Complement** (not replace) Stripe for subscription billing

Given the backing from Visa, Mastercard, Stripe, AWS, and Google, x402 has serious institutional momentum. We should evaluate it before finalizing Phase 7 billing architecture.

## Proposed Specification

- **Name**: x402-billing-evaluation
- **Type**: Phase 7 pre-task (evaluation, not implementation)
- **Description**: Evaluate x402 protocol for per-use agent payments, determine whether it replaces or complements Stripe integration
- **Key Capabilities** (evaluation scope):
  - x402 protocol compatibility with our OpenTelemetry instrumentation
  - Per-invocation micropayment feasibility (latency, fees, settlement)
  - Agent-to-agent payment flows for multi-tenant scenarios
  - Regulatory implications (PDPA, APPI) for automated payments
- **Tools Required**: WebSearch, WebFetch (research only)

## Implementation Notes

- This is an evaluation task, not an implementation task
- Timeline: begin when Phase 7 planning starts (Month 12+)
- Decision output: "use x402 for per-use payments + Stripe for subscriptions" OR "Stripe only"
- Monitor x402 spec evolution in researcher sweeps

## Estimated Impact

- Informs Phase 7 billing architecture with 6+ months of lead time
- Could simplify the per-use billing path significantly
- Avoids costly architecture rework if x402 becomes the standard after we've built Stripe-only
