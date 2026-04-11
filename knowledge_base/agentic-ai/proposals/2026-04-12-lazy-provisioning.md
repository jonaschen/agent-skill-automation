# Skill Proposal: Lazy Provisioning for Researcher Agent

**Date**: 2026-04-12
**Triggered by**: Managed Agents 60% median TTFT reduction via lazy container provisioning (sweep 2026-04-12)
**Priority**: P2 (medium)
**Target Phase**: Phase 4.3 (Observability/Efficiency)

## Rationale

Managed Agents achieves 60% TTFT reduction by only provisioning execution environments
when work exists. Our `daily_research_sweep.sh` spins up a full Claude session (30-60
minutes, ~$2-5 per run) regardless of whether any new releases or announcements exist.

The discussion (2026-04-12) identified the researcher as the **strongest ROI candidate**
for lazy provisioning: clear skip criteria (no new GitHub releases since last sweep),
highest per-session cost, and purely event-reactive work pattern. Steward agents were
explicitly **deferred** — they advance ROADMAP tasks autonomously, making "no new commits"
a poor skip signal.

## Proposed Specification

- **Name**: lazy-provisioning (pipeline optimization, not a Skill)
- **Type**: Script enhancement
- **Components**:
  1. Pre-flight function in `daily_research_sweep.sh` — curl GitHub releases API for
     `anthropics/claude-code`, `anthropics/agent-sdk`, `google/A2A`, `google/adk-python`
  2. Compare latest release dates against `logs/performance/researcher-*.json` last run timestamp
  3. If no new releases since last sweep: write `SKIP` performance JSON, log skip reason, exit 0
  4. Add consecutive-skip counter to performance JSONs — alert if any agent skips >3 consecutive runs
  5. `agent_review.sh` dashboard shows skip count alongside duration trends

## Implementation Notes

- Pre-flight is pure bash (curl + jq) — no Claude session needed
- GitHub API rate limit: 60 req/hr unauthenticated, 5000/hr with token — use token
- Skip criteria: all 4 tracked repos have no new releases since last successful sweep
- Safety: never skip if last run had errors (force re-run on prior failure)
- The pre-flight does NOT check for blog posts, docs changes, or spec updates — those
  require the full sweep. This means some quiet days will still run full sessions.
  Acceptable: even 20% skip rate saves ~$1/day on quiet weekends.
- Estimated savings: 20-40% of researcher compute on quiet days (weekends, freeze periods)

## Estimated Impact

- **Cost**: ~$1-2/day saved on quiet days; ~$30-60/month
- **Efficiency**: No wasted 30-60 min sessions when nothing changed
- **Monitoring**: Consecutive-skip counter prevents silent agent death from detection bugs
- **Risk**: Low — worst case is a slightly delayed sweep (caught next scheduled run)
