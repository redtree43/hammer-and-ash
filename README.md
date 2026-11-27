# Hammer & Ash: Uprising

Start with [docs/design/](docs/design/README.md), the sole source of truth for intended game behavior. [Open decisions](docs/design/OPEN_DECISIONS.md) lists what needs creator review.

1. Extract the package and open the top-level `Hammer-and-Ash` folder as a local project in Codex.
2. In Godot 4.7, import `source/Hammer_Ash_Godot_2D_Build10/project.godot` and press F5. See [Build 10 verification](docs/BUILD_10_PLAYTEST.md) for Godot 4.7.2 results.
3. Start with [Development Status](docs/DEVELOPMENT_STATUS.md) for the baseline, verification, priorities, and migration coverage.

| Handoff | Contents |
| --- | --- |
| [Design specification](docs/design/README.md) | Approved vision, combat, classes, missions and campaign |
| [Open decisions](docs/design/OPEN_DECISIONS.md) | Rules and details awaiting creator review |
| [Development Status](docs/DEVELOPMENT_STATUS.md) | Current behavior, gaps, priorities and migration evidence |
| [Resistance Bunker](docs/IMPLEMENTATION_NOTES.md) | Playtest controls for the current prototype |
| [Build 10 controls](source/Hammer_Ash_Godot_2D_Build10/README_FIRST.txt) | Setup, mission selection and combat controls |
| [Build 10 fixtures](docs/MISSIONS.md#build-10-test-fixtures) | Legacy regression, mixed enemy trials and bunker scenario rules |

Earlier handoffs and the campaign v0.5 transfer remain in `docs/` as evidence and prototype context. `prototypes/` holds the original archives. `references/design/` and `references/images/` hold the original documents and images. `source/` holds the active Godot project. [SHA256SUMS.txt](references/SHA256SUMS.txt) records the original migration hashes, including those for the extracted Build 10 baseline. The active source has evolved since that snapshot.
