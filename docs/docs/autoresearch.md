---
sidebar_position: 3
title: AutoResearch Pattern
---

# The AutoResearch Pattern

The optimization engine at the heart of this project is a direct transplant of [Andrej Karpathy's AutoResearch pattern](https://github.com/karpathy/autoresearch) into the domain of Claude Agent Skill optimization.

## What AutoResearch Is

On March 7, 2026, Andrej Karpathy pushed a 630-line Python script to GitHub and went to sleep. By morning, his agent had run 50 experiments, discovered a better learning rate, and committed the proof to git — without a single human instruction in between.

The repo has exactly three moving parts:

| File | Role |
|------|------|
| `train.py` | The **only mutable asset** — the training script the agent is allowed to modify |
| `program.md` | A Markdown file carrying instructions, constraints, and stopping criteria |
| `val_bpb` (bits per byte) | The **single scalar metric** the agent optimizes against |

The loop:

```
Read train.py -> Form a hypothesis -> Modify code -> Train for exactly 5 minutes
-> Check val_bpb -> Better? Commit. Worse? Revert. -> Repeat overnight.
```

The fixed 5-minute training budget makes every experiment directly comparable, regardless of what the agent changed. Comparable experiments are the foundation of trustworthy optimization.

## The Core Insight

The ML community focused on the loss curves. The broader insight is that **the pattern has nothing to do with GPUs or neural networks**. It works on anything you can score with a number.

Three non-negotiable ingredients:

1. **A single mutable asset** — one file the agent can modify, nothing else
2. **A scalar metric** — one number that goes up when things get better
3. **A fixed evaluation budget** — identical conditions for every experiment

## The Substitution

This project transplants the loop by making three clean substitutions:

| AutoResearch (original) | This Project | Why it works |
|------------------------|-------------|--------------|
| `train.py` — Python code | `SKILL.md` — Markdown instruction file | Both are single mutable text files that fully define behavior |
| `val_bpb` — bits per byte | **Bayesian posterior trigger rate** — mean + 95% CI | Both are scalars with a clear direction |
| 5-minute GPU budget | **Fixed test set** — same 54 prompts every run | Both enforce identical evaluation conditions |
| Agent modifies Python syntax | Agent modifies natural language instructions | Optimization target shifts from syntax to semantics |

The resulting loop in `autoresearch-optimizer`:

```
Read SKILL.md -> Analyze failing test cases -> Propose instruction modification
-> Apply modification -> Run fixed test set in isolated sandbox
-> Pass rate improved? Commit. Worse or same? Revert. -> Repeat.
```

## What Is Reusable vs. What Was Built

### Directly reusable from AutoResearch

- **The `program.md` structural pattern** — instructions, constraints, and stopping criteria in one Markdown document
- **The keep-or-revert via git pattern** — git as the experiment ledger
- **The fixed-budget comparability principle** — never change the test set mid-optimization

### Built for this project

- **The eval runner** (`eval/run_eval_async.py`) — calls Claude API with test prompts, checks trigger correctness, validates output structure
- **Parallel branch search** — simultaneously evaluates multiple modification strategies (A/B/C/D branches)
- **Bayesian scoring** (`eval/bayesian_eval.py`) — posterior mean + credible intervals instead of raw pass rates
- **Train/validation split** (`eval/splits.json`) — prevents the optimizer from overfitting to the test set
- **Semantic prompt cache** (`eval/prompt_cache.py`) — reduces API calls ~40% per iteration

## Commit Decision Rule

A description change is accepted **only** when:

```
new_ci_lower > old_ci_upper
```

Raw pass rate increase alone is insufficient — it may be measurement noise. The Bayesian credible interval non-overlap test provides statistical confidence.

## Results

After two iterations on the `meta-agent-factory` skill:
- **Training**: posterior mean 0.895, CI [0.818, 0.983]
- **Validation**: posterior mean 0.900, CI [0.604, 0.940]
- Exceeds the 0.90 deployment gate on training
- Validation passed the 0.85 overfit threshold
