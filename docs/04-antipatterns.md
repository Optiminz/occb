# Anti-patterns

Concrete failure modes. Format: **context → signal → fix → meta-lesson**.

---

## The 1Password CLI rabbit hole

**Context:** Claude was configured to fetch secrets via the 1Password CLI. Without enough scaffolding, it started asking for interactive permission on every single secret read — dozens of times in quick succession.

**Signal:** Repeated permission prompts of the same type, feeling increasingly absurd. You find yourself approving the same operation over and over. Something that should be automatic is generating friction at every step.

**Fix:** Cancel early. Don't approve 15 times hoping it'll stop. Instead:
- Cache credentials at session start (`op signin` once, up front).
- Point Claude at a local `.env` file rather than live CLI calls.
- If the tool requires interactive confirmation by design, script around it or add the permission to settings permanently.

**Meta-lesson:** When Claude is asking the same kind of permission many times in a row, the design is wrong, not the prompting. Back up and fix the scaffolding.

---

## Leaking secrets via `op --reveal` or pasting into Edit

**Context:** Asked to populate a project's `.env` with OAuth creds from a 1Password item. Ran `op item get --reveal`, then pasted the plaintext values into an `Edit` call. Both values now live in the session transcript in at least two places (input and diff).

**Signal:** You're about to write a file containing a secret, and the secret value just appeared in tool output. Or you're about to `echo`, `cat`, or `Edit` a value that came from `op ... --reveal`.

**Fix:** Stop. Discard the plan. Use one of these instead:
- `op inject -i .env.tpl -o .env` — renders a template of `op://...` refs into `.env` without plaintext touching tool I/O.
- `op run --env-file=.env.tpl -- <command>` — injects secrets as env vars for the child process; never on disk, never in transcript.
- `op read "op://..." | some-tool --token-stdin` for single-shot hand-offs.

If you've already leaked: tell the user, rotate the credential. Don't hide it.

**Meta-lesson:** Never reveal a secret into the session unless the user has asked you to use it for a specific command right now. "To put it in `.env`" is almost never the right move. Full guide: [`docs/06-secrets.md`](06-secrets.md).

---

## Two git repos tracking the same working tree

**Context:** `~/.claude/` was version-controlled as one repo (say `claude-config`), AND had files owned by another tool's installer (occb generating `CLAUDE.md` + symlinks). On each machine, a sync script ran `git add -A` with a `sync: <host>` message. Rebase conflicts ended up with raw `<<<<<<< HEAD` markers left in the generated file — which Claude tolerantly kept reading for days without flagging.

**Signal:** You see conflict markers in a file that's supposed to be generated. Or you find two different tools both writing to the same directory with overlapping file ownership.

**Fix:** One directory, one authoritative source of truth. Either the installer owns the generated files (and the sync repo must gitignore them), or the sync repo owns them (and the installer must not touch them). "Both sync their own view" is always broken.

For symlinks: the `.gitignore` pattern must NOT have a trailing slash — trailing slash means dir-only, but a symlink is a file.

**Meta-lesson:** Before adding a git repo, check if anything else is already writing to that directory. If an installer or generator owns files there, it owns that directory's config tracking too. occb's `install.sh` now detects a `.git` in the target and bails loudly.

---

## Deleting the working directory mid-session

**Context:** A session's working directory was `~/Projects/mlc/`. Mid-session, a cleanup step did `rm -rf ~/Projects/mlc/`. Every subsequent `Bash`, `Grep`, `Glob`, and even subagent call errored with `Working directory "..." no longer exists. Please restart Claude from an existing directory.`

**Signal:** You're about to `rm -rf <dir>` and `<dir>` is an ancestor of `pwd`. Or it IS `pwd`.

**Fix:** In a separate Bash call first, `cd` to a safe location (parent dir). Then run the delete in a follow-up call. The cached `process.cwd()` only updates between tool calls — `cd && rm -rf` in one call won't save you because the call itself errors out before `cd` runs.

Better: run destructive deletes from a parent directory you're already in. Never from inside the thing you're tearing down.

**Fallback if already wedged:** Exit Claude and restart from a safe directory (`cd ~ && claude`). Subagents inherit the broken cwd — don't waste time on that path.

**Meta-lesson:** The "always run Claude from a project directory" habit is a trap when that project is being deleted. Always check whether `<target>` contains `pwd` before an rm.

---

## Large binary files in git history

**Context:** Moved PDFs and screenshots into `docs/` and committed them. `git push` failed with `HTTP 400 / send-pack: unexpected disconnect` — a 4.8MB PDF exceeded GitHub's push limit. Even after a follow-up commit deleting the files, the intermediate commit still had to push through.

**Signal:** You're about to `git add` a binary file (PDF, PNG, video) that's bigger than a few hundred KB. Or a `git push` fails with HTTP 400 / 413 / unexpected-disconnect.

**Fix:** Add `*.pdf`, `*.png`, `*.mov` patterns to `.gitignore` **before** staging. If already committed but not yet pushed: `git reset --mixed <last-good-sha>` rewinds HEAD without touching the working directory, then commit only the `.gitignore` change.

**Meta-lesson:** Once a large blob is in git history, deleting the file doesn't remove it from history — only a rewrite does. Keep binaries out of the initial commit.

---

## Project-scoped memory only fires from that project's CWD

**Context:** Saved a reminder as a project-scoped memory under `~/.claude/projects/<encoded-cwd>/memory/`. Worked multiple sessions from other project directories — the memory never fired.

**Signal:** You're about to save a memory and the current project directory isn't where you'll be next time you need the reminder.

**Fix:** For cross-project or cross-machine reminders, put them in the global `~/.claude/CLAUDE.md` (loaded in every session on every machine) or an appropriate persistent doc. Reserve project-scoped memory for things that genuinely only matter inside that project.

**Meta-lesson:** Memory scope = the encoded cwd of the session that created it. Not "my memories," not "follow me around." If you want global reach, save globally.

---

## Removing packages without checking transitive deps

**Context:** Dropped `@neondatabase/serverless` and other unused-looking deps. Next `tsc` failed because `server/db.ts` imports `pg`, which wasn't a direct dependency — it was working via a transitive dep from `drizzle-orm` that also got removed.

**Signal:** You're about to `npm remove` / `pnpm remove` a package that looks unused but hasn't been verified against actual imports.

**Fix:** Before removing, grep for imports of the package AND check if any remaining code depends on packages that might be transitive. Add `@types/*` for any transitive runtime deps that remain in use. Run the build before committing the removal.

**Meta-lesson:** "Not in my imports" ≠ "not used." Transitive deps can make a package appear optional when it isn't.

---

## Branch drift across a long session

**Context:** During a multi-step refactor spanning many tool calls, the git branch can change outside the Claude session — an IDE commit, a terminal command, another tool switching branches. The file tree on disk often looks identical, so the drift is invisible.

**Signal:** You're about to `git commit` in a session that's been running a while, and you haven't checked the branch recently. Or: a commit lands on the wrong branch and you have to reset + redo.

**Fix:** Call `git branch --show-current` as the first thing in the same Bash invocation as `git add`/`git commit`. Don't trust that you're still on the branch where the session started.

Also: **only stage named paths** — never `git add -A` or `git add .`. Those sweep in pending work you didn't touch, which then travels into your commit with a misleading message.

If you committed to the wrong branch: `git reset --soft HEAD~1` keeps the changes staged. Switch branches (stash first if dirty), and re-commit with specific paths on the right branch.

**Meta-lesson:** In any session longer than a couple of commits, treat branch as volatile. Check explicitly. Specific file paths in `git add` beat wildcards every time.

---

## Reading an `op inject`-rendered file leaks secrets identically to `op --reveal`

**Context:** After rotating a credential and re-running `op inject -i secrets.tpl -o secrets.json`, the rendered output file contains plaintext secrets. A follow-up `cat secrets.json` or `Read secrets.json` to "verify the injection worked" dumps those plaintext values into the session transcript — exactly the leak vector `op --reveal` causes.

**Signal:** You've just injected or rendered a file from an `op://` template, and your next instinct is to `cat`/`Read` it to confirm it worked.

**Fix:** Verify rendered secret files **indirectly** — never by dumping contents. Examples:
- `python3 -c "import json; d=json.load(open('f.json')); v=d[...]['KEY']; print('len:', len(v), 'prefix:', v[:4])"` — shape check, no value
- `grep -c 'op://' f.json` — counts unresolved refs (zero = injection succeeded)
- `jq 'keys' f.json` — structure only
- `python3 -c "json.load(open('f.json'))"` — just validates it parses

If you've already leaked: tell the user, recommend rotation, re-inject after rotation.

**Meta-lesson:** `docs/06-secrets.md` forbids `op read --reveal`; this extends the rule. Any tool call that returns file contents (`cat`, `Read`, `head`, `tail`, opening in a previewer) leaks secrets the same way if the file contains them. "Don't reveal into the transcript" covers file reads, not just `--reveal` flags.

---

## Contributing

Add anti-patterns in the same format: context, signal, fix, meta-lesson. Real stories from real sessions are more useful than hypotheticals.
