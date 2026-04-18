# Secrets handling with the 1Password CLI

> **One-time setup:** install the `op` CLI and sign in once. See `docs/02-prerequisites.md` for instructions. The patterns below assume `op` is available.

The `op` CLI can leak secrets into the session transcript if used carelessly. The transcript persists on disk and is sent to Anthropic — treat anything that appears in tool I/O as compromised-enough-to-rotate.

## The cardinal rule

**Never reveal a secret into the session unless the user has asked you to use it for a specific command right now.** Reading a secret "to put it in `.env`" is almost never the right move — there are cleaner ways.

## Commands that LEAK secrets into the transcript

These put plaintext secret values into tool output that is retained:

- `op item get <item> --reveal` — dumps the whole item including concealed fields
- `op item get <item> --fields label=credential --reveal` — dumps the specific secret
- `op read "op://Vault/Item/field"` — prints the secret to stdout
- Any `Edit`/`Write` call where you paste the secret value into `new_string` — it's stored in the transcript twice (input and diff)
- `echo $SECRET` or any shell command that prints the value

## Commands that DON'T leak

- `op item get <item>` (no `--reveal`) — shows field metadata, values stay concealed
- `op inject -i .env.tpl -o .env` — renders a template of `op://...` references into a real `.env` without the values passing through your tool I/O
- `op run --env-file=.env.tpl -- <command>` — injects secrets as env vars for the child process only; they never touch disk or your transcript
- `op item edit` — modifying an item doesn't echo its current values

## Preferred patterns

1. **Runtime injection over on-disk secrets.** If a script just needs a secret to run right now, prefer `op run -- <script>` over writing to `.env`. The secrets live in the process env for that invocation and nowhere else.
2. **Templated `.env` when a script genuinely needs a file.** Commit a `.env.tpl` containing `op://Vault/Item/field` references; each dev runs `op inject -i .env.tpl -o .env` once. Neither you nor the template ever see the plaintext.
3. **If you must read a secret to hand it to a user-requested command, do it in one piped call:** `op read "op://..." | some-tool --token-stdin`. Don't read into a variable, don't echo, don't paste into Edit.

## If you accidentally leak

Tell the user immediately and recommend rotation. Don't hide it — a leaked secret in a transcript is a real exposure even if the machine is trusted. The correct next step is always "rotate the credential," not "hope nothing happens."

## What counts as a secret

API keys, OAuth client secrets, refresh tokens, database passwords, personal access tokens, webhook signing secrets, anything marked `CONCEALED` in 1Password. Non-secrets: `client_id` (public by design), `app_id`, hostnames, usernames.
