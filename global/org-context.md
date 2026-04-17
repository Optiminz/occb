# Optimi — Organizational Specification

> Source of truth: Notion page `31778416-66cb-810c-9865-c0bb9028f65c`
> URL: https://www.notion.so/3177841666cb810c9865c0bb9028f65c
> Last refreshed: 2026-04-16

---

## Positioning

Optimi is an AI implementation advisory practice that helps professional services firms get their operations AI-ready. We are not a tool reseller, custom dev shop, or big SaaS vendor. We build diagnostic frameworks, operational capability, and AI-ready foundations — then hand ownership to the client.

**Core differentiator:** We combine strategic advisory (Fractional CIO) with hands-on implementation. Clients get both the "what to do" and the "getting it done." We diagnose before we prescribe — fixing the four foundational legs (Clean Data, Documented Processes, Decision Governance, Team Capacity) before adding AI weight.

**Brand voice:** Measured and confident (3-6/10 intensity), never hyperbolic. Evidence-based, framework-focused, specifically attributed. Worthwhile content, seamless journey, quality that's relatable and moving.

**Expert positioning:** Baker/Enns and David C. Baker methodology. The practitioner evaluates fit — the vendor chases deals. No availability signalling, no free work, no competing on price. Full positioning principles: `oai/areas/frameworks/optimi-positioning-principles.md`.

---

## Strategic Direction

**Moving toward:**
- AI-focused advisory and capability building for professional services firms
- Serving small & mighty teams (5-50 people) with flat hierarchies and resource constraints
- Productised service offerings (repeatable, scalable) — diagnostic-first model
- AI-assisted workflows for every business function (writing, sales, development, operations)
- Three-Room Strategy: Lobby (free assessment, creates urgency) -> Room One (paid diagnostic) -> Room Two (paid implementation)

**Moving away from:**
- Legacy Knack platform dependency (existing clients maintained, no new Knack work)
- Custom one-off development projects
- Vendor-specific tool implementation
- Tactical engagements that don't have a higher-level strategic element
- Nonprofit-first positioning (professional services is the primary ICP now)

**Key bet:** Diagnostic-first AI readiness — using the Four Legs framework and Inside-Out Principle (Culture -> Process -> System) to meet teams where they are. Personal AI before Connected AI. Most AI consultancies sell Connected AI to teams that aren't ready for it.

---

## Core Frameworks

**Inside-Out Principle (CPS Stack):** Culture -> Process -> System. When improving operations, always prioritise in this order. Enterprise consulting starts with systems and works backward. Optimi starts with culture and lets technology adapt to people.

**Four Legs of AI Readiness:** The diagnostic framework. AI is a tabletop — it only works when supported by four foundational legs: Clean Accessible Data, Documented Processes, Decision Governance, Team Capacity & Capability. The tabletop specifically represents Connected AI. Personal AI doesn't require all four legs.

**Personal AI vs Connected AI:** The spectrum clients move along. Personal AI (individual productivity) is the entry point and a tool for building the four legs. Connected AI (cross-system workflows, autonomous agents) is the destination — and requires all four legs to be stable.

**4 A's:** Analyse, Architect, Automate, Amplify. The engagement delivery method.

**Agent Readiness Diagnostic:** Five-question framework evaluating whether specific processes are safe for autonomous agents. Verdicts: agent-ready / agent-augmented / human-only.

**Three-Room Strategy (adapted from David C. Baker):** Lobby (free, demonstrates diagnostic quality, creates urgency without resolving it) -> Room One (paid diagnostic — the Digital Operations Audit) -> Room Two (paid implementation).

Full framework documentation: `oai/projects/optimi-methods/core-frameworks.md`

---

## Current Priorities

1. **Client delivery excellence** — Advisory clients (MLC, A Rocha) are the revenue foundation
2. **oi-app launch** — Unblock Phase 1 (content for dead-end resource cards), then Phase 2 calibration post-launch. Free assessment = Lobby in Three-Room Strategy
3. **AI workflow maturation** — Strengthening the writing, sales, and dev orchestration systems. Cross-pollinating patterns between them
4. **Content and thought leadership** — LinkedIn presence, newsletter, establishing positioning in AI-for-operations space. Three content pillars with buyer-pain translations

**Deprioritised:**
- New Knack development (maintenance only for existing clients)
- Speculative product builds without client validation

---

## Key Decisions

- **Win Without Pitching methodology** adopted for all sales engagements — expert positioning, no free work, 3-option proposals
- **Constitution-driven development** — every code repo has a CONSTITUTION.md as the non-negotiable source of truth for standards
- **Persona-driven AI workflows** — writing (9 personas), sales (7 personas), dev (orchestrator framework). Quality gates mandatory
- **Supabase + Next.js** as primary stack for new web applications (OKM, oi-app)
- **Claude Code as primary AI dev environment** — skills, agents, learnings system all built on this
- **Don't automate before validating** — don't build infrastructure for workflows without product-market fit
- **Isolated workflows perform better** — validated pattern across repos; validate before extracting

---

## Active Clients

**Advisory (Fractional CIO):**
- **MLC** — Karl Mill (CA). Dev partnership + advisory. $1,500 USD/mo. Post-audit, implementation phase, 60+ Zapier automations built. Karl is the source for Optimi's "Karl" ICP avatar. Pete handles technical implementation.
- **A Rocha Canada** — Romina (Operations Director). CRM transformation complete. Light-touch advisory (~1hr/month catchup).

**Legacy Knack Maintenance:**
- FBI Talent (AU), TGT The Gift Trust (NZ), TACSI (AU), SEDT (NZ)

---

## ICP — The "Karl" Archetype

Self-taught, ops-minded professional services founder. 10-50 people. Outgrew DIY systems. Asking "what's our AI strategy?" without knowing where to start. Pain language: "held together with duct tape and paper clips," "capped out," "not messing up time is the most important thing."

Karl Avatar Voice & Pain Library (Notion): https://www.notion.so/3227841666cb8183a43cd34afc720b94

---

## Team

- **Malcolm** (25-30 hrs/wk, NZ) — Strategy, client advisory, sales, marketing, finances. Founder.
- **John** (12 hrs/wk, Golden Bay NZ) — Operations, marketing/strategy, HR, product dev. Business partner. Culture and non-hierarchical systems expertise. Notably stronger at critiquing AI output — his rejections and critique patterns are considered Optimi's highest-quality taste signals.
- **Karen** (2-5 hrs/wk, Philippines) — VA tasks, admin, bookkeeping, LinkedIn. Good candidate for structured/documented tasks.
- **Pete** (5-10 hrs/wk) — Full stack dev, primary Knack development, MLC technical implementation.
- **Bryan** (5-10 hrs/month) — Knack dev, Power BI, Notion.
- **Lina** — External business coach (recently engaged, value-aligned). Active structured coaching sessions.

**Hiring target:** In the future, developers with AI/agents/RAG/vector DB skills.

---

## Tools & Systems

- **Communication:** Gmail, Slack
- **Project management:** Notion
- **CRM:** Attio (next experiment — not yet live)
- **Lead scoring:** optimi-lead-scoring app (Express, SQLite, MailerLite integration)
- **Documents:** Google Drive, Google Docs, Google Sheets
- **Automation:** Zapier (with MCP integration)
- **Accounting:** Xero
- **AI development:** Claude Code (primary), Claude Desktop
- **Call recording:** Fathom (customised summaries for multi-pass extraction)
- **Voice dictation:** Super Whisper
- **Email marketing:** MailerLite
- **Hosting:** Vercel (web apps), Supabase (Postgres)
- **Code:** GitHub (Optiminz org)
- **Knowledge management:** OKM (Pinecone + Together.ai embeddings — experimental, evolving toward Context Lake model)

---

## Intelligence Systems

**Signal Tracker (Notion):** Captures strategic insights from thought leader content (Nate B Jones and others). Three-part capture: Signal (named concept) + Recognition (Malcolm's domain connection — must always come from Malcolm, never AI-generated) + Action Horizon (Build Now / Position Later / Watch & Wait).

**Karl Intelligence System:** 4-pass call processing from Fathom summaries -> Pass A (Avatar/ICP), Pass B (Four Legs diagnostic), Pass C (LinkedIn seeds), Pass D (strategic account narrative). Handoff doc: `oai/intelligence/mlc-karl-intelligence-handoff.md`.

---

## Repository Map

| Repo | Purpose | Stack |
|------|---------|-------|
| oai | Business intelligence, client work, operations (PARA structure) | Markdown |
| dash | Personal workflow hub — AI configs, skills, prompts, agent definitions, monday prep, daily briefing | Markdown, Claude Code |
| ai-writing-workflow | All content creation — LinkedIn, newsletters, blogs. 9-agent pipeline with Editorial Constitution | Markdown, Claude Code |
| ai-sales-workflow | Deal-centric sales process from qualification to close. Baker/Enns methodology, 7-persona pipeline | Markdown, Claude Code, oi-app integration |
| ai-outreach | Campaign-based LinkedIn outreach for professional services verticals | Markdown, Claude Code |
| oi-app | Client-facing AI readiness assessment + audit delivery platform (Lobby in Three-Room Strategy) | Next.js, Supabase, Vercel |
| OKM | Knowledge management — Pinecone vectorisation pipeline (evolving toward Context Lake) | Next.js, Supabase, Vercel |
| optimi-lead-scoring | Lead scoring and top-of-funnel interaction tracking | Express, SQLite, MailerLite |

---

## Key Notion Pages

- **Optimi Operating System:** https://www.notion.so/3227841666cb81b7bab4d677d81fbb10
- **Optimi Intent Layer:** https://www.notion.so/3227841666cb81aa9425cf8997551486
- **Decision & Learning Log:** https://www.notion.so/3237841666cb81f7b76fcd4b7ff74f94
- **Karl Avatar Voice & Pain Library:** https://www.notion.so/3227841666cb8183a43cd34afc720b94
- **Signal Tracker DB:** `db317740-83f3-4a05-af75-2a33009baf16`
- **Tasks DB:** `196773cc-cbd0-4377-8837-df514b9e0aca`

---

*This spec is the canonical description of Optimi's current state. All AI sessions across all repos should align with this context. If reality has diverged from this document, update the Notion source page.*
