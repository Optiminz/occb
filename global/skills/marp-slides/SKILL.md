---
name: marp-slides
description: Generate branded Optimi slide decks from markdown using Marp CLI. Trigger on "make slides", "create a deck", "presentation", "marp", "slide deck", "slides".
trigger: make slides, create a deck, presentation, marp, slide deck, slides
---

# Marp Slides — Optimi Branded Deck Generator

Generate professional slide decks using Marp (Markdown Presentation Ecosystem) with the custom Optimi theme.

## Setup

Ensure marp-cli is installed:

```bash
npm list -g @marp-team/marp-cli || npm install -g @marp-team/marp-cli
```

Theme file: `~/.claude/skills/marp-slides/theme/optimi.css`

## Workflow

### 1. Gather Requirements

Ask the user (if not already clear):
- **Topic/title** of the presentation
- **Audience** — client pitch, internal team, workshop, conference?
- **Length** — short (5-8 slides), standard (10-15), long (20+)?
- **Key messages** — what must the audience walk away knowing?
- **Format** — PDF (default), HTML, or PPTX?

### 2. Generate the Markdown File

Create a `.md` file in the user's working directory (or a location they specify). Use this frontmatter:

```yaml
---
marp: true
theme: optimi
paginate: true
---
```

### 3. Apply Slide Classes

Use directives to assign slide types:

```markdown
<!-- _class: title -->        # Navy background, centred, logo bottom-right
<!-- _class: section-break --> # Bright blue background, centred
<!-- _class: default -->       # White background (no directive needed)
<!-- _class: two-column -->    # CSS grid two-column layout
<!-- _class: image-right -->   # Content left, image right (60/40)
<!-- _class: dark -->          # Charcoal background, white text
```

### 4. Content Conventions

- **Max 6 bullet points per slide** — if more, split into two slides
- **One key idea per slide** — the heading should capture it
- **Speaker notes** in HTML comments: `<!-- Speaker notes: ... -->`
- **Title slide first** — always open with `<!-- _class: title -->`
- **Section breaks** between major sections
- **Final slide** — "Questions?" with contact info, or a clear CTA
- **Tables** for comparison/summary data — the theme styles them nicely
- **Blockquotes** for client quotes or callout boxes
- **`<div class="metric">72%</div>`** for large metric callouts (green text)

### 5. Two-Column Content

Marp doesn't have native columns. The `two-column` class uses CSS grid with the heading spanning both columns. Structure content so the first half appears in the left column and the second half in the right. Use a comment to indicate the split:

```markdown
<!-- _class: two-column -->

# Heading Spans Both Columns

- Left column point 1
- Left column point 2
- Left column point 3

<!-- column break -->

- Right column point 1
- Right column point 2
- Right column point 3
```

### 6. Export

**PDF (default — recommended):**
```bash
marp deck.md --theme ~/.claude/skills/marp-slides/theme/optimi.css -o deck.pdf --allow-local-files
```

**HTML (interactive, good for sharing online):**
```bash
marp deck.md --theme ~/.claude/skills/marp-slides/theme/optimi.css -o deck.html --allow-local-files
```

**PPTX (PowerPoint — image-based, NOT editable text):**
```bash
marp deck.md --theme ~/.claude/skills/marp-slides/theme/optimi.css -o deck.pptx --allow-local-files
```

> **PPTX limitation:** Marp exports slides as images embedded in PowerPoint. Text is not editable. Use PDF as the default format. If the user needs editable slides, suggest writing content in Marp for speed, then manually rebuilding key slides in Google Slides/PowerPoint.

### 7. Verify Output

After export, confirm with the user:
- Open the PDF/HTML to check rendering
- Verify logo placement and page numbers
- Check that slide classes render as expected
- Confirm fonts loaded (requires internet for Google Fonts on first render)

## Theme Reference

| Element | Colour | Usage |
|---------|--------|-------|
| Navy `#283791` | Headers, title backgrounds | Primary brand |
| Bright Blue `#0078FF` | Links, accents, section breaks | Secondary |
| Green `#00C896` | Metrics, success indicators | Highlights |
| Yellow `#FFDC00` | `<mark>` highlights | Sparingly |
| Charcoal `#464650` | Body text, dark slides | Neutral |
| Light Gray `#F5F5F5` | Blockquote backgrounds, tags | Subtle |

## Example

See `~/.claude/skills/marp-slides/examples/sample-deck.md` for a complete example using all slide classes.
