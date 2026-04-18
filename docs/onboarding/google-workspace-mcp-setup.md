# Google Workspace MCP Setup

Connect Claude Code to Google Workspace (Gmail, Drive, Docs, Sheets, Calendar, Slides, Forms) via MCP Launchpad (mcpl).

**What this gives you:** Claude can search/read your Gmail, browse Drive files, read Docs and Sheets, check Calendar — all from any repo, using your personal Google account.

---

## Prerequisites

- Claude Code installed and working
- mcpl installed (`npm install -g @anthropic-ai/mcpl` or check current install method)
- A Google Cloud project (Optimi's project ID: `964999822586` — team members can be added to this)

---

## Setup Steps

### 1. Google Cloud Project Access

**If using Optimi's shared project** (preferred for team):
- Ask Malcolm to add your Google account as a test user in the [OAuth consent screen](https://console.cloud.google.com/apis/credentials/consent?project=964999822586)
- This lets you authenticate with the shared OAuth client without needing your own project

**If creating your own project:**
- Go to [Google Cloud Console](https://console.cloud.google.com/)
- Create a new project
- Enable these APIs (APIs & Services > Library):
  - Gmail API
  - Google Drive API
  - Google Docs API
  - Google Sheets API
  - Google Calendar API
  - Google Slides API (optional)
  - Google Forms API (optional)
- Set up OAuth consent screen (External, Testing mode)
- Create OAuth credentials (Desktop app type)

### 2. Enable Required APIs

Even on a shared project, each API must be individually enabled. Go to each link and click "Enable":

- [Gmail API](https://console.developers.google.com/apis/api/gmail.googleapis.com/overview?project=964999822586)
- [Drive API](https://console.developers.google.com/apis/api/drive.googleapis.com/overview?project=964999822586)
- [Docs API](https://console.developers.google.com/apis/api/docs.googleapis.com/overview?project=964999822586)
- [Sheets API](https://console.developers.google.com/apis/api/sheets.googleapis.com/overview?project=964999822586)
- [Calendar API](https://console.developers.google.com/apis/api/calendar.googleapis.com/overview?project=964999822586)

### 3. Install Google Workspace MCP Server

```bash
# Install the MCP server
npm install -g @anthropic-ai/google-workspace-mcp
```

> **Note:** Check the actual package name — it may be a community server like `@anthropic-ai/google-workspace-mcp` or `google-workspace-mcp`. See the [repo](https://github.com/zueai/google-workspace-mcp) for current install instructions.

### 4. Configure mcpl

Add the Google Workspace server to your mcpl config at `~/.claude/mcpl.json`. The exact configuration depends on the MCP server — check the server's README for the correct entry.

### 5. Register Your Google Account

```bash
# The MCP server will prompt you to authenticate via browser
# This creates OAuth tokens at ~/.google-mcp/tokens/
# Your account name (e.g., your first name) is used in all API calls.
# In the examples below, replace "<your-account>" with the label you picked above.
```

### 6. Verify It Works

```bash
# List available tools
mcpl list google-workspace

# Test Gmail
mcpl call google-workspace searchGmail '{"account": "yourname", "query": "is:unread"}'

# Test Drive
mcpl call google-workspace listRecentFiles '{"account": "yourname"}'
```

---

## Usage Examples

### Gmail

```bash
# Search emails
mcpl call google-workspace searchGmail '{"account": "<your-account>", "query": "from:client@example.com"}'

# List recent messages
mcpl call google-workspace listGmailMessages '{"account": "<your-account>"}'

# Create a draft
mcpl call google-workspace createGmailDraft '{"account": "<your-account>", "to": "someone@example.com", "subject": "Subject", "body": "<strong>HTML body</strong>"}'
```

### Google Drive

```bash
# Search files
mcpl call google-workspace searchDrive '{"account": "<your-account>", "query": "budget 2026"}'

# List recent files
mcpl call google-workspace listRecentFiles '{"account": "<your-account>"}'

# Download a file
mcpl call google-workspace downloadFromDrive '{"account": "<your-account>", "fileId": "...", "localPath": "/tmp/file.pdf"}'
```

### Google Docs & Sheets

```bash
# Read a doc
mcpl call google-workspace readGoogleDoc '{"account": "<your-account>", "documentId": "..."}'

# Read a spreadsheet
mcpl call google-workspace readSpreadsheet '{"account": "<your-account>", "spreadsheetId": "...", "range": "Sheet1!A1:Z100"}'
```

### Google Calendar

```bash
# List events
mcpl call google-workspace listCalendarEvents '{"account": "<your-account>"}'

# Create event
mcpl call google-workspace createCalendarEvent '{"account": "<your-account>", "summary": "Meeting", "startDateTime": "2026-03-20T10:00:00", "endDateTime": "2026-03-20T11:00:00"}'
```

---

## Security & Access Model

- **OAuth tokens are personal** — each person authenticates with their own Google account and can only access their own data
- **The Google Cloud project is shared** — it's just the "app" that requests API access, not a data store
- **Tokens stored locally** at `~/.google-mcp/tokens/` — never committed to git
- **Team members cannot see each other's emails, files, or calendar** — OAuth scopes are per-user

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| "Gmail API has not been used in project" | Enable the Gmail API in Google Cloud Console (see links above) |
| "Insufficient Permission" | Re-authenticate: delete tokens in `~/.google-mcp/tokens/` and re-run |
| "Access Not Configured" | Enable the specific API in Google Cloud Console |
| Tools not found | Run `mcpl list google-workspace` to check server is connected |
| Daemon issues | `mcpl session stop` then retry |
