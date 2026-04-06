# Project Mariner

**Last updated**: 2026-04-07
**Sources**:
- https://deepmind.google/models/project-mariner/
- https://deepmind.google/technologies/project-mariner/
- https://techcrunch.com/2024/12/11/google-unveils-project-mariner-ai-agents-to-use-the-web-for-you/
- https://techcrunch.com/2025/05/20/google-rolls-out-project-mariner-its-web-browsing-ai-agent/
- https://www.allaboutai.com/ai-agents/project-mariner/
- https://www.reactionarytimes.com/googles-strategic-pivot-deepmind-absorbs-project-mariner-to-win-the-ai-agent-war/
- https://www.programming-helper.com/tech/google-project-mariner-ai-browser-agent-2026-autonomous-web-navigation
- https://labs.google.com/mariner/
- https://blog.google/technology/google-deepmind/gemini-computer-use-model/

## Overview

Project Mariner is a Google DeepMind research prototype for autonomous web browsing. Built on Gemini 2.0, it can read screen content, plan multi-step workflows, and execute actions in a Chrome browser on behalf of the user. Originally unveiled in December 2024 as a limited research preview, it expanded to broader availability at Google I/O 2025 and has been evolving toward a full consumer product integrated into Google's AI Ultra subscription tier.

## Key Developments (reverse chronological)

### 2026-04-07 -- Mariner 2026 Roadmap Crystallized: Mariner Studio Q2, Enterprise API, Marketplace Q4
- **What**: Project Mariner's 2026 roadmap has been confirmed across multiple sources with four major milestones: (1) **Enterprise API** (Q1 2026, may already be in limited rollout) — authenticated task execution with RBAC (Role-Based Access Control) and SOC 2 compliance posture updates. Enables programmatic Mariner access for enterprise automation workflows. (2) **Mariner Studio** (Q2 2026, expected around Google I/O) — a **visual builder for assembling task flows without direct prompting**. Users create automated workflows through a graphical interface, making browser automation accessible to non-technical users. This is a significant product evolution from prompt-driven to visual-builder-driven automation. (3) **Cross-device sync** (Q3 2026) — allows task progress and continuation across desktop and Android, enabling workflows started on one device to be completed on another. (4) **Agent Marketplace** (Q4 2026) — a curated marketplace where Google will vet and list third-party autonomous workflows, creating a commerce layer around Mariner. (5) No new feature announcements since the Computer Use model three-product deployment (Mariner, Firebase Testing Agent, AI Mode in Search). Product remains in stabilization phase at labs.google.com/mariner/ for AI Ultra subscribers ($249.99/month).
- **Significance**: The four-phase roadmap reveals Google's plan to evolve Mariner from a consumer toy ($250/mo Chrome extension) to a full enterprise automation platform (Enterprise API → Visual Builder → Cross-device → Marketplace). Mariner Studio's visual builder in Q2 is the most impactful milestone — it mirrors the low-code/no-code trend and could significantly expand the Mariner user base beyond technical users. The Q4 Agent Marketplace is strategically important — it creates a commercial ecosystem around browser automation tasks. For our pipeline, the Enterprise API (if accessible) could be a deployment target for browser-based agent skills, and the Marketplace could be a distribution channel.
- **Source**: https://aiagentsdirectory.com/agent/project-mariner, https://www.programming-helper.com/tech/google-project-mariner-ai-browser-agent-2026-autonomous-web-navigation, https://deepmind.google/models/project-mariner/

### 2026-04-06 -- Computer Use Model Powers Three Google Products; Mariner in Stabilization Phase
- **What**: Confirmed that the Gemini 2.5 Computer Use model (Mariner's API surface) now actively powers **three distinct Google products**: (1) **Project Mariner** consumer product (browser automation via AI Ultra subscription), (2) **Firebase Testing Agent** (automated mobile/web app testing), and (3) **AI Mode in Search** (agentic search capabilities). The `computer_use` tool in the Gemini API is designed to operate within a loop pattern. The model outperforms leading alternatives on multiple web and mobile control benchmarks with lower latency. No new Mariner feature announcements in April 4-6 — the product remains in stabilization/expansion phase. Google I/O 2026 (May 19-20) is the next expected venue for Mariner updates.
- **Significance**: The confirmation that Computer Use powers Firebase Testing Agent is new intelligence — it reveals Google is using Mariner's core technology internally for developer tooling, not just consumer browsing automation. This is a "dog-fooding" signal that validates the technology for production use. The three-product deployment (consumer, developer tool, search) demonstrates the versatility of the Computer Use model. For our pipeline, this confirms browser automation is becoming a commodity capability embedded across multiple surfaces, not a standalone product.
- **Source**: https://blog.google/innovation-and-ai/models-and-research/google-deepmind/gemini-computer-use-model/, https://deepmind.google/models/project-mariner/

### 2026-04-05 -- Gemini 2.5 Computer Use Model: Mariner's API Surface Crystallizes
- **What**: The **Gemini 2.5 Computer Use model** (originally released Oct 7, 2025, updated Jan 7, 2026) represents the API-accessible version of Mariner's core capabilities. Key details: (1) Built on Gemini 2.5 Pro's visual understanding and reasoning, specialized for UI interaction. (2) **Outperforms leading alternatives on multiple web and mobile control benchmarks** with lower latency. (3) Available via the **Gemini API in AI Studio and Vertex AI**. (4) Supports both browser and mobile app automation. (5) Mariner consumer product continues on the AI Ultra subscription ($249.99/month) with labs.google.com/mariner/ portal. (6) No new architectural changes or feature announcements in the past week — Mariner remains in stabilization/expansion phase. The Gemini CLI's experimental `browser_agent` subagent (requires Chrome 144+) represents a separate but related developer surface for browser automation using the Computer Use model.
- **Significance**: The Computer Use model is effectively Mariner's developer-facing surface — the technology stack that powered Mariner's consumer product is now accessible to any developer via API. This is a significant democratization moment: what was a $250/month subscription feature is now available at API pricing. The Gemini CLI browser_agent integration means terminal-based developers can invoke browser automation without leaving their workflow. Combined with ADK Java's `ComputerUseTool`, Google now has browser automation APIs in 3 surfaces: Gemini API direct, ADK framework, and Gemini CLI.
- **Source**: https://blog.google/technology/google-deepmind/gemini-computer-use-model/, https://geminicli.com/docs/core/subagents/

### 2026-04-04 -- Mariner API Integration & Labs Portal Confirmed
- **What**: Confirmed status as of April 2026: (1) **Labs portal live** at `labs.google.com/mariner/` — providing direct access to the research prototype. (2) **Gemini API integration planned**: Google confirmed plans to bring "Project Mariner's computer use capabilities into the Gemini API" and expand to "other Google products soon." (3) **Demonstrated use cases refined**: job listing search on job boards, hiring service providers through task-matching platforms, and recipe ingredient shopping (finding missing ingredients → ordering online). (4) **Still a research prototype** — team actively soliciting user feedback. Available in US to Google AI Ultra subscribers ($249.99/month).
- **Significance**: The labs.google.com/mariner/ portal indicates Mariner is approaching broader availability beyond the AI Ultra subscription. The API integration timeline remains vague ("soon") but when it lands, it will make browser automation a commodity capability available to any developer via API. No major architectural changes since last update — Mariner appears to be in a stabilization/expansion phase rather than feature development.
- **Source**: https://deepmind.google/technologies/project-mariner/, https://labs.google.com/mariner/

### 2026-04-03 -- Cloud Infrastructure & Developer API Status
- **What**: Further details on Mariner's evolution in 2026: (1) **Cloud-based infrastructure** accelerated in early 2026 — Mariner now runs on virtual machines in the background, enabling sandboxed task execution in secure VMs in Google Cloud to minimize cross-site contamination or code injection risk. (2) **Developer API**: Google is bringing Mariner capabilities to the Gemini API and Vertex AI, allowing developers to build applications powered by the browser agent. Currently in testing with select partners; broad developer access was planned for summer 2025 but timeline may have shifted. Developers must adhere to strict OAuth and token-based authentication protocols. (3) **Human Security monitoring**: Mariner is being tracked by web security companies (e.g., Human Security) as its autonomous browsing generates identifiable traffic patterns on websites.
- **Significance**: The shift to cloud VMs is architecturally important — it decouples Mariner from the user's local Chrome, enabling background task execution and better security isolation. The developer API availability (when it lands broadly) will be a significant moment — it would let any app embed browser automation capabilities. The security monitoring aspect highlights emerging challenges: websites must now decide how to handle AI browser agents.
- **Source**: https://www.programming-helper.com/tech/google-project-mariner-ai-browser-agent-2026-autonomous-web-navigation, https://www.humansecurity.com/ai-agent/google-mariner/

### 2026-04-02 -- Mariner Absorbed into Core DeepMind (sweep update)
- **What**: Google has officially integrated the Project Mariner team directly into **core Google DeepMind** under Demis Hassabis. This organizational restructuring eliminates bureaucratic layers between Google's most advanced models and its browser agent product. Mariner continues to move from experimental prototype to integrated ecosystem feature, included in Google's AI Ultra plan ($249.99/month) for U.S. subscribers. Features "Teach and Repeat" functionality for learning workflows, persistent cross-session memory, and ability to handle up to 10 concurrent tasks. The "Observe-Plan-Act" loop architecture mirrors human problem-solving.
- **Significance**: Placing Mariner directly under Hassabis at DeepMind is a strong organizational signal — it means browser agents are now a core DeepMind priority, not a peripheral research project. This accelerates the path from prototype to integrated feature across Google products. Combined with the Astra desktop variant, Google is building a comprehensive vision+browser agent stack.
- **Source**: https://www.reactionarytimes.com/googles-strategic-pivot-deepmind-absorbs-project-mariner-to-win-the-ai-agent-war/, https://www.allaboutai.com/ai-agents/project-mariner/

### 2025-05-20 -- Google I/O 2025 Broader Rollout
- **What**: Google announced expanded availability of Project Mariner to more users and developers. Capabilities upgraded to handle nearly a dozen concurrent tasks simultaneously.
- **Significance**: Expansion from limited research preview to broader access marks a significant step toward productization. Multi-task concurrency is a differentiator from other browser agents.
- **Source**: https://techcrunch.com/2025/05/20/google-rolls-out-project-mariner-its-web-browsing-ai-agent/

### 2024-12-11 -- Initial Unveiling
- **What**: Google DeepMind unveiled Project Mariner as a research prototype alongside Gemini 2.0. Initially available to a select group of testers. Achieved 83.5% success rate on WebVoyager benchmark for real-world web tasks.
- **Significance**: First major browser agent from a large AI lab, demonstrating viability of autonomous web navigation. The 83.5% WebVoyager score set an early benchmark for the category.
- **Source**: https://techcrunch.com/2024/12/11/google-unveils-project-mariner-ai-agents-to-use-the-web-for-you/

## Technical Details

### Architecture
- Built on **Gemini 2.0** multimodal foundation
- Uses screen reading (vision) to understand page content and layout
- Plans multi-step action sequences to achieve user goals
- Executes actions in Chrome browser (clicks, typing, navigation, form filling)

### Key Capabilities
- **Autonomous web navigation**: Browses any website regardless of structure
- **Multi-task concurrency**: Handles up to 10 simultaneous tasks
- **Teach and Repeat**: Users demonstrate a workflow once; Mariner learns and can repeat it
- **Persistent cross-session memory**: Remembers preferences and learned workflows between sessions
- **Task types**: Online shopping, information retrieval, form filling, research tasks

### Benchmarks
- **WebVoyager**: 83.5% success rate (at launch, December 2024)

### Availability
- U.S. subscribers to Google AI Ultra plan ($249.99/month)
- Developer access expanding (announced at I/O 2025)
- More countries "coming soon" as of early 2026

## Comparison Notes

**vs Anthropic Computer Use**:
- Anthropic Computer Use operates at the desktop/OS level (full computer control); Mariner is browser-only
- Anthropic Computer Use is available via API for developers to build with; Mariner is primarily a consumer product
- Mariner's "Teach and Repeat" has no direct Anthropic equivalent -- Claude Computer Use requires explicit instructions each time
- Mariner has persistent memory; Computer Use does not retain context across sessions
- Mariner runs in Chrome only; Anthropic Computer Use works across the full desktop
- Mariner is bundled in a $249.99/month subscription; Anthropic Computer Use is billed per API call
- Both use vision-based screen understanding as their foundation
- Mariner targets end-user task automation; Anthropic targets developer-built automation workflows
