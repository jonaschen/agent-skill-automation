# CHALLENGES.md — Why Eval Is Hard and What We Are Doing About It

This document explains the purpose of the G7 (repeatability baseline) and G8
(first live autoresearch run) tasks, why they are time-consuming, and the
fundamental engineering challenges that make this problem harder than it looks.

---

## What G7 and G8 Are Trying to Prove

The pipeline has five agents, an eval runner, 44 test cases, a flaky detector,
and a CI/CD gate. All of it was written in the last week. None of it has been
run as a system.

**G7** is the first reality check: run the eval runner twice and see if it
produces the same number twice. If it does not, nothing downstream — the
optimizer, the gate, the deployment decision — can be trusted, because they all
rely on the eval score as their ground truth.

**G8** is the first end-to-end integration test: does the autoresearch loop
actually close? Can it read a failing test, propose a fix, write it, validate
permissions, run the eval, and commit or revert — repeatedly — without breaking
the repo? Every individual piece has been unit-tested in isolation. G8 tests
whether they work together.

Without G7 and G8, the system is a collection of well-written documents. With
them, it is a running pipeline.

---

## Why It Takes So Long

### One eval run = 44 live API calls

`eval/run_eval.sh` works by calling the Claude CLI once per test prompt:

```
claude --dangerously-skip-permissions -p "$prompt"
```

With 44 test cases and `EVAL_SLEEP=5` between each call, a single eval run
takes a minimum of **3–7 minutes** of wall-clock time, not counting Claude's
processing time per call or any retry delays from rate limiting.

G7 requires two runs with a 90-second gap: roughly **8–15 minutes total**.

G8 requires up to 5 iterations, each containing one full eval run plus analysis,
a description edit, a permission check, and a git operation. That is
**40–75 minutes of wall-clock time** for a 5-iteration validation run.

This is not a software bug. It is the cost of using a live LLM as the test
oracle. Every measurement requires real API calls, real latency, and real money.

---

## The Core Challenge: Measuring a Probabilistic System with a Probabilistic Tool

The eval runner tests whether a skill triggers correctly by sending a prompt to
Claude and observing the output. But Claude's routing decision — whether to
invoke the `meta-agent-factory` skill for a given prompt — is not deterministic.
It depends on:

- The current model state and sampling temperature
- The exact wording of the description field
- Which other skills are loaded and their descriptions
- Whether the model is fresh or has been called many times in a short window
  (rate-limiting degrades response quality before it returns an error)

This creates a **measurement problem**: the tool we use to measure quality
(Claude CLI) is subject to the same non-determinism as the system under test.

### What we observed in practice

| Run | Pass rate | Notes |
|-----|-----------|-------|
| 1   | 0.77      | Fresh session, model responsive |
| 2   | 0.50      | Some tests starting to degrade |
| 3   | 0.27      | Rate-limited — only negative tests pass |
| 4   | 0.27      | Still rate-limited |
| 5   | 0.27      | Still rate-limited |

Run 3–5 scores of 0.27 are not a real signal. They are the
**rate-limit floor**: 8 negative tests passing (Claude returns a minimal
response that does not trigger the skill) and all 22 positive tests failing
(Claude does not have enough capacity to process the skill routing logic
properly). The eval runner now detects this pattern and marks affected tests
as `SKIP:rate-limit` rather than `FAIL`, but skipped tests reduce the sample
size and therefore the statistical confidence of any single run.

---

## The Bootstrap Problem

To optimize the skill description, we need a reliable eval score. To get a
reliable eval score, we need:

1. A non-rate-limited API session
2. Enough gap between runs to let the rate-limit window reset
3. A large enough non-skipped sample to be statistically meaningful

But running the optimizer itself consumes API quota, which makes rate limiting
more likely during the eval runs inside each iteration. The optimizer and the
eval runner are competing for the same resource.

This is the **bootstrap problem**: we cannot reliably measure the skill until
we have already proven the measurement tool is stable, and proving it is stable
requires running it many times — which consumes the quota that stability depends
on.

### Current mitigation (G4)

Gemini's G4 fix added retry logic and `SKIP:rate-limit` detection. The pass
rate is now computed only over non-skipped tests. This helps but does not
eliminate the problem: if 30 of 44 tests are skipped due to rate limiting,
the remaining 14 tests are not a representative sample — positive tests near
the end of the run are more likely to be skipped, which biases the score
upward.

---

## The Deeper Problem: Trigger Routing Is Not Rule-Based

A conventional eval for a rule-based system (e.g., a regex router or a
decision tree) is deterministic: given input X, the system always produces
output Y. You run it once and get a definitive answer.

Skill routing in Claude Code is different. The model reads the description
field and decides — probabilistically — whether the skill applies to the
current prompt. There is no rule that says "if prompt contains 'build an
agent', trigger meta-agent-factory." The model reasons about it, and that
reasoning varies.

This means:

- A description that achieves 0.77 on one run may achieve 0.50 on the next,
  not because the description changed, but because the model's routing decision
  is noisy.
- The true trigger rate of any skill is a distribution, not a point estimate.
  A single eval run gives us one sample from that distribution.
- The Phase 2 acceptance criterion (two runs differ by ≤ 5%) is an attempt to
  bound this variance — but it requires the two runs to be taken under
  comparable conditions (same rate-limit state, same model version).

**This is why Phase 2 repeatability (G7) must be confirmed before optimization
(G8) begins.** If the measurement variance is 20–30%, optimizing against it
will produce a skill description that is overfitted to one noisy sample, not
one that reliably triggers across real usage.

---

## What Success Looks Like

| Milestone | What it proves |
|-----------|---------------|
| G7: two runs, delta ≤ 0.10 | The eval runner is stable enough to be an optimization signal |
| G8: 5 iterations, at least 1 improvement committed | The autoresearch loop closes end-to-end |
| G8: at least 1 revert executed | The safety mechanism works — bad changes are not persisted |
| Final trigger rate after G8 ≥ 0.75 | The skill meets the conditional deployment threshold |

Getting to 0.90 (deployment threshold) will likely require more than 5
iterations and may require accepting some measurement variance as irreducible
noise. The goal of G7 and G8 is not to solve the problem — it is to prove we
understand it well enough to iterate on it systematically.

---

## Strategic Solutions

These four architectural interventions directly address the challenges above.
They are listed in priority order — each one unlocks the next.

---

### Solution 1: Bayesian Evaluation Framework

**Problem it solves**: Single-run pass rate is a noisy point estimate. A score
of 0.77 on one run and 0.50 on the next does not tell us whether the skill
improved or degraded — the difference is within measurement noise.

**The intervention**: Replace the raw pass rate with a Bayesian posterior
estimate. Model the skill's true trigger probability as a Beta distribution.
After N test cases with K passes, the posterior is `Beta(K+1, N-K+1)`. This
gives not just a mean estimate but a **credible interval** — the range within
which the true trigger rate lies with 95% confidence.

**Decision rule for the optimizer**: Accept a description change as a genuine
improvement *only* when the new version's 95% credible interval is entirely
above the old version's 95% credible interval — no overlap. This filters out
changes that merely rode a lucky random sample.

```
Before:  posterior mean 0.62, 95% CI [0.48, 0.75]
After:   posterior mean 0.71, 95% CI [0.58, 0.83]
         → Intervals overlap → NOT a statistically significant improvement → REVERT
```

```
Before:  posterior mean 0.62, 95% CI [0.48, 0.75]
After:   posterior mean 0.88, 95% CI [0.78, 0.95]
         → Intervals do not overlap → GENUINE improvement → COMMIT
```

**Implementation**: `eval/bayesian_eval.py` — takes a list of PASS/FAIL/SKIP
results, outputs posterior mean and credible interval. The autoresearch
optimizer calls this instead of reading the raw pass rate from run_eval.sh.

---

### Solution 2: Async Concurrency + Exponential Backoff

**Problem it solves**: The bash eval runner fires all 44 API calls in a single
sequential stream. Rate limiting hits mid-run and corrupts the results silently
(responses degrade before returning an error). The current fix — fixed retry
sleep — is fragile: it waits a fixed time regardless of actual quota recovery.

**The intervention**: Rewrite the eval runner core in Python using
`asyncio.Semaphore` for concurrency control and true exponential backoff with
jitter on retry:

```python
async def run_prompt(semaphore, prompt, max_retries=5):
    async with semaphore:
        for attempt in range(max_retries):
            result = await call_claude(prompt)
            if not is_rate_limited(result):
                return result
            wait = (2 ** attempt) + random.uniform(0, 1)   # exponential + jitter
            await asyncio.sleep(wait)
        return "RATE_LIMITED"   # mark as SKIP, not FAIL
```

A semaphore of size 3–5 limits concurrent calls, preventing the burst that
triggers rate limiting in the first place. Combined with exponential backoff,
the runner adapts to the actual API quota state instead of guessing.

**Impact**: Reduces rate-limit-induced collapses from "common" to "rare".
Eliminates the need for fixed `EVAL_SLEEP` between tests.

---

### Solution 3: Semantic & Agentic Plan Caching

**Problem it solves**: Each eval run costs 44 API calls. A 5-iteration
optimization session costs ~220 calls. Most of these calls for the same prompt
will produce structurally identical plans — the Claude model reasons about
"Build an agent for X" the same way in iteration 3 as in iteration 1. We are
paying repeatedly for the same computation.

**The intervention**: Cache the Claude CLI output at the semantic level. For
each test prompt, after the first run, store the structured response
(triggered/not-triggered + output signature). On subsequent runs, if the
*description field has not changed*, the routing decision for that prompt will
not change either — return the cached result without an API call.

**Cache invalidation rule**: When the description changes (i.e., after each
optimizer iteration), invalidate the cache for all positive test cases (they
are the ones whose routing may flip). Negative test cases (EXPECT_TRIGGER=no)
never flip regardless of description changes — they can be cached permanently
for the duration of an optimization session.

**Impact**: Up to 40% of calls (the negative test cases = 22/44) can be
served from cache on every iteration after the first. Combined with Solution 2,
this roughly halves the wall-clock time per iteration.

**Implementation**: `eval/prompt_cache.py` — a simple JSON cache keyed on
`(prompt_hash, description_hash)`.

---

### Solution 4: Train/Validation Split + Negative Control Matrix

**Problem it solves**: The optimizer iterates on the same 44 prompts it is
evaluated against. This is equivalent to training and testing on the same
dataset — the optimizer can, in principle, overfit the description to these
exact 44 prompts and still fail on real-world usage.

**The intervention**: Split the 44 test prompts into two fixed sets:

| Set | Size | Purpose |
|-----|------|---------|
| Training (T) | 26 prompts (~60%) | Optimizer reads these failure cases, proposes fixes against these |
| Validation (V) | 18 prompts (~40%) | Never seen by the optimizer during a session; used only for final assessment |

The optimizer loop runs against T only. Before committing a change, it must
also pass V at ≥ the same rate as the current baseline. A description that
overfits T will show a lower score on V — revealing the overfit before it ships.

**Negative control requirement**: At least 30% of each set must be negative
controls (prompts that should NOT trigger the skill). This constrains the
optimizer from widening the description too aggressively — a description that
triggers on everything achieves 100% on positive tests but fails all negative
controls.

**Current state**: Tests 1–22 are positive, 23–44 are negative (21 negative
controls = 48% of the set). The split already has good negative coverage.
The missing piece is formalizing which prompts belong to T vs V and enforcing
that the optimizer only reads T during its analysis step.

---

## Implementation Roadmap for Solutions 1–4

| # | Solution | Artifact | Owner | Blocks |
|---|----------|----------|-------|--------|
| S1 | Bayesian framework | `eval/bayesian_eval.py` | Gemini | Autoresearch optimizer accuracy |
| S2 | Async runner | `eval/run_eval_async.py` | Gemini | Rate-limit collapse |
| S3 | Prompt cache | `eval/prompt_cache.py` | Gemini | Eval cost per iteration |
| S4 | Train/val split | `eval/splits.json` + optimizer update | Claude | Overfitting |

S2 is the highest priority — it directly unblocks G7 and G8 by making the
eval runner reliable under production load. S1 is second — it makes the
optimizer's commit/revert decision statistically sound. S3 and S4 are
efficiency and safety improvements that matter most at scale.

---

## Revised Success Criteria (post-solutions)

| Metric | Old criterion | New criterion |
|--------|--------------|---------------|
| Repeatability | Two runs differ ≤ 5% | 95% credible intervals overlap across two runs |
| Optimization acceptance | Pass rate increased | New CI entirely above old CI (no overlap) |
| Deployment gate | Pass rate ≥ 90% | Posterior mean ≥ 90%, lower CI bound ≥ 80% |
| Overfit detection | None | Training pass rate ≥ 90% AND validation pass rate ≥ 85% |
