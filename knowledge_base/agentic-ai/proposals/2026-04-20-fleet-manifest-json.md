# Skill Proposal: Fleet Manifest JSON
**Date**: 2026-04-20
**Triggered by**: Cross-pollination — production ADK+A2A+Cloud Run article uses Agent Cards for service discovery; our fleet catalog is a manual CLAUDE.md table
**Priority**: P2 (medium) — S2/S3 strategic priority alignment (stepping stone to A2A Agent Cards)
**Target Phase**: Phase 4.3 (Observability) / Phase 5 prep
**Discussion ID**: A5

## Rationale

Our agent fleet is cataloged as a manual Markdown table in CLAUDE.md — 5 core agents, 2 research agents, 3 paper agents, plus stewards. Every agent addition, suspension, or model change requires a manual CLAUDE.md edit. The production ADK+A2A article demonstrates that real-world multi-agent systems use machine-readable agent catalogs (Agent Cards) for service discovery and health monitoring.

A full A2A Agent Card per agent is premature — we'd fill dummy values for authentication, endpoint URLs, and supported protocols that don't apply to local CLI invocations. Instead, a single `fleet_manifest.json` captures the 80% we actually need: name, model, status, permission class, tools granted.

## Proposed Specification

- **Name**: `fleet_manifest.json` (root directory)
- **Type**: JSON data file + generator script
- **Description**: Machine-readable fleet catalog derived from agent definition files
- **Key Capabilities**:
  - Auto-generated from `.claude/agents/*.md` frontmatter parsing
  - Fields per agent: name, description (first line), model, status (active/suspended), permission_class, tools (array), file_path
  - Generator script: `scripts/fleet_registry.sh` — reads all agent .md files, extracts YAML frontmatter, outputs JSON
  - Optional: CLAUDE.md table auto-generation from manifest
- **Tools Required**: bash, yq or Python yaml parser

## Implementation Notes

- **Generator approach**: Parse YAML frontmatter from each `.claude/agents/*.md` file. The frontmatter already contains name, description, tools, model. Permission class and status need to be derived (permission class from tools list; status from CLAUDE.md or a new `status` frontmatter field).
- **A2A upgrade path**: When Phase 5 adopts A2A, manifest entries extend to full Agent Cards (add authentication, endpoint, supported protocols). The manifest IS the Agent Card minus the transport layer.
- **Dashboard integration**: `health_dashboard.py` and `anomaly_alerter.py` can read the manifest instead of hardcoded agent lists.
- **Single source of truth**: Agents self-describe via frontmatter; manifest is derived; CLAUDE.md table is generated. No more manual table edits.

## Estimated Impact

- **S2**: Machine-readable fleet state enables automated health checks, anomaly detection based on declared vs. actual behavior
- **S3**: Stepping stone toward A2A-compatible Agent Cards for cross-platform identity
- **Operational**: Eliminates manual CLAUDE.md agent table maintenance; prevents drift between agent definitions and documentation
