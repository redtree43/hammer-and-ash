# Development Status

**Baseline as of 22 November 2026.** The latest accessible prototype is **Build 10**. Build 09.3 was reported working by the creator. The creator approved Build 10 for testing the reusable objective system and preserving the original chain.

## Start from the existing source

- Godot project `source/Hammer_Ash_Godot_2D_Build10/project.godot`, scene `Main.tscn`, gameplay script `scripts/combat.gd`. The project declares Godot 4.7 with GL Compatibility and requires no external art assets.
- The script holds board state, input and drawing, movement and actions, enemy AI, mission setup, events, and damage/activity reporting. Build 10 separates objective, object, trigger and flag data within the script. Some resolution and setup logic still dispatches through scenario-specific code.
- Import the project and run it with F5. The mission selector is on **M**, **1–5** choose a fixture, **R** restarts, **Enter** advances cleared linked rooms, and **F6–F8** jump to a room with fresh operatives. The original suite remains fixture 1. See the preserved `README_FIRST.txt` for the input map.
- Unchanged historical archives live in `prototypes/`. The two files for every build label are byte-identical and both original names are preserved. `references/` contains the original docs and prototype/AI screenshots, along with one class-style inspiration reference. The reference image is separate from the game's asset pipeline.

## Implemented prototype systems

| System | Build 10 |
| --- | --- |
| Combat | Fixed 2D board, five operatives, selectable units, AP economy, tile-by-tile movement, ranged attacks and special attacks, directional shared-edge cover, LOS, damage/armour previews, phase armour refresh, and reserved Overwatch. |
| Environment | Destructible light (2 HP) and reinforced (5 HP) cover, plus impervious cover and opaque walls. Ordinary shots do not destroy cover. Area Shred can damage light cover, while Anvil Breach and explosions can damage light and reinforced cover. Targetable fuel and waste barrels, chained explosions, friendly fire, weighted knockback/collision, fire/radiation/shock hazards and status ticks. Hazard durations are currently three rounds. |
| Status samples | Burning and irradiated use two own-phase activations. Shocked lasts one and reduces the next AP refresh. Matching hazard entry is suppressed while its status remains active. These are build-specific rules. |
| AI | Tactical and legacy comparison modes, role-aware movement/firing, hound pressure, support pursuit/healing/buffs, bolder or more defensive profiles, escape movement, and defence-objective targeting. |
| Recovery and room carry-over | A first down takes the operative out for the next two full player turns, then they stand at half HP rounded up. Clearing a room before that brings them back in the transition. The half-HP healing cap and down count carry forward. A second down is permanent. Room transitions reset AP, armour and ability cooldowns. |
| Objectives | Five selectable fixtures, timed radio and conditional reinforcements, final-room escape, destructible or interactive machines, prisoner release, and safehouse waves. See [Missions](MISSIONS.md). |
| Interface and reports | Static pixel-art silhouettes distinguish operatives and enemy types on their existing faction tokens. Squad tabs, unit and target inspectors, firing-range/LOS overlay, threat preview, ability text, damage ledger, per-room activity snapshots and final reports. Counters include attacks, movement/tiles, damage dealt and taken, ability use, Overwatch, healing/buffs and objective damage. |

## Preserved build history

| Build | Change evidenced in archive |
| --- | --- |
| 07.1 | Single-encounter horde and Command Bunker scenarios, five player kits, tactical AI comparison, Area Shred, directional cover and audit ledger. |
| 08 | Introduced the three-room chain, between-room squad view, carry-over and first/second down handling. |
| 08.1 | Added the timed Room 2 radio, clear-with-failure rule and three-hound consequence. |
| 08.2 | Added per-room operative activity snapshots and the report browser. |
| 09 | Added environmental destruction, barrels, hazards, weighted push/collision, and developer room jumps. |
| 09.1 / 09.1.1 | Added straight-line Sentinel Breach and differentiated its cover damage from Area Shred. The latter archive is a parser hotfix. |
| 09.2 | Added inspectors and squad tabs, revised barrel placements and prevented same-status hazard entry refresh. |
| 09.3 | Standardised cover tiers, clarified firing indicators and AP state, and changed special abilities to temporary 1 AP test tuning. |
| 10 | Added modular objective fixtures and selector. Retained the original chain and previous environment/reporting features. |

## Gaps between design and code

- Build 10 displays Scythe, Anvil, Needle, Iskra and Alkhimik with their existing prototype kits. [Glaz's control role](CLASSES_AND_ENEMIES.md#confirmed-class-identities) is confirmed design and has no playable slot yet. Scythe's detailed tree is provisional. Build 10 has no progression tree, general equipment system, or final class-specific opportunity reactions.
- Ammunition, magazine capacity/reloading, consumable accounting, broad status and damage-type systems, and logical elevation remain planned. Build 10 has sample hazards and temporary combat effects.
- Build 10 links rooms linearly. Branch selection, early extraction and secured-reward accounting, strategic PMO effects, and the first authored branching mission are still pending.
- Campaign state, roster replacement and recovery, HQ, research, adaptive doctrine, final art and audio, and release scope remain future work.

## Verification during migration

All preserved prototype archives passed ZIP integrity checks. Build 10 source files match their archive entries byte-for-byte. Godot 4.7.2 launched the original scene headlessly from a disposable copy. A separate one-off runtime harness passed **17 checks** covering initialisation of all five fixtures, a missed-radio clear, room transition and two downs, assassination escape/failure, sabotage activation, rescue interaction/completion, and defence wave scheduling/completion. The harness used direct scenario and state calls. Windows editor import, interactive end-to-end play, UI rendering, and balance remain to be verified. The original `VALIDATION_10.txt` and README accurately record the more limited validation done when Build 10 was originally packaged.

## Windows Build 10 playtest

The 22 November 2026 Windows run exercised all five fixtures through the normal input handlers in a rendered Godot 4.7.2 session. Both radio outcomes, squad carry-over and second-down loss were verified through normal room progression. A follow-up assassination retest confirmed 4/5 defeated on Orlov's escape and 5/5 when he and his guards were killed. [Run details and remaining checks](BUILD_10_PLAYTEST.md).

The pixel-art pass was checked at 1460 × 900 in Godot 4.7.2 on Windows. All five fixtures opened, and all 13 active visual roles were sampled, including the activated sabotage robot. The retained legacy commander also has a distinct sprite. Replays of both radio outcomes and both assassination outcomes matched the recorded mission results and squad carry-over.

A follow-up pass refreshed the cover, walls, barrels, hazards and mission props and added the confirmed first-down rules. Both radio branches were replayed through the original chain. The timed return, healing cap, transition recovery, permanent second down and wipe were verified. [Recovery run details](BUILD_10_PLAYTEST.md#first-down-recovery-and-battlefield-visuals).

## Next development priorities

1. Keep the recorded Windows fixture outcomes as the Build 10 regression baseline. Manual pacing and balance assessment remain open.
2. Playtest recovery pacing and cover the remaining confirmed combat gaps, including class-specific reactions. Reconcile collision damage in the prototype with the combat spec. Add the agreed ammunition/equipment behavior and extend statuses incrementally.
3. Use the objective fixtures to build the first forward-only branching mission with a distinct final PMO, optional gain, failed-SMO pressure, secured rewards, and between-room extraction. Test successful, partial, failed and extracted outcomes.
4. Compare mixed and single-role squads against horde, ranged, protected and support compositions. Tune AI and UI using combat ledgers. Refactor combat and objective logic incrementally around shared rules and regression coverage.
5. Once the tactical/mission loop is stable, build the proposed mini-campaign of three to five connected missions with compact HQ and campaign state. Lock large-scale content and production scope after that slice is proven.

Priority order above is the handoff's proposed sequencing of documented work. Git status on the creator's Windows machine is unknown.

## Migration coverage and gaps

| Source | What was available |
| --- | --- |
| ChatGPT Project instructions | The project-scope instruction supplied with this task is carried into `AGENTS.md`. The complete project settings and any additional custom instructions or capabilities were unavailable for inspection. |
| Conversations reviewed through available excerpts | **Combat Prototype Plan**, **Create Project Roadmap**, **Design Tactical Combat**, **Design Tactics Classes**, **Enemy Design**, **Missions - Campaign & Tactical**, and **Codex Project Sync**. These provided decision excerpts, prototype reports and design context. |
| Full conversation access | The private project index opened to a sign-in screen. Full transcripts, any conversations outside the retrieved excerpts, and the complete project attachment inventory could not be independently reviewed. The full Enemy Design Framework and any standalone Red Ledger specification were not retrieved. |
| Recovered original design documents | `01_Game_Vision.docx`, `Player_Unit_Archetypes.docx`, class framework and compendium, 2D visual amendment and prototype plan, Master Game Design v1.0, Combat Specification v1.0, and Mission Objectives Master Guide. All nine are in `references/design/`. |
| Known document references unavailable | `Game_Vision.md` v0.3, `Game_Vision.docx` (the other working rendition), and `Combat_System_Overview.docx` v0.1. The newer master, combat spec, and visual amendment describe where those records were superseded. |
| Known archives unavailable | Earlier Builds 02 through 07 before 07.1 were referenced in prior conversation evidence but did not resolve to accessible files. All ten accessible build labels (07.1 through 10) and their paired copies are included. |
| Other uploads and local code | The project source listing supplied with this task had no entries. The 41 accessible files recovered from the project-named file collection are preserved. The browser workspace could not inspect the Windows `Hammer-and-Ash` folder, any local Git repository, or unlisted chat-only attachments. |

For open mechanics and the current authority rules, see [Open Questions](OPEN_QUESTIONS.md).
