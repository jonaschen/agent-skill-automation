# Experiment Design: OTEL Tracing Pilot on Claude CLI
**Date**: 2026-04-18
**Strategic Priority**: S1 (Automatic Agent/Skill Improvement)
**Hypothesis**: Claude Code `claude -p` emits structured OTEL spans (tool calls, API requests, subagent invocations) when OTEL env vars are set, enabling automated behavioral analysis of agent sessions without SDK migration.
**Method**: Run a manual `claude -p` session with OTEL env vars targeting a console/file exporter, capture raw trace JSON, analyze span structure.
**Metrics**: (1) Span types present (tool call, API request, subagent), (2) Attributes per span (token count, duration, agent name, session ID), (3) Trace tree depth and hierarchy, (4) Data volume per session.
**Compute Budget**: 1 manual `claude -p` session (~5 minutes) + analysis time (~1 hour). Total: ~$0.50 + 1.5 hours.
**Status**: design

## Background

The evening analysis (2026-04-18) discovered that OTEL tracing in Claude Code is **CLI-native** — the SDK passes env vars to `claude -p`, and the CLI emits traces directly. This means our existing `claude -p` pipeline can get full distributed tracing by adding 6 environment variables, without the months-long SDK migration previously assumed necessary.

However, the documentation of Claude Code's OTEL span schema is thin. Before designing an OTEL trace analyzer agent (the S1 strategic goal), we need empirical data on what spans `claude -p` actually emits.

## Experiment Design

### Phase 1: Console Exporter Test (30 minutes)

1. Set environment variables:
   ```bash
   export CLAUDE_CODE_ENABLE_TELEMETRY=1
   export CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1
   export OTEL_TRACES_EXPORTER=console
   export OTEL_METRICS_EXPORTER=console
   export OTEL_LOGS_EXPORTER=console
   ```

2. Run a manual test session (NOT production):
   ```bash
   claude -p "Use the meta-agent-factory agent to create a test skill called otel-validation-test that validates OTEL trace output" 2>&1 | tee logs/otel-pilot-raw.txt
   ```

3. Capture: Does trace JSON appear in stdout/stderr? What format?

### Phase 2: File Exporter Test (if console fails) (30 minutes)

If console export doesn't produce visible output:
1. Deploy minimal OTEL collector (single Docker container, stdout JSON exporter):
   ```bash
   docker run --rm -p 4318:4318 otel/opentelemetry-collector-contrib:latest --config /dev/stdin <<EOF
   receivers:
     otlp:
       protocols:
         http:
           endpoint: 0.0.0.0:4318
   exporters:
     file:
       path: /tmp/traces.jsonl
   service:
     pipelines:
       traces:
         receivers: [otlp]
         exporters: [file]
   EOF
   ```

2. Set `OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318` and re-run the test.

### Phase 3: Span Structure Analysis (1 hour)

Analyze captured traces for:

| Question | Why It Matters |
|----------|---------------|
| Are tool calls individual spans? | Enables per-tool-call timing and cost attribution |
| Do subagent invocations create child traces? | Enables multi-agent trace correlation |
| Is token count an attribute? | Enables automated cost analysis |
| Is `session.id` present? | Enables cross-session comparison |
| What is the span hierarchy? | Determines trace tree depth for Phase 5 multi-agent tracing |
| How much data per session? | Determines storage requirements for collector deployment |

## Success Criteria

| Criterion | Pass | Fail |
|-----------|------|------|
| Traces emitted by `claude -p` | Any structured OTEL data captured | No trace output with any exporter config |
| Tool calls visible as spans | Individual spans per Read/Write/Bash/etc. | Tool calls aggregated or absent |
| Subagent hierarchy | Child spans for subagent sessions | Flat span list (no hierarchy) |
| Token attribution | Token count attribute on spans | No token data in traces |

## Next Steps (conditional on results)

- **If traces are rich** (tool spans + subagent hierarchy + token counts): Write OTEL trace analyzer design document. S1 path validated.
- **If traces are minimal** (session-level only, no tool detail): OTEL provides value for timing/cost but not behavioral analysis. S1 needs additional instrumentation.
- **If no traces emitted**: OTEL tracing may require SDK `query()` mode, not `claude -p`. Defer to Phase 5.3.3 CLI-to-SDK migration.

## Results

*To be filled after execution.*

## Conclusions

*To be filled after analysis.*
