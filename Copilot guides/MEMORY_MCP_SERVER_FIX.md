# Memory MCP Server Configuration Fix

## Problem with PR #47

PR #47 attempted to configure Memory MCP server using `chat.mcp.serverSampling` in `.vscode/settings.json`. This approach **does not work** because:

1. VS Code's `chat.mcp.serverSampling` is not the correct configuration entry point
2. Variable expansion (`${workspaceFolder}`) doesn't work in that context
3. The file format should be JSONL, not JSON
4. Global MCP configuration was taking precedence, preventing workspace-level override

## Solution: Use Workspace-Level `.vscode/mcp.json`

The correct implementation uses VS Code's proper MCP configuration system via `.vscode/mcp.json`.

### Changes Required

#### 1. Create `.vscode/mcp.json`

```json
{
    "servers": {
        "memory": {
            "command": "npx",
            "args": [
                "-y",
                "@modelcontextprotocol/server-memory"
            ],
            "type": "stdio",
            "env": {
                "MEMORY_FILE_PATH": "${workspaceFolder}/knowledge-graph.jsonl"
            }
        }
    }
}
```

**Key points:**

- Use `"servers"` key (not `"mcpServers"`)
- Include `"type": "stdio"` for MCP server protocol
- File extension: `.jsonl` (JSONL format, not JSON)
- Use `${workspaceFolder}` for variable expansion (works at workspace level)

#### 2. Update `.gitignore`

Change the comment about the knowledge graph file:

```diff
- # Note: knowledge-graph.json is intentionally NOT ignored
- # It will be tracked in Git for backup and sync purposes

+ # Note: knowledge-graph.jsonl is intentionally NOT ignored
+ # It will be tracked in Git for backup and sync purposes (Memory MCP server knowledge graph)
```

#### 3. Remove or Clear `.vscode/settings.json` (if it contains `chat.mcp.serverSampling`)

If PR #47 was already applied, `.vscode/settings.json` contains the broken configuration. Either:

- Delete the file, or
- Replace with `{}` to clear the broken config

#### 4. Ensure Global MCP Config Doesn't Include Memory Server

Check `~/.vscode/User/profiles/[profile-name]/mcp.json` (or your global MCP config) and **remove the Memory server entry** if it exists. Keep other servers (context7, github, sequentialthinking, etc.).

This allows workspace-level `.vscode/mcp.json` to take effect.

## Why This Works

1. **Workspace-level MCP config**: `.vscode/mcp.json` is the proper way to configure MCP servers per workspace
2. **Proper variable expansion**: `${workspaceFolder}` is available in workspace config context
3. **No conflicts**: Removing Memory from global config prevents override
4. **Isolation**: Each workspace gets its own `knowledge-graph.jsonl`

## After Implementation

1. Restart VS Code
2. Use the Memory MCP tools (create entities, read graph, etc.)
3. Close VS Code to persist the knowledge graph to `knowledge-graph.jsonl`
4. Commit the file to Git: `git add knowledge-graph.jsonl && git commit -m "feat: Initialize Memory MCP knowledge graph"`
5. Knowledge graph syncs across machines via git

## For Copilot Agents

When instructing Copilot to apply this to other repositories:

1. Create `.vscode/mcp.json` with the configuration above
2. Update `.gitignore` comment from `knowledge-graph.json` to `knowledge-graph.jsonl`
3. Remove or clear `.vscode/settings.json` if it contains `chat.mcp.serverSampling`
4. (If repo maintainer has global MCP config): Remove Memory server from global config
5. Files to ignore: No need to commit initial `knowledge-graph.jsonl` - it will be created on first use

## Common Errors and Solutions

| Error | Cause | Solution |
| ------- | ------- | ---------- |
| `Variable workspaceFolder can not be resolved` | Using workspace variable in global config | Move config to `.vscode/mcp.json` (workspace-level) |
| Memory tools not available | Wrong config key or file location | Check `.vscode/mcp.json` exists and uses "servers" key |
| Knowledge graph not persisting to file | Server running in memory only | Ensure `MEMORY_FILE_PATH` env var is set correctly |
| All workspaces share same graph | Using absolute path in global config | Switch to workspace-level `.vscode/mcp.json` with `${workspaceFolder}` |

## Summary

**What changed since PR #47:**

- Configuration approach: `chat.mcp.serverSampling` → proper `.vscode/mcp.json`
- File format: `knowledge-graph.json` → `knowledge-graph.jsonl`
- Config location: workspace `settings.json` → dedicated workspace `mcp.json`
- Global config: Removed Memory server to avoid conflicts
- Structure: Added `"type": "stdio"` for MCP protocol compliance
