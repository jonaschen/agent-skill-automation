# Computer Use

**Last updated**: 2026-04-08
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

### 2026-04-08 -- Computer Use: Microsoft 365 Integration Now Free-Tier; No New API Changes
- **What**: Microsoft 365 integration has been opened to all Claude users, including free tier, allowing connection to Outlook, OneDrive, and SharePoint directly within Claude. This extends Computer Use's practical utility beyond screen control to structured data access. A fix was shipped for `switch_display` in the computer-use tool returning "not available in this session" on multi-monitor setups. No new Computer Use API changes otherwise. The research preview continues on Mac + Windows.
- **Significance**: The M365 free-tier expansion is a distribution play — getting users comfortable with Claude interacting with their work files before Computer Use exits preview. The multi-monitor fix removes a practical blocker for power users with complex desktop setups.
- **Source**: https://releasebot.io/updates/anthropic

### 2026-04-07 -- Computer Use Stabilized: Mac + Windows Live, No New API Changes
- **What**: No new Computer Use announcements since the Windows expansion (April 3). The feature remains in research preview across both macOS and Windows for Pro/Max subscribers via Cowork/Claude Code. API-level Computer Use (via `computer_20250124` tool) remains stable at the February 2025 version with hold_key, scroll, triple_click, and wait commands. The Dispatch phone-to-desktop delegation feature is live on both platforms. Key operational constraints confirmed: (1) Anthropic cannot remotely disable Computer Use mid-operation — sessions must complete or be manually interrupted. (2) Prompt injection classifier runs automatically but has documented gaps for sophisticated multi-step attacks. (3) ZDR (Zero Data Retention) eligible — screenshots processed in real-time only. (4) Priority architecture unchanged: connectors → browser → screen control. The browser automation benchmark gap persists: ChatGPT agent mode at 87% vs Claude at 56% on isolated browser tasks, though Claude leads on WebArena (full autonomous web navigation).
- **Significance**: Stabilization indicates Anthropic is gathering usage data from the research preview before adding new capabilities. The dual-platform coverage (Mac + Windows) and zero-config consumer setup positions Computer Use as a mainstream feature rather than a developer-only API. The browser automation benchmark gap remains a competitive concern. No indication of when Computer Use will exit research preview to GA.
- **Source**: https://platform.claude.com/docs/en/agents-and-tools/tool-use/computer-use-tool, https://winbuzzer.com/2026/04/04/anthropic-claude-desktop-control-windows-cowork-dispatch-xcxwbn/

### 2026-04-05 -- File-Stealing Prompt Injection Attack Demonstrated Against Cowork
- **What**: Security researchers demonstrated a prompt injection attack against Claude Cowork's Computer Use feature that could steal files from the user's desktop. The attack exploits the screenshot-action loop: a malicious webpage or document displayed on screen can contain instructions that Claude interprets as legitimate user requests, causing it to navigate to sensitive files and exfiltrate their contents. Anthropic acknowledged the vulnerability and confirmed it "cannot remotely disable the technology mid-operation" — once a Computer Use session is running, it must complete or be manually interrupted by the user. The existing prompt injection classifier (documented in April 4 entry) is designed to catch such attacks but is not foolproof.
- **Significance**: Demonstrates that the Computer Use prompt injection classifier has gaps — particularly for sophisticated multi-step attacks embedded in rendered content. The inability to remotely kill sessions is a design constraint that prioritizes user autonomy but creates a security window. Reinforces that Computer Use should be treated as a supervised feature for now, not fully autonomous — aligning with Anthropic's own Dispatch priority architecture (connectors > browser > screen control).
- **Source**: https://www.spokesman.com/stories/2026/apr/01/anthropic-accidentally-exposes-system-behind-claud/, https://winbuzzer.com/2026/04/04/anthropic-claude-desktop-control-windows-cowork-dispatch-xcxwbn/

### 2026-04-04 -- Computer Use Expands to Windows (April 3, 2026)
- **What**: Anthropic expanded Claude's Computer Use to Windows via Claude Cowork and Claude Code, one week after the Mac debut on March 23. The feature is in research preview and requires a Claude Pro or Max subscription. Setup is zero-configuration: "Download the app and it uses what's already on your machine" — no API keys, terminal, or configuration required. The same Dispatch integration from Mac is available, enabling users to send tasks from their phone and retrieve completed work on their PC.
- **Significance**: Windows expansion significantly broadens Computer Use's addressable market. The zero-configuration approach lowers the barrier vs API-based Computer Use which requires Docker/Xvfb setup. Platform support now covers macOS (consumer + API), Windows (consumer + API), and Linux (API/Docker only).
- **Source**: https://www.thurrott.com/a-i/anthropic/334498/anthropic-brings-claude-computer-use-to-windows

### 2026-04-04 -- Dispatch Connector Priority Architecture (newly documented)
- **What**: Detailed architecture of how Claude Computer Use prioritizes task execution confirmed from official blog: (1) Direct integrations first — Claude reaches for connectors to services like Slack, Google Calendar, etc. (2) Browser navigation for web tools without direct integration. (3) Direct screen control (screenshot + mouse/keyboard) as the last resort when no connector or browser path exists. This three-tier hierarchy optimizes for speed and reliability — connectors are fastest/most reliable, screen control is slowest/least reliable. Dispatch enables async task delegation from phone to desktop: user assigns task on mobile, Claude completes it on the desktop app, user reviews finished work later.
- **Significance**: The priority architecture confirms screen control is a fallback, not the primary mode. This explains Anthropic's investment in connectors/integrations alongside Computer Use. The architecture also explains the performance caveat: "complex tasks sometimes need a second try, and working through your screen is slower than using a direct integration."
- **Source**: https://claude.com/blog/dispatch-and-computer-use

### 2026-04-04 -- API Technical Details: ZDR Eligibility and Prompt Injection Classifier
- **What**: Two important technical details confirmed from official docs: (1) Computer Use is Zero Data Retention (ZDR) eligible — Anthropic processes screenshots and action requests in real time but does not retain them after the response is returned. All data storage is client-side. (2) An automatic prompt injection classifier runs on all prompts when computer use tools are active. When the classifier detects potential injections in screenshots, it steers the model to ask for user confirmation before proceeding. Users can opt out by contacting Anthropic support.
- **Significance**: ZDR eligibility is critical for enterprise adoption in regulated industries. The opt-out mechanism for the prompt injection classifier is important for fully autonomous use cases (e.g., unattended desktop automation) where human-in-the-loop is not available.
- **Source**: https://platform.claude.com/docs/en/agents-and-tools/tool-use/computer-use-tool

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

### Platform Support (as of 2026-04-04)
| Platform | Consumer Desktop | API/Docker | Notes |
|----------|-----------------|------------|-------|
| macOS | Supported (March 23, 2026) | Supported | Pro ($20/mo) or Max ($100-200/mo) required |
| Windows | Supported (April 3, 2026) | Supported | Pro or Max required; zero-config setup |
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
