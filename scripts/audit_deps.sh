#!/usr/bin/env bash
# Audit Python dependencies for known security vulnerabilities.
# Uses pip-audit (https://github.com/pypa/pip-audit) against the OSV database.
#
# Usage:
#   ./scripts/audit_deps.sh              # audit requirements.txt
#   ./scripts/audit_deps.sh --fix        # audit + auto-upgrade vulnerable packages
#   AUDIT_FORMAT=json ./scripts/audit_deps.sh  # machine-readable output

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REQ_FILE="${REPO_ROOT}/requirements.txt"
FORMAT="${AUDIT_FORMAT:-columns}"

# System/distro packages that aren't on PyPI — skip them.
SKIP_PACKAGES=(
    bcc
    cloud-init
    command-not-found
    cupshelpers
    dbus-python
    distro-info
    gyp
    kazam
    language-selector
    louis
    pycups
    python-apt
    python-debian
    systemd-python
    ubuntu-drivers-common
    ubuntu-pro-client
    ufw
    unattended-upgrades
    usb-creator
    xkit
    xyzservices
)

if ! command -v pip-audit &>/dev/null; then
    echo "pip-audit not found. Installing via pipx..."
    pipx install pip-audit
fi

# Build a filtered requirements file excluding system packages.
FILTERED_REQ=$(mktemp)
trap 'rm -f "$FILTERED_REQ"' EXIT

while IFS= read -r line; do
    pkg_name="${line%%==*}"
    skip=false
    for sp in "${SKIP_PACKAGES[@]}"; do
        if [[ "${pkg_name,,}" == "${sp,,}" ]]; then
            skip=true
            break
        fi
    done
    if ! $skip && [[ -n "$line" ]]; then
        echo "$line" >> "$FILTERED_REQ"
    fi
done < "$REQ_FILE"

echo "=== Python Dependency Security Audit ==="
echo "Requirements: ${REQ_FILE}"
echo "Skipped: ${#SKIP_PACKAGES[@]} system packages"
echo "Date: $(date -Iseconds)"
echo ""

ARGS=(
    --requirement "$FILTERED_REQ"
    --format "$FORMAT"
    --desc
    --progress-spinner off
)

if [[ "${1:-}" == "--fix" ]]; then
    ARGS+=(--fix)
    echo "Mode: audit + auto-fix"
else
    echo "Mode: audit only (pass --fix to auto-upgrade)"
fi

echo ""

pip-audit "${ARGS[@]}"
exit_code=$?

if [[ $exit_code -eq 0 ]]; then
    echo ""
    echo "No known vulnerabilities found."
else
    echo ""
    echo "Vulnerabilities detected — review output above."
fi

exit $exit_code
