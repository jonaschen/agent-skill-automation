---
sidebar_position: 3
title: Roadmap & KPIs
---

# Roadmap & Key Performance Indicators

## Current Status

**Phase 4 in progress.** Phases 0-3 core complete. Measurement infrastructure built and verified. Security hardening expanded with MCP content validation, dependency pinning, and model migration runbook.

Latest optimization metrics (G8 Iter 2):
- **Training**: T=0.895
- **Validation**: V=0.900
- Validation passed the 0.85 overfit threshold

## Acceptance KPIs

| Metric | Target | Phase | Status |
|--------|--------|-------|--------|
| Deployment gate | `posterior_mean >= 0.90`, `ci_lower >= 0.80` | 2-3 | Met |
| Optimization success rate | `>= 75%` Skills raised to `>= 90%` in `<= 50` iterations | 3 | In progress |
| Repeatability | Two runs' 95% CIs overlap | 3 | Met |
| Overfit protection | `Train >= 0.90` AND `Validation >= 0.85` | 3 | Met |
| End-to-end pipeline time | `<= 4` hours requirements to deployed Skill | 4 | In progress |
| TCI routing accuracy | `>= 95%` on 50-task benchmark | 5 | Pending |
| Edge task success rate | `>= 85%` vs cloud baseline | 6 | Pending |
| Billing accuracy | 100% of successful interactions billed | 7 | Pending |

## Phase-by-Phase Goals

### Phase 0: Repository Bootstrap (Complete)

Established directory structure and skeleton files.

### Phase 1: Meta-Agent Factory (Complete)

Working `meta-agent-factory` that generates format-compliant, permission-correct SKILL.md files from natural language. Achieved `>= 90%` format compliance on first attempt and 100% permission violation interception.

### Phase 2: Quality Validator + CI/CD Gate (Complete)

Objective, automated quality gating. No Skill deploys with trigger rate below 90% without human override. Built the eval runner, adversarial test cases, Bayesian scoring, flaky detection, and deployment gate.

### Phase 3: AutoResearch Optimizer (Core Complete)

Unattended trigger rate optimization using the AutoResearch pattern. Async evaluation, Bayesian scoring, train/validation split, semantic prompt cache. First optimization runs exceeded deployment gate thresholds.

### Phase 4: Closed Loop (Current)

Fully unattended factory-validate-optimize-deploy pipeline. Security hardening (MCP validation, dependency pinning). Closed-loop state machine for autonomous operation.

### Phase 5: Topology-Aware Multi-Agent (Planned)

Task Coupling Index (TCI) routing, Scrum team orchestration (PO/Dev/QA), watchdog circuit breaker for loop detection and token budget enforcement.

### Phase 6: Edge AI + Cloud-Edge Hybrid (Planned)

Edge Talker (System 1) for on-device zero-latency inference. Cloud Reasoner (System 2) for async deep reasoning. ONNX/GGUF model packaging, OTA updates, MQTT/gRPC state sync.

### Phase 7: AaaS Commercialization (Planned)

Outcome-based billing engine, multi-tenancy, cross-regional HA (Taiwan, Japan), compliance audit trail (ISO 27001 / APPI).

## Collaboration Protocol

Task lifecycle is tracked in `ROADMAP.md`:

```
Task added (pending)
    |
    v
Agent picks up task, starts work
    |
    v
Agent completes, updates ROADMAP.md (done / rejected / needs rework)
```

**Gate protocol**: When a task has a gate condition, the agent checks by reading `ROADMAP.md`. If the gate condition is not met, the task is marked `BLOCKED: <reason>`.

**Conflict resolution**: The version that passes `eval/check-permissions.sh` wins. If both pass, the version with the higher Bayesian posterior mean wins. Otherwise, the human decides.
