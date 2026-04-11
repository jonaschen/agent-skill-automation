# Deferred Items — 2026-04-12

**Date**: 2026-04-12
**Source**: Discussion 2026-04-12 (DEFER + REJECT decisions)

## DEFER

### D1: Crash Recovery from Session Logs
- **Original proposal**: Read session logs on startup to detect incomplete tasks and resume
- **Reason**: Steward agents are stateless by design — resume-from-log requires solving
  "what to do with incomplete tasks" (retry? skip? cleanup?). Hard problem, low urgency at Phase 4.
- **Revisit when**: Phase 5 implementation begins, where external session state is a first-class requirement
- **Dependency**: Session state logging (ADOPT A1) must be implemented first

### D2: Lazy Provisioning for Steward Agents
- **Original proposal**: Add pre-flight work checks to all steward scripts
- **Reason**: Stewards advance ROADMAP tasks autonomously — they generate commits, not just
  react to them. "No new commits in target repo" is a poor skip signal since the steward
  is the one making commits. Work detection requires understanding ROADMAP task state.
- **Revisit when**: Event source infrastructure exists (post-MCP Triggers & Events spec, ~June 2026+)
- **Note**: Researcher lazy provisioning (ADOPT A2) is the validated first step

### D3: CLAUDE.md Structural Split (Static + Dynamic)
- **Original proposal**: Split CLAUDE.md into cacheable static base and frequently-updated dynamic status
- **Reason**: Correct for Agent SDK prompt cache optimization but premature — no shared
  session caches in current cron model. Agent SDK `exclude_dynamic_sections` isn't relevant
  until Phase 5. Simpler alternative: move dynamic status line to ROADMAP.md header.
- **Revisit when**: Phase 5 implementation begins and Agent SDK adoption is underway
- **Simpler fix now**: Move the daily countdown/status line from CLAUDE.md to ROADMAP.md

### D4: Standalone Hybrid Scheduling Design Document
- **Original proposal**: Create full design doc for cron + MCP event trigger hybrid
- **Reason**: MCP Triggers & Events spec is "On the Horizon" with no draft. Full design doc
  risks staleness if spec takes a different direction. A lightweight ROADMAP note (ADOPT A6)
  captures the agent classification without premature design.
- **Revisit when**: MCP Triggers & Events spec draft appears (~June 2026)

## REJECT

### R1: Sonnet 4.6 Knowledge Freshness Evaluation
- **Original proposal**: Compare Opus 4.6 vs Sonnet 4.6 on 10 knowledge-freshness prompts
- **Reason**: Researcher uses WebSearch/WebFetch for current events — training cutoff is
  irrelevant for fact retrieval. Opus's reasoning advantage dominates for analysis quality
  (interpreting findings, strategic recommendations). Mixed-model execution (Sonnet for
  planning, Opus for analysis) adds latency and complexity without clear benefit.
- **Alternative**: If evaluating Sonnet for cost savings, target simpler agents like
  project-reviewer where reasoning depth matters less.
