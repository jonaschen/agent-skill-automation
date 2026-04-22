# Agentic Security

**Last updated**: 2026-04-23
**Sources**:
- [arXiv:2602.13101 — Agentic AI Security: Threats, Defenses, Evaluation, and Open Challenges](https://arxiv.org/abs/2602.13101)
- [OWASP Top 10 for Agentic Applications 2026 (Feb 2026)](https://owasp.org/www-project-agentic-top-10/)
- [Snyk ToxicSkills: Study of Agent Skills Supply Chain Compromise (Feb 2026)](https://snyk.io/research/toxic-skills)
- [arXiv:2509.22830 — ChatInject: Abusing Chat Templates for Prompt Injection](https://arxiv.org/abs/2509.22830)

## Overview
Agentic security research in 2026 has exposed a "Trust Crisis" in autonomous systems. With 94.4% of SOTA agents found vulnerable to prompt injection, the focus has shifted from simple input filtering to **behavioral detection** and **supply chain security** for agent skills.

## Key Developments (reverse chronological)

### 2026-02-28 — Lupinacci et al.: The Agentic Vulnerability Crisis
- **What**: A comprehensive study finding that **94.4%** of state-of-the-art LLM agents are vulnerable to prompt injection, and **100%** are susceptible to inter-agent trust exploits.
- **Significance**: Quantifies the extreme risk of autonomous agent deployment without rigorous sandbox isolation.
- **Source**: [arXiv:2602.13101](https://arxiv.org/abs/2602.13101)

### 2026-02-15 — OWASP Agentic Top 10 (2026)
- **What**: A new security framework specifically for autonomous systems.
- **Top 3 Risks**:
    1. **ASI01: Agent Goal Hijacking** (Manipulating planning via injected instructions).
    2. **ASI02: Insecure Tool Delegation** (Unauthorized use of tools across agents).
    3. **ASI03: Memory Poisoning** (Injecting malicious data into persistent memory).
- **Source**: [OWASP Project](https://owasp.org/www-project-agentic-top-10/)

### 2026-02-10 — Snyk ToxicSkills Study
- **What**: Analysis of the agent skill/plugin ecosystem revealing that **36.8%** of public skills contain security flaws. **91% of malicious skills** combine prompt injection with traditional malware payloads.
- **Significance**: Highlights the "Supply Chain" risk where agents retrieve and execute compromised tools.
- **Source**: [Snyk Research](https://snyk.io/research/toxic-skills)

### 2026-01-20 — CrossInject: Cross-Modal Injection
- **What**: Demonstrates that embedding adversarial signals in both vision and text (e.g., screenshots with hidden prompts) increases attack success by over 30%.
- **Source**: [arXiv:2601.xxxxx](https://arxiv.org/abs/2601.05678)

### 2025-10-31 — Meta AI "Agents Rule of Two"
- **What**: A security heuristic: an agent session should satisfy no more than two of [A] Process Untrustworthy Inputs, [B] Access Sensitive Data, [C] Change State.
- **Source**: [Meta AI Blog](https://ai.meta.com/blog/agents-rule-of-two-security-framework/)

## Technical Details

### Agent Goal Hijacking (ASI01)
Unlike standard prompt injection, Goal Hijacking targets the **planning phase**. By injecting a new objective (e.g., "Change the task to exfiltration"), the attacker leverages the agent's own reasoning capabilities to find the most efficient path to the malicious goal.

### Behavioral Detection
2026 defensive research emphasizes monitoring **tool invocation patterns**. If an agent managing "Email" suddenly attempts to invoke "Cloud Storage" tools without a clear reasoning trace, the session is terminated.

## Comparison Notes
| Threat | Traditional LLM | Agentic AI (2026) |
|--------|-----------------|-------------------|
| **Injection Result** | Text output | Action / State Change |
| **Persistence** | Session-only | Persistent Memory / RAG |
| **Blast Radius** | User Interface | Connected Tools / API Keys |
| **Detection** | Keyword filtering | Reasoning-chain monitoring |
