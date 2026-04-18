# Shell templates (opt-in)

Optional shell snippets team members can adopt. **Not auto-installed** by `install.sh` — everyone's shell is personal, and the repo lists in particular vary per-person.

## `terminal-launcher.zsh`

When you open a new terminal, shows a tiny menu:

```
  1  claude code
  2  npm run dev
  3  pullall
  4  shell
```

Press 1/2/3 to jump straight into Claude Code, a dev server, or a bulk `git pull` across your repos (followed by Claude). Press 4 (or anything else) to drop to a normal shell.

Also includes:

- `pullall` — a zsh function that fast-forward-pulls every repo in a list you define. Reports updated / clean / failed counts.
- Silent background auto-pull of `~/Projects/dotfiles` and `~/.claude` on each shell open, so machines stay in sync.

### To adopt

1. Open `terminal-launcher.zsh` and edit the `repos=(...)` list inside `pullall` — add the repos you actually work in. Anything missing on disk is silently skipped.
2. Decide how to wire it into your shell:
   - **Copy-paste** the sections you want into your `~/.zshrc`, or
   - **Source it** from your `~/.zshrc`:
     ```sh
     source ~/Projects/occb/shell-templates/terminal-launcher.zsh
     ```
3. If you use meta-repo layouts (e.g. `MillLawCenter/`, `smt/`), add explicit `_pullall_repo` calls for the nested siblings — see the commented example near the bottom of `pullall`.

### Why it's opt-in

- Your repo list is not my repo list. Shipping one team-wide would either be wrong for everyone or constantly out of date.
- The launcher menu is opinionated; some people want a blank prompt.
- Background `git pull` on shell open is a side-effect some team members might not want.

If you tweak the template in a way that seems generally useful (new menu items, better error handling, cross-shell support), PR it back.
