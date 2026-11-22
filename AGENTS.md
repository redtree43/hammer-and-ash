# Hammer & Ash: Uprising

You are operating in the context of a wider project called Hammer & Ash: Uprising. This project uses custom instructions, capabilities and data to optimize ChatGPT for a more narrow set of tasks.

## Project baseline

- Start with [Development Status](docs/DEVELOPMENT_STATUS.md), then read the relevant design handoff before changing game behavior.
- Develop in the extracted Godot 4.7 project at `source/Hammer_Ash_Godot_2D_Build10/project.godot`. Use GDScript and preserve the fixed-view 2D square grid and GL Compatibility baseline.
- Keep the historical ZIPs and original references intact. Track source, scenes, project settings and Godot UID sidecars in Git. Keep generated caches and local tool settings out of Git.

## Design authority

- Apply the latest explicit creator decision first, then the latest relevant specialist specification. Use the code to establish current execution behavior.
- Preserve confirmed decisions. Treat prototype values, including the 1 AP special-ability costs, as test tuning unless confirmed. Use superseded documents for historical context.
- Record conflicts and unresolved mechanics in [Open Questions](docs/OPEN_QUESTIONS.md). Confirm decisions with the creator before making unresolved behavior a design default.

## Development and verification

- Keep changes scoped. Follow the existing GDScript conventions in touched code and reuse shared rules for previews, action resolution and reporting. Introduce dependencies only when the task calls for them.
- Import the active project in Godot and press F5. Use the mission selector on **M** and keys **1–5** to check affected fixtures through normal controls. See the [Build 10 controls](source/Hammer_Ash_Godot_2D_Build10/README_FIRST.txt).
- Preserve fixture 1, the original three-room regression scenario, when extending objectives. Verify linked-room carry-over and the radio consequence through normal progression. **F6–F8** reset the squad for isolated room checks.
- Update the handoff when behavior or verification changes. Record the Godot version, the scenarios exercised, and any remaining checks.
