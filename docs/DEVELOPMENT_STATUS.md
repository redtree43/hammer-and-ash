# Development Status

**Current handoff as of 27 November 2026.** Build 10 is the active prototype. The bunker runs four operations and the mission selector offers ten fixtures. The [design specification](design/README.md) governs intended behavior. This handoff records current implementation, verification and known gaps.

**27 November player stats.** Bunker operatives use a shared Level 1 baseline of 12 HP, 4 standard attack damage, 0 armour, 8 tiles of ranged reach and 4 tiles per standard move. Maximum HP increases by 1 each level and stacks with class, origin and Supersuit HP bonuses. Personnel and combat use the same HP calculation. The issued Supersuit adds no stat bonus. [Creator decision](design/CLASSES_AND_ENEMIES.md#level-1-base-stats) · [Verification](IMPLEMENTATION_NOTES.md#level-1-player-stat-verification)

**Bunker class trees.** All six classes use the twelve reviewed origin trees, including Jaguar and Scorpion for Scythe. Personnel uses earned Levels 1–3 by default and offers manual Levels 1–9 for development. Godot 4.7.2 passed 1,015 class checks after HP scaling, including 48 linked-room transitions. [Current class controls and verification](IMPLEMENTATION_NOTES.md#class-review-implementation-preview)

**26 November basic melee update.** Click a reachable enemy with a melee operative to approach and strike for 1 AP total. Use **J** to select the separate fixture melee strike. Hover the target to see the approach and damage preview. [Basic melee rule](design/COMBAT.md#confirmed-rules-and-working-baselines) · [Verification](IMPLEMENTATION_NOTES.md#basic-melee-approach-verification)

**25 November documentation consolidation.** Approved rules now live in the [design specification](design/README.md). [Open decisions](design/OPEN_DECISIONS.md) lists unresolved rules and migration gaps. This pass changed documentation only. The existing Godot 4.7.2 playtest records below still apply to their recorded builds and scenarios.

**26 November Personnel update.** The operative portrait is on the left, the interactive class tree is in the centre, and equipment and effective deployment stats are on the right. Hover any node for its cost, limits and effects. [Design decision](design/CAMPAIGN.md#headquarters-and-personnel) · [Controls and verification](IMPLEMENTATION_NOTES.md#personnel-dossier-verification)

**23 November update.** The prototype opens at the [Resistance Bunker](IMPLEMENTATION_NOTES.md). See the [campaign specification](design/CAMPAIGN.md) for the intended campaign.

The Assassination retest cleared all three bunker rooms with five survivors. The earlier wipe came from escort fire against operatives carrying broken armour and prior downs into Room 3. [Damage trace, escape fixes and clear](BUILD_10_PLAYTEST.md#assassination-wipe-investigation-and-full-clear).

The Workshop places consumable purchases beside the equipment inventory. Research shows Stratagems and Intelligence Operations together with the two playable projects. [Workshop and Research controls and verification](IMPLEMENTATION_NOTES.md).

The USSR tab opens a map of Russia's eight federal districts. The Central Federal District carries the four existing bunker operations as mission pins. [Map controls and verification](IMPLEMENTATION_NOTES.md).

**24 November update.** Sabotage has a first playable battlefield art pass with distinct cover tiers, movement and impact playback, and a pod-opening sequence for the 2×2 Iron Giant. Open **M → 3 → Enter** and use **F4** to switch between the 22×16 facility and the 28×20 annex test. [Visual pass and verification](BUILD_10_PLAYTEST.md#sabotage-visual-pass).

**24 November equipment update.** The active build uses an issued Supersuit and one consumable slot. Bunker base attacks follow class, origin and active form. [Attack roster](design/CLASSES_AND_ENEMIES.md#base-attacks) · [Verification](IMPLEMENTATION_NOTES.md#supersuit-and-base-attack-verification).

**25 November update.** Every combat room opens in a fixed angled 2D view with bounded zoom and pan. The logical square grid still drives combat. Godot 4.7.2 on Windows launched the project through F5. The playtest covered all six fixtures and all four bunker operations, including both versions of Assassination Room 2. [Angled battlefield checks and controls](BUILD_10_PLAYTEST.md#angled-battlefield). The original chain also cleared Room 3 on both radio branches through normal combat and room transitions. [Room 3 regression](BUILD_10_PLAYTEST.md#original-chain-room-3-regression).

**Camera and HUD update.** Combat supports deeper zoom, bounded WASD pan and animated 90-degree pivots through all four orientations. The action buttons sit above End Turn, and the top-right Development dropdown holds the debug options. [Camera and HUD verification](BUILD_10_PLAYTEST.md#camera-and-combat-hud).

**Unit facing and animation update.** Players and enemies now face their resolved steps, leap landings and committed aims. Walk slides, hops and attacks play in order, including reactions. Toggle **Unit facing arrows** in the Development dropdown. [Reproduction and verification](BUILD_10_PLAYTEST.md#unit-facing-and-action-playback).

**Combat interface update.** The battlefield viewport grows from 828 × 580 to 1112 × 668. A single bottom bar holds the squad, operative details and labelled actions. Objectives, contextual previews and End Turn sit beside the map. **Development** contains fixture selection, restart, the ledger, logs and overlay toggles. [Combat HUD verification](BUILD_10_PLAYTEST.md#battlefield-first-combat-hud).

The playable review build includes the Scorpion and Anvil revisions, Drone Command, Jekyll and Hyde, Darwinian’s three specialised forms, Needle’s three-hit Vulnerable mark, and Glaz’s shared Safe Passage. The [origin review sheets](design/ORIGIN_TREES_REVIEW.html) record the design proposals and the [open decisions](design/OPEN_DECISIONS.md#classes-equipment-and-enemies) track pending interaction and balance work.

**Mixed enemy trials and progression.** The four mixed trials field all 24 roster enemies across nine rooms. Press **M**, then **7–9** or **0** and **Enter**. Hover an enemy for its family, tier and kill XP. In bunker operations, surviving operatives earn shared XP from kills and objectives on success or controlled extraction. [Mixed trials](MISSIONS.md#build-10-test-fixtures) · [Progression verification](IMPLEMENTATION_NOTES.md#enemy-tier-and-xp-trial-verification)

## Start from the existing source

- Godot project `source/Hammer_Ash_Godot_2D_Build10/project.godot`, scene `Main.tscn`, gameplay script `scripts/combat.gd`. The project declares Godot 4.7 with GL Compatibility and requires no external art assets.
- The script holds board state, input and drawing, movement and actions, enemy AI, mission setup, events, and damage/activity reporting. Build 10 separates objective, object, trigger and flag data within the script. Some resolution and setup logic still dispatches through scenario-specific code.
- Import the project and run it with F5. Choose **USSR → Central Federal District**, select a mission pin, and choose **Deploy** to prepare five operatives. In combat **X** reloads, **J** aims melee, **K** aims the medkit, and **G** uses a prepared Emergency Reload. **Enter** advances Assassination's cleared rooms and **E** extracts between them. **F9** returns to the bunker from the combat report.
- Unchanged historical archives live in `prototypes/`. The two files for every build label are byte-identical and both original names are preserved. `references/` contains the original docs and prototype/AI screenshots, along with one class-style inspiration reference. The reference image is separate from the game's asset pipeline.

## Implemented prototype systems

| System | Build 10 |
| --- | --- |
| Combat | Fixed 2D board, five operatives, selectable units, AP economy, eight-direction movement for both sides with square-footprint support, melee and ranged base attacks, special attacks, directional shared-edge cover, LOS, damage/armour previews, phase armour refresh, and reserved Overwatch. |
| Ranged resources | Sightline, Arc Pistol and Suit Cannon use three charges and recharge for 1 AP. Enemy firearms and regression kits retain three-round magazines. Both refill on room entry. |
| Loadouts | Each operative receives a Supersuit and can pack one consumable. Gear locks at deployment. The single-use Medkit respects wound caps and stays spent across rooms. |
| Resistance Bunker | USSR, Personnel, Workshop, and Research. Eight district maps, four playable operations in the Central Federal District, shared roster and gear, timed recruitment and research, Facility Recon, Emergency Reload, and secured trial rewards. |
| Environment | Destructible light (2 HP) and reinforced (5 HP) cover, plus impervious cover and opaque walls. Ordinary shots do not destroy cover. Area Shred can damage light cover, while Anvil Breach and explosions can damage light and reinforced cover. Targetable fuel and waste barrels, chained explosions, friendly fire, weighted knockback/collision, fire/radiation/shock hazards and status ticks. Hazard durations are currently three rounds. |
| Status samples | Burning, Irradiated and Bleeding use two own-phase ticks. Irradiated and Bleeding each deal 1 direct HP damage per tick, bypassing armour and barriers. Shocked reduces the next AP refresh by 1. Blinded applies −2 basic attack damage until the end of the affected faction's phase, with a minimum of zero damage. Blinded and Bleeding are implemented with provisional timing and await an authored application source. Matching hazard entry is suppressed while its status remains active. [Confirmed effects and open tuning](design/COMBAT.md#status-effects) |
| AI | Tactical and legacy comparison modes, role-aware movement/firing, hound pressure, support pursuit/healing/buffs, bolder or more defensive profiles, escape movement, and defence-objective targeting. |
| Recovery and room carry-over | A first down takes the operative out for the next two full player turns, then they stand at half HP rounded up. Clearing a room before that brings them back in the transition. The half-HP healing cap and down count carry forward. A second down is permanent. Room transitions reset AP, armour and ability cooldowns. |
| Fixtures | Ten selectable fixtures, including four mixed enemy trials, the original chain and a Scythe test range for Charge, Wolverine Claws, Spider Agility and Short Blink. Mission objectives include timed radio and conditional reinforcements, final-room escape, destructible or interactive machines, prisoner release, and safehouse waves. See [Missions](MISSIONS.md). |
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

- Build 10 counts a diagonal as one tile for bunker player attacks. Enemy and legacy fixture shot range still adds row and column distances. Ordinary shot checks use the attacker’s and target’s anchor tiles. The confirmed design uses the larger distance, so a diagonal counts as one tile. Multi-tile units can fire from or be targeted at any occupied tile that gives a legal shot. [Shot range and targeting](design/COMBAT.md#confirmed-rules-and-working-baselines)
- Build 10 reserves Overwatch on the unit and checks shots on eligible steps. The intended redesign uses a set, visible area. Detailed mechanics are deferred. [Overwatch rules](design/COMBAT.md#overwatch)
- Build 10 carries reductions to maximum armour across linked bunker rooms, which matches the revised design. The design also allows classes and Supersuits to prevent those reductions. Eligibility awaits class and Supersuit specifications. [Armour rules](design/COMBAT.md#confirmed-rules-and-working-baselines)
- Build 10 uses an untyped damage value and handles exceptions in individual effects, such as the prototype robot’s poison immunity. The revised design uses one damage value. The replacement for the former type-based resistance model remains open. [Damage resolution](design/COMBAT.md#damage-resolution)
- Build 10 can bypass a set number of armour points. The confirmed design makes piercing bypass all armour for the hit. [Armour piercing](design/COMBAT.md#armour-piercing)
- Build 10 normally reduces ranged damage by one point through half cover and two points through full cover. The confirmed design makes full cover block ordinary ranged shots from its protected angle and uses a flat reduction for half cover. The half-cover amount remains open for tuning. [Cover rule](design/COMBAT.md#confirmed-rules-and-working-baselines)
- Build 10 resolves class blast hits before damaging cover and processes cover first for barrel explosions. The design resolves unit hits with the existing protection before applying the same attack’s cover damage. [Cover damage order](design/COMBAT.md#confirmed-rules-and-working-baselines)
- Build 10 requires exactly five ready operatives to deploy from HQ. The confirmed design allows a short squad when only one to four operatives are ready. It provides an emergency recruit if nobody survives and the player cannot afford ordinary recruitment. [Deployment rules](design/CAMPAIGN.md#headquarters-and-personnel)
- Build 10 uses campaign days to complete research, recruitment and operative recovery. The confirmed design shows days for immersion. Research unlocks and HQ recruits become ready immediately once the player meets their requirements and commits the resources. Wounded operatives recover through operations they sit out or the player skips. [Campaign structure](design/CAMPAIGN.md#confirmed-campaign-structure) · [Recruitment and recovery](design/CAMPAIGN.md#headquarters-and-personnel) · [Research rules](design/CAMPAIGN.md#economy-workshop-and-research)
- Build 10 lets the squad extract between cleared Assassination rooms and awards Sabotage and Rescue trial rewards on successful completion. The confirmed design defines and displays a securing condition for each reward-bearing objective so a secured reward can survive early extraction even when the overall mission is lost. This reward path has yet to be exercised in the prototype. [Secured rewards](design/MISSIONS.md#secured-rewards)
- Build 10 shows Stratagems and Intelligence Operations on the Research screen. The confirmed design adds Workshop recipe research there and keeps consumable manufacturing on the Workshop screen. Recipe research is still pending in the prototype. [Campaign specification](design/CAMPAIGN.md#economy-workshop-and-research)
- Build 10 adds 1 damage when barrel knockback is blocked. The confirmed design stops a blocked push and deals impact damage only when specified by the ability or hazard. The 25 November decision was recorded without changing the build. [Collision rule](design/COMBAT.md#collision-and-displacement)
- Build 10 assigns charges to Sightline, Arc Pistol and Suit Cannon. Review final attack assignments, capacity, recharge and room-entry refills.
- Bunker operations trial earned Levels 1–3 and offer manual builds through Level 9. Campaign XP pacing beyond Level 3 and combat balance remain open. The original selector fixtures retain their legacy kits, including Wolverine, Arachnid and Blink in fixture 6.
- Build 10 issues one standard Supersuit and gives each operative one consumable slot. The design calls for equippable, class-restricted variants with ability or stat changes. Higher-tier suits are acquired separately, and class or Supersuit can change consumable capacity. [Equipment rules](design/COMBAT.md#equipment)
- Further status rules remain open. Build 10 renders an angled view over a flat combat grid. The design calls for logical elevation that affects shot geometry and gives eligible ranged attacks a range bonus. The amount and geometry rules still need details. [Open decisions](design/OPEN_DECISIONS.md) · [Elevation rule](design/COMBAT.md#elevation)
- Assassination retains its three linked rooms and supports extraction between them. The old three-mission trial is retired from the playable menu. Authored branching and strategic PMO effects remain pending.
- The HQ trial implements a limited in-memory campaign state, roster replacement, recovery and research. Build 10 shows eight districts and four prototype operations in Central. The campaign design counts the other seven districts toward liberation and lockouts. Four liberations unlock the Moscow finale in Central. Four district lockouts or a second loss to the Politburo ends the campaign in defeat. Build 10 has yet to implement those rules. Disk saves, regional strategy, adaptive doctrine, final art and audio, and release scope remain future work. [Campaign specification](design/CAMPAIGN.md#victory-defeat-and-soviet-response)

## Verification during migration

At migration, all preserved prototype archives passed ZIP integrity checks and the initial extracted Build 10 source matched the archived entries byte-for-byte. Godot 4.7.2 launched the original scene headlessly from a disposable copy. A separate harness passed **17 checks** using direct calls for the original five fixtures and their key objective and room-transition outcomes. The Windows checks below and the current playtest log cover later changes. `VALIDATION_10.txt` records the checks from the original packaging.

## Windows Build 10 playtest

**26 November status review.** Godot 4.7.2 on Windows launched Build 10 from the editor with **F5**. A focused run passed 16 checks for radiation entry, direct HP ticks through armour and barriers, downing, Blinded previews and basic attack resolution, and effect expiry. Blinded and Bleeding were injected for the checks pending authored sources. A separate input-driven regression passed 33 checks, opening fixtures **1–6** through **M** and exercising both radio outcomes with staged combat and normal room transitions. It confirmed HP carry-over and the zero- or three-hound Room 3 lineups. [Status decisions and remaining tuning](design/COMBAT.md#status-effects)

The 22 November 2026 Windows run exercised all five fixtures through the normal input handlers in a rendered Godot 4.7.2 session. Both radio outcomes, squad carry-over and second-down loss were verified through normal room progression. A follow-up assassination retest confirmed 4/5 defeated on Orlov's escape and 5/5 when he and his guards were killed. [Run details and remaining checks](BUILD_10_PLAYTEST.md).

The pixel-art pass was checked at 1460 × 900 in Godot 4.7.2 on Windows. All five fixtures opened, and all 13 active visual roles were sampled, including the activated sabotage robot. The retained legacy commander also has a distinct sprite. Replays of both radio outcomes and both assassination outcomes matched the recorded mission results and squad carry-over.

A follow-up pass refreshed the cover, walls, barrels, hazards and mission props and added the confirmed first-down rules. Both radio branches were replayed through the original chain. The timed return, healing cap, transition recovery, permanent second down and wipe were verified. [Recovery run details](BUILD_10_PLAYTEST.md#first-down-recovery-and-battlefield-visuals).

The ammunition pass was verified through both branches of the original chain, including magazine refills on each room entry. [Ammunition run details](BUILD_10_PLAYTEST.md#ammunition-and-reload-retest).

The starter loadout was tested in the rendered Windows build. Rifle compatibility, gear locking, melee and Medkit actions, consumable carry-over and both radio branches passed. [Loadout run details](BUILD_10_PLAYTEST.md#starter-loadout-retest).

Fixture 6 was cleared on Windows. Focused checks verified Charge interruption and persistent claw armour loss. Both original-chain branches matched the preceding playtest. [Scythe test range results](BUILD_10_PLAYTEST.md#scythe-test-range).

The Scythe origin pass verified Arachnid movement and Charge range, Blink landing rules and Overwatch, and distinct portraits and battlefield sprites. Wolverine and both original-chain outcomes passed regression checks. [Origin retest](BUILD_10_PLAYTEST.md#scythe-origin-retest).

The 23 November bunker build was checked in a rendered Godot 4.7.2 Windows run. The follow-up played each operation through multiple times and checked Assassination's Room 2 transitions, the prototype terminal and Orlov's escape. [Operation playthroughs and remaining crash investigation](BUILD_10_PLAYTEST.md#bunker-operation-playthroughs).

The diagonal movement pass checked both factions and 2×2 through 4×4 footprints in Godot 4.7.2 on Windows. Both original-chain radio branches and HP carry-over passed in an accelerated, input-driven run. [Movement verification](BUILD_10_PLAYTEST.md#diagonal-movement-and-square-footprints).

## Next development priorities

1. Keep the recorded Windows fixture outcomes as the Build 10 regression baseline. Manual pacing and balance assessment remain open.
2. Playtest recovery, ranged charge pacing and Supersuit balance. Add class-specific reactions and further status interactions. The approved collision rule is tracked above as an implementation gap.
3. Use the objective fixtures to test forward-only branching with a distinct final PMO, optional gain, failed-SMO pressure, secured rewards, and between-room extraction. Test successful, partial, failed and extracted outcomes. Build 10 missions are test content and production mission selection remains open. [Prototype mission scope](design/MISSIONS.md#prototype-mission-scope)
4. Compare mixed and single-role squads against horde, ranged, protected and support compositions. Tune AI and UI using combat ledgers. Refactor combat and objective logic incrementally around shared rules and regression coverage.
5. Review the HQ trial's progression, economy and attrition before authoring the first full regional campaign. Resolve remaining campaign decisions in the [current register](design/OPEN_DECISIONS.md#campaign-and-headquarters).

The priorities above are proposed sequencing for the next development pass. [Open decisions](design/OPEN_DECISIONS.md) tracks remaining rules, deferred redesigns, content and verification after the 25 November review.

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

For the current authority rules, see [docs/design/](design/README.md).
