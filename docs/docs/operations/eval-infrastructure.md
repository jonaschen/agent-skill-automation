---
sidebar_position: 2
title: Eval Infrastructure
---

# Evaluation Infrastructure

Accuracy is the only currency. If the measurement tools are flawed, optimization results are meaningless.

## Components

| Tool | Purpose | Status |
|------|---------|--------|
| `eval/run_eval_async.py` | Primary eval runner — asyncio + Semaphore(1) + exponential backoff | Active |
| `eval/bayesian_eval.py` | Bayesian posterior + 95% CI; `--compare` for CI non-overlap test | Active |
| `eval/prompt_cache.py` | Semantic cache — reduces API calls ~40% per optimizer iteration | Active |
| `eval/splits.json` | Train (36) / Validation (18) split — prevents optimizer overfitting | Active |
| `eval/flaky_detector.py` | Bayesian flaky test classifier — reads `eval/flaky_history.json` | Active |
| `eval/check-permissions.sh` | Static YAML validator — enforces mutually exclusive permission rules | Active |
| `eval/tci_compute.py` | Task Coupling Indexer for Phase 5 topology routing | Active |
| `.claude/hooks/pre-deploy.sh` | Deployment gate — enforces Bayesian posterior mean `>= 0.90` | Active |
| `eval/run_eval.sh` | Legacy bash runner — functional but not rate-limit safe at scale | Legacy |

## Test Set

**54 prompts total**: `eval/prompts/test_1.txt` through `test_54.txt`

| Range | Type | Purpose |
|-------|------|---------|
| Tests 1-22 | Positive cases | Should trigger `meta-agent-factory` |
| Tests 23-39 | Hallucination traps | Should NOT trigger (false-positive detection) |
| Tests 40-44 | Cross-domain conflicts | Near-misses with `autoresearch-optimizer` |
| Tests 45-54 | Extended cases | Additional coverage |

### Train/Validation Split

Defined in `eval/splits.json`:
- **Training set** (T, 36 prompts): Optimizer reads failures from these only
- **Validation set** (V, 18 prompts): Held out — used only for final assessment

This split prevents the optimizer from overfitting to the evaluation set.

## Measurement Decision Rules

### Optimization Commit Rule

Accept a description change **only** when:

```
new_ci_lower > old_ci_upper
```

Raw pass rate increase alone is insufficient — it may be measurement noise.

### Deployment Gate

```
posterior_mean >= 0.90 AND ci_lower >= 0.80
```

### Repeatability

Two runs pass when their 95% CIs overlap (not when raw scores differ by `<= 5%`).

### Overfitting Check

```
Training posterior_mean >= 0.90 AND Validation posterior_mean >= 0.85
```

## Bayesian Evaluation

The `bayesian_eval.py` module computes a Beta-Binomial posterior distribution over the trigger rate:

```bash
# Run evaluation and get Bayesian score
python eval/bayesian_eval.py --results eval_output.json

# Compare two versions (CI non-overlap test)
python eval/bayesian_eval.py --compare old_results.json new_results.json
```

The posterior provides:
- **Mean**: best estimate of true trigger rate
- **95% Credible Interval**: the range within which the true rate lies with 95% probability
- **CI non-overlap test**: determines if a change is statistically significant

## Prompt Cache

The `prompt_cache.py` module provides semantic caching for eval runs:

- **Negative tests**: cached description-invariantly (they don't depend on the skill description)
- **Positive tests**: invalidated when the description changes
- Reduces API calls by approximately 40% per optimizer iteration

## Flaky Test Detection

The `flaky_detector.py` module uses Bayesian classification on `eval/flaky_history.json`:

- Tests with inconsistent pass/fail across multiple runs are flagged as flaky
- Requires at least 5 run history entries to make a determination
- Flaky tests are reported but not counted toward the trigger rate

## Running Evaluations

```bash
# Full async evaluation
python eval/run_eval_async.py

# Check permission compliance
bash eval/check-permissions.sh .claude/agents/my-agent.md

# View experiment history
bash eval/show_experiments.sh
```
