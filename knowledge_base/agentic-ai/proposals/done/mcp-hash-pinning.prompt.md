# Ready-to-Execute: MCP Hash-Based Tool Pinning

**Source proposal**: `knowledge_base/agentic-ai/proposals/2026-04-06-mcp-scan-hash-pinning.md`
**Priority**: P1
**Target agent**: factory-steward (pipeline improvement)
**Generated**: 2026-04-06

---

## Prompt for factory-steward

Implement MCP tool definition hash-pinning in the CI/CD gate to detect rug pull attacks (OWASP MCP03 variant 3).

### Step 1: Compatibility Spike (15 min max)

Test if `mcp-scan` (`uvx mcp-scan@latest`) works with our `.mcp.json` format:
```bash
# Check if mcp-scan is available and understands our config format
uvx mcp-scan@latest --help 2>/dev/null
```

If `mcp-scan` is compatible with our format, integrate it. If not (or if `uvx` is unavailable), implement native hash computation.

### Step 2: Native Implementation (if mcp-scan incompatible)

Add a `hash_mcp_tools()` function to `eval/mcp_config_validator.sh`:

1. For each MCP server configuration in a Skill's `.mcp.json`:
   - Extract the tool definitions (name, description, inputSchema)
   - Compute SHA-256 hash: `echo -n "$tool_json" | sha256sum | cut -d' ' -f1`
   - Store hashes in `eval/mcp_tool_hashes/<skill-name>.json`
2. On subsequent validations:
   - Compare current hashes against stored baseline
   - If any hash mismatches: exit with error "MCP rug pull detected: tool definition changed for <tool-name>"
   - If no baseline exists: create it (first-time validation)

### Step 3: Create Hash Storage Directory

```bash
mkdir -p eval/mcp_tool_hashes
echo '# MCP Tool Definition Hashes' > eval/mcp_tool_hashes/README.md
echo 'SHA-256 hashes of MCP tool definitions, committed alongside Skills.' >> eval/mcp_tool_hashes/README.md
echo 'Hash mismatch = potential rug pull attack (OWASP MCP03 variant 3).' >> eval/mcp_tool_hashes/README.md
```

### Step 4: Integration

Add the hash verification step to the deployment gate in `.claude/hooks/pre-deploy.sh` — run after static content scanning passes.

### Validation

Test with a mock MCP config to verify:
- First run creates baseline hashes
- Second run with identical config passes
- Third run with modified tool definition fails with rug pull warning
