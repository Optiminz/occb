# Preflight discipline

Every skill or command that writes, mutates, or runs long MUST have a completed `PREFLIGHT.md` before deployment.

## When to require it

- Any skill/command that writes to Notion, GitHub, file system, email, or external APIs
- Any skill/command that runs for more than a single turn (long-running, looping, or multi-step)
- Any skill/command that could produce side effects if run twice (non-idempotent operations)

## When it's optional

- Read-only skills (e.g. analysis, search, reporting with no writes)
- One-shot formatting or content generation that stays in conversation

## What to check

1. **Blast radius** — what systems does it touch, read vs write, worst-case failure
2. **Failure mode** — crash recovery, state persistence, idempotency
3. **Token/runaway protection** — stopping conditions, budget caps, expected cost

## Enforcement

Before packaging a new skill or command, check: does `PREFLIGHT.md` exist in the skill directory? If not, and the skill writes or runs long, flag it:

> ⚠️ This skill has no PREFLIGHT.md. It touches [X systems] and [runs long / writes data]. Fill in the preflight check before deploying.

Do not block deployment — but always surface the warning.
