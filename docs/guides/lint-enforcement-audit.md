# Lint Enforcement Audit — Standard Operating Procedure

*Mechanical enforcement of code quality rules in agentic codebases*

**Created:** 2026-03-27
**From:** Malcolm
**Provenance:** Nate B Jones signal — "AGENTS.md as industry-standard machine constitution" (Factory AI Agent-Native Development, 2026-03-27). Signal Tracker record: [Notion](https://www.notion.so/3307841666cb8136b3d7e4390acdda80)
**First applied:** oi-app (mdshearer/oi-app@2f40f79)

---

## Why This Exists

In an agentic development environment, documented rules that rely on the agent "reading and choosing to comply" are insufficient. AI agents write code that compiles and passes tests but silently violates architectural rules, security standards, and naming conventions — because those rules exist only in a markdown file the agent may or may not have in context.

**The principle:** Linters are executable law, not stylistic preference. If a CONSTITUTION.md rule can be expressed as a linter rule or compiler flag, it must be. Lint green becomes the proxy for constitutional compliance.

**What this guide is for:** Running a structured audit on any TypeScript/JavaScript repo to close the gap between documented rules and mechanical enforcement.

---

## When to Use This

- Setting up a new repo with ai-dev-orchestrator
- Onboarding an existing repo to agentic development
- After significant changes to CONSTITUTION.md rules
- Periodic audit (quarterly) to check for drift

---

## The Prompt

Copy this prompt and give it to Claude Code in any TypeScript/JavaScript project. It assumes a CONSTITUTION.md exists (or equivalent governance doc). Adapt the file references for your project.

````markdown
# Lint Enforcement Audit & Upgrade

## Purpose

Audit and upgrade the linting configuration so that CONSTITUTION.md rules are
mechanically enforced by tooling, not just documented for compliance. The goal:
if an agent writes code that violates architectural rules, the linter catches it
before commit — not code review.

## Step 1: Read the Governance Files

Before making any changes, read:

1. `CONSTITUTION.md` (or `AGENTS.md`) — the project's standards
2. `tsconfig.json` — current TypeScript configuration
3. ESLint config (`.eslintrc.*` or `eslint.config.*`)
4. Prettier config (`.prettierrc` or `prettier.config.*`)
5. `package.json` — dev dependencies and scripts

**Do not modify anything yet.** Produce a gap analysis first.

## Step 2: Gap Analysis

For each category below, check whether the CONSTITUTION mandates it AND whether
the linting config enforces it. Present findings as a table:

| Rule Category | CONSTITUTION Says | Currently Enforced? | Gap? |

### Categories to Check

**TypeScript Strictness:**
- `strict: true` in tsconfig
- `noUncheckedIndexedAccess: true` — prevents agents assuming array access is safe
- `noImplicitReturns: true` — prevents undefined return paths
- `noFallthroughCasesInSwitch: true` — prevents switch bugs

**Architectural Boundaries (highest value):**
- No cross-layer imports (frontend importing from server, or vice versa)
- Database access only through the ORM/client layer
- Shared types from designated location only (no parallel definitions)

**Security (critical for agentic output):**
- No hardcoded secrets (`no-secrets/no-secrets` plugin or custom regex)
- No dynamic code execution (`no-eval`, `no-new-func`, `no-implied-eval`)
- No XSS-enabling React props

**Code Quality:**
- No `any` type usage (`@typescript-eslint/no-explicit-any`)
- No unused variables (`@typescript-eslint/no-unused-vars`)
- No `console.log` in production (allow `console.error`/`console.warn`)
- No floating promises (`@typescript-eslint/no-floating-promises`)

**Import Organisation:**
- Import order enforced and sorted (`eslint-plugin-simple-import-sort`)

**Testing:**
- No skipped tests (`.skip`) in committed code

## Step 3: Propose Changes

Based on the gap analysis, propose changes in priority order:

1. **P1: Architectural Boundaries** (prevent the most expensive mistakes)
2. **P2: Security Rules** (catch things agents have no intuition about)
3. **P3: TypeScript Strictness** (reduce surface area for hallucinated code)
4. **P4: Code Quality** (hygiene that compounds over time)
5. **P5: Naming & Organisation** (improves agent navigability)

For each change, specify:
- The exact ESLint rule or plugin
- Severity: `error` (blocks commit) vs `warn` (flags but allows)
- Whether it has an autofix
- Count of existing violations that would need fixing

**Severity guidance:**
- `error` for architectural boundaries and security — genuinely dangerous
- `warn` for quality/style — start as warn, graduate to error once violations cleared

## Step 4: Implement (after user approval)

1. Install needed ESLint plugins
2. Create/update ESLint config (prefer flat config `eslint.config.js` for ESM projects)
3. Update tsconfig.json if strictness changes approved
4. Run `npx eslint . --fix` for auto-fixable violations
5. Fix TypeScript errors from new strictness flags
6. List remaining manual fixes with file paths

## Step 5: Pre-Commit Enforcement

1. Install `husky` + `lint-staged` if not present
2. Configure lint-staged: `eslint --fix` + `prettier --write` on staged files
3. Add `tsc --noEmit` to pre-commit hook (full type check)
4. Add scripts: `lint`, `lint:fix`, `typecheck`

## Step 6: Create AGENTS.md

Create AGENTS.md with:
- Quick reference commands (lint, test, build, typecheck)
- Enforced rules table (what's `error` vs `warn`)
- Architecture boundaries (which directories, what can import what)
- File naming conventions
- Environment setup

## Important Notes

- Present gap analysis BEFORE making changes
- Use `error` sparingly — only for genuinely dangerous violations
- If tightening rules would flag 200+ violations, start as `warn` and graduate
- Phase-in: `warn` first, `error` once existing code is clean
- After implementation, update CONSTITUTION.md to note which rules are mechanically enforced
````

---

## What the Prompt Produces

When run against a typical TypeScript project, this produces:

| Artifact | Purpose |
|---|---|
| `eslint.config.js` | Flat config with architectural, security, quality, and import rules |
| Updated `tsconfig.json` | Strictness flags (`noUncheckedIndexedAccess`, `noImplicitReturns`, `noFallthroughCasesInSwitch`) |
| Updated `package.json` | `lint`, `lint:fix`, `typecheck` scripts + lint-staged config |
| Updated `.husky/pre-commit` | Runs lint-staged + tsc on every commit |
| `AGENTS.md` | Machine-readable reference for AI tools |
| Updated `CONSTITUTION.md` | Notes which rules are now mechanically enforced |

---

## Lessons from First Application (oi-app)

These findings apply across projects:

### `noUncheckedIndexedAccess` is the highest-value tsconfig flag

AI agents write `array[0].property` constantly without null checks. This flag caught 40 real issues in a 40-file codebase. Fix patterns are simple: `??` fallback, `!` after bounds check, early return guard.

### `recommendedTypeChecked` fires heavily on untyped API clients

Supabase, Prisma `.raw()`, and other clients that return `any` will trigger 100+ `no-unsafe-*` violations. These are real issues but must start as `warn` — fixing requires adding return type generics to every API call.

### Phase-in with `warn` then graduate to `error`

Starting everything as `error` blocks all commits immediately. Start inherited strictness as `warn` so enforcement ships on day one with zero errors, while issues surface in editors. Track graduation in GitHub issues.

### Import sorting is zero-effort compliance

94 of 101 autofixable violations in oi-app were import order. `eslint-plugin-simple-import-sort` with `--fix` handles this automatically. Worth adding to every project.

### Real bugs surface immediately

On the first run against oi-app:
- Conditional React hook call (would crash on re-render)
- Unsafe HTML injection prop in a component
- Hardcoded URL flagged by entropy detection (false positive, but proved the rule works)

---

## Adapting for Other Languages

The prompt above is TypeScript-specific. For other stacks:

| Stack | Linter | Key Flags | Architectural Enforcement |
|---|---|---|---|
| **Python** | Ruff / Pylint | `--strict` mypy, `disallow_any_explicit` | `import-linter` for boundary rules |
| **Go** | golangci-lint | `govet`, `staticcheck` | Package-level visibility + `depguard` |
| **Rust** | clippy | `#![deny(clippy::all)]` | Module visibility + `cargo deny` |

The principle is the same: if the CONSTITUTION says it, the tooling must enforce it.

---

## Provenance & References

- **Signal source:** Nate B Jones — "Nvidia Just Open-Sourced What OpenAI Wants You to Pay Consultants For / Factory AI Agent-Native Development" (2026-03-27)
- **Core principle:** "Lint green becomes the proxy for constitutional compliance" — Factory AI research on using linters to direct agents
- **Signal Tracker:** [Notion record](https://www.notion.so/3307841666cb8136b3d7e4390acdda80)
- **First implementation:** oi-app commit `2f40f79` — full audit from zero ESLint to enforced boundaries
- **Follow-up issues:** mdshearer/oi-app#119, #120, #121
- **ai-dev-orchestrator:** CONSTITUTION-TEMPLATE.md Section 5 updated with enforcement standard
