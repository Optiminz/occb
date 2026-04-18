# Notion Query MCP Server

A lightweight MCP server for querying Notion databases with exact property filters. Replaces semantic search (`notion-search`) for filtered task lists — more reliable and predictable for structured queries like "show me my Nextup tasks".

---

## Setup

### 1. Install dependencies (venv required on macOS)

macOS system Python is externally managed (PEP 668), so install in an isolated venv:

```bash
cd ~/Projects/occb/global/tools/notion-query-mcp
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

The `.venv/` directory is gitignored.

### 2. Get a Notion integration token

1. Go to https://www.notion.so/my-integrations
2. Create a new internal integration
3. Copy the token (starts with `ntn_...`)
4. For each database you want to query: open it in Notion → Share → Connections → add your integration

### 3. Register in Claude Code

Add to your `~/Projects/occb-personal/claude/mcp.json.template` (committed with `op://` ref, then render via `op inject -i mcp.json.template -o mcp.json -f`):

```json
{
  "mcpServers": {
    "notion-query": {
      "command": "/Users/you/Projects/occb/global/tools/notion-query-mcp/.venv/bin/python",
      "args": ["/Users/you/Projects/occb/global/tools/notion-query-mcp/server.py"],
      "env": {
        "NOTION_API_TOKEN": "op://Vault/Notion API/credential"
      }
    }
  }
}
```

### 4. Restart Claude Code

---

## Tools

### `get_my_tasks`

Fetches tasks from the Tasks database with optional status and responsible filters.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `status` | string | `"Nextup"` | Task status to filter by (e.g. Nextup, In Progress, Done, Backlog) |
| `responsible` | string | Malcolm's user ID | Notion user ID to filter by responsible person |

---

### `get_inbox_items`

Fetches unprocessed items from the Inbox database.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `limit` | integer | `50` | Maximum number of items to return |

---

### `query_database`

Generic query tool for any Notion database. Use this for databases not covered by the specialised tools above.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `database_id` | string | required | Notion database UUID (see Database IDs below) |
| `filter` | object | none | Notion filter object (see Notion API docs) |
| `sorts` | array | none | Notion sorts array |
| `limit` | integer | `100` | Maximum number of results to return |
| `raw` | boolean | `false` | Return raw Notion API response instead of simplified output |

---

## Database IDs

These are the actual Notion API database UUIDs — use these with `query_database`.

| Database | ID |
|----------|----|
| Tasks | `c2d82f9b-823d-40bd-adb4-3fd708e51912` |
| Inbox | `8dad53d2-7f29-46db-95ce-2cb1cffa493b` |
| Projects | `06434890-bbc0-418c-b11d-4fa72076c7be` |
| Areas | `3dda230a-e759-4868-a5c7-ba489ebb47b0` |
| Resources | `d3ed0cea-8508-4b43-a3b0-99965d2aa735` |
| Meetings | `600d9ef9-59a0-48f9-9ff1-9f2c1be9ea43` |

> **Important:** These IDs are the actual Notion API database UUIDs. They differ from the "data source IDs" in `~/.claude/notion-map.md`, which are internal to the Notion MCP plugin and not interchangeable.
