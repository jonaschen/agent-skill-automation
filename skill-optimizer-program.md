## Target
- **Optimize**: .claude/skills/meta-agent-factory/SKILL.md
- **Metric**: Bayesian posterior mean (run: `python3 eval/run_eval_async.py .claude/skills/meta-agent-factory/SKILL.md --no-cache`)
- **Goal**: Posterior mean >= 0.90 AND CI lower bound >= 0.80

## What you may modify
- The `description` field in the YAML frontmatter of the target `SKILL.md`.
- Any content in the Markdown body of the target `SKILL.md`.
- Level 3 scripts in the `scripts/` subdirectory of the target Skill.

## What you must never modify
- The `tools:` list in the YAML frontmatter (enforced via `check-permissions.sh`).
- The `model:` field in the YAML frontmatter.
- Files outside the target Skill's directory tree (except for git commits).

## Evaluation Budget
- **Fixed test set**: Run `python3 eval/run_eval_async.py --inter-test-delay 15` exactly once per experiment.
- The test set is fixed at 54 prompts (36 Training, 18 Validation). Use `eval/splits.json`.

## Stopping criteria
- Stop when **posterior_mean >= 0.90**.
- Stop after **50 iterations**, whichever comes first.
- Report the best version found and the experiment trajectory.

## Loop Procedure
1. **Analyze**: Identify the Training set (T) prompts that failed in the last eval run.
2. **Hypothesize**: Determine why the current instructions led to the failure.
3. **Propose**: Draft a modification to the `SKILL.md` to address the failure.
4. **Apply**: Write the proposed change to the file.
5. **Evaluate**: Run `python3 eval/run_eval_async.py` and record Bayesian stats.
6. **Commit/Revert**: Commit ONLY if the new CI lower bound > old CI upper bound. Otherwise, revert.
7. **Repeat**: Continue to the next iteration.
