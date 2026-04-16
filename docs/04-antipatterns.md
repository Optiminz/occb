# Anti-patterns

Concrete failure modes. Format: **signal → fix → meta-lesson**.

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

## Contributing

Add anti-patterns in the same format: context, signal, fix, meta-lesson. Real stories from real sessions are more useful than hypotheticals.
