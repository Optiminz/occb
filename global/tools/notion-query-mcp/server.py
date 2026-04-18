"""
Notion Query MCP Server

Provides filtered database queries against the Notion API using exact property
filters — replacing unreliable semantic search for task and inbox retrieval.
"""

import asyncio
import os
import sys
from typing import Any, Optional

import httpx
from fastmcp import FastMCP

# ---------------------------------------------------------------------------
# Token validation — fail fast with a clear message if missing
# ---------------------------------------------------------------------------
NOTION_API_TOKEN = os.environ.get("NOTION_API_TOKEN", "").strip()
if not NOTION_API_TOKEN:
    print(
        "ERROR: NOTION_API_TOKEN environment variable is not set. "
        "Export it before starting the server.",
        file=sys.stderr,
    )
    sys.exit(1)

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------
NOTION_API_BASE = "https://api.notion.com/v1"
NOTION_VERSION = "2022-06-28"

TASKS_DB_ID = "c2d82f9b-823d-40bd-adb4-3fd708e51912"
INBOX_DB_ID = "8dad53d2-7f29-46db-95ce-2cb1cffa493b"
MALCOLM_USER_ID = "a6c529a1-e620-4567-93a1-e46c1030172e"

# ---------------------------------------------------------------------------
# FastMCP app
# ---------------------------------------------------------------------------
mcp = FastMCP("notion-query")


# ---------------------------------------------------------------------------
# Notion API client
# ---------------------------------------------------------------------------
async def _query_notion_database(
    database_id: str,
    filter_obj: Optional[dict] = None,
    sorts: Optional[list] = None,
    page_size: int = 100,
) -> list[dict]:
    """
    POST to Notion's database query endpoint and return all result pages.

    Handles 429 rate limiting with a single retry after the Retry-After delay.
    Raises RuntimeError for non-200 responses.
    """
    url = f"{NOTION_API_BASE}/databases/{database_id}/query"
    headers = {
        "Authorization": f"Bearer {NOTION_API_TOKEN}",
        "Notion-Version": NOTION_VERSION,
        "Content-Type": "application/json",
    }

    all_results: list[dict] = []
    has_more = True
    start_cursor: Optional[str] = None

    async with httpx.AsyncClient(timeout=30.0) as client:
        while has_more:
            payload: dict[str, Any] = {"page_size": min(page_size, 100)}
            if filter_obj:
                payload["filter"] = filter_obj
            if sorts:
                payload["sorts"] = sorts
            if start_cursor:
                payload["start_cursor"] = start_cursor

            response = await client.post(url, headers=headers, json=payload)

            # Handle rate limiting with a single retry
            if response.status_code == 429:
                retry_after = float(response.headers.get("Retry-After", "1"))
                await asyncio.sleep(retry_after)
                response = await client.post(url, headers=headers, json=payload)

            if response.status_code != 200:
                try:
                    error_data = response.json()
                    msg = error_data.get("message", response.text)
                except Exception:
                    msg = response.text
                raise RuntimeError(
                    f"Notion API error {response.status_code}: {msg}"
                )

            data = response.json()
            all_results.extend(data.get("results", []))

            has_more = data.get("has_more", False)
            start_cursor = data.get("next_cursor")

            # Respect the caller's page_size limit
            if len(all_results) >= page_size:
                break

    return all_results[:page_size]


# ---------------------------------------------------------------------------
# Property flattener
# ---------------------------------------------------------------------------
def _flatten_property(prop: dict) -> Any:
    """
    Convert a Notion property object to a plain Python value.

    Handles all common Notion property types. Unknown types fall back to str().
    """
    prop_type = prop.get("type", "")

    if prop_type == "title":
        parts = prop.get("title", [])
        return "".join(part.get("plain_text", "") for part in parts)

    if prop_type == "rich_text":
        parts = prop.get("rich_text", [])
        return "".join(part.get("plain_text", "") for part in parts)

    if prop_type == "number":
        return prop.get("number")

    if prop_type == "select":
        select = prop.get("select")
        return select.get("name") if select else None

    if prop_type == "multi_select":
        return [option.get("name") for option in prop.get("multi_select", [])]

    if prop_type == "status":
        status = prop.get("status")
        return status.get("name") if status else None

    if prop_type == "date":
        date_value = prop.get("date")
        if date_value is None:
            return None
        start = date_value.get("start")
        end = date_value.get("end")
        # Return plain string for point-in-time dates, dict for ranges
        if end:
            return {"start": start, "end": end}
        return start

    if prop_type == "checkbox":
        return prop.get("checkbox", False)

    if prop_type == "url":
        return prop.get("url")

    if prop_type == "people":
        people = []
        for person in prop.get("people", []):
            # Prefer display name, fall back to email, then id
            name = person.get("name")
            if name:
                people.append(name)
            else:
                email = (person.get("person") or {}).get("email")
                people.append(email or person.get("id", "unknown"))
        return people

    if prop_type == "relation":
        return [rel.get("id") for rel in prop.get("relation", [])]

    if prop_type == "formula":
        formula = prop.get("formula", {})
        formula_type = formula.get("type", "")
        return formula.get(formula_type)

    if prop_type == "rollup":
        rollup = prop.get("rollup", {})
        rollup_type = rollup.get("type", "")
        if rollup_type == "array":
            return [_flatten_property(item) for item in rollup.get("array", [])]
        return rollup.get(rollup_type)

    # Unknown property type — return string representation for debugging
    return str(prop)


# ---------------------------------------------------------------------------
# Page flattener
# ---------------------------------------------------------------------------
def _flatten_page(page: dict) -> dict:
    """
    Convert a raw Notion page object to a flat dict with string keys.

    Returns id, url, and all properties flattened by their display name.
    """
    flattened: dict[str, Any] = {
        "id": page.get("id"),
        "url": page.get("url"),
    }
    for prop_name, prop_value in page.get("properties", {}).items():
        flattened[prop_name] = _flatten_property(prop_value)
    return flattened


# ---------------------------------------------------------------------------
# MCP Tools
# ---------------------------------------------------------------------------

@mcp.tool()
async def get_my_tasks(
    status: str = "Nextup",
    responsible: str = MALCOLM_USER_ID,
) -> list[dict]:
    """
    Fetch tasks from the Optimi Tasks database filtered by status and responsible person.

    Args:
        status: The Status property value to filter by (default: "Nextup").
        responsible: Notion user ID of the responsible person (default: Malcolm).

    Returns:
        List of flattened task objects sorted by Due Date ascending.
    """
    filter_obj = {
        "and": [
            {"property": "Status", "status": {"equals": status}},
            {"property": "Responsible", "people": {"contains": responsible}},
        ]
    }
    sorts = [{"property": "Due Date", "direction": "ascending"}]

    results = await _query_notion_database(TASKS_DB_ID, filter_obj, sorts)
    return [_flatten_page(page) for page in results]


@mcp.tool()
async def get_inbox_items(limit: int = 50) -> list[dict]:
    """
    Fetch items from the Optimi Notion inbox, sorted by Importance descending.

    Args:
        limit: Maximum number of items to return (default: 50).

    Returns:
        List of flattened inbox item objects.
    """
    sorts = [{"property": "Importance", "direction": "descending"}]
    results = await _query_notion_database(INBOX_DB_ID, sorts=sorts, page_size=limit)
    return [_flatten_page(page) for page in results]


@mcp.tool()
async def query_database(
    database_id: str,
    filter: Optional[dict] = None,
    sorts: Optional[list] = None,
    limit: int = 100,
    raw: bool = False,
) -> list[dict]:
    """
    Generic query tool for any Notion database.

    Args:
        database_id: The Notion database ID to query.
        filter: Optional Notion filter object (passed directly to the API).
        sorts: Optional list of sort objects (passed directly to the API).
        limit: Maximum number of results to return (default: 100).
        raw: If True, return raw Notion page objects instead of flattened dicts.

    Returns:
        List of page objects — flattened by default, raw Notion format if raw=True.
    """
    results = await _query_notion_database(
        database_id,
        filter_obj=filter,
        sorts=sorts,
        page_size=limit,
    )
    if raw:
        return results
    return [_flatten_page(page) for page in results]


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------
if __name__ == "__main__":
    mcp.run()
