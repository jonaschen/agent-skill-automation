# Ready-to-Execute: Routing Regression Fix — Description Deconfliction

**Source proposal**: `knowledge_base/agentic-ai/proposals/2026-04-06-routing-regression-fix.md`
**Priority**: CRITICAL
**Target agent**: factory-steward (modifies existing agent descriptions)
**Generated**: 2026-04-06

---

## Prompt for factory-steward

Fix the routing regression that dropped meta-agent-factory trigger rate from T=0.895 to T=0.658. Execute a two-pronged approach:

### Prong 1: Vocabulary Deconfliction

Edit the `description:` frontmatter field in the following agent definition files to replace competing verbs. Only change the description text — do NOT change operational instructions, tool lists, or model settings.

| File | Current phrase | Replacement |
|---|---|---|
| `.claude/agents/factory-steward.md` | "Implements ADOPT items" | "Acts on ADOPT items" |
| `.claude/agents/factory-steward.md` | "improves eval infrastructure" | "refines eval infrastructure" |
| `.claude/agents/agentic-ai-researcher.md` | "generate action plans for new skills" | "propose action plans for new skills" |
| `.claude/agents/android-sw-steward.md` | "implementing H8 multi-agent orchestration" | "executing H8 multi-agent orchestration" |
| `.claude/agents/bsp-knowledge-steward.md` | "improving skill.md files" | "refining skill.md files" |
| `.claude/agents/project-reviewer.md` | "creates steering notes" | "writes steering notes" |

Also update the corresponding `description:` field entries in `settings.json` agent definitions to match.

### Prong 2: Routing Anchor Verification

Verify that `.claude/agents/meta-agent-factory.md` description contains the ROUTING RULE with explicit examples and the EXCLUSION clause. It should already be present from G8 Iter 2. If missing or incomplete, ensure it includes:
> "ROUTING RULE: Any request whose primary intent is to CREATE, BUILD, DEFINE, GENERATE, or ADD a new agent, Skill, persona, expert, or role MUST route here — even when an existing domain agent covers that topic"

### Validation

After making all changes, run the full eval suite:
```bash
python3 eval/run_eval_async.py --all
python3 eval/bayesian_eval.py eval/results.json
```

Confirm:
- meta-agent-factory trigger rate recovers to T >= 0.895
- Validation set passes overfit threshold (V >= 0.85)

### Post-fix

Add to ROADMAP.md Lessons Learned: "L8: Vocabulary deconfliction is a mandatory step when adding agents to the fleet — use distinct verbs per agent role to prevent routing competition."
