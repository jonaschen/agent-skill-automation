# Hook Integration Notes

## Command-Chain Monitor → post-tool-use.sh

The `scripts/cmd_chain_monitor.sh` script needs to be integrated into `.claude/hooks/post-tool-use.sh`.

**Manual step required**: `.claude/hooks/` is protected by Claude Code and cannot be auto-modified.

Add these lines to `post-tool-use.sh` after the variable declarations and before the `Write/Edit` check:

```bash
# --- Command-chain length monitor (Bash tool) ---
if [[ "$TOOL_NAME" == "Bash" ]]; then
  CMD_INPUT="${CLAUDE_BASH_COMMAND:-}" \
    bash "$REPO_ROOT/scripts/cmd_chain_monitor.sh" || exit 1
fi
```

This delegates to the standalone monitor script which:
- Warns at >30 subcommands
- Hard blocks at >45 subcommands
- Logs to `logs/security/cmd-chain-alerts.log`
