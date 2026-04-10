# Skill Update Recommendations — 2026-04-06

**Source**: Analysis 2026-04-06, Discussion 2026-04-06
**Author**: agentic-ai-researcher (L4 strategic planning)

---

## 1. ALL AGENT DESCRIPTIONS — Vocabulary Deconfliction (CRITICAL)

**Agents affected**: All 11 agents in `.claude/agents/`
**Change type**: Description text (routing semantics)
**Priority**: CRITICAL — blocks routing regression fix

### Problem

Agent fleet expansion created description vocabulary overlap. Steward, researcher, and reviewer agents contain "implements", "generates", "creates" — verbs that compete with `meta-agent-factory`'s routing triggers. This caused T=0.895→0.658 regression.

### Recommended Changes

**Per-agent deconfliction table**:

| Agent | Current competing phrase | Replacement |
|---|---|---|
| `factory-steward` | "Implements ADOPT items" | "Acts on ADOPT items" |
| `factory-steward` | "improves eval infrastructure" | "refines eval infrastructure" |
| `agentic-ai-researcher` | "generate action plans for new skills" | "propose action plans for new skills" |
| `agentic-ai-researcher` | "generates sweep reports" → in routine description | "produces sweep reports" |
| `android-sw-steward` | "implementing H8 multi-agent orchestration" | "executing H8 multi-agent orchestration" |
| `arm-mrs-steward` | "Drives H8 multi-agent orchestration" | OK (no "create" vocabulary) |
| `bsp-knowledge-steward` | "improving skill.md files" | "refining skill.md files" |
| `project-reviewer` | "creates steering notes" | "writes steering notes" |
| `autoresearch-optimizer` | "Iteratively repairs under-performing Skills" | OK ("repairs" is distinct from "creates") |
| `skill-quality-validator` | No competing vocabulary | No change needed |
| `agentic-cicd-gate` | No competing vocabulary | No change needed |

**Note**: Only change description/trigger text. Do not change operational instructions or tool lists.

### meta-agent-factory — Routing Anchor Reinforcement

**Current** (partial, added in G8 Iter 2): Contains routing rule but may not be prominent enough.

**Recommended**: Ensure the description frontmatter begins with or prominently features:
> "ROUTING RULE: Any request whose primary intent is to CREATE, BUILD, DEFINE, GENERATE, or ADD a new agent, Skill, persona, expert, or role MUST route here — even when an existing domain agent covers that topic (e.g., 'create an AOSP expert' routes here, not to aosp-integration-expert; 'add a persona to the Changeling role library' routes here, not to changeling-router). EXCLUSION: Does NOT activate for modifying, improving, or debugging EXISTING agents/Skills."

---

## 2. `agentic-cicd-gate` — MCP Hash Pinning Extension (P1)

**Agent affected**: `agentic-cicd-gate`
**Change type**: Add MCP hash verification step to deployment gate logic
**Priority**: P1

### Recommended Change

Add to the agent's deployment checklist (in its operational instructions):
- After static content scanning passes, verify MCP tool definition hashes against stored baselines in `eval/mcp_tool_hashes/<skill-name>.json`
- If no baseline exists (first deployment), compute and store hashes
- If hashes mismatch, block deployment with "MCP rug pull detected" message

### Dependency

Requires `eval/mcp_config_validator.sh` hash-pinning function to be implemented first (proposal `2026-04-06-mcp-scan-hash-pinning.md`).

---

## 3. `autoresearch-optimizer` — State Persistence (P2)

**Agent affected**: `autoresearch-optimizer`
**Change type**: Add state persistence and resume-from-log instructions
**Priority**: P2

### Recommended Change

Add to the agent's operational instructions:
- After each iteration, write `best_so_far` state to `eval/experiment_log.json`
- On startup, check for existing state in experiment log
- If recent state exists (< 24h), offer to resume from that point
- Track `current_description` to prevent re-testing already-evaluated descriptions

### Dependency

Requires `eval/experiment_log.json` schema extension (proposal `2026-04-06-optimizer-state-persistence.md`).

---

## 4. `meta-agent-factory` — Sprint Contract Manifest (P2)

**Agent affected**: `meta-agent-factory`
**Change type**: Add manifest generation to output pipeline
**Priority**: P2

### Recommended Change

Add to the agent's generation pipeline:
- After generating SKILL.md, also output `manifest.json` with:
  - `permission_model`: one of "review-only", "execution", "orchestration"
  - `target_domain`: free text describing the Skill's domain
  - `mcp_servers`: list of MCP servers used (empty if none)
- Manifest is a build artifact — discarded after validation

### Companion Change

`skill-quality-validator` must be updated to consume the manifest for structural validation (but NOT for dynamic test generation).

---

## 5. `agentic-ai-researcher` — NO CHANGES (Correct Decision)

**Agent affected**: `agentic-ai-researcher`
**Change type**: None
**Priority**: N/A

### Rationale

The discussion correctly REJECTED modifying the researcher agent definition for the time-bounded Google I/O event. Agent definitions should remain stable; time-bounded monitoring belongs in knowledge base files that the agent discovers during its regular scans.

The Google I/O tracking file (`knowledge_base/agentic-ai/events/google-io-2026.md`) is the correct mechanism.

---

## DEFERRED Updates (Not for Current Phase)

| Agent/Skill | Update | Revisit When |
|---|---|---|
| `post-tool-use.sh` | Tool return content scanning (OWASP MCP06) | Phase 5 PreToolUse reflection hook |
| `post-tool-use.sh` | MCP-specific audit trail (OWASP MCP08) | First MCP-using Skill deployment |
| All agents | A2A protocol integration | Phase 5 implementation kickoff |
| `topology-aware-router` | Agent marketplace distribution | Phase 7 planning kickoff |
