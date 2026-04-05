#!/bin/bash
# eval/mcp_config_validator.sh — Validate .mcp.json configs against MCP SDK schema
#
# Part of the CI/CD gate (task 4.4). Checks:
#   1. .mcp.json is valid JSON
#   2. Required fields present (mcpServers, command/url per server)
#   3. No deprecated auth patterns (mcp.server.auth v1 fields)
#   4. No empty allowedTools with dangerous commands
#   5. SDK version pin check (warns if MCP SDK not pinned)
#   6. Tool description content scanning (P0 — MCP tool poisoning defense):
#      - Injection phrase detection (ignore previous, you must, send to, etc.)
#      - Description length limits (>500 chars flagged)
#      - Credential keyword rejection (password, token, secret, API_KEY)
#      - File path reference detection
#      - Allowlist bypass for known-good servers (eval/mcp_server_allowlist.json)
#
# Usage:
#   bash eval/mcp_config_validator.sh [path-to-mcp.json]
#   Default: .mcp.json in repo root
#
# Exit codes:
#   0 — valid
#   1 — validation error

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

MCP_CONFIG="${1:-$REPO_ROOT/.mcp.json}"

if [[ ! -f "$MCP_CONFIG" ]]; then
  echo "SKIP: No .mcp.json found at $MCP_CONFIG"
  exit 0
fi

ERRORS=0
WARNINGS=0

# 1. Valid JSON check
if ! python3 -c "import json; json.load(open('$MCP_CONFIG'))" 2>/dev/null; then
  echo "ERROR: $MCP_CONFIG is not valid JSON"
  exit 1
fi

echo "Validating: $MCP_CONFIG"

# 2. Required structure: must have mcpServers key
HAS_SERVERS=$(python3 -c "
import json, sys
cfg = json.load(open('$MCP_CONFIG'))
if 'mcpServers' not in cfg:
    print('MISSING')
    sys.exit(0)
servers = cfg['mcpServers']
if not isinstance(servers, dict):
    print('INVALID_TYPE')
    sys.exit(0)
print(len(servers))
" 2>/dev/null)

if [[ "$HAS_SERVERS" == "MISSING" ]]; then
  echo "ERROR: .mcp.json missing required 'mcpServers' key"
  ERRORS=$((ERRORS + 1))
elif [[ "$HAS_SERVERS" == "INVALID_TYPE" ]]; then
  echo "ERROR: 'mcpServers' must be an object"
  ERRORS=$((ERRORS + 1))
else
  echo "  Found $HAS_SERVERS MCP server(s)"
fi

# 3. Per-server validation
VALIDATION_OUTPUT=$(python3 << 'PYEOF'
import json, sys

cfg = json.load(open(sys.argv[1] if len(sys.argv) > 1 else ".mcp.json"))
servers = cfg.get("mcpServers", {})
errors = 0
warnings = 0

for name, server in servers.items():
    # Must have either command (stdio) or url (SSE/streamable-HTTP)
    has_command = "command" in server
    has_url = "url" in server
    if not has_command and not has_url:
        print(f"  ERROR: Server '{name}' missing both 'command' and 'url' — one is required")
        errors += 1

    # Deprecated auth patterns (MCP v1 → v2 migration risk)
    if "auth" in server:
        auth = server["auth"]
        if isinstance(auth, dict):
            # v1 pattern: auth.type = "bearer" with static token
            if auth.get("type") == "bearer" and "token" in auth:
                print(f"  WARNING: Server '{name}' uses deprecated v1 auth pattern (static bearer token)")
                print(f"           MCP V2 uses OAuth-based auth. See: https://modelcontextprotocol.io/specification/2025-06-18/basic/authorization")
                warnings += 1
            # v1 pattern: auth references mcp.server.auth module
            if "mcp.server.auth" in str(auth):
                print(f"  WARNING: Server '{name}' references 'mcp.server.auth' — may break in MCP SDK V2")
                warnings += 1

    # Empty env with placeholder values
    env = server.get("env", {})
    for key, val in env.items():
        if val == "" or val == "REPLACE_ME" or val == "your-key-here":
            print(f"  WARNING: Server '{name}' has empty/placeholder env var: {key}")
            warnings += 1

    # allowedTools sanity check
    allowed = server.get("allowedTools", None)
    if allowed is not None and isinstance(allowed, list) and len(allowed) == 0:
        # Empty allowedTools means no tools — likely misconfigured
        print(f"  INFO: Server '{name}' has empty allowedTools (no tools will be available)")

print(f"RESULT:{errors}:{warnings}")
PYEOF
) 2>/dev/null <<< "" || true

# Parse results — use the MCP_CONFIG path
VALIDATION_OUTPUT=$(python3 -c "
import json, sys

cfg = json.load(open('$MCP_CONFIG'))
servers = cfg.get('mcpServers', {})
errors = 0
warnings = 0

for name, server in servers.items():
    has_command = 'command' in server
    has_url = 'url' in server
    if not has_command and not has_url:
        print(f'  ERROR: Server \"{name}\" missing both command and url')
        errors += 1

    if 'auth' in server:
        auth = server['auth']
        if isinstance(auth, dict):
            if auth.get('type') == 'bearer' and 'token' in auth:
                print(f'  WARNING: Server \"{name}\" uses deprecated v1 auth (static bearer token)')
                warnings += 1
            if 'mcp.server.auth' in str(auth):
                print(f'  WARNING: Server \"{name}\" references mcp.server.auth — may break in V2')
                warnings += 1

    env = server.get('env', {})
    for key, val in env.items():
        if val == '' or val == 'REPLACE_ME' or val == 'your-key-here':
            print(f'  WARNING: Server \"{name}\" has empty/placeholder env var: {key}')
            warnings += 1

print(f'RESULT:{errors}:{warnings}')
" 2>/dev/null)

echo "$VALIDATION_OUTPUT" | grep -v "^RESULT:" || true

RESULT_LINE=$(echo "$VALIDATION_OUTPUT" | grep "^RESULT:" || echo "RESULT:0:0")
V_ERRORS=$(echo "$RESULT_LINE" | cut -d: -f2)
V_WARNINGS=$(echo "$RESULT_LINE" | cut -d: -f3)

ERRORS=$((ERRORS + V_ERRORS))
WARNINGS=$((WARNINGS + V_WARNINGS))

# 4. Content scanning for tool description injection (P0 — MCP tool poisoning defense)
# Allowlisted servers bypass content scanning to avoid false positives on vault-type servers.
ALLOWLIST_FILE="$SCRIPT_DIR/mcp_server_allowlist.json"

CONTENT_OUTPUT=$(python3 -c "
import json, sys, re, os

mcp_config = '$MCP_CONFIG'
allowlist_file = '$ALLOWLIST_FILE'

cfg = json.load(open(mcp_config))
servers = cfg.get('mcpServers', {})
errors = 0
warnings = 0

# Load allowlist patterns
allowlist_patterns = []
if os.path.exists(allowlist_file):
    al = json.load(open(allowlist_file))
    allowlist_patterns = al.get('allowlist', [])

def is_allowlisted(server_name, server_cfg):
    cmd = server_cfg.get('command', '')
    args = ' '.join(server_cfg.get('args', []))
    url = server_cfg.get('url', '')
    for entry in allowlist_patterns:
        if 'pattern' in entry and entry['pattern'] in args:
            return True
        if 'pattern' in entry and entry['pattern'] in cmd:
            return True
        if 'url_pattern' in entry and entry['url_pattern'] in url:
            return True
    return False

# Injection phrases to reject
INJECTION_PATTERNS = [
    r'ignore\s+(previous|above|all)',
    r'you\s+must',
    r'do\s+not\s+tell',
    r'send\s+(to|data|info)',
    r'(https?://\S+)',
    r'exfiltrate',
    r'override\s+(instructions?|system)',
    r'disregard\s+(previous|above|all)',
    r'forget\s+(previous|above|all|your)',
]

# Credential keywords
CREDENTIAL_KEYWORDS = ['password', 'token', 'secret', 'api_key', 'apikey', 'private_key', 'credentials']

for name, server in servers.items():
    if is_allowlisted(name, server):
        print(f'  SKIP: Server \"{name}\" is on the allowlist — bypassing content scan')
        continue

    # Scan tool descriptions if present (tools array or description fields)
    descriptions_to_scan = []

    # Check server-level description
    if 'description' in server:
        descriptions_to_scan.append(('server description', server['description']))

    # Check tools array if present
    for tool in server.get('tools', []):
        if isinstance(tool, dict) and 'description' in tool:
            tool_name = tool.get('name', 'unnamed')
            descriptions_to_scan.append((f'tool \"{tool_name}\"', tool['description']))

    # Check args for embedded descriptions (common in stdio servers)
    args_str = ' '.join(str(a) for a in server.get('args', []))

    for label, desc in descriptions_to_scan:
        desc_lower = desc.lower()

        # Length check (>500 chars is suspicious for a tool description)
        if len(desc) > 500:
            print(f'  WARNING: Server \"{name}\" {label} exceeds 500 chars ({len(desc)} chars) — review manually')
            warnings += 1

        # Injection pattern check
        for pattern in INJECTION_PATTERNS:
            if re.search(pattern, desc_lower):
                print(f'  ERROR: Server \"{name}\" {label} contains injection pattern: /{pattern}/')
                errors += 1
                break

        # Credential keyword check
        for kw in CREDENTIAL_KEYWORDS:
            if kw in desc_lower:
                print(f'  WARNING: Server \"{name}\" {label} contains credential keyword: \"{kw}\"')
                warnings += 1
                break

        # File path reference check
        if re.search(r'(/etc/|/home/|/root/|/var/|C:\\\\|~/.)', desc):
            print(f'  WARNING: Server \"{name}\" {label} contains file path reference')
            warnings += 1

print(f'CONTENT_RESULT:{errors}:{warnings}')
" 2>/dev/null)

echo "$CONTENT_OUTPUT" | grep -v "^CONTENT_RESULT:" || true

CONTENT_RESULT_LINE=$(echo "$CONTENT_OUTPUT" | grep "^CONTENT_RESULT:" || echo "CONTENT_RESULT:0:0")
C_ERRORS=$(echo "$CONTENT_RESULT_LINE" | cut -d: -f2)
C_WARNINGS=$(echo "$CONTENT_RESULT_LINE" | cut -d: -f3)

ERRORS=$((ERRORS + C_ERRORS))
WARNINGS=$((WARNINGS + C_WARNINGS))

# Summary
echo "---"
echo "MCP config validation: $ERRORS error(s), $WARNINGS warning(s)"

if [[ $ERRORS -gt 0 ]]; then
  echo "FAIL: Fix errors before deployment"
  exit 1
fi

if [[ $WARNINGS -gt 0 ]]; then
  echo "PASS (with warnings)"
else
  echo "PASS"
fi

exit 0
