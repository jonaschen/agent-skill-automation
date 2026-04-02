# Computer Use

**Last updated**: 2026-04-02
**Sources**:
- https://platform.claude.com/docs/en/agents-and-tools/tool-use/computer-use-tool
- https://siliconangle.com/2026/03/23/anthropics-claude-gets-computer-use-capabilities-preview/
- https://tech-insider.org/anthropic-claude-computer-use-agent-2026/
- https://brainroad.com/claude-computer-use-what-it-means-for-ai-agents-in-2026/

## Overview

Computer Use is a beta feature that enables Claude to interact with desktop environments by taking screenshots, interpreting what is on screen, and controlling mouse/keyboard inputs. It operates as a screenshot-action loop: Claude sees the screen, decides what to click or type, executes the action, takes another screenshot, and repeats. As of March 2026, Anthropic announced Mac desktop control for Pro/Max subscribers, and a "Zoom Action" feature was added for inspecting small UI elements at high resolution.

## Key Developments (reverse chronological)

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

### Safety Measures
- Permission-first approach (approval per app)
- App blocklists
- Restrictions on high-risk actions (fund transfers, etc.)
- Input monitoring for prompt injection detection
- Automatic classifier that steers model to ask for user confirmation on detected prompt injections
- ZDR (Zero Data Retention) eligible

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
