# Ready-to-Execute: MCP Tool Description Content Validator

**Source proposal**: `proposals/2026-04-05-mcp-content-validator.md`
**Priority**: P0 (critical)
**Type**: Extension of existing `eval/mcp_config_validator.sh`
**Generated**: 2026-04-05 by agentic-ai-researcher (L5: Action)

---

## Prompt for Implementation

Extend the existing `eval/mcp_config_validator.sh` with static content scanning of MCP tool descriptions to detect tool poisoning attacks (Invariant Labs, March 2025).

### Requirements

1. **Create allowlist file** `eval/mcp_server_allowlist.json`:
   ```json
   {
     "description": "Known-good MCP servers that bypass content scanning",
     "servers": [
       "npx -y @modelcontextprotocol/server-filesystem",
       "npx -y @modelcontextprotocol/server-github",
       "npx -y @modelcontextprotocol/server-postgres",
       "npx -y @modelcontextprotocol/server-sqlite",
       "npx -y @modelcontextprotocol/server-puppeteer",
       "npx -y @anthropic/mcp-server-*"
     ],
     "notes": "Allowlist check runs BEFORE content scanning to avoid false positives on vault-type servers"
   }
   ```

2. **Extend `eval/mcp_config_validator.sh`** — add a `validate_tool_descriptions()` function AFTER the existing structural validation:

   a. **Allowlist bypass**: For each server in `.mcp.json`, check if its `command` matches any entry in `eval/mcp_server_allowlist.json`. If matched, skip content scanning for that server. Log: `"[ALLOWLIST] Skipping content scan for: <server>"`

   b. **Injection phrase detection**: Scan all `description` fields (server-level and tool-level if present) for these regex patterns:
      - `ignore (previous|above|prior)` (case-insensitive)
      - `you must|you should|you are required` (case-insensitive)
      - `do not (tell|reveal|disclose|show)` (case-insensitive)
      - `send (to|data|information|results) .*(http|https|ftp|ws)://` (URL exfiltration)
      - `<\|.*\|>` (hidden instruction delimiters)
      - `\bsystem\s*:` (system prompt injection)

   c. **Length limit**: Flag descriptions exceeding 500 characters as WARNING (not blocking — some legitimate tools have long descriptions).

   d. **Credential keywords**: FAIL on descriptions containing: `password`, `token`, `secret`, `API_KEY`, `api_key`, `APIKEY`, `credential`, `private_key` (case-insensitive). These should never appear in tool descriptions.

   e. **Output format** (append to existing validation output):
      ```
      [MCP-CONTENT] PASS|WARN|FAIL: <server_name> — <reason>
      ```

3. **Gate behavior**:
   - Injection phrase detected → FAIL (hard block)
   - Credential keyword detected → FAIL (hard block)
   - Description > 500 chars → WARN (log, don't block)
   - Allowlisted server → SKIP (log, don't scan)
   - No issues → PASS

### Context

- Invariant Labs demonstrated MCP tool poisoning: malicious tool descriptions inject hidden instructions into the LLM context
- Our `mcp_config_validator.sh` (2026-04-04) validates JSON structure and auth patterns but NOT description content
- This is the P0 security gap — a valid `.mcp.json` pointing to a malicious server passes our current gate
- Static scanning only — do NOT fetch from live MCP servers (avoids network failure mode in CI/CD)

### Files to Modify

- `eval/mcp_config_validator.sh` — add `validate_tool_descriptions()` function
- Create `eval/mcp_server_allowlist.json` — known-good server list

### Files NOT to Modify

- `.claude/hooks/pre-deploy.sh` — already calls `mcp_config_validator.sh`; the extension is automatic
- `.claude/agents/` — agent definition updates are separate (see `skill-updates-2026-04-05.md`)

### Test Cases

Add to existing MCP validator test fixtures:
- `eval/fixtures/mcp-poisoned-injection.json` — tool description with "ignore previous instructions" pattern
- `eval/fixtures/mcp-poisoned-exfiltration.json` — tool description with URL exfiltration pattern
- `eval/fixtures/mcp-poisoned-credential.json` — tool description mentioning API_KEY
- `eval/fixtures/mcp-long-description.json` — tool description > 500 chars (should WARN, not FAIL)
- `eval/fixtures/mcp-allowlisted-server.json` — server matching allowlist (should SKIP scanning)
