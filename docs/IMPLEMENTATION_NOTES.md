# Resistance Bunker playtest

Run `source/Hammer_Ash_Godot_2D_Build10/project.godot` in Godot and press **F5**. The game opens on **USSR** in the bunker. Press **M** in the bunker to open the test mission selector, then choose a fixture with **1–9** or **0** and press **Enter**. Press **F9** from the selector to return to the bunker.

| Area | Playtest |
| --- | --- |
| USSR | Click a district on the Russia map or in the district list. In the **Central Federal District**, click an Assassination, Sabotage, Rescue or Defence pin to open its briefing. **Deploy** opens squad preparation, **Intel Op** opens Facility Recon, and **Back** returns to the district map. The other seven districts open with no missions available. |
| Squad loadout | Select five ready operatives. **Gear** shows their Supersuit and base attack and lets you choose one consumable. Medkit selections share Workshop stock. |
| Personnel | Choose an operative with the roster picker and sort by Type or Name. The portrait is on the left, the class tree is in the centre, and the issued Supersuit, default consumable and current stats are on the right. Hover any ability node for its details. **Dev level → Earned** uses the operative’s earned level. Levels 1–9 are available for manual builds. A deployment with a manual level pauses campaign XP. |
| Workshop | Purchase individual Medkits or a batch. Inventory shows the issued Supersuit and live Medkit stock. Sabotage success grants 6 Supplies and 2 Intel. |
| Research | Browse **Stratagems** and **Intelligence Operations** side by side. Click an available project card to start research and use **Debug: Advance Day** to complete it after two days. Each board has 24 slots from the layout reference, with one live project per board. Select Emergency Reload in squad preparation. Buy Facility Recon from the mission briefing or squad preparation after completing its research. |
| Combat | Use **G** to refill the selected ranged operative's charges once per operation after preparing Emergency Reload. It costs 3 Intel on use and spends no AP. Facility Recon costs 2 Intel and previews that operation's existing objectives and events. **F9** returns to the bunker from the report. |

Campaign state lasts for the running session. Use **Enter** after clearing an Assassination room to advance or **E** to extract. Normal objectives, enemy schedules, combat rules and item effects use the existing Build 10 code. Personnel and combat derive stats from the same player baseline.

## 27 November checkpoint verification

Godot 4.7.2 reran the headless class matrix against the checkpoint. All 1,015 checks passed across 384 builds, including 48 staged linked-room transitions. See the sections below for the earlier rendered runs and fixture regression results.

## Level 1 player stat verification

**27 November maximum HP progression.** After the creator reported that HP stayed at 12 in Personnel, the shared HP calculation now adds one per level after Level 1, each unlocked node’s `max_hp_bonus` if present and the equipped Supersuit’s HP bonus. The issued suit grants zero. Personnel displays **Max HP**. Fresh bunker deployments start at that maximum, and linked rooms retain current HP and wounds. [Creator decision](design/CLASSES_AND_ENEMIES.md#level-1-base-stats)

Godot 4.7.2 on Windows imported the project. The 242-check Personnel run covered Levels 1–9 across all twelve origins and returning from the Dev level override to the earned level. The 30-check Rescue run confirmed that Level 8 Steel Skin displayed 19 max HP and deployed at 19/19, with the expected armour and movement bonuses. That run passed headlessly and under rendered GL Compatibility with ANGLE. The rendered run logged shader initialization errors before completing. Godot’s Project Manager did not retain focus for the editor launch, so the rendered run used the command line. The 1,015-check class matrix confirmed HP bonus stacking and wounded HP with level-scaled maxima through 48 linked-room transitions. The 33-check fixture regression passed for **M → 1–6** and both original-chain radio branches.

On 27 November 2026, Godot 4.7.2 on Windows imported the active project and launched via **F5**. Personnel showed Jaguar with 12 HP, 0 armour, 4 basic damage and 5 tiles of movement after Rosette Claws. Personnel now accepts reviewed origins without a separate identity description. The [creator’s baseline](design/CLASSES_AND_ENEMIES.md#level-1-base-stats) applies to bunker operatives. Regression fixtures continue to use authored kits. The issued Supersuit has no separate stat modifier. [Variant rules](design/COMBAT.md#equipment)

The headless class matrix passed 942 checks across all twelve origins, including 48 linked-room transitions. A separate 26-check input-driven Rescue run compared Personnel with deployed stats, checked ranged previews at eight and nine tiles, and used board clicks to verify damage and a four-tile standard move. The 33-check fixture regression opened **M → 1–6**, then used staged targets, normal attacks and **Enter** to clear both original-chain branches. It confirmed HP carry-over and zero or three alert hounds in Room 3. Full mission balance with the new stats remains open.

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
2. Open **USSR → Central Federal District**, choose any operation and select five operatives. Choose a Darwinian Alkhimik's starting form in **Personnel** or their **Gear** panel during squad preparation. The deployment records each selected build for the linked mission.
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
