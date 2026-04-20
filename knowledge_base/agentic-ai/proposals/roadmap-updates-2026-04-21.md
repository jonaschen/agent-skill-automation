# ROADMAP Update Recommendations — 2026-04-21

**Source**: Analysis 2026-04-21, Discussion 2026-04-21
**Reviewer**: agentic-ai-researcher (Mode 2c)

---

## PROPOSED CHANGE 1: Update Phase 6 with Gemma 4 Edge Benchmark Data

**Section**: Phase 6 → Task 6.1 Edge Readiness Assessment gate
**Type**: Design note addition
**Priority**: P3 (informational, no immediate action)

**Current text**: Task 6.1 references model size ≤ ~1.5GB for Gemma 4 E2B/E4B

**Proposed addition** (append as design note after task 6.1):

```
> **Design note (2026-04-21)**: Gemma 4 edge benchmarks confirmed: <1.5GB RAM, RPi5 at 133 prefill tok/s (CPU), Qualcomm NPU at 3,700 prefill tok/s. LiteRT-LM processes 4,000 input tokens + 2 skills in <3 seconds (GPU). Our SKILL.md files are <5K tokens — within the 128K context window. LiteRT-LM should be evaluated as an alternative runtime alongside ONNX/GGUF when Phase 6 design begins. Reference: analysis 2026-04-21 Finding 3.
```

**Rationale**: Concrete hardware numbers de-risk Phase 6 feasibility. LiteRT-LM's "4K tokens + 2 skills in <3s" maps directly to our SKILL.md execution model. Recording this now prevents re-research when Phase 6 starts.

---

## PROPOSED CHANGE 2: Update Phase 5 A2A Design Principle with Production Scale Data

**Section**: Phase 5 → Task 5.3.0 design principle
**Type**: Update existing design note
**Priority**: P3 (informational)

**Current text**: "A2A is now the de facto inter-agent standard (150+ orgs, triple hyperscaler integration)"

**Proposed update**: The current text already captures the key data point. However, the analysis reveals additional specifics worth recording:

```
> **Update (2026-04-21)**: A2A 1-year anniversary data confirms production scale: 150+ organizations, 22K+ stars, 5 SDK languages (Python, JS, Java, Go, .NET), triple-hyperscaler production (Azure AI Foundry, AWS Bedrock AgentCore, Google Cloud). AP2 (Agent Payments Protocol) at 60+ financial services orgs. A2A has achieved multi-vendor runtime interoperability — our fleet manifest should validate against A2A Agent Card v1.0 schema. Reference: analysis 2026-04-21 Finding 2.
```

**Rationale**: The 5-SDK-language coverage and AP2 adoption are new data points since the last update. They strengthen the case for A2A adoption in Phase 5 and inform the fleet manifest field mapping.

---

## PROPOSED CHANGE 3: Add Factory-Steward Priority Queue to Phase 4 Status

**Section**: Phase 4 (top-level status or as note)
**Type**: Operational note
**Priority**: P2 (factory guidance)

**Proposed addition** (for next directive, not ROADMAP directly):

The following factory-steward priority queue emerges from the 2026-04-21 discussion:

1. Shadow eval gate check (5 seconds)
2. A4: Validator inline tests (P2, 10 min)
3. A1: Fleet manifest (P2, 30 min)
4. A2: ADK v2.0 ↔ TCI comparison framework (P2, 30 min)
5. A3: Phase 5 design index (P3, 20 min)
6. Carried forward: Programmatic Tool Calling deny rule (P1, human action), G20 MCP false-positive tests (P2)

**Note**: This is directive content, not ROADMAP content. Included here for completeness. The research-lead should incorporate this queue into the next directive.

---

## PROPOSED CHANGE 4: No New Risks

The analysis identified no new risks beyond those already tracked. Existing risk entries remain current:

- "Fleet running outdated Claude Code" — still P0, upgrade pending
- "Opus 4.7 silent routing regression" — shadow eval infrastructure complete, awaiting execution
- "A2A v1.0→v1.1 migration risk" — deferred to post-I/O, unchanged
- "MCP ecosystem scale + active exploitation" — contained by Phase 5 transport policy

No additions to the risk table recommended this cycle.

---

## PROPOSED CHANGE 5: Human Action Items (Unchanged)

For research-lead directive inclusion:

1. **Run shadow eval manually** — or verify cron fired: check `crontab -l`, check `logs/performance/shadow-eval-2026-04-20.json`, verify `PENDING_MIGRATION_MODEL` in crontab env
2. **Install Gemini CLI** — gates all S3 research beyond format comparison
3. **Upgrade Claude Code** to v2.1.114+

These are unchanged from the 2026-04-20 directive. No new human action items this cycle.
