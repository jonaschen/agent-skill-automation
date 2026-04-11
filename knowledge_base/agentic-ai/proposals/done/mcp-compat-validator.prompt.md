# Ready-to-Execute: MCP Config Compatibility Validator

**Source proposal**: `proposals/2026-04-04-mcp-compat-check.md`
**Priority**: P1
**Type**: Enhancement to `agentic-cicd-gate` validation pipeline
**Generated**: 2026-04-04 by agentic-ai-researcher (L5: Action)

---

## Prompt for Implementation

Add an MCP config validation step to the `agentic-cicd-gate` agent's deployment pipeline.

### Requirements

1. **Add a validation step** (after SKILL.md format check, before Bayesian scoring) that:
   - Scans the Skill directory for `.mcp.json` files
   - If no `.mcp.json` exists, skip (most Skills don't use MCP)
   - If `.mcp.json` exists, validate:
     a. JSON is well-formed
     b. Required fields are present (`mcpServers` with at least one entry)
     c. Each server entry has `command` or `url` (transport type)
     d. Auth patterns are compatible with installed MCP SDK version

2. **MCP SDK version detection**:
   - Check `pip show mcp 2>/dev/null | grep Version` for Python SDK
   - Check `npm list @modelcontextprotocol/sdk 2>/dev/null` for JS SDK
   - Store detected version for comparison

3. **Auth pattern validation**:
   - V1 pattern: `mcp.server.auth` with `OAuthServerProvider` interface
   - V2 pattern (when detected): validate against V2 auth schema (TBD — add stub)
   - Flag deprecated auth patterns with a warning (not a hard block until V2 is GA)

4. **Output format** (append to existing CI/CD gate report):
   ```json
   {
     "mcp_validation": {
       "status": "pass|warn|fail",
       "mcp_sdk_version": "1.26.0",
       "configs_checked": 1,
       "issues": [
         {"file": ".mcp.json", "severity": "warn", "message": "Auth pattern may be deprecated in MCP V2"}
       ]
     }
   }
   ```

5. **Gate behavior**:
   - `pass` — no issues found
   - `warn` — deprecated patterns detected, log but don't block deployment
   - `fail` — malformed config or missing required fields, block deployment

### Context

- MCP Python SDK has been frozen at v1.26.0 for 63+ days — V2 rewrite is underway
- Our `meta-agent-factory` generates `.mcp.json` configs as part of Skill creation
- Currently no validation exists for MCP configs in the deployment pipeline
- This closes the last uncovered config validation gap

### Files to Modify

- `.claude/agents/agentic-cicd-gate.md` — document the new validation step
- `.claude/hooks/pre-deploy.sh` — add MCP config check function
- Create `eval/mcp_config_schema.json` — validation schema for .mcp.json files

### Test Fixtures to Create

- `eval/fixtures/mcp-valid-v1.json` — known-good V1 MCP config
- `eval/fixtures/mcp-invalid-malformed.json` — malformed JSON
- `eval/fixtures/mcp-missing-fields.json` — valid JSON, missing required fields
- `eval/fixtures/mcp-deprecated-auth.json` — V1 auth pattern (for future V2 warning)
