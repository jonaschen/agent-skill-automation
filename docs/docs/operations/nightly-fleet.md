---
sidebar_position: 1
title: Nightly Fleet
---

# Nightly Agent Fleet

Seven agent runs execute daily via cron, staggered to avoid resource contention and API quota limits. Each writes a performance JSON record to `logs/performance/` for tracking.

## Schedule (Asia/Taipei)

```
12:00 PM --- factory-steward ----------- Daytime: advances ROADMAP, fixes regressions
                                          -> /home/jonas/gemini-home/agent-skill-automation/
 9:00 PM --- factory-steward ----------- Evening: implements ADOPT items, tunes agents
                                          -> /home/jonas/gemini-home/agent-skill-automation/
 2:00 AM --- agentic-ai-researcher ----- Scans Anthropic + Google AI developments
                                          -> knowledge_base/agentic-ai/
 3:00 AM --- android-sw-steward -------- Advances AOSP skill set (Phase 4 work)
                                          -> /home/jonas/gemini-home/Android-Software/
 4:00 AM --- arm-mrs-steward ----------- Advances AArch64 skill set (data expansion)
                                          -> /home/jonas/arm-mrs-2025-03-aarchmrs/
 5:00 AM --- bsp-knowledge-steward ----- Advances BSP mentor skill sets (Phase 3/4)
                                          -> /home/jonas/ai-bsp-agent/github/ai-bsp-knowledge-skill-sets/
 7:00 AM --- project-reviewer ---------- Reviews steward work, validates skills
                                          -> reads all 3 project repos, writes feedback
```

## Manual Runs

Any agent can be triggered manually:

```bash
# Run specific agents
./scripts/daily_factory_steward.sh
./scripts/daily_research_sweep.sh
./scripts/daily_android_sw_steward.sh
./scripts/daily_arm_mrs_steward.sh
./scripts/daily_bsp_knowledge_steward.sh
./scripts/daily_project_reviewer.sh
```

## Performance Tracking

### JSON Records

Each run produces a performance record at `logs/performance/{agent}-YYYY-MM-DD.json` with metrics including:
- Duration
- Exit code
- Commits made
- Files changed
- Test counts (agent-specific)

Records are auto-cleaned after 30 days.

### Review Dashboard

```bash
# Last 7 days — success rate, duration, commits, test counts
./scripts/agent_review.sh

# Monthly view
./scripts/agent_review.sh 30
```

## Log Files

| Agent | Log file | Performance file |
|-------|----------|-----------------|
| Factory | `logs/factory-YYYY-MM-DD.log` | `logs/performance/factory-YYYY-MM-DD.json` |
| Researcher | `logs/sweep-YYYY-MM-DD.log` | `logs/performance/researcher-YYYY-MM-DD.json` |
| Android-SW | `logs/android-sw-YYYY-MM-DD.log` | `logs/performance/android-sw-YYYY-MM-DD.json` |
| ARM MRS | `logs/arm-mrs-YYYY-MM-DD.log` | `logs/performance/arm-mrs-YYYY-MM-DD.json` |
| BSP Knowledge | `logs/bsp-knowledge-YYYY-MM-DD.log` | `logs/performance/bsp-knowledge-YYYY-MM-DD.json` |
| Reviewer | `logs/reviewer-YYYY-MM-DD.log` | `logs/performance/reviewer-YYYY-MM-DD.json` |

## The Self-Correcting Cycle

The nightly fleet forms a closed feedback loop:

1. **Stewards** build and commit changes to their target repos
2. **Project reviewer** assesses each steward's work against the project ROADMAP
3. **Steering notes** are written when corrections are needed
4. **Stewards** read steering notes at the start of their next session
5. **Factory steward** implements pipeline improvements from the researcher's findings
6. **Skills that fail validation** are flagged as P0 correction items for the next cycle
