# Env Sync Convention — 1Password as Source of Truth

## Why

`.env` files across many repos, multiple machines, occasional rotations. The problem with plaintext `.env`s isn't primarily secrecy — it's **sync**. When a key changes, every machine that has the repo checked out is instantly stale, and there's no single place to update it.

This convention puts 1Password in the middle: every `.env` is mirrored as a 1Password **Document**, and two small shell tools (`pull-env`, `push-env`) move bytes between disk and vault.

## Trade-off vs `op run`

| Approach | Secrets on disk? | Friction | Fit |
|---|---|---|---|
| **Document sync** (this) | Yes, plaintext `.env` | Low — sync once, then normal commands | Daily dev work |
| **`op run --env-file`** | No — injected at process start, scrubbed on exit | High — every command wrapped | Prod CI, highly sensitive creds |

Use document sync for day-to-day. Reserve `op run` for genuinely sensitive environments (production database admin creds, payment gateway keys, anything where "never on disk" actually matters).

## Naming convention

**Vault:** depends on the repo — there's no single team-wide default. Personal/internal repos typically live in `Private`; client/shared work in `Technical Vault`. Set the vault per-machine with `export ENV_SYNC_VAULT="..."` in `~/.zshrc`, or per-invocation by exporting before the call.

**Document title:** `<repo-name>.env[.<suffix>]`

The `<repo-name>` is the directory name of the repo root (what `basename $(git rev-parse --show-toplevel)` returns). Examples:

| Local file | 1Password document title |
|---|---|
| `oi-app/.env` | `oi-app.env` |
| `oi-app/.env.production` | `oi-app.env.production` |
| `mlc-context/.env.testing` | `mlc-context.env.testing` |
| `OKM/.env` | `OKM.env` |

Case matters — the repo name is used verbatim. Rename the 1Password document if a repo gets renamed.

## Usage

Both tools auto-detect the repo from the current working directory. Run them from anywhere inside a repo.

```bash
pull-env                              # Fetch .env for the current repo
pull-env development                  # Fetch .env.development
pull-env development production       # Fetch several at once
```

```bash
push-env                              # Push .env (shows diff, asks for confirmation)
push-env production                   # Push .env.production
```

`push-env` always:
1. Fetches the current 1Password version to a temp file
2. Shows a unified diff
3. Prompts before writing — no `--yes` flag, this is deliberate
4. Offers to create the document if it doesn't exist yet

## Onboarding a new repo

First time:

```bash
cd ~/Projects/some-new-repo
push-env   # → "document does not exist, create it? [y/N]" → y
```

Or for multi-environment repos:

```bash
push-env development
push-env production
```

On another machine:

```bash
cd ~/Projects/some-new-repo
pull-env development production
```

## Rotation procedure

When a key changes (API key cycled, new integration, etc.):

1. Edit the local `.env` on whichever machine you're on
2. `push-env` — review the diff, confirm
3. On other machines: `pull-env` to refresh

If you're rotating a shared key that others use, coordinate — 1Password is the source of truth but has no lock.

## Script locations

- `~/.local/bin/pull-env`
- `~/.local/bin/push-env`

Both are plain bash, no dependencies beyond `op` (1Password CLI) and `git`. `~/.local/bin` should be on your PATH.

## Security notes

- `pull-env` always `chmod 600`s the local file so it's not world-readable
- Scripts use `set -euo pipefail` — any `op` failure aborts cleanly
- No secrets are ever printed to stdout; only document titles and paths
- `op` handles auth via the 1Password desktop app integration — no long-lived API tokens on disk
- `.env` files should still be in `.gitignore` everywhere. This convention does not replace gitignore hygiene.

## When to reach for `op run` instead

If any of the following is true for a specific `.env`, consider `op run` for that one:

- Contains production database admin credentials
- Contains payment gateway or financial API keys
- Contains keys that would be catastrophic if leaked from a stolen laptop
- Runs in CI/CD (where disk persistence is pointless and `op run` is cleaner anyway)

The two approaches can coexist in the same repo — document sync for dev `.env`, `op run --env-file=.env.production` for prod commands.
