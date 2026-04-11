# Ready-to-Execute: Command-Chain Length Monitor

**Source proposal**: `proposals/2026-04-04-cmd-chain-monitor.md`
**Priority**: P1
**Type**: Enhancement to `.claude/hooks/post-tool-use.sh`
**Generated**: 2026-04-04 by agentic-ai-researcher (L5: Action)

---

## Prompt for Implementation

Implement a command-chain length monitor in the existing `.claude/hooks/post-tool-use.sh` hook.

### Requirements

1. **Add a function `check_cmd_chain_length()`** that:
   - Accepts a Bash command string as input
   - Counts the number of subcommands by splitting on pipe (`|`), semicolon (`;`), `&&`, and `||` delimiters
   - Ignores delimiters inside quoted strings (single and double quotes)
   - Returns the count

2. **Alert thresholds** (configurable via env vars):
   - `CMD_CHAIN_WARN_THRESHOLD` (default: 30) — log a warning to stderr and to `logs/security/cmd-chain-alerts.log`
   - `CMD_CHAIN_BLOCK_THRESHOLD` (default: 45) — hard block the command, log to alert file, exit with error

3. **Alert log format** (`logs/security/cmd-chain-alerts.log`):
   ```
   [2026-04-04T12:34:56+0800] WARN chain_length=32 cmd_preview="first 200 chars of command..."
   [2026-04-04T12:34:56+0800] BLOCK chain_length=47 cmd_preview="first 200 chars of command..."
   ```

4. **Integration point**: Call `check_cmd_chain_length "$BASH_COMMAND"` early in the post-tool-use hook, before other checks.

5. **Create the log directory** if it doesn't exist: `mkdir -p logs/security`

### Context

- Adversa disclosed that Claude Code deny rules are bypassed when Bash commands exceed 50 subcommands (`MAX_SUBCOMMANDS_FOR_SECURITY_CHECK = 50`)
- Our autonomous agents run in auto-accept mode during Phase 4 closed-loop execution
- The block threshold (45) is deliberately below the bypass threshold (50) as defense-in-depth
- Legitimate pipeline commands rarely exceed 10 subcommands — false positive risk is minimal

### Test Cases

1. Simple command (`ls -la`) — should pass (chain_length=1)
2. Short pipeline (`cat file | grep pattern | wc -l`) — should pass (chain_length=3)
3. 31-subcommand chain — should WARN
4. 46-subcommand chain — should BLOCK
5. Quoted string with pipes (`echo "a|b|c"`) — should count as 1, not 3
6. Mixed delimiters (`cmd1 | cmd2 && cmd3; cmd4`) — should count as 4

### Files to Modify

- `.claude/hooks/post-tool-use.sh` — add the monitor function and call site
- Create `logs/security/` directory (add `.gitkeep`)
