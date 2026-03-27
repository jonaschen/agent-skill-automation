## Target
- **Optimize**: .claude/skills/meta-agent-factory/SKILL.md
- **Metric**: trigger_rate (run: `bash eval/run_eval.sh .claude/skills/meta-agent-factory/SKILL.md`)
- **Goal**: trigger_rate >= 0.90

## What you may modify
- The `description` field in the YAML frontmatter of the target `SKILL.md`.
- Any content in the Markdown body of the target `SKILL.md`.
- Level 3 scripts in the `scripts/` subdirectory of the target Skill.

## What you must never modify
- The `tools:` list in the YAML frontmatter (enforced via `check-permissions.sh`).
- The `model:` field in the YAML frontmatter.
- Files outside the target Skill's directory tree (except for git commits).

## Evaluation Budget
- **Fixed test set**: Run `eval/run_eval.sh` exactly once per experiment.
- The test set is currently fixed at 40 prompts. Do not add or remove prompts during an optimization cycle.

## Stopping criteria
- Stop when **trigger_rate >= 0.90**.
- Stop after **50 iterations**, whichever comes first.
- Report the best version found and the experiment trajectory.

## Loop Procedure
1. **Analyze**: Identify the specific prompts that failed in the last eval run.
2. **Hypothesize**: Determine why the current instructions led to the failure.
3. **Propose**: Draft a modification to the `SKILL.md` to address the failure.
4. **Apply**: Write the proposed change to the file.
5. **Evaluate**: Run the eval script and record the pass rate.
6. **Commit/Revert**: If pass rate improved, `git commit` the change. If not, `git revert` or manually undo.
7. **Repeat**: Continue to the next iteration.
