# Computer Use

**Last updated**: 2026-04-03
**Sources**:
- https://platform.claude.com/docs/en/agents-and-tools/tool-use/computer-use-tool
- https://siliconangle.com/2026/03/23/anthropics-claude-gets-computer-use-capabilities-preview/
- https://tech-insider.org/anthropic-claude-computer-use-agent-2026/
- https://brainroad.com/claude-computer-use-what-it-means-for-ai-agents-in-2026/
- https://9to5google.com/2026/03/24/claude-can-now-remotely-control-your-computer-and-it-looks-absolutely-wild-video/
- https://aitoolanalysis.com/claude-in-chrome-review/

## Overview

Computer Use is a beta feature that enables Claude to interact with desktop environments by taking screenshots, interpreting what is on screen, and controlling mouse/keyboard inputs. It operates as a screenshot-action loop: Claude sees the screen, decides what to click or type, executes the action, takes another screenshot, and repeats. As of March 2026, Anthropic announced Mac desktop control for Pro/Max subscribers, and a "Zoom Action" feature was added for inspecting small UI elements at high resolution.

## Key Developments (reverse chronological)

### 2026-04-03 -- No New Announcements; Feature Stable in Research Preview
- **What**: No new Computer Use features, API changes, or announcements have been published since April 2, 2026. The feature remains in research preview status as launched on March 23, 2026. Latest version is v2.1.90. Most recent changes were bug fixes: multi-monitor `switch_display` fix (v2.1.85, March 26), Dispatch message delivery fix (v2.1.87, March 29).
- **Significance**: The feature is stable in its current research preview form. No new capabilities or API surface changes detected.
- **Source**: https://releasebot.io/updates/anthropic

### 2026-04-02 -- Dispatch Phone Companion Integration (newly documented)
- **What**: The "Dispatch" feature allows users to assign Claude a task from their phone, walk away, and pick up the finished work on their computer. Both the Mac and Claude desktop app must remain active. This extends Computer Use into an asynchronous delegation model.
- **Significance**: Shifts computer use from a supervised real-time interaction to a background task execution paradigm. Users can delegate while AFK.
- **Source**: https://9to5google.com/2026/03/24/claude-can-now-remotely-control-your-computer-and-it-looks-absolutely-wild-video/

### 2026-04-02 -- Browser Automation Benchmark Gap (newly documented)
- **What**: On browser automation benchmarks as of early 2026, ChatGPT agent mode hits 87% success rate while Claude Sonnet achieves 56%. However, on WebArena (autonomous web navigation), Claude achieves state-of-the-art results among single-agent systems.
- **Significance**: Claude excels at full end-to-end web navigation but lags on isolated browser automation tasks compared to OpenAI. The zoom action may help close this gap by improving small-element targeting.
- **Source**: https://aitoolanalysis.com/claude-in-chrome-review/

### 2026-04-02 -- Claude in Chrome Extension Details (newly documented)
- **What**: Chrome extension that turns the browser into an AI-powered automation tool. Claude can see, click, type, and navigate the web. Targeted at professionals spending 2+ hours daily on repetitive browser tasks (data extraction, form filling, multi-site research).
- **Significance**: Provides a lighter-weight browser-only automation path alongside full desktop Computer Use. Lower barrier to entry than full desktop control.
- **Source**: https://aitoolanalysis.com/claude-in-chrome-review/

### 2026-03-23 -- Mac Desktop Control Announced
- **What**: Claude can now take control of a user's Mac and execute tasks autonomously. Available as exploratory preview for Claude Pro and Max subscribers. Permission-first approach requiring approval for each new app, blocklists for specific apps, restrictions on high-risk actions.
- **Significance**: First consumer-facing desktop automation from Anthropic. Previously API-only. Currently Mac-only (no Windows/Linux consumer version).
- **Source**: https://siliconangle.com/2026/03/23/anthropics-claude-gets-computer-use-capabilities-preview/

### 2026-02-01 -- Zoom Action Added (computer_20251124)
- **What**: New `zoom` action lets Claude inspect a specific screen region at full resolution before clicking. Requires `enable_zoom: true` in tool definition. Takes `region` parameter with `[x1, y1, x2, y2]` coordinates.
- **Significance**: Fixes one of the biggest reliability problems from early beta -- guessing at small buttons and misclicking. Available for Opus 4.6, Sonnet 4.6, and Opus 4.5.
- **Source**: https://platform.claude.com/docs/en/agents-and-tools/tool-use/computer-use-tool

### 2025-11-24 -- computer_20251124 Tool Version
- **What**: New tool version for Opus 4.6, Sonnet 4.6, and Opus 4.5. Beta header: `computer-use-2025-11-24`. Includes all actions from previous version plus zoom.
- **Significance**: Latest tool version with expanded model support and zoom capability.
- **Source**: https://platform.claude.com/docs/en/agents-and-tools/tool-use/computer-use-tool

### 2025-08-01 -- Claude for Chrome Extension
- **What**: Google Chrome extension allowing Claude Code to directly control the browser.
- **Significance**: Browser integration complements desktop computer use for web-based automation.
- **Source**: https://siliconangle.com/2026/03/23/anthropics-claude-gets-computer-use-capabilities-preview/

### 2025-01-24 -- computer_20250124 Tool Version (Claude 4 models)
- **What**: Enhanced actions for Claude 4/Sonnet 3.7: scroll, left_click_drag, right_click, middle_click, double_click, triple_click, left_mouse_down/up, hold_key, wait.
- **Significance**: Major expansion of action repertoire enabling complex UI interactions.
- **Source**: https://platform.claude.com/docs/en/agents-and-tools/tool-use/computer-use-tool

## Technical Details

### Three-Tier Task Hierarchy
Claude completes tasks using a priority-ordered approach:
1. Direct integrations (Google Workspace, Slack, etc.)
2. Browser navigation for web tools
3. Direct screen control (screenshot + mouse/keyboard) as fallback

### Tool Versions
| Version | Models | Beta Header |
|---------|--------|-------------|
| `computer_20251124` | Opus 4.6, Sonnet 4.6, Opus 4.5 | `computer-use-2025-11-24` |
| `computer_20250124` | Claude 4 models, Sonnet 3.7 | `computer-use-2025-01-24` |

### Available Actions

**Basic (all versions):** screenshot, left_click, type, key, mouse_move

**Enhanced (20250124+):** scroll (directional), left_click_drag, right_click, middle_click, double_click, triple_click, left_mouse_down/up, hold_key, wait

**Latest (20251124+):** zoom (region inspection at full resolution)

**Modifier keys:** Click and scroll actions support modifier keys (shift, ctrl, alt, super) via `text` parameter.

### Tool Parameters
| Parameter | Required | Description |
|-----------|----------|-------------|
| type | Yes | Tool version string |
| name | Yes | Must be "computer" |
| display_width_px | Yes | Display width in pixels |
| display_height_px | Yes | Display height in pixels |
| display_number | No | X11 display number |
| enable_zoom | No | Enable zoom action (20251124 only) |

### Coordinate Scaling
API constrains images to max 1568px longest edge and ~1.15 megapixels. Developers must:
1. Resize screenshots before sending to Claude
2. Scale Claude's returned coordinates back up to actual screen resolution

Formula: `scale = min(1.0, 1568/max(w,h), sqrt(1150000/(w*h)))`. Apply scale to screenshot before sending; divide Claude's returned coordinates by scale before executing.

### Safety Measures
- Permission-first approach (approval per app)
- App blocklists
- Restrictions on high-risk actions (fund transfers, stock trading, sensitive data input, facial image collection)
- Input monitoring for prompt injection detection
- Automatic classifier that steers model to ask for user confirmation on detected prompt injections
- ZDR (Zero Data Retention) eligible
- Users can stop processes at any time

### Token Usage
- System prompt overhead: 466-499 tokens
- Tool definition: 735 tokens per Claude 4.x models
- Plus screenshot image tokens (vision pricing)

### Recommended Resolutions
- General desktop: 1024x768 or 1280x720
- Web applications: 1280x800 or 1366x768
- Avoid above 1920x1080

### Known Limitations
1. Latency too slow for real-time human-AI interaction
2. Vision accuracy: may hallucinate coordinates
3. Tool selection: may take unexpected actions with niche apps
4. Niche app reliability lower than mainstream apps
5. Account creation/social media interaction limited
6. Prompt injection vulnerability in web content
7. Browser automation benchmark: 56% success rate (vs ChatGPT 87%) on isolated tasks, though SOTA on WebArena end-to-end navigation

### Platform Support (as of 2026-04-02)
| Platform | Consumer Desktop | API/Docker | Notes |
|----------|-----------------|------------|-------|
| macOS | Supported (March 2026) | Supported | Pro ($20/mo) or Max ($100-200/mo) required |
| Windows | Not yet | Supported | Cowork added Windows Feb 2026; Computer Use expected soon |
| Linux | Not available | Supported | Reference implementation via Docker/Xvfb |

## Comparison Notes

vs Google Project Mariner (browser agent):
- Claude Computer Use is a general desktop automation tool; Mariner is browser-specific
- Claude operates via screenshot-action loop; Mariner uses browser DOM understanding
- Claude is API-available for developers; Mariner is consumer-facing
- Both face similar challenges with prompt injection and reliability
- Claude's zoom feature addresses small-element reliability; Mariner uses DOM-level precision

vs Google Project Astra (multimodal agent):
- Astra is a multimodal AI assistant with real-time video/audio understanding
- Computer Use is specifically desktop/browser automation
- Different use cases: Astra for conversational assistance, Computer Use for task automation

vs OpenAI ChatGPT Agent Mode:
- ChatGPT agent mode: 87% on browser automation benchmarks
- Claude Sonnet: 56% on same benchmarks, but SOTA on WebArena (end-to-end web navigation)
- Claude offers full desktop control; ChatGPT agent mode is primarily browser-based
- Claude's Dispatch feature enables async phone-to-desktop delegation; no direct OpenAI equivalent
