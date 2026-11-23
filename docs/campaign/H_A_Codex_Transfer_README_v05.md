# HAMMER & ASH: UPRISING — CODEX PROJECT HANDOFF v0.5

**Date:** 23 November 2026\
**Status:** WIP campaign design + trial-only HQ progression implementation. This package does not contain the Godot project itself.

## Package contents and what each file does

1. **`H_A_Campaign_Design_Master_v05.md`** — canonical campaign design, confirmed principles, unresolved mechanics, and trial boundaries.
2. **`H_A_Campaign_Decision_Register_v05.md`** — comprehensive audit of Decisions 1–34, plus explicit additional commitments; Stage 5 Decisions 22–27 are OPEN.
3. **`H_A_Codex_Trial_Implementation_Brief_v05.md`** — detailed Codex work order for a small HQ/research/equipment/recruitment sandbox. Read after the master and register.
4. **`H_A_Campaign_Design_Master_v05.docx`** — formatted review copy of master design (optional for Codex, better for human review).
5. **`H_A_Campaign_Loop.png`** — visual of regional commitment / win / loss / transition.
6. **`H_A_Campaign_Progression_Flow_v04.png`** — accurate system boundary visual; it predates the v0.5 audit but agrees with equipment/research rules.

## Do not treat older material as authoritative

- Any v0.3/v0.4 documentation should be archived/replaced with v0.5 after checking for conflicting edits in the Codex repo.
- An older bunker wireframe showed **armour as craftable**. It is **obsolete**. Only consumables may be produced in the Workshop.
- Other existing project documentation (tactical combat, classes, missions) remains authoritative in its domain. **Do not replace it** with campaign summaries.

## Recommended transfer procedure

1. Download and unzip this handoff package onto your PC.
2. Copy the **Markdown files** and diagrams into the Codex project's existing documentation folder (create a `docs/design/campaign/` folder if there isn't an established structure).
3. Open the same project in the Codex desktop app; give Codex the prompt below.
4. Let Codex first **audit the existing repository** and tell you what would be added/changed. Review that list before broad implementation if needed.
5. Commit design documentation to git, then implement the **limited HQ progression trial** as described in the brief. Do not start building the first complete region yet.

## Suggested copy/paste prompt for Codex

> Review `H_A_Campaign_Design_Master_v05.md`, `H_A_Campaign_Decision_Register_v05.md`, and `H_A_Codex_Trial_Implementation_Brief_v05.md`. Treat only CONFIRMED player decisions as requirements; treat TRIAL content as test assumptions and OPEN as undecided. Inspect the current Godot repository, its other design documents, and git state before making changes. First produce a concise compatibility audit (already implemented, missing, conflicting, and open decisions). Then implement **only** the headquarters progression vertical slice within the brief: one shared roster without presets, class-selectable timed base recruitment, mission-earned persistent equipment, Workshop consumables only, the three-branch research tree, limited Intel Ops/Stratagem hooks and secured rewards. Preserve existing tactical mechanics and unrelated project work. Run appropriate tests and report test results, changed files, mocks, blockers and remaining design questions. Do not implement Stage 5, a full regional campaign or the Moscow finale yet.

## Transfer verification

- [ ] Canonical master and register visible in repository.
- [ ] Codex identifies Stage 5 Decisions 22–27 as OPEN.
- [ ] Codex acknowledges 15–30-hour duration, two random regional offers, one-region commitment, four-of-eight liberation and five-lock defeat.
- [ ] Codex acknowledges single shared five-operative roster and NO presets.
- [ ] Codex acknowledges only consumables may be crafted; permanent gear is mission/event acquired.
- [ ] Codex acknowledges Workshop / Stratagems / Intel Ops research and hybrid Intel spending.
- [ ] Codex acknowledges slow class-selected base recruitment + mission/event rewards.
- [ ] Codex produces a repo audit before implementing and does not overwrite other specs.

## What this handoff does **not** include

No Godot source files, save data, previous tactical design/source files, or code changes. This is a **documentation and work-order** transfer; actual state of Codex work must be verified in the repository.
