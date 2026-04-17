# Multi-Agent Patterns

**Last updated**: 2026-04-18
**Sources**:
- https://resources.anthropic.com/hubfs/2026%20Agentic%20Coding%20Trends%20Report.pdf
- https://zenvanriel.com/ai-engineer-blog/claude-code-swarms-multi-agent-orchestration/
- https://blog.imseankim.com/claude-code-team-mode-multi-agent-orchestration-march-2026/
- https://www.atcyrus.com/stories/what-is-claude-code-swarm-feature
- https://claude.com/blog/building-agents-with-the-claude-agent-sdk
- https://www.anthropic.com/engineering/multi-agent-research-system
- https://code.claude.com/docs/en/agent-teams
- https://medium.com/@richardhightower/claude-code-subagents-and-main-agent-coordination-a-complete-guide-to-ai-agent-delegation-patterns-a4f88ae8f46c
- https://www.anthropic.com/engineering/harness-design-long-running-apps
- https://www.infoq.com/news/2026/04/anthropic-three-agent-harness-ai/
- https://www.the-ai-corner.com/p/anthropic-30b-arr-passed-openai-revenue-2026

## Overview

Anthropic has developed multi-agent orchestration patterns both in Claude Code (agent teams/swarm mode) and the Claude Agent SDK (subagents). The core architecture follows a lead-agent/specialist pattern where an orchestrator decomposes problems, delegates to specialized agents working in parallel with isolated context windows, and synthesizes results. As of March 2026, multi-agent orchestration is no longer experimental -- it shipped as a first-class Claude Code feature on February 6, 2026 alongside Opus 4.6.

## Key Developments (reverse chronological)

### 2026-04-18 -- Multi-Agent Patterns Stabilization: Routines as Lightweight Orchestration; Agent Teams vs Subagents Guidance Crystallized
- **What**: No new multi-agent API announcements since April 16. **Pattern consolidation review**: Anthropic now offers four distinct multi-agent execution models, each documented with clear guidance: **(1) Agent Teams** — coordinate multiple Claude instances with independent contexts, direct inter-agent communication, shared task list. Best for complex parallel tasks. Higher token cost. **(2) Subagents** — operate in same session as main agent, report results only. More economical for sequential/targeted tasks. **(3) Three-Agent Harness** (Planning/Generation/Evaluation) — formalized April 4 for long-running autonomous sessions (4+ hours, 5–15 refinement iterations). Structured handoff artifacts, independent evaluation, Playwright MCP grading. **(4) Orchestrator-Worker** (Multi-Agent Research System) — lead decomposes, 3-5 parallel specialist subagents, synchronous cohort completion, external memory for context window survival. 90% time reduction on complex research. **New from v2.1.111**: Opus 4.7 behavioral change — "fewer subagents spawned by default" — steerable through prompting. This means Opus 4.7 prefers reasoning over delegation, using subagents more selectively. **Routines** (April 14) add a lightweight cloud orchestration layer — a routine bundles prompt + repo + connectors, runs on schedule/API/GitHub triggers. Not multi-agent per se, but serves as a scheduling primitive that could chain multiple agent sessions. **Agent SDK v0.1.60 subagent transcript helpers** (`list_subagents()`, `get_subagent_messages()`) enable post-hoc inspection of subagent chains — critical observability for multi-agent debugging.
- **Significance**: Anthropic's multi-agent toolkit is now mature enough to classify by use case: parallel research → orchestrator-worker; sequential deep work → three-agent harness; simple delegation → subagents; recurring automation → routines. For our pipeline: **(1) Opus 4.7's "fewer subagents by default"** means our steward agents may need prompt tuning when upgrading — add explicit subagent-spawning instructions if we observe reduced parallelism. **(2) The four-pattern taxonomy** should inform our Phase 5 topology-aware-router: TCI scoring should route to the correct pattern (low coupling → parallel orchestrator-worker; high coupling → three-agent harness; simple → single subagent). **(3) Routines as a scheduling primitive** could eventually replace our cron scripts for simpler agent sessions, but our current pipeline needs the logging/performance-JSON infrastructure that cron scripts provide.
- **Source**: https://code.claude.com/docs/en/agent-teams, https://www.anthropic.com/engineering/harness-design-long-running-apps, https://www.anthropic.com/engineering/multi-agent-research-system, https://code.claude.com/docs/en/routines, https://github.com/anthropics/claude-agent-sdk-python/releases

### 2026-04-17 -- Three-Agent Harness (Planning / Generation / Evaluation) Formalized in Anthropic Engineering Blog
- **What**: Anthropic's April 4, 2026 engineering post "Harness Design for Long-Running Apps" introduces a **formal three-agent harness pattern** for multi-hour autonomous development sessions. The three distinct roles: **(1) Planning Agent** — task decomposition, strategy formulation, explicit success criteria definition. **(2) Generation Agent** — executes the development work (code, design, implementation). **(3) Evaluation Agent** — independently grades Generation Agent outputs. **Critical design insight**: Separating evaluation from generation is described as "a strong lever" to counter models' tendency to overestimate their own output quality, particularly on subjective tasks. **Architectural primitives**: (a) **Structured handoff artifacts** replace shared rolling context — each agent hands its successor a defined state snapshot (plan doc → patch → eval report). Contrasted explicitly with context compaction, which "can make models overly cautious about approaching token limits." (b) **Concrete frontend implementation**: the Evaluator uses **Playwright MCP** to navigate live pages and grades on four axes: **design quality, originality, craft, functionality**. (c) **Iteration cadence**: 5–15 refinements per run, sometimes spanning ~4 hours of autonomous operation. (d) This is the sibling architecture to the Multi-Agent Research System's orchestrator-worker pattern — research uses parallel specialists, long-running apps use sequential role-separated agents with handoffs.
- **Significance**: This is the single most important public architectural disclosure from Anthropic in Q2 2026 for our pipeline, because it maps 1:1 onto our existing architecture: **meta-agent-factory (Generation) ↔ skill-quality-validator (Evaluation) ↔ autoresearch-optimizer (Planning/replanning)**. Key insights for our Phase 5 topology-aware-router: **(1) Structured handoff artifacts is the canonical pattern, not shared context** — our JSON report hand-off between validator and optimizer is validated as the right approach. **(2) "Separation of evaluation from generation is a strong lever"** is Anthropic's explicit endorsement of our mutually-exclusive-permission design (validators denied Write/Edit, generators denied Task). **(3) 4-hour run horizon with 5–15 refinements** matches our Phase 4 ≤4-hour end-to-end KPI, and aligns with our ≤50 optimizer iterations budget (Opus uses far fewer iterations because each iteration is higher-effort). **(4) Playwright MCP 4-axis grading** is directly adoptable for any UI-facing skill we produce — and we should evaluate adding a Playwright-MCP-based UI evaluator to our validator when the pipeline produces frontend-generating skills. **(5) Long-running apps vs research = two canonical topologies** — our router should distinguish them: parallel orchestrator-worker for high-branching research; sequential three-role harness for high-depth app generation. Add to ROADMAP Phase 5 task list: "Implement three-role harness as a second topology in topology-aware-router alongside orchestrator-worker."
- **Source**: https://www.anthropic.com/engineering/harness-design-long-running-apps, https://www.infoq.com/news/2026/04/anthropic-three-agent-harness-ai/

### 2026-04-16 -- Multi-Agent Research System Engineering Blog: Orchestrator-Worker Architecture with 90% Time Reduction; 2026 Agentic Coding Trends Report: 8 Trends Reshaping Software Development
- **What**: Two major Anthropic publications on multi-agent patterns: **(1) Engineering blog — "How we built our multi-agent research system"**: Detailed write-up of Anthropic's internal research agent system. Architecture: **orchestrator-worker pattern** — lead agent decomposes queries, spawns 3-5 specialist subagents in parallel, synthesizes results, decides if additional research is needed. Two complementary parallelization strategies: agent-level (3-5 concurrent subagents) and tool-level (each subagent invokes 3+ search tools simultaneously). Combined result: **research time cut by up to 90% for complex queries**. Coordination mechanism: currently **synchronous** — lead waits for cohort completion before proceeding (simplifies state consistency, creates bottleneck; async noted as future work). Memory persistence: agents store research plans + completed phases **externally** to survive context window truncation. Task decomposition: lead agent provides detailed objectives, output formats, and clear inter-agent boundaries to prevent duplication. Artifact storage: structured outputs bypass coordinator, reducing coordinator token overhead. Tool ergonomics: improved tool descriptions reduced task completion time by 40% for future agents. Effort scaling heuristics: 1 agent + 3-10 tool calls for simple fact-finding; 10+ subagents with divided responsibilities for complex research. Production requirements: durable execution (resume from failure), comprehensive observability (no conversation content monitoring), rainbow deployments (gradual rollout for long-running processes), graceful error handling (agents adapt when tools fail). Model upgrade insight: switching to Claude Sonnet 4 yielded larger efficiency gains than doubling token budgets on earlier models. Evaluation approach: outcome-focused LLM judges scoring factual accuracy, citation quality, completeness, source authority, and tool efficiency (not step-by-step validation). **(2) 2026 Agentic Coding Trends Report** (resources.anthropic.com): Eight trends identified for 2026: shifting engineering roles, multi-agent coordination (single-agent → coordinated teams), human-AI collaboration patterns, scaling agentic coding beyond engineering teams, parallel specialized agents with synthesized results, orchestrator-delegate patterns, context management across agents, and effective human judgment integration. Case studies: Rakuten, CRED, TELUS, Zapier. Report notes "effective AI collaboration still requires active human judgment."
- **Significance**: The research system blog is the most detailed public disclosure of Anthropic's own multi-agent architecture. Key validation points for our pipeline: (1) **Orchestrator-worker IS Anthropic's canonical pattern** — validates our Phase 5 topology-aware-router design. (2) **Synchronous cohort + external memory** matches our steward agent model (sequential phases, external file-based state). (3) **Effort scaling heuristics** (1-10 tool calls for simple, 10+ agents for complex) provide concrete calibration for our TCI router thresholds. (4) **Tool description quality** directly impacts agent performance — our SKILL.md trigger descriptions should be treated as performance-critical, not just documentation. (5) **Rainbow deployments** for long-running processes: our steward agents should not hot-swap during active runs — coordinate restarts at natural pause points. (6) **Outcome-focused evaluation** aligns with our Bayesian eval approach (we don't step-validate agent actions, only final outputs). The Agentic Coding Trends Report confirms multi-agent coding teams are now a mainstream 2026 trend, not experimental — accelerating our Phase 5 urgency.
- **Source**: https://www.anthropic.com/engineering/multi-agent-research-system, https://resources.anthropic.com/2026-agentic-coding-trends-report

### 2026-04-12 -- Managed Agents Architecture Deep Dive: Brain-Hands Decoupling with 60% TTFT Reduction
- **What**: Anthropic published an engineering blog on Managed Agents architecture — "Scaling Managed Agents: Decoupling the brain from execution." Key architectural details: (1) **Three-component virtualization**: Session (append-only activity log), Harness (decision loop calling Claude + routing tool calls), Sandbox (execution environment for code/files). (2) **Brain-hands decoupling**: The harness no longer runs inside containers. It invokes sandboxes as tools via a standard `execute(name, input) → string` interface. Failed containers are replaceable (harness treats failures as tool-call errors). Stateless harnesses can be rebooted with `wake(sessionId)` and resume from `getSession(id)`. Network flexibility: harnesses no longer assume resource co-location, enabling VPC integration. (3) **Performance**: ~60% reduction in median TTFT (time-to-first-token); >90% reduction in P95 TTFT — achieved by lazy container provisioning (initialized on-demand via tool calls, not upfront). (4) **Security isolation**: credentials never reach sandboxes. Two patterns: resource-bundled auth (git tokens initialize repos during setup, push/pull works without exposure) and vault-based credentials (OAuth tokens in secure vaults, accessed via MCP proxy servers). (5) **Multi-brain, multi-hand scaling**: stateless harnesses scale independently; each hand (container, phone, other env) is an interchangeable tool; agents can delegate across environments and pass tools between brains. (6) **Context management**: Session provides durable context store outside Claude's context window. `getEvents()` interface enables flexible retrieval (pickup from previous position, rewind, specific slices). Transformations in harness layer preserve session durability. This architecture follows OS design principles where abstractions remain stable while implementations change.
- **Significance**: This is the most detailed architecture disclosure for Managed Agents to date. The brain-hands decoupling pattern is directly relevant to our Phase 5 multi-agent topology: (1) The `execute(name, input) → string` interface is essentially our tool-calling pattern — validates our architectural approach. (2) The stateless harness + session log pattern could replace our current stateful agent sessions. (3) The 60% TTFT improvement from lazy provisioning is an optimization we should consider for our steward agents. (4) The multi-brain/multi-hand model maps to our topology-aware-router concept — multiple harnesses (brains) connecting to shared execution environments (hands). (5) The credential isolation pattern (vault-based via MCP proxy) is more secure than our current approach of environment variables. For Phase 7 AaaS: Managed Agents' pricing ($0.08/session-hr + tokens) provides a reference point.
- **Source**: https://www.anthropic.com/engineering/managed-agents

### 2026-04-11 -- Advisor Tool Creates New Multi-Agent Primitive: Inline Model Pairing
- **What**: The Advisor Tool (launched April 9, beta header `advisor-tool-2026-03-01`) introduces a new multi-agent primitive that is architecturally distinct from both the three-agent harness and Agent Teams/Swarm patterns. Instead of orchestrating separate agent sessions, the advisor runs as a **server-side sub-inference within a single API request** — the executor model calls the advisor like any other tool, the advisor sees the full transcript, returns strategic guidance (400-700 tokens), and the executor continues. This is effectively a two-model collaboration pattern that doesn't require external orchestration. Valid pairs: Haiku→Opus, Sonnet→Opus, Opus→Opus. Anthropic's internal benchmarks show Sonnet+Opus advisor achieves near-Opus-solo quality at Sonnet-dominated cost. The recommended pattern for coding agents: call advisor before substantive work, when stuck, and before declaring done. The pattern composes with the three-agent harness — an evaluator agent could use the advisor tool for its assessment pass.
- **Significance**: The advisor pattern represents a third multi-agent architecture alongside orchestrated (Agent Teams/Swarm) and managed (Managed Agents multiagent preview): **inline model collaboration** at the API level. For our Phase 5 topology: (1) The advisor tool could replace a dedicated planner agent for simpler workflows, reducing orchestration complexity. (2) The TCI router could use advisor-pattern for low-coupling tasks and full agent teams for high-coupling tasks. (3) The `usage.iterations[]` billing model provides a template for per-agent cost attribution in Phase 7.
- **Source**: https://platform.claude.com/docs/en/agents-and-tools/tool-use/advisor-tool, https://platform.claude.com/docs/en/release-notes/overview

### 2026-04-10 -- Agentic Coding Trends Report Gaining Industry Traction; Managed Agents Multiagent Waitlist Active
- **What**: (1) **2026 Agentic Coding Trends Report** continues generating significant industry coverage. The report identifies 8 trends: shifting engineering roles, multi-agent coordination replacing single-agent workflows, human-AI collaboration patterns, scaling agentic coding beyond engineering teams. Featured case studies: Rakuten, CRED, TELUS, Zapier. Anthropic's internal data shows typical three-agent harness workflows span 5-15 iterations, occasionally extending to four hours. (2) **Managed Agents multiagent waitlist active** — the research preview enables agents to spawn additional agents, coordinate parallel tasks, evaluate outputs, and manage memory. No public documentation yet on orchestration patterns or limits. (3) **Three-agent harness** (planner/generator/evaluator) solidifying as industry reference architecture: InfoQ, Bitcoin News, and Pathmode all published analyses. The harness separates subjective evaluation from generation — "tuning a standalone evaluator to be skeptical is far more tractable than making a generator critical of its own work." The pattern uses context resets and sprint contracts between agents. (4) **Anthropic $30B ARR** (reported April 2026) — signals massive revenue growth that funds continued multi-agent R&D. TeammateTool remains feature-gated in Claude Code.
- **Significance**: The three-agent harness is becoming the recognized standard for autonomous development. Our pipeline's multi-agent topology (Phase 5) should incorporate this planner/generator/evaluator separation. The $30B ARR validates sustained investment in the agent platform.
- **Source**: https://resources.anthropic.com/2026-agentic-coding-trends-report, https://www.infoq.com/news/2026/04/anthropic-three-agent-harness-ai/, https://www.the-ai-corner.com/p/anthropic-30b-arr-passed-openai-revenue-2026

### 2026-04-09 -- Claude Managed Agents "Multiagent" Research Preview; TeammateTool Still Feature-Gated
- **What**: Two multi-agent developments: (1) **Managed Agents multiagent mode** (research preview) — Claude Managed Agents (launched April 8) includes a "multiagent" feature in research preview, requiring separate access request. No public documentation yet on how it works, but it's listed alongside "outcomes" and "memory" as gated Managed Agents capabilities. This is the first indication of Anthropic offering managed multi-agent orchestration as a cloud service. (2) **TeammateTool remains feature-gated** in Claude Code — the 13 operations (spawnTeam, write, broadcast, approvePlan, requestShutdown, etc.) are fully implemented but behind `I9()`/`qFB()` feature gates. No change in gate status with v2.1.94/v2.1.96. Community workaround (claude-sneakpeek) continues to provide early access. The three-agent harness pattern (planner/generator/evaluator) continues spreading — now adopted by Swarms framework. Gartner's 1,445% surge in multi-agent inquiries (Q1 2024→Q2 2025) validates the space.
- **Significance**: Managed Agents multiagent mode could be Anthropic's server-side answer to the TeammateTool/Swarm pattern. If it enables orchestrated multi-agent sessions in cloud containers, it would directly compete with Google's ADK multi-agent orchestration and our Phase 5 architecture. The fact that it requires separate access suggests it's early-stage. For our pipeline: monitor for documentation release and evaluate whether Managed Agents multiagent could replace our local agent fleet orchestration.
- **Source**: https://platform.claude.com/docs/en/managed-agents/overview, https://paddo.dev/blog/claude-code-hidden-swarm/

### 2026-04-08 -- No New Multi-Agent Developments; Three-Agent Harness Adoption Spreading
- **What**: No new Anthropic multi-agent announcements since the three-agent harness engineering blog (April 6). The Swarms framework (github.com/kyegomez/swarms) continues to adopt the pattern. The 2026 Agentic Coding Trends Report continues to generate industry coverage, with key reports from InfoQ, Bitcoin News, and Pathmode analyzing the orchestrator-worker shift. The report's eight trends include: (1) shifting engineering roles, (2) multi-agent coordination, (3) human-AI collaboration patterns, (4) scaling agentic coding beyond engineering teams, plus case studies from Rakuten, CRED, TELUS, and Zapier. The harness design pattern (planner/generator/evaluator with context resets and sprint contracts) is becoming a recognized industry standard. Anthropic's internal data shows typical harness workflows span 5-15 iterations per run, occasionally extending to four hours.
- **Significance**: The three-agent harness is solidifying as the reference architecture for long-running autonomous development. No new patterns or features to track. Our pipeline's multi-agent topology (Phase 5) aligns well with this direction.
- **Source**: https://www.infoq.com/news/2026/04/anthropic-three-agent-harness-ai/, https://resources.anthropic.com/2026-agentic-coding-trends-report

### 2026-04-07 -- claude-sneakpeek: Community Workaround for Early Swarm Access; "Harness Engineering" Named as Discipline
- **What**: Two multi-agent ecosystem developments: (1) **claude-sneakpeek** project provides community-built early access to Claude Code's TeammateTool/swarm mode before official GA. Uses isolated configuration at `~/.claude-sneakpeek/claudesp/` to avoid affecting primary Claude Code installations. Offers native swarm mode and task delegation by bypassing the `I9()`/`qFB()` feature gates that keep TeammateTool disabled in public releases. (2) **"Harness engineering"** is being recognized as a distinct discipline within AI development. The Swarms framework (github.com/kyegomez/swarms) has adopted Anthropic's three-agent harness pattern, and InfoQ's coverage explicitly named it as a new practice area. Key principle from Anthropic: "Every component in a harness encodes an assumption about what the model can't do on its own, and those assumptions are worth stress testing" — as models improve, harness complexity should decrease, not increase. The simplification principle: start with the simplest viable harness, add components only when the model demonstrably cannot handle a task alone.
- **Significance**: The claude-sneakpeek project demonstrates strong community demand for multi-agent capabilities and validates our Phase 5 multi-agent topology investment. The 13 TeammateTool operations (spawn, write, broadcast, approve/reject plan, graceful shutdown) are fully implemented but feature-gated — suggesting official launch is imminent. "Harness engineering" as a named discipline validates our pipeline's multi-agent architecture approach. The simplification principle is directly applicable: we should regularly stress-test whether our validator/optimizer separation is still needed as models improve.
- **Source**: https://paddo.dev/blog/claude-code-hidden-swarm/, https://www.infoq.com/news/2026/04/anthropic-three-agent-harness-ai/, https://github.com/kyegomez/swarms

### 2026-04-06 -- Anthropic Engineering: Three-Agent Harness for Long-Running Development (Planner/Generator/Evaluator)

- **What**: Anthropic published an engineering blog post detailing a GAN-inspired three-agent harness architecture for autonomous long-running software development: (1) **Planner Agent** — expands a 1-4 sentence user prompt into a comprehensive product spec, focusing on deliverables and high-level technical design. Actively identifies opportunities to integrate AI features. (2) **Generator Agent** — implements features iteratively using React/Vite/FastAPI/SQLite stacks, working sprint-by-sprint. Before each sprint, negotiates a "sprint contract" with the evaluator defining success criteria. (3) **Evaluator Agent** — uses Playwright MCP to interact with running applications like a real user, testing UI features, API endpoints, and database states. Grades sprints against predetermined criteria with hard thresholds; if any criterion fails, the sprint is rejected with detailed feedback. Key design insights: (a) Context resets between sessions with structured handoff artifacts (files, not conversations) instead of context compaction — Sonnet 4.5 exhibited "context anxiety" approaching limits. (b) Opus 4.6 improved enough to sustain continuous sessions without resets. (c) Self-evaluation bias is the critical failure mode: "agents tend to confidently praise their own work even when quality is obviously mediocre." Separating generator from evaluator proved the strongest lever. (d) Evaluator required significant prompt engineering — initial versions identified issues but rationalized approving mediocre work anyway. Four grading criteria for frontend: design quality, originality, craft, functionality. Design quality and originality weighted higher because Claude naturally excels at craft/functionality. Explicitly penalizes "AI slop" patterns.
- **Concrete Metrics**: Game Maker (Opus 4.5): solo agent 20min/$9 vs harness 6h/$200 — solo had broken game mechanics, harness produced functional gameplay with physics. DAW (Opus 4.6): Planner 4.7min/$0.46, 3 build rounds ~3.3h/$113, 3 QA rounds ~25min/$10, total ~3h50m/$124.70. Evaluator caught missing audio recording, non-functional timeline dragging, missing effect visualizations.
- **Key Quote**: "Every component in a harness encodes an assumption about what the model can't do on its own, and those assumptions are worth stress testing" — as models improve, harness components that compensate for model limitations can be simplified.
- **Significance**: This is Anthropic's first official multi-agent architecture recommendation for production use. The Planner/Generator/Evaluator pattern directly maps to our pipeline's meta-agent-factory (generator) / skill-quality-validator (evaluator) separation. The sprint contract pattern validates our Phase 4 approach. The context reset vs continuous session tradeoff is directly relevant to our steward agents' long-running sessions. The $124-200 cost range for complex outputs sets expectations for multi-agent costs. The GAN-style feedback loop is a concrete pattern we could adopt for autoresearch-optimizer iterations.
- **Source**: https://www.anthropic.com/engineering/harness-design-long-running-apps, https://www.infoq.com/news/2026/04/anthropic-three-agent-harness-ai/

### 2026-04-05 -- Conway: Anthropic's Always-On Persistent Agent Platform (Leaked)
- **What**: Multiple outlets (TestingCatalog, Dataconomy, aibase.com) reported on "Conway," an internal Anthropic platform for persistent, always-on Claude agents. Key details: (1) Conway operates as a dedicated web page ("Conway instance") rather than a standard chat view, with three core areas: Search, Chat, and System. (2) Can execute Claude Code, support external webhooks (public URLs that wake the instance), interact with Chrome, and send notifications. (3) Features an Extensions area for installing custom tools, UI tabs, and context handlers via `.cnw.zip` files — described as an "app store" for agent capabilities. (4) Webhook-driven wake means Conway instances can be triggered by external services (CI/CD, monitoring, Slack, etc.) without keeping a session open. (5) Codename "Lobster" also referenced in some reports.
- **Significance**: Conway represents Anthropic's vision for persistent agents — moving beyond session-based interactions to always-on autonomous environments. The `.cnw.zip` extension format signals a new ecosystem play. Webhook wake enables event-driven agent activation — a pattern our pipeline could adopt. If Conway ships, it could be the natural runtime for deployed Skills, replacing the current cron-based scheduling. The extension system could inform our Phase 5 multi-agent topology design.
- **Source**: https://dataconomy.com/2026/04/03/anthropic-tests-conway-platform-for-continuous-claude/, https://www.testingcatalog.com/exclusive-anthropic-tests-its-own-always-on-conway-agent/, https://news.aibase.com/news/26796

### 2026-04-04 -- Gartner Prediction: 40% Enterprise Apps Include Task-Specific Agents by End of 2026
- **What**: Gartner predicts that by end of 2026, 40% of enterprise applications will include task-specific AI agents, with multi-agent coordination being the key enabler. The 2026 Agentic Coding Trends Report confirms: "2026 is the year single-agent workflows give way to coordinated multi-agent systems, where one orchestrator decomposes a problem, specialized agents handle the parts, and results get synthesized."
- **Significance**: External validation that multi-agent is becoming the default enterprise pattern, not an experimental approach. Aligns with our pipeline's Phase 5 (Topology-Aware Multi-Agent) timeline.
- **Source**: https://zenvanriel.com/ai-engineer-blog/claude-code-swarms-multi-agent-orchestration/

### 2026-04-04 -- TeammateTool Internal Architecture: 13 Operations, 4 Categories (expanded detail)
- **What**: Expanded documentation of the TeammateTool architecture from the paddo.dev reverse engineering analysis. The 13 operations are organized into 4 categories: (1) Team Lifecycle: `spawnTeam`, `discoverTeams`, `cleanup`, `requestJoin`, `approveJoin`, `rejectJoin`. (2) Coordination: `write` (direct messaging), `broadcast` (all-teammate communication), `approvePlan`, `rejectPlan`. (3) Graceful Shutdown: `requestShutdown`, `approveShutdown`, `rejectShutdown`. Environmental infrastructure uses `~/.claude/teams/{team-name}/config.json` and `~/.claude/tasks/{team-name}/` for persistent state. Feature gates controlled by `I9()` and `qFB()` functions.
- **Significance**: The plan approval/rejection operations (`approvePlan`/`rejectPlan`) embedded in the coordination layer confirm that plan-then-implement workflows are a first-class primitive, not an afterthought. The graceful shutdown protocol (request → approve/reject) mirrors distributed systems consensus patterns.
- **Source**: https://paddo.dev/blog/claude-code-hidden-swarm/

### 2026-04-03 -- Rust C Compiler: 16-Agent Team Benchmark Published
- **What**: Anthropic tasked 16 agents working as a team with writing a Rust-based C compiler from scratch, capable of compiling the Linux kernel. Over ~2,000 Claude Code sessions and $20,000 in API costs, the agent team produced a 100,000-line compiler that can build Linux 6.9 on x86, ARM, and RISC-V architectures.
- **Significance**: Most ambitious public multi-agent benchmark from Anthropic. The scale (16 agents, 2,000 sessions, 100K lines) demonstrates agent teams can tackle system-level software engineering. The $20,000 cost figure provides a concrete economic benchmark for multi-agent ROI.
- **Source**: https://www.anthropic.com/engineering/building-c-compiler

### 2026-04-03 -- 2026 Agentic Coding Report: Multi-Agent Teams as Core Trend
- **What**: Anthropic's 2026 Agentic Coding Trends Report identifies "multi-agent coordination" as one of eight key trends. States: "Software development is shifting from an activity centered on writing code to an activity grounded in orchestrating agents that write code." Fountain case study: 50% faster screening, 40% quicker onboarding, 2x candidate conversions using hierarchical multi-agent orchestration. Claude Code demonstrated implementing complex methods in a 12.5M-line codebase in 7 hours with 99.9% accuracy.
- **Significance**: Positions multi-agent orchestration as Anthropic's strategic direction. The shift from "writing code" to "orchestrating agents" signals the future developer role as a conductor of agent teams.
- **Source**: https://news.bitcoin.com/anthropics-2026-agentic-coding-report-maps-the-rise-of-multi-agent-dev-teams/

### 2026-04-02 -- Deep Dive: Anthropic Multi-Agent Research System Architecture
- **What**: Anthropic engineering published detailed architecture of their internal multi-agent research system. Key pattern: orchestrator-worker with a LeadResearcher that spawns 3-5 parallel subagents. The lead analyzes queries, develops research strategies, decomposes into subtasks, and coordinates. Subagents execute independent web searches using parallel tool calls (3+ simultaneous), apply interleaved thinking to evaluate results, and return filtered findings. A dedicated CitationAgent handles source attribution. State is persisted via external memory when context approaches 200K tokens, with resumable checkpoints for error recovery and rainbow deployments to avoid disrupting active agents.
- **Significance**: First detailed public disclosure of Anthropic's own production multi-agent system internals. Reveals concrete performance data: multi-agent uses ~15x more tokens than single-turn chat; individual agents use ~4x. Token usage explains 80% of performance variance. Parallel tool execution reduces research time by up to 90% versus sequential.
- **Source**: https://www.anthropic.com/engineering/multi-agent-research-system

### 2026-04-02 -- Claude Code Agent Teams: Full Documentation and Architecture Reference
- **What**: Comprehensive official documentation for Agent Teams published at code.claude.com. Key details not previously captured: (1) Agent Teams require v2.1.32+, enabled via `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` env var. (2) Two display modes: in-process (all in one terminal, Shift+Down to cycle) and split-pane (tmux/iTerm2). (3) Shared task list uses file locking to prevent race conditions on claim. (4) Three hook events for quality gates: `TeammateIdle` (exit code 2 keeps teammate working), `TaskCreated` (exit code 2 blocks creation), `TaskCompleted` (exit code 2 blocks completion). (5) Subagent definitions can be reused as teammate roles -- define once, use as both subagent and teammate. (6) Team config stored at `~/.claude/teams/{team-name}/config.json`, tasks at `~/.claude/tasks/{team-name}/`. (7) Plan approval mode: teammates can be required to plan in read-only mode before the lead approves implementation. (8) No nested teams allowed -- only the lead can manage the team. (9) Lead is fixed for team lifetime -- no leadership transfer.
- **Significance**: Reveals production-grade orchestration primitives: file-locking task claims, hook-based quality gates, plan-then-implement approval workflows, and reusable subagent-as-teammate pattern. The hook system (TeammateIdle, TaskCreated, TaskCompleted) enables programmable quality enforcement without human intervention.
- **Source**: https://code.claude.com/docs/en/agent-teams

### 2026-04-02 -- Subagents vs Agent Teams: Formal Comparison
- **What**: Official documentation establishes clear taxonomy. Subagents: run within a single session, report results back to the main agent only, no peer communication, lower token cost. Agent Teams: fully independent sessions, direct peer-to-peer messaging via mailbox system, shared task list with self-coordination, higher token cost. Both have own context windows. Decision criterion: use subagents when only the result matters; use agent teams when teammates need to share findings, challenge each other, and coordinate independently.
- **Significance**: Clears up confusion in the ecosystem about when to use which pattern. The "competing hypotheses" use case (spawn 5 investigators that actively try to disprove each other) is a novel adversarial-debate orchestration pattern not seen in other frameworks.
- **Source**: https://code.claude.com/docs/en/agent-teams

### 2026-03-01 -- 2026 Agentic Coding Trends Report
- **What**: Anthropic published a comprehensive report on agentic coding trends. Key finding: developers use AI in ~60% of work but can fully delegate only 0-20% of tasks. Multi-agent systems amplify the cost of ambiguity -- they multiply the need for clarity rather than reduce it.
- **Significance**: Establishes that multi-agent is production-real but the "delegation gap" remains the primary bottleneck.
- **Source**: https://resources.anthropic.com/hubfs/2026%20Agentic%20Coding%20Trends%20Report.pdf

### 2026-02-06 -- Claude Code Agent Teams Official Launch
- **What**: Multi-agent system officially enabled in Claude Code alongside Opus 4.6 release. Architecture: lead agent plans and delegates; specialist agents (frontend, backend, testing, docs, architecture) work in parallel via independent Git worktrees; task board with dependencies; inter-agent @mention coordination.
- **Significance**: Multi-agent coding transitions from hidden/experimental to default workflow. Production-tested sweet spot: 2-5 teammates with 5-6 tasks each.
- **Source**: https://techcrunch.com/2026/02/05/anthropic-releases-opus-4-6-with-new-agent-teams/

### 2026-01-01 -- Hidden Multi-Agent System Discovered
- **What**: Security researchers found a fully-implemented multi-agent orchestration system inside Claude Code binary, feature-flagged off. Included TeammateTool and Delegate Mode for spawning background agents. Discovered via `claude-sneakpeek` binary inspection tool.
- **Significance**: Revealed Anthropic had been developing multi-agent capabilities for some time before official release.
- **Source**: https://paddo.dev/blog/claude-code-hidden-swarm/

### 2025-09-01 -- Agent SDK Subagent Pattern
- **What**: Claude Agent SDK formalized the subagent pattern: orchestrator spawns specialized agents via `AgentDefinition`, each with their own tools, prompt, and context window. Results reported back to parent.
- **Significance**: Provides the programmatic API for multi-agent patterns, complementing Claude Code's interactive approach.
- **Source**: https://claude.com/blog/building-agents-with-the-claude-agent-sdk

## Technical Details

### Claude Code Agent Teams Architecture (Updated 2026-04-02)

**Components**:
| Component | Role |
|-----------|------|
| Team lead | Main Claude Code session; creates team, spawns teammates, coordinates work |
| Teammates | Separate Claude Code instances; each works on assigned tasks |
| Task list | Shared list of work items; teammates claim and complete; file-locking prevents races |
| Mailbox | Messaging system for direct inter-agent communication |

**Lead Agent (Orchestrator)**:
- Does not write code directly
- Creates plan from user requirements
- Enters "delegation mode" when plan approved
- Creates specialist agents for specific roles
- Synthesizes results from all agents
- Can require plan approval before teammates implement

**Specialist Agents (Teammates)**:
- Each gets a fresh, focused context window
- Works in independent Git worktree (no edit collisions)
- Shares task board with dependency tracking
- Communicates via direct messaging (not just @mentions -- full mailbox system)
- Can self-claim unassigned, unblocked tasks
- Worktrees with no changes automatically cleaned up
- Load same project context (CLAUDE.md, MCP servers, skills) but NOT the lead's conversation history

**Display Modes**:
- `in-process`: all teammates in main terminal; Shift+Down to cycle; works anywhere
- `split-panes`: each teammate gets own pane; requires tmux or iTerm2
- `auto` (default): uses split panes if already in tmux, in-process otherwise

**Quality Gate Hooks**:
- `TeammateIdle`: runs when teammate about to idle; exit code 2 = send feedback, keep working
- `TaskCreated`: runs on task creation; exit code 2 = block creation with feedback
- `TaskCompleted`: runs on task completion; exit code 2 = block completion with feedback

**Permissions**: Teammates inherit lead's permission settings at spawn. Can be changed individually after.

**Limitations (current)**:
- No session resumption for in-process teammates
- Task status can lag (manual nudge sometimes needed)
- One team per session; no nested teams
- Lead is fixed for lifetime; no leadership transfer
- Split panes not supported in VS Code terminal, Windows Terminal, or Ghostty

**Storage Paths**:
- Team config: `~/.claude/teams/{team-name}/config.json`
- Task list: `~/.claude/tasks/{team-name}/`

### Anthropic Internal Multi-Agent Research System (2026-04-02)

**Architecture**: Orchestrator-worker pattern (hierarchical)
- LeadResearcher: analyzes queries, develops strategies, spawns 3-5 parallel subagents
- Subagents: execute independent web searches (3+ simultaneous parallel tool calls)
- CitationAgent: dedicated agent for source attribution
- Interleaved thinking: agents evaluate tool results inline before returning

**State Management**:
- External memory persistence when context approaches 200K tokens
- Resumable checkpoints for error recovery
- Rainbow deployments: prevent disruption to active agents during system updates
- Graceful tool failure handling (no restart-from-beginning)

**Performance Metrics**:
- Multi-agent: ~15x tokens vs single-turn chat
- Individual agent: ~4x tokens vs single-turn chat
- Token usage explains 80% of benchmark performance variance
- Parallel tool execution: up to 90% time reduction vs sequential

**Delegation Best Practices (from Anthropic)**:
- Detailed task specs required: clear objectives, output formats, tool guidance, explicit boundaries
- Without detailed descriptions: agents duplicate work, leave gaps, or fail to find information
- Effective delegation = the primary determinant of multi-agent system quality

### Agent SDK Subagent Pattern

```python
agents={
    "code-reviewer": AgentDefinition(
        description="Expert code reviewer",
        prompt="Analyze code quality.",
        tools=["Read", "Glob", "Grep"],
    ),
    "test-writer": AgentDefinition(
        description="Test generation specialist",
        prompt="Write comprehensive tests.",
        tools=["Read", "Write", "Bash"],
    )
}
```

Properties:
- Parallelization: multiple subagents run simultaneously
- Context isolation: each subagent has own context window
- Result aggregation: only relevant info returned to orchestrator
- Tracking: `parent_tool_use_id` links messages to parent

### Production Guidelines (from Anthropic)
- **Team size**: 2-5 teammates (>5 hits coordination overhead)
- **Task granularity**: 5-6 tasks per teammate
- **Scope clarity**: Each agent needs clear scope, success criteria, boundaries
- **Delegation gap**: Full delegation possible for only 0-20% of tasks; clarity is critical
- **Start simple**: Begin with research/review tasks, not code-writing, when new to agent teams

### Orchestration Patterns

1. **Fan-out/Fan-in**: Orchestrator decomposes task, fans out to specialists, collects results
2. **Pipeline**: Sequential handoff between specialized agents (e.g., write -> review -> test)
3. **Collaborative**: Agents share a task board and coordinate through messaging
4. **Hierarchical**: Multi-level delegation (orchestrator -> sub-orchestrator -> workers)
5. **Adversarial Debate** (new): Spawn multiple investigators with competing hypotheses; each tries to disprove the others; the surviving theory is more likely correct. Counters anchoring bias inherent in sequential investigation.

### Cost Considerations
- Multiple agents = multiple model calls = higher API costs
- Token costs scale linearly with number of active teammates
- Multi-agent: ~15x tokens of single-turn chat (Anthropic's own measurement)
- Productivity gains may offset cost increase for complex tasks
- Simple tasks remain more efficient with single-agent approaches
- For research/review/new features: extra tokens usually worthwhile
- For routine tasks: single session more cost-effective

## Comparison Notes

Anthropic Multi-Agent vs Google ADK Multi-Agent:
- **Anthropic**: Tight integration with Claude Code (Git worktrees, task boards, mailbox, hooks); SDK offers programmatic subagents
- **Google ADK**: Supports multi-agent via agent composition with routing agents, sequential agents, and parallel agents
- **Both**: Support orchestrator/specialist patterns and parallel execution
- **Key difference**: Anthropic's agent teams are deeply integrated into the coding workflow (worktrees, file ownership, quality gate hooks); Google's approach is more general-purpose

Anthropic Subagents vs Agent Teams:
- **Subagents**: Within single session, report to parent only, no peer communication, lower token cost, best for focused tasks
- **Agent Teams**: Fully independent sessions, direct peer messaging, shared task list with self-coordination, higher token cost, best for collaborative/adversarial work

Anthropic vs A2A Protocol:
- Anthropic's multi-agent patterns are intra-ecosystem (Claude agents talking to Claude agents)
- A2A protocol (Google-originated) focuses on cross-vendor agent interoperability
- MCP focuses on model-to-tool; A2A focuses on agent-to-agent
- No current Anthropic-native A2A support, though MCP and A2A are designed to be complementary
