#!/usr/bin/env bash
# Audit installed Python packages for known security vulnerabilities.
# Uses pip-audit (PyPA) which checks against the Python Packaging Advisory Database (PyPI/OSV).
#
# Usage:
#   ./scripts/audit-deps.sh              # audit current environment
#   ./scripts/audit-deps.sh -r req.txt   # audit a requirements file
#   ./scripts/audit-deps.sh --fix        # auto-upgrade vulnerable packages
#
# Exit codes: 0 = no vulnerabilities, 1 = vulnerabilities found, 2 = tool error

set -euo pipefail

# Ensure pip-audit is available
if ! command -v pip-audit &>/dev/null; then
  echo "pip-audit not found — installing..."
  pip install --quiet pip-audit
fi

echo "=== Python Dependency Security Audit ==="
echo "Date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo ""

# Pass all arguments through (e.g. -r requirements.txt, --fix, --json)
pip-audit "$@"
