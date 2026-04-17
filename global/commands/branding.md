---
description: Optimi brand guidelines, colors, fonts, and identity
---

# Optimi Brand Guidelines

Use these guidelines when creating any branded content, designs, proposals, or communications.

**Source of truth:** The PDF style guide is canonical. If anything here disagrees with the PDF, the PDF wins — fix this file.

**Web/design asset library (Google Drive):** https://drive.google.com/drive/folders/1ZYw2LQSR_DKBM64LSYr-QXXl-s3p7y6h — use this when sharing assets with external designers, clients, or anyone who doesn't have `~/.claude/assets/optimi/`.

## Company Identity

**Company Name:** Optimi (stylized lowercase: "optimi")
**Legal Name:** Optimi Limited
**Website:** https://www.optimi.co.nz
**Location:** New Zealand

**Primary Contact:**
- Malcolm Colman-Shearer, Director
- malcolm@optimi.co.nz
- +64 21 844 171

---

## Logo

The Optimi logo consists of two elements:
1. **Icon:** A circle made of scattered dots in a gradient flow (teal → blue → green → yellow)
2. **Wordmark:** "optimi" in lowercase dark blue

**Logo Formats:**
- **Portrait:** Icon stacked above wordmark (preferred for square spaces)
- **Landscape:** Icon beside wordmark (preferred for horizontal spaces)

**Clear Space:**
- Portrait: Use height of the "p" as minimum margin
- Landscape: Use height of the "o" as minimum margin

**Minimum Sizes:**
- Portrait: 13mm print / 56px web
- Landscape: 16mm print / 70px web

**Usage Rules:**
- Prefer full-color logo on white/light backgrounds
- Use white (reversed) logo only on dark solid colors that don't conflict with icon colors
- Never place on busy backgrounds

---

## Color Palette

| Color | Name | Hex | RGB | Use |
|-------|------|-----|-----|-----|
| Dark Blue | Primary | #283791 | 40/55/145 | Wordmark, headers, primary text |
| Blue | Accent | #0078FF | 0/120/255 | Links, CTAs, highlights |
| Teal | Accent | #00C896 | 0/200/150 | Success states, growth themes |
| Yellow | Accent | #FFDC00 | 255/220/0 | Attention, energy, optimism |
| Dark Gray | Neutral | #464650 | 70/70/80 | Body text, secondary elements |

**Color Usage Notes:**
- Dark Blue (#283791) is the primary brand color
- Use the accent colors sparingly to add energy
- The gradient flow in the logo goes: teal → blue → green → yellow

---

## Typography

**Primary Font:** Lora (Google Fonts)
- Used for headlines and body copy
- Preferred weights: Medium & Light

**Digital Fallback:** Josefin Sans (Google Fonts)
- Use where Lora isn't available or where a sans-serif reads better (emails, UI)

**Typography Guidelines:**
- Use uppercase sparingly (headlines only when appropriate)
- Prefer sentence case for readability
- Stick to Medium and Light weights — avoid Bold

---

## Voice & Tone

Optimi's communication style:
- Professional but approachable
- Systematic and methodical
- Honest about progress ("working towards" not claiming mastery)
- Specific attribution (name tools, partners, frameworks)
- Outcome-focused (explain WHY something matters)

**Avoid:**
- Corporate jargon
- Hyperbolic claims ("revolutionary", "game-changing")
- Vague generalizations

---

## Logo Assets

All logo files live at `~/.claude/assets/optimi/` (distributed via occb, so every team member has them at the same path).

| File | Description | Use case |
|------|-------------|----------|
| `logo-portrait-color.png` | Full color, icon above wordmark | Documents, title slides, square spaces |
| `logo-landscape-color.png` | Full color, icon beside wordmark | Headers, email, horizontal spaces |
| `logo-landscape-white.png` | White reversed, landscape | Dark backgrounds, dark slides |
| `logo-icon-color.png` | Icon only, full color | Avatars, social, tight spaces |
| `logo-icon-white.png` | Icon only, white | Dark-background avatars |
| `logo-icon-favicon.png` | Icon only, favicon-sized | App icons, favicons |
| `logo-email-signature.png` | Small landscape | Email signatures |

**Quick chooser:**
- Light background → `*-color.png`
- Dark background → `*-white.png`
- Wide space → landscape; square/tight space → portrait or icon

---

## Making a branded asset

### Slide deck
Use the `marp-slides` skill — it renders markdown through the Optimi Marp theme (colors, fonts, logo already wired in). Trigger with "make slides" or "create a deck". No need to hand-apply the palette.

### Google Doc / Google Slides
Set the document defaults once, then write normally:
- Heading font: **Lora Medium**, color **#283791** (Dark Blue)
- Body font: **Lora Light** or **Josefin Sans**, color **#464650** (Dark Gray)
- Link/accent: **#0078FF** (Blue)
- Drop `logo-landscape-color.png` in the header

### Email signature
Use `logo-email-signature.png` with name in Dark Blue (#283791), title/contact in Dark Gray (#464650). See `~/.claude/CLAUDE.md` → Gmail Formatting for HTML rules.

### CSS / web snippet
```css
:root {
  --optimi-dark-blue: #283791;
  --optimi-blue: #0078FF;
  --optimi-teal: #00C896;
  --optimi-yellow: #FFDC00;
  --optimi-dark-gray: #464650;
  --optimi-font-serif: 'Lora', Georgia, serif;
  --optimi-font-sans: 'Josefin Sans', system-ui, sans-serif;
}
```

### One-off graphic (Figma, Canva, Keynote)
Pull the hex values from the palette table above and the logo from `~/.claude/assets/optimi/`. Keep accents sparing — Dark Blue carries most of the weight.
