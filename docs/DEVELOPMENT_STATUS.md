# Development Status

**Baseline as of 22 November 2026.** The latest accessible prototype is **Build 10**. Build 09.3 was reported working by the creator. The creator approved Build 10 for testing the reusable objective system and preserving the original chain.

**23 November update.** The prototype opens at the [Resistance Bunker](IMPLEMENTATION_NOTES.md). The latest bunker decisions govern this prototype. See [Campaign v0.5](campaign/H_A_Campaign_Design_Master_v05.md) for the broader campaign handoff.

The Personnel dossier uses three panels for stats, class path and equipment. Scythe's provisional class tree can be browsed by origin. [Personnel controls and verification](IMPLEMENTATION_NOTES.md).

## Start from the existing source

- Godot project `source/Hammer_Ash_Godot_2D_Build10/project.godot`, scene `Main.tscn`, gameplay script `scripts/combat.gd`. The project declares Godot 4.7 with GL Compatibility and requires no external art assets.
- The script holds board state, input and drawing, movement and actions, enemy AI, mission setup, events, and damage/activity reporting. Build 10 separates objective, object, trigger and flag data within the script. Some resolution and setup logic still dispatches through scenario-specific code.
- Import the project and run it with F5. Choose **USSR → Region 1**, select an operation, and prepare five operatives. In combat **X** reloads, **J** aims melee, **K** aims the medkit, and **G** uses a prepared Emergency Reload. **Enter** advances Assassination's cleared rooms and **E** extracts between them. **F9** returns to the bunker from the combat report.
- Unchanged historical archives live in `prototypes/`. The two files for every build label are byte-identical and both original names are preserved. `references/` contains the original docs and prototype/AI screenshots, along with one class-style inspiration reference. The reference image is separate from the game's asset pipeline.

## Implemented prototype systems

| System | Build 10 |
| --- | --- |
| Combat | Fixed 2D board, five operatives, selectable units, AP economy, tile-by-tile movement, ranged attacks and special attacks, directional shared-edge cover, LOS, damage/armour previews, phase armour refresh, and reserved Overwatch. |
| Ammunition | Allied and enemy firearms have three rounds per magazine, unlimited 1 AP reloads and automatic refills on room entry. The inspector shows current ammo and offers Reload alongside Shoot until the magazine is empty. |
| Loadouts | Four slots per operative in pre-mission preparation. Gear stays locked during the mission. Two-handed rifles exclude a melee weapon. The single-use Medkit respects wound caps and stays spent across rooms. |
| Resistance Bunker | USSR, Personnel, Workshop, and Research. One playable region with four existing operations, shared roster and gear, timed recruitment and research, Facility Recon, Emergency Reload, and secured trial rewards. |
| Environment | Destructible light (2 HP) and reinforced (5 HP) cover, plus impervious cover and opaque walls. Ordinary shots do not destroy cover. Area Shred can damage light cover, while Anvil Breach and explosions can damage light and reinforced cover. Targetable fuel and waste barrels, chained explosions, friendly fire, weighted knockback/collision, fire/radiation/shock hazards and status ticks. Hazard durations are currently three rounds. |
| Status samples | Burning and irradiated use two own-phase activations. Shocked lasts one and reduces the next AP refresh. Matching hazard entry is suppressed while its status remains active. These are build-specific rules. |
| AI | Tactical and legacy comparison modes, role-aware movement/firing, hound pressure, support pursuit/healing/buffs, bolder or more defensive profiles, escape movement, and defence-objective targeting. |
| Recovery and room carry-over | A first down takes the operative out for the next two full player turns, then they stand at half HP rounded up. Clearing a room before that brings them back in the transition. The half-HP healing cap and down count carry forward. A second down is permanent. Room transitions reset AP, armour and ability cooldowns. |
| Fixtures | Six selectable fixtures, including the original chain and a Scythe test range for Charge, Wolverine Claws, Spider Agility and Short Blink. Mission objectives include timed radio and conditional reinforcements, final-room escape, destructible or interactive machines, prisoner release, and safehouse waves. See [Missions](MISSIONS.md). |
| Interface and reports | Static pixel-art silhouettes distinguish operatives, Scythe origins and enemy types. Squad tabs, unit and target inspectors, firing-range/LOS overlay, threat preview, ability text, damage ledger, per-room activity snapshots and final reports. Counters include attacks, movement/tiles, damage dealt and taken, ability use, Overwatch, healing/buffs and objective damage. |

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

- Build 10 displays Scythe, Anvil, Needle, Iskra and Alkhimik with their existing prototype kits. [Glaz's control role](CLASSES_AND_ENEMIES.md#confirmed-class-identities) is confirmed design and has no playable slot yet. Scythe's detailed tree is provisional. Build 10 has no progression tree or final class-specific opportunity reactions.
- Broader gear choices and class restrictions, further status and damage-type systems, and logical elevation remain planned. [Game Design](GAME_DESIGN.md#ammunition-and-equipment).
- Assassination retains its three linked rooms and supports extraction between them. The old three-mission trial is retired from the playable menu. Authored branching and strategic PMO effects remain pending.
- The HQ trial implements a limited in-memory campaign state, roster replacement, recovery and research. Disk saves, regional strategy, adaptive doctrine, final art and audio, and release scope remain future work.

## Verification during migration

All preserved prototype archives passed ZIP integrity checks. Build 10 source files match their archive entries byte-for-byte. Godot 4.7.2 launched the original scene headlessly from a disposable copy. A separate one-off runtime harness passed **17 checks** covering initialisation of all five fixtures, a missed-radio clear, room transition and two downs, assassination escape/failure, sabotage activation, rescue interaction/completion, and defence wave scheduling/completion. The harness used direct scenario and state calls. Windows editor import, interactive end-to-end play, UI rendering, and balance remain to be verified. The original `VALIDATION_10.txt` and README accurately record the more limited validation done when Build 10 was originally packaged.

## Windows Build 10 playtest

The 22 November 2026 Windows run exercised all five fixtures through the normal input handlers in a rendered Godot 4.7.2 session. Both radio outcomes, squad carry-over and second-down loss were verified through normal room progression. A follow-up assassination retest confirmed 4/5 defeated on Orlov's escape and 5/5 when he and his guards were killed. [Run details and remaining checks](BUILD_10_PLAYTEST.md).

The pixel-art pass was checked at 1460 × 900 in Godot 4.7.2 on Windows. All five fixtures opened, and all 13 active visual roles were sampled, including the activated sabotage robot. The retained legacy commander also has a distinct sprite. Replays of both radio outcomes and both assassination outcomes matched the recorded mission results and squad carry-over.

A follow-up pass refreshed the cover, walls, barrels, hazards and mission props and added the confirmed first-down rules. Both radio branches were replayed through the original chain. The timed return, healing cap, transition recovery, permanent second down and wipe were verified. [Recovery run details](BUILD_10_PLAYTEST.md#first-down-recovery-and-battlefield-visuals).

The ammunition pass was verified through both branches of the original chain, including magazine refills on each room entry. [Ammunition run details](BUILD_10_PLAYTEST.md#ammunition-and-reload-retest).

The starter loadout was tested in the rendered Windows build. Rifle compatibility, gear locking, melee and Medkit actions, consumable carry-over and both radio branches passed. [Loadout run details](BUILD_10_PLAYTEST.md#starter-loadout-retest).

Fixture 6 was cleared on Windows. Focused checks verified Charge interruption and persistent claw armour loss. Both original-chain branches matched the preceding playtest. [Scythe test range results](BUILD_10_PLAYTEST.md#scythe-test-range).

The Scythe origin pass verified Arachnid movement and Charge range, Blink landing rules and Overwatch, and distinct portraits and battlefield sprites. Wolverine and both original-chain outcomes passed regression checks. [Origin retest](BUILD_10_PLAYTEST.md#scythe-origin-retest).

The 23 November bunker build was checked in a rendered Godot 4.7.2 Windows run. The follow-up played each operation through multiple times and checked Assassination's Room 2 transitions, the prototype terminal and Orlov's escape. [Operation playthroughs and remaining crash investigation](BUILD_10_PLAYTEST.md#bunker-operation-playthroughs).

## Next development priorities

1. Keep the recorded Windows fixture outcomes as the Build 10 regression baseline. Manual pacing and balance assessment remain open.
2. Playtest recovery, reload pacing and starter equipment balance. Add class-specific reactions and further status interactions. Reconcile collision damage in the prototype with the combat spec.
3. Use the objective fixtures to build the first forward-only branching mission with a distinct final PMO, optional gain, failed-SMO pressure, secured rewards, and between-room extraction. Test successful, partial, failed and extracted outcomes.
4. Compare mixed and single-role squads against horde, ranged, protected and support compositions. Tune AI and UI using combat ledgers. Refactor combat and objective logic incrementally around shared rules and regression coverage.
5. Review the HQ trial's progression, economy and attrition before authoring the first full regional campaign. Resolve the open campaign decisions in the [v0.5 register](campaign/H_A_Campaign_Decision_Register_v05.md).

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
