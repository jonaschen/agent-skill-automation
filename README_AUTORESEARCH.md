# How This DEV PLAN Uses Andrej Karpathy's AutoResearch

> **Document:** `README_AUTORESEARCH.md`
> **Relates to:** `AGENT_SKILL_AUTOMATION_DEV_PLAN.md` — Section 7: AutoResearch Optimization Engine Design
> **Source project:** [karpathy/autoresearch](https://github.com/karpathy/autoresearch) (MIT License, ~49k GitHub stars as of March 2026)

---

## What AutoResearch Actually Is

On March 7, 2026, Andrej Karpathy pushed a 630-line Python script to GitHub and went to sleep. By morning, his agent had run 50 experiments, discovered a better learning rate, and committed the proof to git — without a single human instruction in between.

The repo is minimal by design. It has exactly three moving parts:

| File | Role |
|------|------|
| `train.py` | The **only mutable asset** — the training script the agent is allowed to modify |
| `program.md` | A Markdown file carrying instructions, constraints, and stopping criteria for the agent |
| `val_bpb` (bits per byte) | The **single scalar metric** the agent optimizes against |

The loop is:

```
Read train.py → Form a hypothesis → Modify code → Train for exactly 5 minutes
→ Check val_bpb → Better? Commit. Worse? Revert. → Repeat overnight.
```

The fixed 5-minute training budget is not an arbitrary constraint. It is what makes every experiment directly comparable, regardless of what the agent changed — model size, batch size, architecture, anything. Comparable experiments are the foundation of trustworthy optimization.

After two days of running on Karpathy's own already well-tuned model, the agent found 20 additive improvements — including a bug in the attention implementation he had missed entirely after years of manual work. The 11% efficiency gain stacked perfectly onto the larger model.

Shopify CEO Tobi Lutke tried the same pattern on Liquid, Shopify's templating engine. The agent made 93 automated commits and produced 53% faster rendering with 61% fewer memory allocations.

---

## The Core Insight: The Pattern Is Domain-Independent

The ML community focused on the loss curves. The broader insight — which this DEV PLAN is built on — is that **the pattern has nothing to do with GPUs or neural networks**.

It works on anything you can score with a number. The three non-negotiable ingredients are:

1. **A single mutable asset** — one file the agent can modify, nothing else
2. **A scalar metric** — one number that goes up when things get better
3. **A fixed evaluation budget** — identical conditions for every experiment so results are comparable

The most underappreciated file in the entire AutoResearch repo is `program.md`. As the New Stack noted, this single Markdown document simultaneously handles three registers of communication that no other common format covers together: instructions (what the agent should search for), constraints (what must not change), and stopping criteria (when to stop). YAML encodes structure but not reasoning. Python is executable but not legible as strategy. JSON has no narrative. Markdown sits at the exact intersection of human editability and agent parseability.

This is the structural insight this DEV PLAN directly inherits.

---

## The Substitution This DEV PLAN Makes

The DEV PLAN transplants the AutoResearch loop into the domain of Claude Agent Skill optimization by making three clean substitutions:

| AutoResearch (original) | This DEV PLAN (transplanted) | Why the substitution works |
|------------------------|------------------------------|---------------------------|
| `train.py` — Python training code | `SKILL.md` — Markdown instruction file | Both are single mutable text files that fully define the system's behavior. Each modification produces a clean, reviewable git diff. |
| `val_bpb` — bits per byte on validation set | **Binary eval pass rate** — does the Skill trigger correctly AND produce valid structured output? | Both are scalar numbers with a clear direction (lower bpb = better; higher pass rate = better). Neither requires subjective human judgment. |
| 5-minute GPU training budget | **Fixed test set** — the same N test cases run every evaluation, without exception | Both enforce identical evaluation conditions across all experiments. This is what makes version A and version B directly comparable. |
| Agent modifies Python code syntax | Agent modifies natural language instruction text | The optimization target shifts from syntax to semantics, but the loop structure is identical. The LLM itself acts as the optimizer. |

The loop in the DEV PLAN's `autoresearch-optimizer` Skill is structurally identical to Karpathy's original:

```
Read SKILL.md → Analyze failing test cases → Propose instruction modification
→ Apply modification → Run fixed test set in isolated sandbox
→ Pass rate improved? Commit. Worse or same? Revert. → Repeat.
```

---

## What Is Directly Reusable vs. What You Must Build

This is the most important section to read before starting implementation. The DEV PLAN uses AutoResearch as a **design pattern transplant**, not a code dependency. Be precise about what exists today and what needs to be built.

### What you can use directly from the AutoResearch repo today

**The `program.md` structural pattern.** This is the most immediately reusable artifact. Before writing a single line of optimization code, write a `program.md` equivalent for your `autoresearch-optimizer` Skill. It should specify:
- The target asset path (the SKILL.md being optimized)
- The evaluation command (how to run your test set and get a pass rate number)
- What the agent is allowed to modify (description field? full Markdown body? scripts/?)
- What is off-limits (YAML tool permissions are never touched by the optimizer)
- The stopping criterion (target pass rate, or max iterations)

**The keep-or-revert via git pattern.** AutoResearch uses git as its experiment ledger — every trial is a potential commit, every failure is a revert. Your optimization loop can adopt this directly. It costs nothing and gives you a full experiment history for free.

**The fixed-budget comparability principle.** Your "budget" is not GPU minutes — it is a fixed test set. Decide on a size (30 test cases is a reasonable starting point) and never change it mid-optimization run. This is the same discipline AutoResearch enforces with its 5-minute timer.

### What the AutoResearch repo does NOT provide (you build this)

**The eval runner.** AutoResearch's equivalent of your evaluation step is just running `train.py` for 5 minutes and reading `val_bpb`. Your equivalent — calling the Claude API with a test prompt, checking whether the correct Skill triggered, validating the output structure — is something you write yourself. This is the engineering work at the core of Phase 2 of the DEV PLAN.

**Parallel branch search.** Karpathy's original code runs a single sequential chain of experiments. The DEV PLAN's parallel version search (simultaneously evaluating Branch A: boundary conditions, Branch B: minimal+script, Branch C: few-shot) is an extension the repo does not include. Karpathy himself noted on X that the next step for AutoResearch is "asynchronously massively collaborative for agents — the goal is not to emulate a single PhD student, it's to emulate a research community of them." The parallel search in this DEV PLAN is exactly that direction — you are building it.

**The MDP / PPO layer.** The base AutoResearch uses a greedy hill-climbing strategy — try something, keep it if it's better, discard if not. The MDP formalization and PPO-guided modification direction described in the DEV PLAN's Section 7 is an advanced extension that treats the experiment history as training data for the optimizer itself. This is Phase 3 work and is currently in research territory, not production-ready tooling you can import.

**Model distillation.** The heterogeneous model distillation feature — using the optimizer to rewrite SKILL.md until a Haiku-class model reaches 90% of Opus-class performance — is a novel application of the AutoResearch pattern with no existing implementation. You design the baseline dataset, the distillation eval criteria, and the comparison framework from scratch.

---

## The Practical Starting Point

If you want to begin tomorrow, the minimum viable version of the AutoResearch pattern applied to Skill optimization is 40 lines of shell script and one Markdown file. Here is the structure:

**`skill-optimizer-program.md`** (your `program.md` equivalent):

```markdown
## Target
Optimize: .claude/skills/my-skill/SKILL.md
Metric: trigger_rate (run: bash eval/run_eval.sh)
Goal: trigger_rate >= 0.90

## What you may modify
- The `description` field in YAML Frontmatter
- Any content in the Markdown body below the frontmatter divider

## What you must never modify
- The `tools:` list
- The `model:` field
- Any file outside the target SKILL.md

## Per-experiment budget
Run eval/run_eval.sh exactly once per experiment.
The test set is fixed at 30 prompts. Do not add or remove prompts.

## Stopping criteria
Stop when trigger_rate >= 0.90, or after 50 iterations, whichever comes first.
Report the best version found and the experiment trajectory.
```

**`eval/run_eval.sh`** (your equivalent of `train.py`):

```bash
#!/bin/bash
# Run 30 fixed test prompts against the target Skill.
# Print a single float to stdout: the pass rate.
SKILL_PATH=$1
PASS=0
TOTAL=30

for i in $(seq 1 $TOTAL); do
  RESULT=$(claude run --skill "$SKILL_PATH" < eval/prompts/test_$i.txt 2>/dev/null)
  EXPECTED=$(cat eval/expected/test_$i.txt)
  if echo "$RESULT" | grep -q "$EXPECTED"; then
    PASS=$((PASS + 1))
  fi
done

echo "scale=4; $PASS / $TOTAL" | bc
```

Point Claude Code at `skill-optimizer-program.md` and let it run overnight. This is the Karpathy loop, applied to your Skill.

---

## What the Pattern Ultimately Enables

The deepest value of the AutoResearch transplant is not the individual Skill improvement. It is the shift in who does the optimization work.

Manual prompt engineering is a linear, human-bottlenecked process. One engineer, one Skill, one round of edits at a time. With the AutoResearch loop running overnight, the bottleneck moves from human iteration speed to evaluation throughput. The human's role shifts from experimenter to experimental designer — which is exactly what Karpathy described as the consequence of AutoResearch: "the role of the human shifts from experimenter to experimental designer."

For an enterprise maintaining dozens or hundreds of Skills across multiple agent legions, this is not a productivity gain. It is an architectural change in how AI capability is maintained at scale.

---

## Key References

- [karpathy/autoresearch](https://github.com/karpathy/autoresearch) — The source repo (MIT License)
- [The New Stack: Karpathy's Autonomous Experiment Loop](https://thenewstack.io/karpathy-autonomous-experiment-loop/) — Best technical breakdown of the `program.md` pattern
- [VentureBeat: Karpathy's autoresearch lets you run hundreds of AI experiments a night](https://venturebeat.com/technology/andrej-karpathys-new-open-source-autoresearch-lets-you-run-hundreds-of-ai) — Shopify/Liquid case study detail
- [Karpathy on X: next step for autoresearch](https://x.com/karpathy/status/2030705271627284816) — His own statement on the collaborative agent research community direction

---

*This README is a companion document to `AGENT_SKILL_AUTOMATION_DEV_PLAN.md`. It provides the technical rationale and implementation guidance for Section 7 (AutoResearch Optimization Engine Design) of that plan.*
