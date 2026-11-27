# Hammer & Ash: Uprising

You are operating in the context of a wider project called Hammer & Ash: Uprising. This project uses custom instructions, capabilities and data to optimize ChatGPT for a more narrow set of tasks.

## Project baseline

- Start with [Development Status](docs/DEVELOPMENT_STATUS.md) for the current build, then read the governing specification in [docs/design/](docs/design/README.md) before changing game behavior.
- Develop in the extracted Godot 4.7 project at `source/Hammer_Ash_Godot_2D_Build10/project.godot`. Use GDScript and preserve the fixed-view 2D square grid and GL Compatibility baseline.
- Keep the historical ZIPs and original references intact. Track source, scenes, project settings and Godot UID sidecars in Git. Keep generated caches and local tool settings out of Git.

## Design authority

- [docs/design/](docs/design/README.md) is the sole source of truth for intended game behavior. Use code and playtest records to establish current execution behavior. Use earlier handoffs, specialist specs and references as evidence.
- Record each new explicit creator decision in the owning design document with its date and source. Check affected design sections, open items and the implementation handoff for follow-up changes.
- Record conflicts, approval gaps and unresolved mechanics in [Open decisions](docs/design/OPEN_DECISIONS.md). Confirm the choice with the creator before making it a permanent rule. Preserve prototype tuning, including the 1 AP test costs, as provisional until approved.

## Development and verification

- Keep changes scoped. Follow the existing GDScript conventions in touched code and reuse shared rules for previews, action resolution and reporting. Introduce dependencies only when the task calls for them.
- Import the active project in Godot and press F5. Deploy from the USSR map for mission and combat playtesting. Check the affected operations through normal controls. See the [Build 10 controls](source/Hammer_Ash_Godot_2D_Build10/README_FIRST.txt).
- Preserve fixture 1, the original three-room regression scenario, when extending objectives. Open it from HQ with **M → 1 → Enter**. Verify linked-room carry-over and the radio consequence through normal progression. **F6–F8** reset the fixture squad for isolated room checks.
- For behavior changes, identify the governing design section and verify the affected rules through normal play. Update the handoff with discrepancies, the Godot version, scenarios exercised and remaining checks.
