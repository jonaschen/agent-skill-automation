# Ready-to-Execute: Dependency Pinning + Audit Gate

**Source proposal**: `proposals/2026-04-05-dependency-pinning.md`
**Priority**: P1 (high)
**Type**: CI/CD gate extension in `pre-deploy.sh`
**Generated**: 2026-04-05 by agentic-ai-researcher (L5: Action)

---

## Prompt for Implementation

Add dependency pinning (Python) and audit (npm) to the pre-deploy pipeline to mitigate supply chain attacks demonstrated against agent framework dependencies (LiteLLM compromise, npm axios RAT).

### Requirements

1. **Create locked Python manifest** — generate `requirements.txt` from current working environment:
   ```bash
   # Run once to establish baseline, then check into git
   pip freeze > requirements.txt
   ```
   - This file MUST be checked into git
   - All CI/CD runs must use `pip install --require-hashes -r requirements.txt`

2. **Add to `.claude/hooks/pre-deploy.sh`** — two new checks:

   a. **Python dependency lock check** (BLOCKING):
      ```bash
      check_python_deps() {
        if [ -f requirements.txt ]; then
          # Verify installed packages match locked manifest
          pip freeze | diff - requirements.txt > /dev/null 2>&1
          if [ $? -ne 0 ]; then
            echo "[DEPLOY-GATE] FAIL: Python dependencies differ from requirements.txt"
            echo "[DEPLOY-GATE] Run 'pip freeze > requirements.txt' and commit the update"
            return 1
          fi
          echo "[DEPLOY-GATE] PASS: Python dependencies match locked manifest"
        else
          echo "[DEPLOY-GATE] WARN: No requirements.txt found — run 'pip freeze > requirements.txt'"
        fi
        return 0
      }
      ```

   b. **npm audit check** (WARNING only, not blocking):
      ```bash
      check_npm_audit() {
        if command -v npm >/dev/null 2>&1 && [ -f package-lock.json ]; then
          npm audit --audit-level=high 2>/dev/null
          if [ $? -ne 0 ]; then
            echo "[DEPLOY-GATE] WARN: npm audit found high-severity vulnerabilities"
            echo "[DEPLOY-GATE] These may be upstream dependencies we cannot fix"
          else
            echo "[DEPLOY-GATE] PASS: npm audit clean"
          fi
        fi
        return 0  # Always return 0 — npm audit is warning-only
      }
      ```

3. **Gate behavior**:
   - Python deps mismatch → FAIL (blocks deployment)
   - No requirements.txt → WARN (doesn't block, but logs warning)
   - npm audit high-severity → WARN (doesn't block — we're downstream of Claude Code's npm chain)
   - Both clean → PASS

### Context

- ADK Python shipped 3 emergency patches (v1.27.3-v1.27.5) for a compromised LiteLLM dependency
- A RAT was found in axios npm packages
- Our Python eval tools (`run_eval_async.py`, `bayesian_eval.py`, `prompt_cache.py`) are exposure surfaces
- npm audit is warning-only per Engineer decision: high-severity npm findings could block the entire pipeline on things we can't fix

### Files to Modify

- `.claude/hooks/pre-deploy.sh` — add `check_python_deps()` and `check_npm_audit()` functions
- Create `requirements.txt` — locked Python dependency manifest (run `pip freeze` once)

### Files NOT to Modify

- `eval/` scripts — no changes needed to eval tools themselves
- `.claude/agents/` — agent definitions unchanged
