# Agentic AI Sweep Report — 2026-04-18 Evening (Google/DeepMind Only)

## Executive Summary

- **CORRECTION**: Gemini CLI v0.38.2 shipped Apr 17 — earlier sweep's "Day 3 quiet" was wrong for stable track; nightly pipeline pause still holds
- **Android XR April update** (Apr 7) ships 5 features: auto-spatialization (2D→3D), real hand tracking, session resume, app pinning, Android Enterprise XR — first major update to Galaxy XR headset
- **vLLM Blackwell benchmarks** confirm 26B MoE as optimal Gemma 4 variant for agent workloads: 3.6x concurrent throughput advantage over Ollama, 3.2x faster TTFT
- **I/O session schedule** reveals "Agent-first workflows from prompt to production" at 3:30 PM May 19 — strongest signal yet for ADK v2.0 headline
- **Frozen topics stable**: A2A day 38 (no change), Vertex AI day 59+ (no change), Mariner day 14 (no change), ADK v1.31.0 day 1 (no change)

## Google/DeepMind Updates

### Gemini Agents / CLI
- **Gemini CLI v0.38.2** (Apr 17) — patch release cherry-picking commit 14b2f35 from v0.38.1. Corrects earlier "Day 3 quiet" narrative: stable releases are still shipping, only the nightly pipeline is paused (no nightlies for Apr 16-18)
- **Gemini API** — confirmed silent since Apr 15 (TTS). Page "last updated 2026-04-15 UTC"
- **I/O session "Agent-first workflows from prompt to production"** confirmed May 19 at 3:30 PM PT alongside "What's new in Google AI" and "What's new in Android"
- **I/O expectations consolidation**: Engadget, Sportskeeda, 91mobiles, Android Central — Gemini 4, Astra, Android XR, "Aluminium OS," Boston Dynamics robotics
- **Source**: [Releasebot](https://releasebot.io/updates/google/gemini-cli), [GitHub](https://github.com/google-gemini/gemini-cli/releases), [Technobezz](https://www.technobezz.com/news/google-io-2026-schedule-puts-ai-ahead-of-android-17-and-chrome-updates)

### A2A Protocol
- Day 38 post-v1.0.0. No change. 210 open issues, 22 PRs. Zero v1.1 activity. I/O 31d.
- **Source**: [GitHub](https://github.com/a2aproject/A2A/releases)

### Agent Development Kit (ADK)
- ADK v1.31.0 (Apr 17) holds, day 1. No v1.32.0 or v2.0.0-alpha.4.
- v1.31.0 also includes "Live UI" overhaul and "Computer Use View" for task visualization (beyond the Session Rewind / Service Registry / Sandbox Executor already captured)
- Next release ~Apr 27-May 1 based on 4-day cadence
- **Source**: [GitHub](https://github.com/google/adk-python/releases)

### Vertex AI Agents (AI Applications)
- Day 59+ Agent Builder silence. Last entry Feb 18 (Code Execution GA). No change.
- Vertex AI GenAI last entry Apr 15 (TTS). 3 days quiet.
- HIPAA workload support on Agent Engine confirmed (new observation)
- **Source**: [Release Notes](https://docs.cloud.google.com/agent-builder/release-notes)

### Project Mariner
- Day 14 quiet phase. No change. Enterprise API still "coming to the Gemini API" with no date.
- "Teach and Repeat" persistent memory and Computer Use in Gemini 3 Pro/Flash API confirmed (captured in earlier sweep)
- **Source**: [DeepMind](https://deepmind.google/models/project-mariner/)

### Project Astra
- Day 14 quiet phase. Key new finding:
- **Android XR April 2026 update** (Apr 7, rolled out) — 5 features:
  1. **Auto-Spatialization** (Labs) — any 2D app/game/website/video → 3D with one button
  2. **App Pinning** — anchor apps to physical walls
  3. **Real Hand Tracking** — see physical hands in home space (replaces white outlines)
  4. **Session Resume** — automatic restoration of app placement/layouts
  5. **100+ XR-optimized apps** — doubled since Galaxy XR launch
- **Android Enterprise XR** now supported — enterprise training/collaboration at scale
- Improved hand tracking, eye tracking, and accessibility
- **Source**: [Google Blog](https://blog.google/products-and-platforms/platforms/android/android-xr-immersive-features-update-april-2026/), [9to5Google](https://9to5google.com/2026/04/07/android-xr-apps-april/), [Android Authority](https://www.androidauthority.com/galaxy-xr-android-xr-new-features-3655529/)

### Gemma / Open Models
- Day 17. No new variants. Key new finding:
- **vLLM v0.19.0** — complete Gemma 4 support (all 4 variants). 445 commits, 213 contributors
- **Blackwell benchmark** (RTX PRO 6000, 96GB): vLLM TTFT 3.2x faster (58ms vs 184ms), 3.6x concurrent throughput, but Ollama 1.4-2.6x faster single-user decode
- **26B MoE confirmed optimal** for agent workloads: "26B intelligence at near-4B speed"
- **EAGLE3** still WIP at day 11 — no merge in sight
- **NVIDIA NVFP4** quantization available for 31B on HuggingFace
- **Source**: [Medium Benchmark](https://allenkuo.medium.com/gemma-4-on-vllm-vs-ollama-benchmarks-on-a-96-gb-blackwell-gpu-804ca4845a21), [Fazm Blog](https://fazm.ai/blog/vllm-update-april-2026)

## Google I/O Event-Driven Queries (May 19-20, 31 days)

| Query | Result |
|-------|--------|
| "Google I/O 2026" ADK agent development kit | "Agent-first workflows" session confirmed May 19 3:30pm |
| "Google I/O 2026" Gemini 4 model | Multiple outlets expect Gemini 4; speculative articles appearing but no confirmed leak |
| "Google I/O 2026" A2A protocol v1.1 | No A2A-specific I/O session. Agent tracks expected. Zero v1.1 leaks |
| "Google I/O 2026" Android XR agent | "Adaptive Everywhere" Day 2 track confirmed. No dedicated XR session yet |
| "Google I/O 2026" Gemma agent edge | Gemma sessions confirmed. Gemini Nano 3 API surface expected |

## Deprecation Countdown

| Model | Retirement Date | Days Remaining |
|-------|----------------|---------------|
| `gemini-robotics-er-1.5-preview` | Apr 30, 2026 | 12 |
| Gemini 2.0 Flash | Jun 1, 2026 | 44 |
| Gemini 2.0 Flash-Lite | Jun 1, 2026 | 44 |
| Gemini 2.5 Pro | Oct 16, 2026 | 181 |
| Gemini 2.5 Flash | Oct 16, 2026 | 181 |
| Gemini 2.5 Flash-Lite | Oct 16, 2026 | 181 |

## Implications for Our Pipeline

- **No immediate action items** — Google track remains in deep pre-I/O freeze
- **vLLM 26B MoE benchmark** is actionable intelligence for Phase 6 serving architecture: 3.6x concurrent throughput makes vLLM the clear choice for multi-agent inference
- **Android Enterprise XR** opens a new deployment surface worth tracking for Phase 6/7 enterprise agent deployment
- **"Agent-first workflows" I/O session** will be the single most important Google announcement for our Phase 5 multi-agent architecture — monitor closely

## Next Sweep Focus

- Monitor for Gemini CLI nightly pipeline resumption (stable patches continue but no nightlies since Apr 15)
- Pre-I/O leak window opens ~May 2 (14 days) — increase Google monitoring frequency
- vLLM EAGLE3 merge status (#38893) — now day 11 WIP with no progress signal
- ADK v1.32.0 expected ~Apr 27-May 1
