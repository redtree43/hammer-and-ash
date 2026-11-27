# Resistance Bunker playtest

Run `source/Hammer_Ash_Godot_2D_Build10/project.godot` in Godot and press **F5**. The game opens on **USSR** in the bunker. Open a district, select a site and choose **Deploy** to prepare the squad. For the original regression chain, use **M → 1 → Enter** from the bunker. **F9** returns from the regression selector or a campaign report.

| Area | Playtest |
| --- | --- |
| USSR | Click any of the seven open districts on the map or in the list. Choose a patrol, relay, rescue or sweep from its map pin or mission list. **Deploy** opens squad preparation and **Intel Op** opens Facility Recon. Moscow is locked. |
| Squad loadout | Select five ready operatives. **Gear & build** opens an operative's equipment and class tree. Choose a consumable, an origin, **Earned** or a manual level from 1–9, and the unlocked ability choices. **Reset to Personnel** restores the operative's build defaults. Medkit selections share Workshop stock. |
| Personnel | Choose an operative with the roster picker and sort by Type or Name. The portrait is on the left, the class tree is in the centre, and the issued Supersuit, default consumable and current stats are on the right. Hover any ability node for its details. **Dev level → Earned** uses the operative’s earned level. Levels 1–9 are available for manual builds. A deployment with a manual level pauses campaign XP. |
| Workshop | Purchase individual Medkits or a batch. Inventory shows the issued Supersuit and live Medkit stock. Relay success grants 6 Supplies and 2 Intel. Rescue success grants a Needle recruit and 4 Supplies. |
| Research | Browse **Stratagems** and **Intelligence Operations** side by side. Click an available project card to start research and use **Debug: Advance Day** to complete it after two days. Each board has 24 slots from the layout reference, with one live project per board. Select Emergency Reload in squad preparation. Buy Facility Recon from the mission briefing or squad preparation after completing its research. |
| Combat | Use **G** to refill the selected ranged operative's charges once per operation after preparing Emergency Reload. It costs 3 Intel on use and spends no AP. Facility Recon costs 2 Intel and previews that operation's existing objectives and events. **F9** returns to the bunker from the report. |

Campaign state lasts for the running session. Use **Enter** after clearing a sweep room to advance or **E** to extract. Generator and rescue objectives secure their trial rewards on mission success. Personnel and combat derive stats from the same player baseline.

## 27 November checkpoint verification

Godot 4.7.2 on Windows passed 1,129 headless class checks across 384 builds, 420 briefing checks across all 28 sites, and 37 deployment checks through the Southern Federal District’s Floodplain Sweep. The original-chain driver passed 21 headless checks using **M → 1 → Enter**, staged fights and normal room transitions. It verified wounded HP carry-over and both the baseline and three-extra-hound Room 3 lineups. The rendered checks in the sections below describe their recorded runs.

## 27 November deployment build verification

Squad preparation uses the [regional playtest deployment rules](design/CAMPAIGN.md#regional-campaign-playtest). Operatives start with their Personnel builds. Preparation can override level, origin, unlocked ability choices and the Darwinian starting form for one operation. The chosen build carries through linked rooms. Any manual level pauses campaign XP for the squad.

Godot 4.7.2 on Windows passed 37 deployment checks headlessly and in standalone GL Compatibility at 1460 × 900. The run used **USSR → Southern Federal District → Floodplain Sweep**, deployed a Level 9 Scorpion alongside Level 3 and Level 1 operatives, and verified the chosen capstone on the combat HUD, build and HP carry-over through **Enter**, reset to Personnel and the XP pause. The headless briefing suite passed 420 checks across all 28 sites, and the class matrix passed 1,129 checks across 384 builds. The rendered fixture 1 regression passed 21 checks for both radio outcomes and HP carry-over with staged fights.

The editor imported the active project, then reported a safe-save error. Window activation timed out on both attempts, so the rendered runs launched from the command line. Manual small-window readability remains open.

## 27 November combat HUD and Escape verification

The [presentation specification](design/VISION.md#confirmed-presentation-baseline) records the placement from the creator's Smelter Relay markup. The unit cards stack on the left, and yellow action icons start at the lower left. The panel below shows the hovered or armed action's AP cost and details while the right panel shows target and movement previews. Escape dismisses the active overlay, cancels targeting or returns to the prior HQ screen.

Godot 4.7.2 on Windows passed 57 input-driven checks in a rendered standalone run. The run deployed to Ural's Smelter Relay through USSR and checked squad selection, hover details, Overwatch and class cancellation, and Escape through the briefing, loadout and overlays. Fixture 1 opened through **M → 1 → Enter**. With staged fights and normal room transitions, HP carried forward on both radio branches and the alert added exactly three hounds. The class matrix passed 1,129 checks across 384 builds. The editor reported a safe-save error, so this verification used the standalone run. Small-window and advanced-build readability remain open for playtesting.

## 27 November combat presentation pass

[Vision and presentation](design/VISION.md#confirmed-presentation-baseline) governs the visual pass. Ground tiles use cached pixel textures and operation-specific palettes. Walls, shared cover and objective props have raised silhouettes. Movement, elevation, hazard and Overwatch indicators remain on the tactical grid. Animated hazards and the Iskra drone use the same camera projection as the board.

The action queue drives facing, footfalls, leaps, blinks, lunges, recoil and hit reactions. Ranged, melee and support effects use shared visual families with distinct timing and shapes. Resolved attacks still use their existing AP, damage and cover rules. The preview harness rendered sampled effects at fixed time steps. It also deployed to Ural’s Smelter Relay through the USSR screens and used the combat HUD and tile clicks to fire Breach Shell at a staged cover edge.

Godot 4.7.2 on Windows loaded the bunker through **F5**. The class matrix passed 1,129 checks across 384 builds. The Iskra HUD run passed 24 checks across relay and sweep deployments for Artillery, Assault and Guardian. Fixture 1 passed 21 input-driven checks with staged fights, including linked-room HP carry-over and both radio outcomes. The GL Compatibility runs used ANGLE, which logged shader initialization messages. Full manual pacing and readability across the remaining layouts are playtest items. [Presentation review](design/OPEN_DECISIONS.md#presentation-production-and-evidence)

## Full campaign balance verification

On 27 November 2026, Godot 4.7.2 imported and launched with **F5**. The campaign driver completed all 28 sites through normal controls, including each of the twelve origins as lead in two full sweeps at Levels 3 and 9. Enemy movement and class-action room completion regressions passed. The rendered Ural relay repeat completed under ANGLE despite shader initialization messages. The balance record contains the baseline counts and limitations. [Full campaign playtest](BUILD_10_PLAYTEST.md#27-november-full-campaign-balance-playtest)

## Full-cover verification

On 27 November 2026, Godot 4.7.2 imported Build 10 and launched it from the editor with **F5**. A shared directional cover check governs ordinary direct ranged targeting and execution, including Overwatch and drone shots. Shot previews, AI target selection, and the legality check for Taunt use the same protection. Destroying the edge reopens the protected lane immediately. Half cover and explicit bypass rules retain their own resolution.

The headless class matrix passed 1,128 checks across 384 builds. The **M → 1 → Enter** fixture passed 23 checks including linked rooms and both radio outcomes. The campaign rerun cleared all 56 operations and 114 rooms, with 58 linked transitions. The rendered GL Compatibility repeat cleared both Ural relay passes and logged ANGLE shader initialization messages. [Combat rule](design/COMBAT.md#confirmed-rules-and-working-baselines) · [Matched results and remaining balance checks](BUILD_10_PLAYTEST.md#27-november-full-cover-campaign-retest)

### Shot-cost follow-up

The 27 November follow-up allows an otherwise legal shot into full cover to resolve for zero damage at its normal AP and ammo cost. Targeting warns before committing. Enemy direct-fire planning prefers shots that can hit, while an eligible Overwatch shot into a covered tile spends its shot budget. Named ranged powers and drone orders spend their normal resources and the blocked hit applies no status.

Godot 4.7.2 launched through **F5**. The class matrix passed 1,129 checks across 384 builds, including the normal board click, Needle Beam, and Overwatch against operatives and drones. The rendered original chain passed 21 checks including both radio outcomes. The four-site difficulty comparison used three uniform squad levels and cleared all 12 operations. [Level and formation check](BUILD_10_PLAYTEST.md#27-november-shot-cost-and-level-check)

## Sweep formation verification

On 27 November 2026, Godot 4.7.2 on Windows ran all seven sweep lineups in the active project and in a copy with the earlier formations. The paired manual-level runs matched squad members, class builds and approach-room outcomes. All 70 operations cleared, with 140 linked transitions and no carry mismatch. The editor launched the trial through **F5**. The class matrix passed 1,129 checks over 384 builds, and the rendered original chain passed 21 checks including both radio outcomes. [Sweep formation comparison](BUILD_10_PLAYTEST.md#27-november-sweep-formation-comparison)

### Northwestern and Volga squad retest

Godot 4.7.2 on Windows reran the stronger lineups at both sites with fire-support and close-control squads at five levels. All 20 main runs cleared through normal tactical inputs, with 40 linked-room transitions and no carry mismatch. Build 10 launched from the editor with **F5**. Two additional Level 5 runs in OpenGL Compatibility reproduced the headless casualty and HP outcomes. [Retest and minimum-level recommendations](BUILD_10_PLAYTEST.md#27-november-northwestern-and-volga-squad-retest)

The 27 November briefing follow-up added the approved advisory minimums. A rendered Godot 4.7.2 run at 1460 × 900 passed 35 checks. It displayed both recommendations, deployed five Level 1 operatives through each briefing and checked the generic Southern sweep briefing. The original chain passed 21 checks, including both radio outcomes. [Briefing decision](design/MISSIONS.md#regional-playtest-operations)

### Remaining five sweep briefings

Godot 4.7.2 on Windows ran 50 new sweeps at the five requested levels. Forty-nine cleared, and all 100 room transitions preserved squad state. Build 10 launched through **F5**. A rendered 1460 × 900 check passed all 110 assertions. It verified the recommendations and deployed five Level 1 operatives at each of the seven sweep sites. The original chain passed all 21 checks, including both radio outcomes. [Retest and recommendations](BUILD_10_PLAYTEST.md#27-november-remaining-five-sweep-retests)

### Patrol, relay and rescue briefings

Godot 4.7.2 on Windows completed 210 runs across all 21 one-room sites, with two compositions at each of the five manual levels. All runs cleared. The relay and rescue results verified objective completion. Build 10 launched through **F5**. A rendered 1460 × 900 check passed all 420 assertions, including briefing text and normal Level 1 deployment at all 28 campaign sites. The original chain passed all 21 checks, including both radio outcomes. [Results and recommendations](BUILD_10_PLAYTEST.md#27-november-patrol-relay-and-rescue-retest)

## Regional campaign verification

On 27 November 2026, Godot 4.7.2 on Windows opened the imported build through **F5**. The USSR screen showed seven available districts and locked Moscow. The Northwestern district displayed four selectable map pins and four briefing entries.

A separate rendered GL Compatibility run using ANGLE passed 1,638 checks. It exercised all 28 deployments from HQ, all 42 rooms and the opening enemy turn of every operation. The run checked spawn locations, objective access, high cover, all 24 approved enemies and the 14 rooms with high ground. A Hawk Wings Needle walked onto an authored relay platform via a board click and gained High Perch at the start of the next player round.

Staged clears exercised generator attacks, adjacent prisoner interactions, rewards, XP and debriefs, return to HQ, linked-room HP carry-over and controlled extraction. The original **M → 1 → Enter** regression retained HP through both radio branches and fielded zero or three extra hounds in Room 3. The existing class matrix passed 1,048 checks after moving its linked-room coverage to the Southern sweep. Full mission playthroughs and balance tuning across roster levels remain open. [Regional operations](design/MISSIONS.md#regional-playtest-operations)

## 27 November checkpoint verification

Godot 4.7.2 reran the headless class matrix against the checkpoint. All 1,015 checks passed across 384 builds, including 48 staged linked-room transitions. See the sections below for the earlier rendered runs and fixture regression results.

## Level 1 player stat verification

**27 November maximum HP progression.** After the creator reported that HP stayed at 12 in Personnel, the shared HP calculation now adds one per level after Level 1, each unlocked node’s `max_hp_bonus` if present and the equipped Supersuit’s HP bonus. The issued suit grants zero. Personnel displays **Max HP**. Fresh bunker deployments start at that maximum, and linked rooms retain current HP and wounds. [Creator decision](design/CLASSES_AND_ENEMIES.md#level-1-base-stats)

Godot 4.7.2 on Windows imported the project. The 242-check Personnel run covered Levels 1–9 across all twelve origins and returning from the Dev level override to the earned level. The 30-check Rescue run confirmed that Level 8 Steel Skin displayed 19 max HP and deployed at 19/19, with the expected armour and movement bonuses. That run passed headlessly and under rendered GL Compatibility with ANGLE. The rendered run logged shader initialization errors before completing. Godot’s Project Manager did not retain focus for the editor launch, so the rendered run used the command line. The 1,015-check class matrix confirmed HP bonus stacking and wounded HP with level-scaled maxima through 48 linked-room transitions. The 33-check fixture regression passed for **M → 1–6** and both original-chain radio branches.

On 27 November 2026, Godot 4.7.2 on Windows imported the active project and launched via **F5**. Personnel showed Jaguar with 12 HP, 0 armour, 4 basic damage and 5 tiles of movement after Rosette Claws. Personnel now accepts reviewed origins without a separate identity description. The [creator’s baseline](design/CLASSES_AND_ENEMIES.md#level-1-base-stats) applies to bunker operatives. Regression fixtures continue to use authored kits. The issued Supersuit has no separate stat modifier. [Variant rules](design/COMBAT.md#equipment)

The headless class matrix passed 942 checks across all twelve origins, including 48 linked-room transitions. A separate 26-check input-driven Rescue run compared Personnel with deployed stats, checked ranged previews at eight and nine tiles, and used board clicks to verify damage and a four-tile standard move. The 33-check fixture regression opened **M → 1–6**, then used staged targets, normal attacks and **Enter** to clear both original-chain branches. It confirmed HP carry-over and zero or three alert hounds in Room 3. Full mission balance with the new stats remains open.

## 27 November Scythe, Anvil and Needle revisions

The new abilities are available through Personnel and the combat action bar. Rake previews selected tiles. Venom Jet and Gleaming Armour use a directional cone. Throw previews its flight path and stops at the first enemy or destructible cover collision. Strike and Drop takes separate choices for the Hawk landing and adjacent enemy landing. Anvil can use Lend Armour starting at Level 1. Both new low-cover effects protect from every direction and use the regular ranged damage reduction.

Godot 4.7.2 imported Build 10 and launched from the editor with **F5**. The class matrix passed 1,048 headless and rendered assertions across all twelve origins and 384 builds, including 48 staged linked-room transitions. New effect checks exercised the melee reaction cap, three-tile Rake, Throw collisions, Linebreaker, Colossal Combo’s strike order, mantle cover and expiry, owner-only designation, Blind for three turns, Sweep Beam cover destruction and both manual Hawk flight landings. High Perch passed with a staged elevation tile. The current maps remain flat by creator decision.

The rendered fixture suite passed all 33 checks with **M → 1–6** and both radio outcomes. Wounded HP carried forward and the missed radio added three hounds. The ANGLE runs reported shader initialization errors at startup and completed their assertions. Full encounter balance with the revised nodes remains open. [Creator decisions](design/CLASSES_AND_ENEMIES.md#27-november-class-update)

## 27 November Iskra playtest

Godot 4.7.2 on Windows imported Build 10 and launched with **F5**. The class matrix passed 1,080 checks across 384 builds and twelve origins, including 48 staged linked-room transitions. The Iskra checks exercised Assault’s flanking disruption and chain targeting, Guardian’s directed cover and ally protection, remote breaching, drone Overwatch, drone wounds and destruction across rooms, and Emergency Rebuild. Artillery checks covered Anchor and Quick-Lock, heavy fire and Heat limits, basic cannon fire at full Heat, cover destruction and follow-up shots, Flak Curtain entry, Incendiary Shell and both capstones.

An additional 24 input-driven checks deployed Assault and Guardian into **Freight Yard Sweep** and Artillery into **Dockside Relay** through the USSR campaign UI. The checks used the combat action bar and board clicks with staged targets. Both drone chassis stayed destroyed after a normal **Enter** transition. The active **M → 1** regression fixture passed 23 checks, including wounded HP carry-over and both radio outcomes of zero or three hounds.

The class matrix and HUD checks passed headlessly and in rendered GL Compatibility with ANGLE. The rendered runs logged shader initialization errors at startup and completed their assertions. Full encounter balance and repeated mission outcomes remain open. [Approved Iskra redesign](design/CLASSES_AND_ENEMIES.md#27-november-iskra-redesign)

## 27 November Glaz and Alkhimik verification

Godot 4.7.2 on Windows imported Build 10 and launched with **F5**. The class matrix passed 1,109 checks in headless and rendered GL Compatibility runs across all twelve origins, 384 builds and 48 staged room transitions. The rendered run reported ANGLE shader initialization errors at startup and completed the checks.

The four origins passed 25 additional HUD checks. The driver deployed each from the USSR map into **Freight Yard Sweep**, exercised combat via the action bar and board clicks, and advanced through **Enter** after staged room clears. Glaz’s optional suppression and push actions appeared after their basic attacks. Darwinian’s Shift action appeared in the HUD and the selected form carried forward. Hyde’s Hurl Aside damaged both units in a collision. Entering the next room restored Jekyll and applied the recovery AP penalty.

The active **M → 1** fixture passed 23 checks, including both radio outcomes and wounded HP carry-over. These verification runs used scripted combat setups. Full encounter balance remains open. [Design rules](design/CLASSES_AND_ENEMIES.md#27-november-glaz-and-alkhimik-implementation)

## Class review implementation preview

### 26 November branch and capstone matrix

Godot 4.7.2 on Windows passed 894 assertions headlessly and in rendered GL Compatibility using ANGLE. The matrix checked all 384 Level 9 builds across the twelve origins. Two complementary builds per origin deployed in staged Assassination rooms, exercising 94 active nodes and 50 branch passives across the twelve origins. All 24 capstone choices received effect checks. Each deployed build passed through Rooms 2 and 3, for 48 transitions. The transition checks covered the selected build, HP, spent consumables, maximum armour loss, room and operation use limits, Darwinian form, Hyde recovery, and permanent drone loss. They also checked that Emergency Rebuild and Burrow Defense stay spent after room entry. These were controlled gameplay checks with staged clears and targets. They did not measure whole-campaign difficulty. The 57-check HUD and departure-reaction suite and 33-check fixture regression also passed.

The matrix exposed three defects. Rake rejected diagonal adjacency because review powers used Manhattan distance. The bunker player range preview and class targeting now count diagonals as one tile. Guardian Overclock's second facing used an incomplete plan dictionary and now resolves both lines. Rampage now accepts the operative’s own tile to skip the follow-up. Quarry refresh now transfers ownership to the latest Needle and clears that owner when the three-hit pool expires.

Balance observations from the staged tests. Colossal Combo delivered 9 damage for 2 AP against an unarmoured target before any Quarry bonuses, so watch repeated elite removal every other turn. Siege Salvo dealt 5 damage to the target in isolation and 7 when nearby authored barrels chained into it, making its payoff sensitive to map layout. Field Hospital healed the severely wounded test patient for 4 HP with Clinical Eye and added 2 temporary armour, so compare carry-over survival with and without that capstone. The new Quarry refresh can extend an entire squad's damage window when two Needles stagger their marks, even though only three hits are available at once.

Run the matrix from the Godot project with `godot --headless --path . --script res://tests/full_class_playtest.gd`. For the rendered Windows check, run the same script using GL Compatibility with `--rendering-driver opengl3_angle`.

### 26 November class completion playtest

Godot 4.7.2 on Windows passed 57 checks headlessly and in rendered GL Compatibility on ANGLE. Each origin deployed in bunker Assassination with a staged board state, and its representative ability resolved through the action bar and board clicks. Separate checks passed for all twelve unlock paths, Vulnerable's hit count, drone carry-over and Hyde recovery. The 33-check fixture suite passed with both original-chain radio outcomes and wounded HP carry-over.

| Origin | Passed | Changes exercised or added in this pass |
| --- | --- | --- |
| Jaguar | 2 AP Charge, Slipping Guard and its own departure reaction | Charge advances movement budget without moving or attacking. Slipping Guard blocks the marked enemy's first departure attack. Rosette Rush takes manually selected landings and targets. |
| Scorpion | Venom Jet and the same 2 AP Charge | Stronger Poison extends Venom by one tick. |
| Steel Skin | Taunt | Colossal Combo was incorrectly tagged passive and is now a 2 AP active with CD2. Throw takes a manually selected landing. |
| Psionic Armour | Lend Armour and selected Mantle Recall | Recall spends the chosen patient's protection on a direct hit. Lend tracks unused returned armour. Sanctuary takes manual allocations. |
| Eye Powers | Designate Quarry and Vulnerable expiry | Afterglow can fire its qualifying follow-up at zero charges. |
| Hawk Wings | Fly, Silent Landing, Pinion Guard and its own departure reaction | Silent Landing blocks the marked enemy's first departure attack after flight and a hit. Pinion Guard applies the flat reduction. |
| Drone Command | Chain Arc hits exactly the two selected enemies | Chain and Overclock accept manual link targets. Guardian Overclock accepts separate facings and protection targets. |
| Artillery Suit | Mortar Cup and Heat Jacket | Heat Jacket affects direct hits only. Hot Breech snapshots heat for the whole attack. |
| Darwinian | Tongue Vault with optional pull selection | Mosaic Body takes an ordered pair of forms with manual targets. Quick Adaptation, Form Mastery and Reflex Shift have combat hooks. |
| Jekyll / Hyde | Adrenal Rescue and early reversion | Rescue takes a destination. Field Hospital takes initial selections and later patients can be chosen with Treat Patient. Fixed the 2 AP costs on prefixed ability descriptions. |
| Telepathy | Aphasia | Phantom Threat now filters enemy targeting. Empathic Echo can reward a squadmate follow-up. |
| Telekinesis | Vector Pull | Hurl Debris takes a specific cover edge, Wrecking Ball takes a direction, and Counterweight lets the player pick the ally and landing. |

The departure tests staged an actual basic melee hit and a legal walk away. Both passives blocked the first enemy reaction. A later departure triggered it, a third did not retrigger it in the same round, and the player could react to the enemy leaving.

Mantle Recall is armed by choosing a patient during the player phase. Glaz's Residual Distortion and several other optional follow-ups use a free action rather than pausing an attack or enemy turn. The later [branch and capstone matrix](#26-november-branch-and-capstone-matrix) extended coverage. Campaign balance playthroughs remain open. The imported editor was detected, but Windows activation timed out twice, so editor F5 was not verified. The rendered gameplay run launched directly with ANGLE and completed despite shader initialization warnings.

Personnel shows the twelve origin trees from the current design review. Level 1 grants both nodes. Use the earned level or pick a development level. Choose one node at each unlocked fork at Levels 2, 3, 5, 6 and 9. Changing origin clears the previous origin's node choices. Jaguar and Jekyll / Hyde reuse their previous portrait assets. The bunker operation deployment stores the selected build. The M-menu fixtures use their original kits.

The action bar uses the new class nodes and exposes form actions, drone orders and suit venting when available. Jaguar and Scorpion share the same movement-only Charge. Needle's designation adds direct HP damage to three hits. The drone's HP and destruction carry between rooms. Hyde transforms once per room and returns to Jekyll with reduced AP, including on a linked-room transition if the room ends while transformed.

The spec remains the reference for intended behavior and any open interaction or tuning. [Origin trees](design/ORIGIN_TREES_REVIEW.html) · [Open decisions](design/OPEN_DECISIONS.md)

Godot 4.7.2 on Windows passed 32 focused checks headlessly and in a rendered GL Compatibility run using ANGLE. Checks covered all twelve unlock paths, two bunker Assassination deployments, core action listings, three-hit direct HP Vulnerable, drone destruction carry-over data and Hyde's early reversion. The input-driven headless chain regression passed 33 checks across fixtures 1–6, including normal progress through both radio outcomes and wounded HP carry-over. The default native OpenGL run reported shader initialization errors and crashed in the Intel graphics driver. The headless editor import reported a local safe-save warning and completed its scan. Editor F5, complete origin-by-origin gameplay and balance verification remain pending.

## V3 player classes

The following notes describe the earlier V3 playtest baseline.

1. Open **Personnel**, choose an operative, then set **Origin** and **Playtest level** above the tree. At Levels 4 and 5, click either node to choose it once that level is unlocked. Active abilities use square-cornered nodes and passive abilities use rounded nodes. Locked nodes and unselected alternatives are grey and remain inspectable on hover. Recruits start at Level 1.
2. Open **USSR**, choose a regional operation and select five operatives. Choose a Darwinian Alkhimik's starting form in **Personnel** or their **Gear** panel during squad preparation. The deployment records each selected build for the operation.
3. In combat, select an operative. The square action buttons sit above End Turn. Hover a button to see the ability name, cost and effect, then click it and select its target on the board. Multi-step actions prompt for each tile. **Esc** cancels targeting. A passive that grants a free step adds **Follow-up Step** to the action bar.

Iskra loses one Heat at the end of each player turn. Delayed Mortar and Iron Rain land at the start of the enemy phase. Healing-origin Alkhimik shares four Treatment charges across all linked rooms for that operative. Ordinary Medkits use their own gear charges. Armour destruction and the existing wound ceiling carry between rooms in bunker operations. **M** opens the original fixtures and their regression rules.

The V3 tree data comes from the attached review bundle. Personnel, squad selection, the battle tabs, and battlefield units share the same 30 × 32 pixel avatars. Each origin has its own silhouette and palette. Darwinian Alkhimik changes avatar when switching between Frog, Jellyfish, and Skunk. Smoke and water interactions are wired for class abilities. The current operation layouts have no authored smoke or water tiles. AP costs, targeting ranges, damage, and resistance thresholds are playtest tuning. [V3 verification](BUILD_10_PLAYTEST.md#v3-bunker-mission-playthroughs).

The bunker Scythe paths are Wolverine and Scorpion. The older Arachnid and Blink paths remain available in fixture 6. The later Scorpion and Anvil redesigns are documented for review. The combat menus used V3 in this earlier pass. [Class revisions](CLASSES_AND_ENEMIES.md#scorpion-and-anvil-design-revisions).

The map uses the current eight English district names. It groups simplified Natural Earth Admin-1 boundaries for Russia's 83 federal subjects, with Ukraine's internationally recognized territory outside the district shapes. The four Central District pins are provisional locations for the existing prototype missions. [National Centre RUSSIA](https://en.russia.ru/news/nacionalnyi-centr-rossiia-prisoediniaetsia-k-prazdnovaniiu-25-letiia-so-dnia-osnovaniia-federalnyx-okrugov) · [Natural Earth boundary data](https://www.naturalearthdata.com/downloads/10m-cultural-vectors/) · [UN resolution on Ukraine's territorial integrity](https://mandates.un.org/mandate/A/RES/68/262)

## Personnel dossier verification

On 26 November 2026, Godot 4.7.2 on Windows passed 72 checks in a rendered OpenGL Compatibility run at 1460 × 900. The checks exercised hover on a locked ability, branch selection, the roster and all twelve origins, Darwinian stat and attack changes, and the equipment controls. A Rescue deployment matched the seven displayed stats for all five chosen operatives and carried over the selected Medkit. The mission selector opened each of the six fixture loadouts through **M** and the number keys. The issued Supersuit has no separate stat bonus in Build 10. [Equipment design](design/COMBAT.md#equipment)

The Godot editor imported the project and displayed local cache permission errors. The rendered verification used a direct launch. Editor **F5** remains unchecked for this update.

## Supersuit and base attack verification

In Godot 4.7.2 on Windows, the project imported and passed 95 integration checks headlessly and in a rendered OpenGL Compatibility run. The checks deployed all four bunker operations, exercised all twelve origins and three Darwinian forms, and covered attacks through board clicks and **J**, Medkit use and stock, ranged charge use and recharge, Emergency Reload, and basic attacks against barrels, machines and large targets. The harness used scripted combat setup and room clears. It opened fixtures **1–6** through **M** and the number keys and advanced fixture 1 through both radio branches with **Enter**. HP and Medkit state carried over, and the missed radio added three hounds. The standard rendered launch exited cleanly. The harness reported resource cleanup warnings on exit. Editor F5 remains unchecked after two timeouts while activating the editor window. Full manual playthroughs and balance remain open.

## Basic melee approach verification

On 26 November 2026, Godot 4.7.2 on Windows imported the project and launched it from the editor with **F5**. Rendered OpenGL Compatibility and headless runs passed 16 focused checks using staged positions and normal board clicks in bunker Assassination and **J** in fixture 1. The checks verified the four-step approach and strike for 1 AP, adjacent strikes, blocked and out-of-budget approaches, damage previews, movement and attack reporting, and a hazard that downed the operative before the hit.

The 33-check room regression opened fixtures **1–6** and used normal attacks and **Enter** to progress through fixture 1. HP carried over, and the radio outcome produced zero or three Alert Hounds in Room 3. Build 10 applies the combined action to player attacks against enemy units. Broader playtesting of reaction-heavy approaches and the proposed Charge and Breakthrough abilities remains open. [Basic melee rule](design/COMBAT.md#confirmed-rules-and-working-baselines) · [Class review](design/OPEN_DECISIONS.md#classes-equipment-and-enemies)

## Earlier verification

The district map opened from **F5** in the Godot 4.7.2 Windows editor after dismissing warnings about writes to the editor's local cache. A separate rendered OpenGL Compatibility run at 1460 × 900 passed 60 checks. It clicked all eight district shapes, checked district and briefing Back navigation, bought Facility Recon through **Intel Op**, and deployed each of the four pinned operations. The run entered fixtures 1–5 through **M** and the number keys. It also checked wound carry-over and both radio outcomes through fixture 1's room transition controls, with scripted room clears and radio test setup. Full manual combat playthroughs remain outside this map pass.

The bunker footer shows research and recruitment status. In a rendered Godot 4.7.2 Windows run, the footer omitted Medkit stock and Workshop → Consumables updated from two to three in stock after one purchase. **M** then **1** opened the original-chain loadout. This check used a direct launch and stopped at the loadout.

The Workshop and Research layouts were inspected at 1460 × 900 in a rendered Godot 4.7.2 Windows session using OpenGL Compatibility. An input-driven run exercised all four inventory filters, both Medkit purchases, insufficient Supplies, both projects through completion, and the shared research-slot block. **M**, **F9**, and fixture **1** were checked through the original chain's loadout. The project was imported and launched directly for verification. The editor's F5 path remains unchecked because the Windows automation could not reliably focus the editor.

The redesigned Personnel dossier was checked in a rendered Godot 4.7.2 session. The check covered operative and origin selection, name sorting with selection preserved, recovery status, recruitment, two-handed melee compatibility, and transfer of edited equipment into a Rescue deployment.

Godot 4.7.2 stable on Windows. All 30 integration checks passed headlessly and in a rendered OpenGL Compatibility session at 1460 × 900. They cover bunker startup, roster sorting, all four equipment slots, consumable purchases, support research, Facility Recon, Emergency Reload, mission reports and the four operations' objective hooks. The checks use menu actions and combat event handlers with scripted setup for selected battle conditions. An earlier rendered run passed all assertions and exited abnormally during shutdown. Both repeat runs exited normally. Full manual playthroughs and balance remain open.

### Mixed enemy formation verification

26 November 2026. Godot 4.7.2 opened the four new trials through their M-menu number and Enter inputs. The rendered GL Compatibility run used ANGLE. All 24 roster entries appeared across nine rooms. The driver checked spawn occupancy, machine classification, an enemy phase in every room, staged clears, squad HP carry-over and mission completion. Targeted setups exercised splash damage, displacement, healing on HP damage, Burning, Bleeding, Shocked, close-range modifiers and the Matryoshka's single drone release. Visual inspection covered the Foundry battlefield and the hover panel. Bunker Sabotage and Rescue deployed five operatives and completed their opening enemy phases.

The original chain retained seven final-room enemies after radio destruction and ten after failure in staged progression through all three rooms. The class suite passed 894 checks across 384 builds. F5 was sent to the imported editor; the verified rendered run launched directly. Full unassisted clears and difficulty tuning across the four trials remain playtest work.

### Enemy tier and XP trial verification

27 November 2026, creator-assigned roster tiers. Build 10 uses 6 Low, 9 Mid and 9 High archetypes for the inspector, Enemy tier mix and kill XP. [Roster assignments](design/CLASSES_AND_ENEMIES.md#enemy-tiers)

A staged Godot 4.7.2 run passed headlessly and in rendered GL Compatibility (ANGLE). It opened the four mixed trials through M, the number keys and Enter, verified all 24 tier and kill XP values across nine rooms, checked room kill XP and the summoned Matryoshka drone, opened fixtures 1–6, and verified linked HP carry-over and both original-chain radio lineups. The rendered driver logged shader initialization errors and completed the checks. This pass launched directly. Editor F5 and manual difficulty and XP pacing playthroughs remain to be checked.

27 November 2026. Godot 4.7.2 passed 34 progression and fixture assertions in headless mode and rendered GL Compatibility (ANGLE). Staged play exercised early Assassination extraction, full linked progression, failed escape, Rescue, both Iron Giant outcomes, Matryoshka's summoned drone, manual level overrides, repeated debrief protection, fixtures 1-6 and both radio branches. The rendered inspector, tier mix and Personnel XP display were reviewed. The existing class matrix passed 942 checks across 384 builds. F5 was sent to the imported editor, and the verified rendered run launched directly. Full playthroughs and tuning the curve beyond Level 3 remain open.

### Progression balance verification

27 November 2026. The [progression balance trials](design/CLASSES_AND_ENEMIES.md#enemy-balance-across-progression) rebalance the existing tiers and give the four mixed trials separate progression targets. Bunker Rescue uses a Grenadier in place of its second Mid enemy. The original fixtures retain their regression profiles.

Godot 4.7.2 launched from the editor with F5 and displayed the updated mission selector. A separate staged run passed 99 checks headlessly and in rendered GL Compatibility (ANGLE). It used M and the number keys, selected a squad through the loadout, and ran an enemy phase in each of nine trial rooms at Levels 1, 4, 6 and 9. It verified all 24 archetypes, final-room command synergy, linked HP carry-over, Medkit and Emergency Reload consumption within the trial, campaign isolation, F9 exit, fixtures 1–6 and both original-chain radio lineups. The rendered run logged shader initialization errors and completed the checks. The headless class matrix passed 1,048 checks over 384 builds. Full combat clears, alternate squad compositions, and balance with future Supersuit and stratagem options remain to be tested.

## Overwatch cone verification

On 27 November 2026, Godot 4.7.2 on Windows launched Build 10 through **F5**. A rendered GL Compatibility run with ANGLE passed 25 focused checks using **M**, fixture selections **1** and **6**, **O**, **Esc**, battlefield clicks and staged reaction setups. Checks covered cone width and direction, blocked shots, movement lock, repeated shots, AP and ammo limits, a large target crossing the cone, AI aiming, expiry and the sentry interrupting Charge. A rendered fixture regression passed 33 checks, including wounded HP carry-over and both radio branches with zero or three hounds in Room 3. The headless class matrix passed 1,015 checks. Full encounter balance and enemy aim selection across maps remain open. [Overwatch rules](design/COMBAT.md#overwatch)

The 27 November route-preview and AI follow-up launched through **F5** in Godot 4.7.2 and passed 14 focused checks in rendered GL Compatibility. The Cordon movement preview displayed two expected shots and resolving that route fired two. Staged checks isolated AP, ammo, wall occlusion, a sealed room and an open approach. Fixture 6 still stopped Charge at the first step that drew fire. Two scripted passes cleared all nine mixed-trial rooms, and each of the 18 enemy cones contained only tiles visible to its shooter. Both original-chain radio branches passed the 33-check rendered regression again, and the headless class matrix passed 1,015 checks. Longer-horizon lane selection and overlapping high-damage cones remain open.
