# Project Mariner

**Last updated**: 2026-04-02
**Sources**:
- https://deepmind.google/models/project-mariner/
- https://techcrunch.com/2024/12/11/google-unveils-project-mariner-ai-agents-to-use-the-web-for-you/
- https://techcrunch.com/2025/05/20/google-rolls-out-project-mariner-its-web-browsing-ai-agent/
- https://www.allaboutai.com/ai-agents/project-mariner/

## Overview

Project Mariner is a Google DeepMind research prototype for autonomous web browsing. Built on Gemini 2.0, it can read screen content, plan multi-step workflows, and execute actions in a Chrome browser on behalf of the user. Originally unveiled in December 2024 as a limited research preview, it expanded to broader availability at Google I/O 2025 and has been evolving toward a full consumer product integrated into Google's AI Ultra subscription tier.

## Key Developments (reverse chronological)

### 2026-04-02 -- Mariner as Integrated Product (surveyed)
- **What**: Project Mariner is moving from experimental prototype to integrated ecosystem feature. Included in Google's AI Ultra plan ($249.99/month) for U.S. subscribers. Features "Teach and Repeat" functionality for learning workflows, persistent cross-session memory, and ability to handle up to 10 concurrent tasks.
- **Significance**: The shift from research prototype to subscription product signals Google's commitment to browser agents as a commercial offering. Persistent memory enables Mariner to remember user preferences and workflows across sessions.
- **Source**: https://www.allaboutai.com/ai-agents/project-mariner/

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
