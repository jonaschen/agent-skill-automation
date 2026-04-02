# Project Mariner

**Last updated**: 2026-04-03
**Sources**:
- https://deepmind.google/models/project-mariner/
- https://techcrunch.com/2024/12/11/google-unveils-project-mariner-ai-agents-to-use-the-web-for-you/
- https://techcrunch.com/2025/05/20/google-rolls-out-project-mariner-its-web-browsing-ai-agent/
- https://www.allaboutai.com/ai-agents/project-mariner/
- https://www.reactionarytimes.com/googles-strategic-pivot-deepmind-absorbs-project-mariner-to-win-the-ai-agent-war/
- https://www.programming-helper.com/tech/google-project-mariner-ai-browser-agent-2026-autonomous-web-navigation

## Overview

Project Mariner is a Google DeepMind research prototype for autonomous web browsing. Built on Gemini 2.0, it can read screen content, plan multi-step workflows, and execute actions in a Chrome browser on behalf of the user. Originally unveiled in December 2024 as a limited research preview, it expanded to broader availability at Google I/O 2025 and has been evolving toward a full consumer product integrated into Google's AI Ultra subscription tier.

## Key Developments (reverse chronological)

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
