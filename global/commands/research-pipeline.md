---
name: research-pipeline
description: Research on steroids. Takes a topic and sources (YouTube URLs, article URLs, file paths, or a search query), runs them through NotebookLM for structured analysis, synthesises findings, and outputs a structured markdown report. Optionally produces deliverables (infographic, audio, slides, mind map). Source inspiration: https://www.youtube.com/watch?v=kU3qYQ7ACMA
---

## Purpose

This command runs a structured research pipeline: gather sources → build a NotebookLM notebook → query it systematically → synthesise findings → write a research report → (optionally) produce a deliverable.

Invoke in natural language. Parse the following from the input:

- **topic** — what is being researched (required)
- **sources** — one or more YouTube URLs, article URLs, or file paths (optional if a search query is given)
- **search_query** — a keyword string to find sources via yt-dlp (optional if sources are given)
- **analysis_focus** — a specific angle or question to analyse beyond the standard queries (optional)
- **deliverable_type** — one of: `audio`, `infographic`, `slides`, `mind_map`, `video` (optional)

If both sources and a search query are given, combine them.

---

## Step 0: LOCATE OUTPUT

Decide where to write outputs based on the current repo. In order of preference:

1. If `research/` exists at the repo root, use it.
2. If `resources/research/` exists, use it.
3. If `docs/research/` exists, use it.
4. Otherwise, create `research/` at the repo root.

Set `RESEARCH_DIR` to the chosen path. Asset/deliverable subdirectory is `{RESEARCH_DIR}/assets/`.

**Optional context file:** if `.claude/research-context.md` exists in the repo, read it during Step 4 and apply its guidance to the Implications section (e.g. positioning principles, active client work, audience). If it doesn't exist, the Implications section is generic.

---

## Step 1: GATHER

**Two paths depending on input:**

### Path A — URLs or file paths provided

For each HTTP/HTTPS URL, validate it is reachable:

```bash
curl -sI "{url}" | head -1
```

Collect the HTTP status. Flag any that return non-2xx. For file paths, confirm the file exists on disk.

List back all sources in a table:

| # | Title/Filename | URL or Path | Status |
|---|---------------|-------------|--------|

Titles: fetch from `<title>` tag for web URLs where possible; use filename for files.

### Path B — Search query provided

Check whether yt-dlp is installed:

```bash
which yt-dlp
```

If available, run:

```bash
yt-dlp --flat-playlist --print "%(title)s | %(url)s | %(channel)s | %(view_count)s views" "ytsearch5:{search_query}"
```

Present the top 5 results in a table:

| # | Title | Channel | Views | URL |
|---|-------|---------|-------|-----|

If yt-dlp is not installed, say: "yt-dlp is not installed — provide URLs directly or run `brew install yt-dlp`."

---

**After listing sources (both paths), ask exactly this — this is the ONLY interactive pause in the pipeline:**

> "Here are your sources. Want to drop any before I send them to NotebookLM?"

Wait for confirmation, then proceed.

---

## Step 2: NOTEBOOK

Create a NotebookLM notebook using:

```
mcp__notebooklm-mcp__notebook_create
  name: "Research: {topic} — {YYYY-MM-DD}"
```

Add each confirmed source one at a time:

```
mcp__notebooklm-mcp__source_add
  source_type: url        (for HTTP/HTTPS URLs)
  source_type: file       (for local file paths)
  source_type: text       (for raw text content)
  url: {url}              (for URLs)
  file_path: {path}       (for files)
```

After all sources are added, tag the notebook with topic keywords:

```
mcp__notebooklm-mcp__tag
  tags: [derived from topic — 3–5 relevant keywords]
```

Brief status update: "Notebook created with {n} sources. Running analysis..."

---

## Step 3: ANALYSE

Run the following queries against the notebook using `mcp__notebooklm-mcp__notebook_query`. Run each query in sequence, storing all responses for use in Step 4.

**Q1 — Key findings and themes:**

> "What are the key findings and recurring themes across all sources? Focus on specific claims, frameworks, data points, and named concepts rather than general summaries."

**Q2 — Contradictions and tensions:**

> "Where do the sources contradict or disagree with each other? Identify specific points of tension, different recommendations, or conflicting data. If sources broadly agree, say so and note where they diverge on nuance."

**Q3 — Gaps:**

> "What important aspects of this topic are NOT covered by any of these sources? What questions remain unanswered? What would a thorough treatment of this topic need to include that these sources miss?"

**Q4 — Custom focus (only if analysis_focus was specified):**

> Construct a specific question using analysis_focus. Example: if focus is "implications for professional services firms", ask "How do the findings across these sources apply specifically to professional services firms? What is most and least relevant?"

**Timeout fallback:** If `notebook_query` times out, use the async pair instead:

```
mcp__notebooklm-mcp__notebook_query_start  →  store job_id
mcp__notebooklm-mcp__notebook_query_status  →  poll every 20 seconds until complete
```

Do not proceed to Step 4 until all queries have returned responses.

---

## Step 4: SYNTHESISE

If `.claude/research-context.md` exists in the repo, read it now and use it to shape the Implications section.

**Writing style:** Dense analytical prose. Third-person perspective. **Bold key terms and named concepts** on first use. No bullet soup — write in paragraphs. Name frameworks and concepts explicitly. Substantiate claims with specifics from the sources.

**Derive the topic slug:** lowercase, hyphens, no special characters. Example: "AI in legal operations" → `ai-legal-operations`.

**Write the report to:** `{RESEARCH_DIR}/{topic-slug}-{YYYY-MM-DD}.md`

Use this exact structure:

```markdown
# {Topic} — Research Analysis
*Date: {YYYY-MM-DD} | Sources: {count} | Notebook: {notebook_name}*
*Analysis focus: {focus or "general"}*

## Key Findings

{Dense paragraph prose synthesising Q1 response. Bold named frameworks and concepts. Specific, not general.}

## Themes Across Sources

{Prose synthesis of recurring patterns. What do the sources collectively emphasise? What is the dominant logic?}

## Contradictions & Tensions

{Prose synthesis of Q2 response. Where do sources disagree? Be specific about who says what and why it matters.}

## Gaps

{Prose synthesis of Q3 response. What is missing? What questions does this research raise rather than answer?}

## Implications

{The most important section. Specific and actionable, not generic.

If `.claude/research-context.md` was found, apply its guidance: positioning, audience, active work, decision criteria. Filter the findings through that lens.

If no context file exists, write implications oriented to the topic itself: who should care, what decisions does this change, what to do next, what to watch.

Avoid generic "this is relevant" statements — every claim should be defensible and specific.}

## Sources

| # | Title | Channel/Author | URL | Key Contribution |
|---|-------|---------------|-----|-----------------|
{One row per source}

---
*Generated via /research-pipeline | NotebookLM notebook: {notebook_name}*
```

---

## Step 5: DELIVERABLE (optional — only if deliverable_type was specified)

Create the studio artefact:

```
mcp__notebooklm-mcp__studio_create
  artifact_type: {deliverable_type}
  confirm: true
```

After creation, poll for completion every 30 seconds:

```
mcp__notebooklm-mcp__studio_status
```

Once complete, download to:

```
mcp__notebooklm-mcp__download_artifact
  artifact_type: {deliverable_type}
  destination: {RESEARCH_DIR}/assets/{topic-slug}-{YYYY-MM-DD}.{ext}
```

File extension map: `audio` → `.mp3`, `infographic` → `.png`, `slides` → `.pdf`, `mind_map` → `.png`, `video` → `.mp4`.

Add a link to the deliverable at the bottom of the markdown report, below the Sources table and above the generated-by line:

```markdown
**Deliverable:** [{deliverable_type}](assets/{topic-slug}-{YYYY-MM-DD}.{ext})
```

---

## Step 6: INDEX

Confirm `{RESEARCH_DIR}/_index.md` exists. If not, create it with a header row:

```markdown
# Research Index

| Date | Report | Sources | Deliverable |
|------|--------|---------|-------------|
```

Append a row for this research:

```markdown
| {YYYY-MM-DD} | [{topic}]({filename}) | {source count} | {deliverable_type or "—"} |
```

Confirm completion with:

1. The file path of the report
2. A preview of the Key Findings section (first 3–4 sentences)
3. The NotebookLM notebook name
4. Deliverable path (if produced)
