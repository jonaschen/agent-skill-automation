# Platform Generalization Plan: Claude-Gemini Parity

**Status**: DRAFT / FOR REVIEW
**Owner**: Gemini CLI (Orchestrator)
**Strategic Alignment**: Priority S3 (Platform Generalization)

## 1. Executive Summary
The goal is to transition from a Claude-centric agent fleet to a vendor-agnostic "Shared Core" architecture. This enables the repository's agents and skills to be consumed by both Claude Code and Gemini CLI with zero maintenance overhead when logic changes.

## 2. Target Architecture: The Symlink Bridge
We will move away from storing logic in `.claude/` or `.gemini/`.

### 2.1 Directory Structure
```text
/repo-root
├── core/
│   ├── agents/           # Canonical .md agent definitions
│   └── skills/           # Canonical SKILL.md directories
├── .claude/
│   ├── agents -> ../core/agents/
│   └── skills -> ../core/skills/
└── .gemini/
    ├── agents -> ../core/agents/
    └── skills -> ../core/skills/
```

## 3. The "Polyglot" Frontmatter Standard
All agents and skills will share a unified YAML frontmatter.

### 3.1 Schema Definition
```yaml
---
name: [agent-id]
description: [Routing-optimized description]

# Claude Keys
tools: [Read, Write, Edit, Bash, Task, mcp__*]

# Gemini Keys
kind: local
subagent_tools: [read_file, write_file, replace, grep_search, run_shell_command, mcp_*]
model: gemini-3-flash-preview
temperature: 0.2
max_turns: 30
---
```

## 4. Canonical Instruction Language (CIL)
Literal tool names are prohibited in the body of agent instructions.

### 4.1 Functional Mapping
Agents must be instructed to use "functional intents" which the respective LLMs will map to their available tools:

- **Claude `Write` / Gemini `write_file`** → "write complete file content"
- **Claude `Edit` / Gemini `replace`** → "perform surgical text replacement"
- **Claude `Read` / Gemini `read_file`** → "read file segments or content"
- **Claude `Bash` / Gemini `run_shell_command`** → "execute shell commands"
- **Claude `Task` / Gemini `subagent_*`** → "delegate to specialized agents"

### 4.2 Example Transformation
*   **Before (Claude-centric)**: "Use the Edit tool to update the version number in package.json."
*   **After (Canonical)**: "Modify the version number in package.json using your surgical text replacement tool."

## 5. Implementation Roadmap

### Phase 1: Canonicalization (Current)
- [ ] Audit all 23+ agents in `~/.claude/@lib/agents/` and `.claude/agents/`.
- [ ] Rewrite instructions to use CIL (Functional Intent).
- [ ] Append Gemini-specific frontmatter keys.

### Phase 2: Relocation & Linking
- [ ] Create `/core/agents` and `/core/skills`.
- [ ] Move files from `.claude/` to `/core/`.
- [ ] Establish symlinks in `.claude/` and `.gemini/`.

### Phase 3: Cross-Platform Validation
- [ ] Run `run_eval_async.py` using `claude-opus-4-7` baseline.
- [ ] Run `run_eval_async.py` using `gemini-3-flash-preview`.
- [ ] **Success Criteria**: Bayesian posterior mean trigger rate ≥ 0.90 on BOTH platforms.

## 6. Maintenance & Scalability
- The `factory-steward` will be updated to generate "Polyglot" files by default.
- The `skill-quality-validator` will be updated to check for literal tool name leaks in instructions (CIL compliance).
- New vendors (e.g., GPT-based CLIs) can be added by simply adding their frontmatter keys and creating a new symlinked folder.

---
**Reviewer Note**: Please evaluate for maintenance overhead and potential routing regressions caused by the "Polyglot" description.
