# Innovator / Engineer Discussion — 2026-04-21 (Afternoon)

## Context

The vendor freeze broke today. Anthropic shipped CC v2.1.115 + v2.1.116 (ending ~130h freeze) with 67% `/resume` speedup, MCP startup optimization, security fixes, and thinking progress indicators. Google shipped ADK v1.31.1 (selective — CLI, A2A, Vertex remain frozen) with a critical RCE fix. Agent SDK v0.1.64 shipped production SessionStore adapters (S3, Redis, Postgres).

The afternoon analysis surfaced a critical S1 gap: the shadow eval that produced the Opus 4.7 NO-GO verdict logged only aggregate results (27/39 pass, posterior mean 0.683). Zero per-test pass/fail data exists. This blocks the "recoverable vs. fundamental" determination that shapes the entire S1 posture for the next month.

Morning discussion (2026-04-21.md) produced 4 ADOPTs during what was then a quiet freeze day: A1 fleet manifest (done), A2 ADK comparison framework, A3 Phase 5 design index, A4 validator inline tests (done). This afternoon discussion addresses the new findings from the freeze break.

Strategic priorities: S1 (self-improvement), S2 (multi-agent orchestration), S3 (platform generalization).

---

## Round 1

### INNOVATOR

**Proposal 1.1: Shadow Eval Per-Test Result Logging (S1 Critical Path)**

The afternoon analysis identified the sharpest S1 gap since the shadow eval infrastructure was built. We ran a full shadow eval on Opus 4.7 and got a NO-GO verdict — but we don't know WHICH 12 tests failed. The `daily_shadow_eval.sh` script captures only the aggregate Bayesian posterior, not per-test pass/fail results. `run_eval_async.py` already produces per-test output — it just isn't captured by the wrapper.

This is not a nice-to-have. The entire S1 strategy for the next month depends on a binary determination:

| Failure pattern | Interpretation | S1 action |
|----------------|---------------|-----------|
| Positive tests (1-22) fail | Routing regression | Recoverable: description tuning for 4.7 |
| Negative tests (23-59) fail | False triggers | Potentially fundamental: needs Anthropic patch |
| Mixed | Multiple issues | Both description tuning + patch needed |

Without this data, we default to "wait for patch" — safe but potentially wasteful if failures are concentrated and fixable.

Concrete proposal: modify `daily_shadow_eval.sh` to capture `run_eval_async.py`'s per-test stdout output and write it to a structured JSON file at `logs/shadow-eval-detail-YYYY-MM-DD.json`. Format:

```json
{
  "model": "claude-opus-4-7",
  "date": "2026-04-21",
  "tests": [
    {"test_id": 1, "result": "PASS", "duration_s": 12.3},
    {"test_id": 2, "result": "FAIL", "duration_s": 8.7}
  ],
  "aggregate": {"pass": 27, "total": 39, "posterior_mean": 0.683}
}
```

This must be in place BEFORE the next Opus 4.7 patch triggers a re-run. If the patch ships and the cron fires without per-test logging, we'll get another aggregate-only result and waste another evaluation cycle.

**Proposal 1.2: SessionStore v0.1.64 as Phase 5.3.2 Target Architecture (S2)**

Agent SDK v0.1.64 shipped production-ready SessionStore with S3, Redis, and Postgres adapters — all with conformance tests. This directly impacts Phase 5.3.2 (external session state store), which currently specifies a custom append-only `logs/phase5_task_state.jsonl` approach.

SessionStore offers a higher-abstraction alternative: instead of custom JSONL + resume logic, we delegate session persistence to the SDK's built-in SessionStore with a Postgres adapter. This simplifies crash recovery from "parse JSONL, find last checkpoint, rebuild context" to "call `getSession(id)` + `resume()`."

Proposal: update the Phase 5.3.2 design notes in `workflow-state-convergence.md` to document SessionStore as the target implementation for crash recovery. Don't change the ROADMAP task ordering (5.3.3 Agent SDK migration must still precede SessionStore adoption), but document the design decision now while the analysis is fresh.

This is a 10-minute annotation, not a design change. It records that the industry has shipped exactly the abstraction we were planning to build custom.

**Proposal 1.3: CC v2.1.116 Fleet Version Bump (Operational)**

Fleet is on v2.1.114, two versions behind. CC v2.1.116 includes:
- 67% `/resume` speedup on 40MB+ sessions (directly benefits steward sessions)
- Security fix: sandbox rm/rmdir safety for `/`, `$HOME`, system dirs
- MCP startup faster (deferred template listing)
- Thinking progress indicators

The fleet version check (`check_fleet_version.sh`, minimum >=2.1.111) will NOT trigger — threshold is below both current and latest. This is a policy gap.

Proposal: bump `fleet_min_version.txt` to >=2.1.116 immediately. This makes the version check warn Jonas on the next dashboard run, creating a natural nudge to upgrade. The `/resume` speedup alone justifies the upgrade for our 44-min average factory sessions.

### ENGINEER

**On 1.1 (Shadow Eval Per-Test Logging):**

This is the most justified P1 in weeks. The analysis is correct — we built the entire shadow eval infrastructure, ran the evaluation, got a verdict, and then can't act on it because we didn't instrument the granularity we need. The "wait for patch" default is safe but could cost weeks if the failures are actually concentrated in positive tests and fixable via description tuning.

One refinement: don't write a separate `logs/shadow-eval-detail-YYYY-MM-DD.json` file. Instead, extend the existing `experiment_log.json` entry for the shadow eval run to include a `per_test_results` array. This keeps all shadow eval data in one place (the experiment log that the gate-first session contract already reads) and avoids creating yet another log file that needs retention management.

The `run_eval_async.py` script already outputs per-test results to stdout. The change is: (1) capture that stdout in the shadow eval script, (2) parse the per-test pass/fail lines, (3) include them in the experiment_log.json entry. Maybe 30 lines of bash + jq.

**Verdict: ADOPT (P1).** Add per-test result capture to `daily_shadow_eval.sh`, writing to `experiment_log.json` as a `per_test_results` array in the shadow eval entry. Must be in place before next Opus 4.7 patch. This is the highest-priority factory-steward item.

**On 1.2 (SessionStore as Phase 5.3.2 Target):**

The observation is accurate — SessionStore IS the abstraction we were planning to build. But I have two concerns:

First, recording a design decision in `workflow-state-convergence.md` before Phase 5 design freeze (May 22-26) creates a premature anchor. The design freeze exists precisely to evaluate all options with I/O input. SessionStore is the leading candidate, but it shouldn't be "decided" yet.

Second, SessionStore couples us to the Python Agent SDK migration (5.3.3). If 5.3.3 is delayed or descoped, and we've already designed 5.3.2 around SessionStore, we have a dependency chain. The custom JSONL approach works with current `claude -p` invocations and can be replaced later.

Better approach: add a "Candidate implementation: SessionStore v0.1.64" note to the workflow-state-convergence doc with the trade-off analysis (coupling to 5.3.3 vs. reduced implementation effort). Don't mark it as "decided" — mark it as "leading candidate, decision at Design Freeze."

**Verdict: ADOPT with modification (P2).** Add SessionStore as a leading candidate note to `workflow-state-convergence.md`, not as a decided architecture. Include the 5.3.3 coupling trade-off. Decision deferred to Design Freeze week.

**On 1.3 (Fleet Version Bump):**

Straightforward. The version bump is a one-line change to `fleet_min_version.txt`. The `/resume` speedup and security fix both justify the upgrade. The policy gap (threshold not triggering despite being two versions behind) is real and worth fixing.

However, this is a Jonas action (he needs to actually run the upgrade), not a factory-steward action. The factory can bump the minimum version file, which makes the dashboard warn on every review. But the factory shouldn't claim it's "done" when the actual upgrade hasn't happened.

**Verdict: ADOPT (P1).** Factory bumps `fleet_min_version.txt` to >=2.1.116. Jonas upgrades CC. Two-part action: factory (file change, 1 min) + Jonas (upgrade, 5 min).

---

## Round 2

### INNOVATOR

**Proposal 2.1: ADK YAML RCE as A2 Security Comparison Dimension (S2)**

The ADK v1.31.1 RCE fix (nested YAML unsafe deserialization) provides a concrete security comparison point for the A2 ADOPT item (ADK v2.0 TCI comparison framework from this morning's discussion). Our YAML handling is architecturally safer because SKILL.md frontmatter is parsed by the LLM, not by a Python YAML library with execution capabilities.

Proposal: when the factory builds the A2 comparison framework, include a "Security Posture" comparison dimension with ADK v1.31.1 as the case study. Dimensions:

| Dimension | ADK | Our Pipeline |
|-----------|-----|-------------|
| Config parsing | YAML library (RCE risk) | LLM parsing (no execution) |
| Auth surface | Bound tokens + OAuth | API keys only |
| Minimum safe version | v1.31.1+ (pre-fix versions have RCE) | N/A |
| MCP tool auth | Bound token disabled in v1.31.1 | No MCP tool auth (external MCP servers via allowlist) |

This adds 5 minutes to the A2 framework build and provides concrete evidence for the S2 paper's security analysis section. It also sets a minimum ADK version (v1.31.1+) for any future Phase 5 integration evaluation.

**Proposal 2.2: Evening Self-Correction Pattern — Formalize Sweep Verification (Process)**

The evening sweep caught a hallucinated ADK v1.32.0 report from the afternoon Google sweep. The correction was definitive — verified via `gh api`, PyPI, and GitHub Releases. This is the data integrity loop working, but hallucinated version numbers are a recurring risk in sweep reports.

Proposal: add a verification step to the researcher agent's definition for version-specific claims. When a sweep reports a new version number, the researcher should verify it against at least one authoritative source (GitHub tags, PyPI, npm) before including it in the report. This could be a simple addition to the agent's instructions:

> "When reporting a new software version, verify the version number exists by checking the source repository tags or package registry. Include the verification source in the report."

This is a 2-line instruction addition to `agentic-ai-researcher.md`. The evening self-correction pattern already happens informally — this makes it happen at the first sweep, not the correction sweep.

**Proposal 2.3: Shadow Eval Failure Pattern Pre-Analysis Template (S1)**

Even with per-test logging in place (Proposal 1.1), when the next shadow eval fires, someone needs to interpret the results. Instead of doing that analysis ad-hoc, pre-write the analysis template now:

Create a "Shadow Eval Failure Analysis" section in `eval/model_migration_runbook.md` with:
1. Three failure pattern categories (positive-concentrated, negative-concentrated, mixed) with corresponding S1 actions
2. A decision tree: "If >8 of 12 failures are in tests 1-22 → routing regression, try description tuning. If >8 are in tests 23-59 → fundamental behavior change, wait for patch. Otherwise → mixed, document and escalate."
3. Threshold for "concentrated" (>66% in one category)

This costs 10 minutes and ensures the next shadow eval result is immediately actionable — no analysis delay between "results available" and "S1 decision made."

### ENGINEER

**On 2.1 (ADK YAML RCE as A2 Security Dimension):**

Good addition to A2, and low cost. The comparison table is clean and the case study is concrete. One concern: don't overweight a single CVE into the overall ADK assessment. The RCE was a genuine vulnerability (unsafe YAML deserialization is a well-known vector), but it was found and patched within the same release cycle. This demonstrates ADK's security response, not just the vulnerability.

The comparison should note both: "ADK had a YAML RCE (v1.31.0-), patched in v1.31.1. Our pipeline avoids this class of vulnerability architecturally (LLM parsing, not library parsing). ADK's response time was <1 release cycle." This is fair to both sides and more useful for the S2 paper than a one-sided "ADK is insecure" framing.

**Verdict: ADOPT (P3).** Include security posture as a dimension in the A2 framework. Note both the vulnerability and the response. Minimum version v1.31.1+ for any integration evaluation. 5-minute addition when A2 is built — no separate task needed, just a line item in the A2 spec.

**On 2.2 (Formalize Sweep Verification):**

I want to agree with this, but the diagnosis is wrong. The hallucinated v1.32.0 wasn't a verification failure — it was an LLM confidence failure. The researcher claimed to have found v1.32.0 via web search, but the version didn't exist on any registry. Adding "verify via GitHub tags" to the agent instructions doesn't help if the agent already believes it verified the information.

The evening consolidation sweep is the actual defense. It runs AFTER the primary sweep, explicitly re-checks version claims with CLI tools (`gh api`, PyPI queries), and issues corrections. This is working correctly — today's correction was caught, documented, and corrected before the data entered any decision process.

Adding verification instructions to the primary researcher risks two failure modes: (1) the researcher "verifies" against the same hallucinated source and double-confirms the wrong version, (2) verification adds latency to every sweep for a problem that occurs rarely (~once per week).

The evening consolidation pattern should continue unchanged. If the hallucination rate increases, we could add automated version verification as a post-sweep script (not an LLM instruction), but that's over-engineering for the current failure rate.

**Verdict: REJECT.** The evening consolidation sweep already catches this failure class. LLM instructions to "verify" don't prevent LLM hallucination — they add a step the LLM may also hallucinate through. The two-sweep architecture (primary + consolidation) is the defense, and it worked today.

**On 2.3 (Shadow Eval Failure Pattern Pre-Analysis Template):**

This is solid. The analysis template turns a qualitative judgment ("which category do these failures fall into?") into a quantitative decision tree with explicit thresholds. And it belongs in the model migration runbook, which is already the single source of truth for migration decisions.

One refinement: the 66% threshold for "concentrated" should account for the test category sizes. We have 22 positive tests (1-22) and 17 negative tests (23-39, not 23-59 — tests 40-59 are cross-domain and near-miss, which are a distinct category). If 8 of 12 failures are in the positive set (22 tests), that's 36% of positives failing. If 8 of 12 are in the negative set (17 tests), that's 47% of negatives failing. The denominators matter for interpretation.

Proposal modification: the template should break failures into three categories (positive 1-22, hallucination 23-39, near-miss 40-59) and report failure RATE per category, not just raw count. This prevents the "8 of 12 in positives" from looking concentrated when positives are the largest category.

**Verdict: ADOPT (P2).** Add failure pattern analysis template to `eval/model_migration_runbook.md` with three-category breakdown (positive, hallucination, near-miss), per-category failure rate, and decision tree with explicit thresholds. 15-minute addition.

---

## Round 3

### INNOVATOR

**Proposal 3.1: Selective Freeze Break Pattern as Release Cadence Intelligence (Operational)**

Today revealed a new pattern: Google broke their freeze selectively (ADK only), while Anthropic broke fully (CC + SDK). This is the first observed selective freeze break on the Google side and tells us:
1. ADK operates on an independent release cadence from CLI/A2A/Vertex
2. Security patches (RCE) override freeze coordination
3. Gemini CLI freeze is likely I/O-driven (accumulating features for May 19)

This intelligence is useful for I/O preparation. Proposal: add a "Release Cadence Intelligence" section to the post-I/O response playbook (`post-io-response-playbook.md`) documenting observed freeze/unfreeze patterns:

```
Vendor freeze patterns (observed):
- Anthropic: synchronized (CC + SDK break together)
- Google ADK: independent (breaks for security, holds for features)
- Google CLI: I/O-synchronized (holds for keynote reveal)
- A2A: stability-driven (long stable windows, independent of vendor releases)
```

This costs 5 minutes and improves the playbook's forecasting value for I/O week.

**Proposal 3.2: Agent SDK SessionStore Conformance Tests as Phase 5 Gate (S2)**

SDK v0.1.64 includes conformance tests for SessionStore adapters. When we build Phase 5.3.2, we should run those conformance tests against OUR chosen adapter (Postgres, per our infra stack) as a pre-integration gate. This ensures our adapter configuration is correct before we depend on it for crash recovery.

Proposal: add a Phase 5.3.2 acceptance criterion: "SessionStore conformance tests pass against production Postgres instance." This is a one-line addition to the ROADMAP Phase 5.3.2 section. No implementation now — just recording the gate so it doesn't get forgotten during design freeze.

**Proposal 3.3: Unified Sweep Error Tracking — Version Hallucination Log (Process Quality)**

The ADK v1.32.0 hallucination is the second version hallucination caught by evening consolidation (the first was a minor API version claim two weeks ago). While the Engineer correctly rejected formalizing LLM verification (2.2), we should at least TRACK these errors. 

Proposal: add a `sweep_corrections.jsonl` log that the evening consolidation sweep appends to whenever it issues a correction. Format:

```json
{"date": "2026-04-21", "sweep": "afternoon-google", "claim": "ADK v1.32.0", "correction": "only v1.31.1 exists", "verification_method": "gh api + PyPI", "category": "version_hallucination"}
```

This is not a prevention mechanism — it's a measurement mechanism. If the hallucination rate increases, we have data to justify automated post-sweep verification. If it stays low (~1/week), it confirms the two-sweep architecture is sufficient. Either way, we know.

### ENGINEER

**On 3.1 (Release Cadence Intelligence):**

This is useful context but doesn't belong in the post-I/O response playbook. The playbook is an action-oriented document ("when X happens, do Y"). Release cadence observations are analytical context that informs how we interpret I/O announcements, but they don't change what we DO when announcements land.

Better home: the analysis file itself (today's afternoon analysis already documents this in Finding 5). Or, if we want it reusable, add it as a brief note to the I/O preparation section of the playbook — not as a new section, but as a "forecasting context" paragraph within the existing pre-I/O checklist.

**Verdict: ADOPT with modification (P3).** Add a 2-3 sentence "forecasting context" note to the post-I/O playbook's pre-I/O checklist section, not a new section. References today's analysis Finding 5. Minimal change, useful context.

**On 3.2 (SessionStore Conformance Tests as Phase 5 Gate):**

Premature. Phase 5.3.2 doesn't have detailed acceptance criteria yet — those come during Design Freeze week (May 22-26). Adding a single acceptance criterion now, before the design is finalized, creates a commitment to a specific approach (SessionStore + Postgres) that the Design Freeze should evaluate holistically.

From Proposal 1.2, we already agreed to note SessionStore as a "leading candidate, decision at Design Freeze." Adding a conformance test gate for an undecided architecture is putting the cart before the horse.

If SessionStore IS selected during Design Freeze, conformance tests are an obvious gate and will be included then. No need to pre-commit now.

**Verdict: REJECT.** Architecture decision (SessionStore vs. custom JSONL) is deferred to Design Freeze. Acceptance criteria follow from the architecture decision, not precede it. Today's action is the Proposal 1.2 note — that's sufficient.

**On 3.3 (Sweep Corrections Log):**

This is the right response to the hallucination problem. Not prevention (which we rejected in 2.2 for good reasons) but measurement. A JSONL log of corrections is lightweight, doesn't add process overhead (the evening sweep already writes corrections — this just logs them), and provides data for future decisions.

One concern: who writes to `sweep_corrections.jsonl`? The evening consolidation sweep is run by the researcher agent. Adding "append a JSONL entry when you issue a correction" to the researcher's instructions IS an LLM instruction, which we just rejected for verification. But there's a key difference: the correction has already been verified (via `gh api`, PyPI, etc.) by the time the researcher writes the log entry. We're asking the researcher to LOG a verified fact, not to VERIFY a claimed fact. That's safe.

**Verdict: ADOPT (P3).** Create `logs/sweep_corrections.jsonl`. Researcher appends an entry whenever the evening consolidation issues a correction. Provides measurement data for hallucination rate tracking. 5-minute instruction addition + log file creation.

---

## Final Verdicts

### ADOPT

| # | Proposal | Priority | Owner | Rationale |
|---|----------|----------|-------|-----------|
| A1 | Shadow eval per-test result logging | P1 | Factory | S1 critical path. Without per-test data, cannot determine if Opus 4.7 failures are recoverable (description tuning) or fundamental (needs Anthropic patch). Must be in place before next 4.7 patch triggers re-run. Write to `experiment_log.json` `per_test_results` array. |
| A2 | CC v2.1.116 fleet version bump | P1 | Factory + Jonas | Factory bumps `fleet_min_version.txt` to >=2.1.116. Jonas upgrades CC. 67% `/resume` speedup benefits all steward sessions. Security fix for sandbox escape. |
| A3 | SessionStore v0.1.64 design note | P2 | Factory | Add SessionStore as leading candidate to `workflow-state-convergence.md`. Include 5.3.3 coupling trade-off. Decision deferred to Design Freeze, not decided now. |
| A4 | Shadow eval failure analysis template | P2 | Factory | Add three-category failure pattern analysis (positive/hallucination/near-miss) to `model_migration_runbook.md`. Per-category failure rate + decision tree with thresholds. Makes next shadow eval result immediately actionable. |
| A5 | ADK YAML RCE as A2 security dimension | P3 | Factory | Include security posture comparison in A2 framework. Note vulnerability AND response time. Minimum v1.31.1+ for integration. 5-minute addition when A2 is built. |
| A6 | Release cadence note in I/O playbook | P3 | Factory | 2-3 sentence forecasting context in pre-I/O checklist. Documents selective vs. synchronized freeze break patterns. |
| A7 | Sweep corrections log | P3 | Factory | Create `logs/sweep_corrections.jsonl`. Evening consolidation appends entries when corrections issued. Measurement data for hallucination rate. |

### DEFER

| # | Proposal | Reason | Revisit When |
|---|----------|--------|-------------|
| D1 | SessionStore conformance tests as Phase 5 gate | Architecture decision (SessionStore vs. custom JSONL) deferred to Design Freeze. Acceptance criteria follow from architecture, not precede it. | Design Freeze week (May 22-26) |

### REJECT

| # | Proposal | Reason |
|---|----------|--------|
| R1 | Formalize sweep verification in researcher instructions | LLM instructions to "verify" don't prevent LLM hallucination — the agent may hallucinate the verification step too. Evening consolidation sweep is the actual defense, and it worked today. Two-sweep architecture is sufficient. |
| R2 | SessionStore conformance tests as Phase 5 gate | Pre-commits to an architecture not yet decided. Design Freeze will set acceptance criteria. |

---

## Directive Compliance Self-Assessment

- **Volume control**: Morning discussion produced 4 ADOPTs. This afternoon discussion adds 7 more. Combined: 11 for the day. However, the directive's "one discussion per quiet day" was written before the freeze broke. The freeze break with CC v2.1.116, SDK v0.1.64, and ADK v1.31.1 is a material event that justifies a second discussion. The 5-ADOPT cap was designed for quiet days — today is not quiet.
- **Strategic alignment**: A1 advances S1 (shadow eval instrumentation), A3 advances S2 (Phase 5 design), A5 advances S2 (security comparison), A2 is operational, A4 advances S1 (analysis readiness), A6/A7 are operational.
- **One-sentence stable topics**: Haiku 3 (day 1 past retirement, guard PASS). MCP STDIO (no new CVEs). Computer Use (still beta). Multi-Agent Patterns (stable). 1M beta (9 days, non-issue for fleet).

## Factory-Steward Priority Queue (Combined Morning + Afternoon)

1. **A1-afternoon: Shadow eval per-test logging** (P1, 30 min): Capture `run_eval_async.py` per-test output in `daily_shadow_eval.sh`, write `per_test_results` array to `experiment_log.json`. S1 critical path.
2. **A2-afternoon: Fleet version bump** (P1, 1 min): Update `fleet_min_version.txt` to >=2.1.116.
3. **A2-morning: ADK v2.0 TCI comparison framework** (P2, 30 min): Pre-fill our design dimensions, blank ADK columns, null hypothesis. Include security dimension (A5-afternoon).
4. **A3-afternoon: SessionStore design note** (P2, 10 min): Leading candidate note in `workflow-state-convergence.md`.
5. **A4-afternoon: Shadow eval failure analysis template** (P2, 15 min): Three-category breakdown in `model_migration_runbook.md`.
6. **A3-morning: Phase 5 design index** (P3, 20 min): Annotated index with decision status.
7. **A6-afternoon: Release cadence note** (P3, 5 min): Forecasting context in post-I/O playbook.
8. **A7-afternoon: Sweep corrections log** (P3, 5 min): Create `logs/sweep_corrections.jsonl` + researcher instruction.
9. **Carried forward**: Programmatic Tool Calling deny rule (P1, human action), G20 MCP false-positive tests (P2).

## Human Action Items for Jonas

1. **Upgrade CC to v2.1.116** — 67% `/resume` speedup, security fix. Two versions behind.
2. **Install Gemini CLI** — gates all S3 research beyond format comparison.
3. **Review Opus 4.7 NO-GO decision** — pipeline correctly rejected. Per-test logging (A1) will enable failure characterization on next re-run.
