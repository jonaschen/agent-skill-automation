---
sidebar_position: 1
title: Daily Fleet
---

# Daily Agent Fleet

The research pipeline runs two cycles daily, each a three-agent chain. LTC steward runs independently. Each agent writes a performance JSON record to `logs/performance/` for tracking.

## Schedule (Asia/Taipei)

**Night Cycle**

```
 2:00 AM --- researcher ----------- L1-L5 sweep (reads prior directive)
 3:00 AM --- research-lead --------- Reviews output, writes priority directive
 4:00 AM --- factory-steward ------- Implements ADOPT items guided by directive
```

**Morning Cycle**

```
10:00 AM --- researcher ----------- L1-L5 sweep (reads prior directive)
11:00 AM --- research-lead --------- Reviews output, writes priority directive
12:00 PM --- factory-steward ------- Implements ADOPT items guided by directive
```

**Independent**

```
 8:00 AM --- ltc-steward ----------- Phase work on long-term-care-expert
```

## Manual Runs

```bash
./scripts/daily_research_sweep.sh       # Run researcher
./scripts/daily_research_lead.sh        # Run research lead
./scripts/daily_factory_steward.sh      # Run factory steward
./scripts/daily_ltc_steward.sh          # Run LTC steward
```

## Performance Tracking

### JSON Records

Each run produces a performance record at `logs/performance/{agent}-YYYY-MM-DD.json` with metrics including:
- Duration
- Exit code
- Commits made
- Files changed
- Agent-specific metrics (directive_written, adopt_items_available, etc.)

Records are auto-cleaned after 30 days.

### Review Dashboard

```bash
./scripts/agent_review.sh        # Last 7 days
./scripts/agent_review.sh 30     # Monthly view
```

## Log Files

| Agent | Log file | Performance file |
|-------|----------|-----------------|
| Researcher | `logs/sweep-YYYY-MM-DD.log` | `logs/performance/researcher-YYYY-MM-DD.json` |
| Research Lead | `logs/research-lead-YYYY-MM-DD.log` | `logs/performance/research-lead-YYYY-MM-DD.json` |
| Factory | `logs/factory-YYYY-MM-DD.log` | `logs/performance/factory-YYYY-MM-DD.json` |
| LTC | `logs/ltc-YYYY-MM-DD.log` | `logs/performance/ltc-YYYY-MM-DD.json` |

## The Research Direction Loop

The research pipeline forms a closed feedback loop:

1. **Researcher** runs L1-L5 sweep, producing findings in `knowledge_base/agentic-ai/`
2. **Research-lead** reviews output, evaluates quality, writes directive with P0/P1/P2 priorities
3. **Factory-steward** implements ADOPT items, prioritized by the directive
4. **Researcher** reads the directive in its next sweep, adjusting depth per topic
5. **Research-lead** compares its previous directive against actual output to assess compliance
