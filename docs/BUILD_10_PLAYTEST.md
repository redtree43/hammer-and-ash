# Build 10 Windows playtest

22 November 2026 · Godot 4.7.2 stable · Windows · OpenGL Compatibility at 1460 × 900

A temporary test driver ran the unchanged game scene in a rendered window. It sent the normal number keys, tile clicks, ability keys, Space, Enter and mission-menu controls through Godot's input API. It sampled game state for comparisons and accelerated the clock for movement and enemy phases. Tactical AI and armour stayed enabled. Neither room jumps nor direct state edits were used.

## 27 November full campaign balance playtest

Godot 4.7.2 on Windows ran a deterministic tactical input driver against the campaign scene. It used the USSR site and squad controls, action bar, board clicks, end turn, and **Enter** for room progression. The driver selected builds before deployment and accelerated presentation between inputs. Enemy formations, objectives, HP, cooldowns and combat AI resolved normally. Each operation started from a fresh bunker state. These results measure full operations with manual-level builds and one repeatable player policy.

The main pass completed **52 of 52 operations**, visiting **all 28 sites** and **all 24 enemy archetypes**. It cleared **102 rooms** and used **50 linked-room transitions**. There was one down and zero permanent losses. Of the 102 rooms, 14 cleared in one round, 65 in two, 21 in three and two in four. The original chain fixture passed 23 regression checks, including the two radio outcomes. The branch matrix passed 1,112 checks. Two of the Ural relay passes were also repeated with rendered GL Compatibility.

### Matched sweep comparisons

Each pair swapped the lead origin with the same squadmates on the same three-room sweep at Levels 3 and 9. Damage and kills below refer to the selected operative. This driver favours visible attacks and evaluates support and positioning with simple heuristics. Prevention and setup do not receive comparable scoring in the damage ledger.

| Class | Observation |
| --- | --- |
| Scythe | Jaguar reached enemies and finished them more readily. It scored nine direct kills to Scorpion's four across the two matched runs, while taking 25 direct HP damage to Scorpion's one. Scorpion stayed safer and contributed less pressure in short fights. |
| Anvil | Both origins had identical matched sweep times and took no direct HP damage. The lead spent much of its AP on Taunt. The results support durability, with limited evidence for distinguishing Steel Skin's frontline control from Psionic Armour's ally protection. |
| Needle | Eye Powers scored 13 kills and dealt 57 direct HP damage across the matched sweeps, remaining unwounded by direct enemy hits. Hawk Wings scored five kills and dealt 37 direct HP damage while taking 31 direct HP damage and the run set's one down. Eye Powers cleared each sweep faster. |
| Iskra | Artillery's basic gun contributed more direct damage. The early sweep ended before the driver found an attractive heavy-fire setup. A deliberate Ural relay run used Anchor and Siege Salvo and secured three kills with the Artillery operative. Drone Command contributed through Scout Run, but its defensive value and loss risk need more sustained enemy pressure. |
| Alkhimik | Darwinian dealt seven direct HP damage and healed ten HP in the matched sweeps. Jekyll / Hyde dealt 41 direct HP damage and healed four HP. The driver mostly fought as Jekyll, indicating his basic attack was already useful in short rooms. |
| Glaz | Both origins cleared their matched sweeps on similar timelines. Telepathy suppressed reactions on organic targets. Telekinesis moved robots and organic targets, giving it the broader matchup. |

Four additional Level 9 sweeps tested the Assault and Guardian chassis, a Hyde-focused build, and Telepathy on the robot-heavy Ore Terminal Sweep. All four cleared, adding 12 rooms and eight transitions. Assault and Guardian took five and six total rounds respectively. Both drones carried their HP through all rooms and neither was destroyed. Guardian used Shield Run in two rooms. The Hyde run used Break the Vial in only one room. In the robot-heavy Telepathy run, the lead dealt 11 direct HP damage across six rounds, and Distort Aim remained available against machines. These runs favoured the origin tools deliberately, so the results are separate from the matched sweep comparisons above.

### Enemy pressure

Man of Steel was the most repeatable threat within its tier, dealing 76 recorded direct HP damage over 20 appearances. Proletariat dealt 19 over four appearances and caused the only down. Red Star and Individualist also had notable peaks, with small samples. Hammer, Combine and Nevalyashka recorded no direct HP damage over eight, six and four appearances respectively. Clergy recorded no healing over eleven appearances. This exposes a problem with getting into effective positions before the squad clears the room. The ledger credits ongoing environmental damage separately and does not assign ally damage to supporting aura units.

### Bugs corrected

- Restored the broken indentation that prevented the Headquarters and combat scene from loading.
- Guarded the player-only standard-move hook against enemy units that have no class state.
- Restored objective and room-clear assessment after a class action finishes, so a killing ability can open the next room or the debrief immediately.

This baseline used the old two-point reduction for physical full cover. The creator subsequently confirmed protected-side shot blocking. [Full-cover retest](#27-november-full-cover-campaign-retest)

## 27 November full-cover campaign retest

Godot 4.7.2 on Windows reran the same 56 operations, including the four targeted sweeps. The driver used the same sites, squads, builds and input policy as the baseline. All twelve origins led a three-room sweep at both Level 3 and Level 9. The replay exercised all 28 sites and 24 enemy archetypes.

| Measure | Previous full-cover reduction | Protected-side shot blocking |
| --- | ---: | ---: |
| Operations cleared | 56/56 | 56/56 |
| Rooms cleared / linked transitions | 114 / 58 | 114 / 58 |
| Total rounds across rooms | 237 | 244 |
| Enemy direct HP damage across squads | 490 | 531 |
| Downs / permanent losses | 1 / 0 | 1 / 0 |

Both runs cleared 112 of 114 rooms within three rounds. Ural Rescue took five rounds with Psionic Armour, up from four. The squad took more direct HP damage overall even though individual protected-side shots were unavailable. These totals reflect changed engagements and come from one repeatable player policy with fresh squads.

- **Needle.** Across the two matched sweeps per origin, Eye Powers dropped from 57 to 50 direct HP damage and from 13 to 10 kills. It still beat Hawk Wings on clear time and stayed unwounded by direct fire. Hawk took 31 direct HP damage and the same down from Proletariat as before. Hawk remains the more exposed choice.
- **Iskra and Glaz.** Artillery held its matched sweep times and rose from 33 to 37 direct HP damage. Standard Drone Command took one more round across its matched sweeps, while the separate Guardian sweep improved from six rounds to five. Both drone probes kept their drones through all three rooms. Telepathy took an extra round in each Far Eastern sweep and finished the separate Ural sweep at 3 HP. Telekinesis held its clear times while dealing less and taking less direct HP damage.
- **Other origins.** Both Anvils cleared their Level 9 Southern sweeps one round faster. Their leads took no direct HP damage across the matched sweeps. Jaguar, Scorpion, Darwinian and Jekyll / Hyde held their matched sweep times. The Volga Rescue with Darwinian took an extra round.
- **Enemies.** Man of Steel rose from 85 to 106 direct HP damage across 23 appearances. Marksman and Rifleman barely changed. Hammer and Nevalyashka still dealt no direct HP damage across nine and four appearances respectively, and Clergy recorded no heals across twelve.

Godot's class matrix passed 1,128 checks across 384 builds. It covered blocked previews and execution, flank angles, half cover, melee, explicit cover pierce, Taunt fallback, and ordinary and drone Overwatch. The original three-room chain passed all 23 checks, including linked carry-over and both radio outcomes. The imported project launched through F5. Both rendered Ural relay repeats completed under GL Compatibility despite ANGLE shader initialization messages.

## 27 November shot cost and level check

The preceding 56-operation pass used the earlier cover implementation, which rejected shots into full cover. Under the updated rule, the player can commit a shot into full cover and see the zero-damage result before firing. A committed shot spends its usual AP and ammo or charge, including Overwatch. The target and the cover edge take no damage from an ordinary blocked shot.

All five operatives in each of the 56 earlier operations were set to the same manual level. Level 3 accounted for 22 operations and 46 rooms, with one down to Proletariat. Level 9 accounted for 34 operations and 68 rooms, with no downs. Both levels fielded about 4.8 enemies per room. Squads entered operations fully healed.

Four repeat matchups used the updated shot rule and identical selected squads and branch choices at each of Levels 1, 3 and 9. All 12 operations cleared, including all nine linked sweeps. The Level 1 and 3 Hawk Wings squads each took one down to Proletariat in Volga. The other three Level 1 squads had zero downs.

| Formation | Level 1 rounds / downs | Level 3 rounds / downs | Level 9 rounds / downs |
| --- | ---: | ---: | ---: |
| Volga Sweep, Hawk Wings | 8 / 1 | 8 / 1 | 7 / 0 |
| Ural Sweep, Drone Command | 7 / 0 | 7 / 0 | 6 / 0 |
| Far Eastern Sweep, Telepathy | 6 / 0 | 7 / 0 | 6 / 0 |
| Ural Rescue, Psionic Armour | 3 / 0 | 5 / 0 | 5 / 0 |

Of 203 authored enemy slots across the 42 campaign rooms, 146 are Low-tier, 40 are Mid-tier and 17 are High-tier. Only two rooms field two or more High-tier foes. A five-operative squad starts with 15 AP, so screening enemies can disappear before their anchor, support or melee threats get into position. The next tuning comparison should keep enemy stats steady and test stronger checkpoint and final-room formations with a screen and a protected anchor or support unit. The four-site run used fresh squads and one scripted policy.

## 27 November sweep formation comparison

Godot 4.7.2 on Windows replayed the seven campaign sweeps with the previous and trial formations. Each site used the same named five operatives, origins, branch choices and loadout in both versions. All five started fully healed at the same manual level, with separate runs at Levels 1, 3, 5, 7 and 9. The driver selected the squad and operation through HQ and used the action bar, battlefield clicks, end turn and Enter to play through the linked rooms. This method tests each operation with one repeatable playstyle.

The trial used the same five enemy posts in each affected room. Across the seven checkpoints, the number of High-tier slots rose from one to seven. Across the seven final yards, it rose from seven to fourteen. Enemy stat profiles, terrain and the approach lineups were identical in both builds.

All **70 operations** cleared across the two builds, with **210 rooms** and **140 linked-room transitions**. Paired approach results matched exactly. No carry-over mismatch or Godot script error was recorded.

| Squad level | Clears, previous → trial | Total rounds | Direct enemy HP damage | Operatives downed |
| --- | ---: | ---: | ---: | ---: |
| 1 | 7/7 → 7/7 | 46 → 55 | 117 → 170 | 3 → 6 |
| 3 | 7/7 → 7/7 | 46 → 55 | 114 → 179 | 1 → 5 |
| 5 | 7/7 → 7/7 | 44 → 52 | 107 → 183 | 0 → 3 |
| 7 | 7/7 → 7/7 | 42 → 48 | 99 → 156 | 0 → 2 |
| 9 | 7/7 → 7/7 | 43 → 47 | 108 → 146 | 0 → 2 |
| **All** | **35/35 → 35/35** | **221 → 257** | **545 → 834** | **4 → 18** |

Downs count unique operatives within an operation. The trial had one permanent loss, already counted among the 18. At Level 7 in Volga, Hawk Wings went down in the checkpoint, returned wounded for the yard and went down again. The earlier lineups had zero permanent losses.

Each cell below shows total rounds followed by operatives downed for the complete linked sweep.

| Sweep and lead origin | Level 1 | Level 3 | Level 5 | Level 7 | Level 9 |
| --- | --- | --- | --- | --- | --- |
| Northwestern, Jaguar | 6/1 → 6/1 | 5/0 → 7/2 | 5/0 → 7/1 | 5/0 → 6/1 | 5/0 → 6/1 |
| Southern, Steel Skin | 6/0 → 7/0 | 6/0 → 7/0 | 6/0 → 7/0 | 6/0 → 6/0 | 6/0 → 6/0 |
| Volga, Hawk Wings | 8/1 → 9/1 | 8/1 → 9/2 | 8/0 → 8/1 | 7/0 → 8/1 | 7/0 → 7/1 |
| Ural, Drone Command | 7/0 → 9/1 | 7/0 → 9/0 | 5/0 → 7/0 | 5/0 → 6/0 | 6/0 → 6/0 |
| North Caucasian, Jekyll / Hyde | 6/0 → 8/1 | 6/0 → 8/0 | 6/0 → 8/0 | 5/0 → 6/0 | 5/0 → 6/0 |
| Far Eastern, Telepathy | 6/0 → 8/1 | 7/0 → 8/1 | 7/0 → 8/1 | 6/0 → 8/0 | 6/0 → 8/0 |
| Siberian, Darwinian | 7/1 → 8/1 | 7/0 → 7/0 | 7/0 → 7/0 | 8/0 → 8/0 | 8/0 → 8/0 |

The checkpoint added 14 rounds across the 35 paired runs, and the final yard added 22. Northwestern and Volga accounted for 12 of the 18 trial downs. Southern caused no downs, so it gives this squad an easier entry point. Matryoshka dealt the most direct HP damage in the trial, with 177 HP across 25 appearances. Clergy restored 39 HP in the trial after recording zero healing with the previous lineups, and Hammer dealt 16 direct HP damage after recording zero. These totals reflect different numbers of appearances and supporting formations. Repeat Northwestern and Volga with other squads and compare the choice to extract after the checkpoint before locking the formations.

## 27 November Northwestern and Volga squad retest

The stronger formations stayed in use. Godot 4.7.2 on Windows deployed each of two alternate five-operative squads through Headquarters at Levels 1, 3, 5, 7 and 9 on both sweeps. The driver repeated the earlier tactical input policy and played all three linked rooms, carrying HP, downs and consumables. Each operation began with a fresh squad at full HP.

- **Fire support** used Artillery Suit, Eye Powers, Psionic Armour, Telekinesis and Jekyll / Hyde.
- **Close control** used Jaguar, Steel Skin, Hawk Wings, Darwinian and Drone Command, with Guardian Chassis selected from Level 3 onward.
- **Original comparison** uses the same stronger lineups from the first test. Its Northwestern squad was Jaguar, Steel Skin, Eye Powers, Telekinesis and Jekyll / Hyde. Its Volga squad was Hawk Wings, Steel Skin, Telekinesis, Jekyll / Hyde and Drone Command.

All 20 new main runs cleared, covering 60 rooms and 40 linked transitions with no carry-over mismatch. The two Level 5 rendered spot checks reproduced the headless casualties and final HP. The table includes the 10 original comparison runs. Downs count unique operatives within each run, including operatives permanently lost.

| Squad level | Northwestern clears | Northwestern downs / losses | Volga clears | Volga downs / losses |
| --- | ---: | ---: | ---: | ---: |
| 1 | 3/3 | 7 / 4 | 3/3 | 5 / 3 |
| 3 | 3/3 | 6 / 2 | 3/3 | 5 / 2 |
| 5 | 3/3 | 6 / 4 | 3/3 | 4 / 1 |
| 7 | 3/3 | 5 / 2 | 3/3 | 2 / 2 |
| 9 | 3/3 | 4 / 0 | 3/3 | 2 / 0 |

**Northwestern, Freight Yard Sweep.** Recommend Level 9 as the general minimum for committing to all three rooms. The close-control squad suffered permanent losses at every tested level below 9. It still had three operatives down at Level 9, and the original squad had one. The fire-support squad took no downs at Levels 7 and 9, making Level 7 a reasonable minimum for that composition. Matryoshka was a repeat threat across both later rooms.

**Volga, Weir Compound Sweep.** Recommend Level 9 for a general squad. At Level 7, both the original and close-control squads lost one operative permanently. At Level 9, each suffered one down and both recovered. The fire-support squad had no downs at any tested level. Level 3 is a reasonable minimum for that composition because at Level 1 three operatives finished on 3 HP, while at Level 3 everyone finished on at least 10 HP.

These are briefing recommendations for fresh squads. Level 9 was the first tested level with no permanent losses across all three squad compositions at either site. Each composition used one scripted playstyle, with one main attempt per level.

## 27 November remaining five sweep retests

Godot 4.7.2 on Windows ran the other five sweeps with the same fire-support and close-control compositions used for the Northwestern and Volga retest. Each squad began fresh and fully healed at uniform Levels 1, 3, 5, 7 and 9. The driver used the same tactical input policy and played through the linked rooms via Headquarters. The comparison also uses the original squad at each site from the stronger-lineup trial, for three compositions at each site and level.

Of 50 new runs, 49 cleared. The Level 1 close-control squad was wiped in Ural’s final yard. All squads reached the final yard, completing 100 linked-room transitions in the new runs with no carry-over mismatch. All 25 original comparison runs cleared.

| Sweep | Level 1 | Level 3 | Level 5 | Level 7 | Level 9 | General minimum | With fire support |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Southern · Floodplain | 4 / 2 | 4 / 0 | 3 / 0 | 1 / 0 | 1 / 0 | 3 | 3 |
| North Caucasian · Pass Road | 4 / 1 | 2 / 1 | 3 / 1 | 3 / 2 | 3 / 0 | 9 | 5 |
| Ural · Ore Terminal | 7 / 4 | 3 / 0 | 4 / 2 | 1 / 1 | 1 / 0 | 9 | 3 |
| Siberian · Timber Depot | 3 / 1 | 3 / 2 | 3 / 1 | 1 / 0 | 1 / 0 | 7 | 1 |
| Far Eastern · Coastal Depot | 5 / 3 | 6 / 2 | 5 / 1 | 2 / 0 | 2 / 0 | 7 | 7 |

The level columns show operatives downed and permanent losses across all three compositions, with permanent losses included in the down count. General recommendations use the first tested level from which all three compositions cleared without permanent losses at that level and at every higher tested level. Recommendations with fire support also account for wounds at the end of the sweep.

- **Southern.** The three squads cleared without permanent losses from Level 3 onward. Four operatives went down at Level 3, and the fire-support squad finished that run with at least 7 HP on everyone.
- **North Caucasian.** Close control took permanent losses through Level 7. The fire-support squad lost no one but finished with one operative at 1 HP at Level 3. Its lowest final HP at Level 5 was 8.
- **Ural.** Level 3 was loss-free, but close control lost operatives at Levels 5 and 7. Fire support took no downs starting at Level 3.
- **Siberian.** Fire support took no downs at any tested level and everyone finished the Level 1 run with at least 4 HP. Close control had permanent losses through Level 5.
- **Far Eastern.** Close control lost operatives through Level 5. The fire-support squad had one down at Level 3 and finished Level 5 with one operative at 2 HP. At Levels 7 and 9 its lowest final HP was 9 and 8, respectively.

The briefing values are advisory for fresh squads. Each composition had one run at each level under one tactical input policy.

## 27 November patrol, relay and rescue retest

Godot 4.7.2 on Windows played all 21 one-room campaign operations with the fire-support and close-control squads from the sweep retests. Five fully healed operatives at the same manual level entered each run. The test matrix covered Levels 1, 3, 5, 7 and 9, with one attempt per squad at each level. The driver deployed from Headquarters and used the action bar, board clicks and end turn. Relay clears required destroying the generator and rescue clears required releasing both prisoners, in addition to defeating all hostiles.

All **210 runs** cleared. The scripts verified generator destruction for all 70 relay clears and both prisoner releases for all 70 rescue clears. Fire support had one down and zero permanent losses in 105 runs. Close control had 18 downs and two permanent losses in 105 runs. Both losses occurred in the Level 1 Clifftop Relay clear.

| Squad level | Clears | Operatives downed | Permanent losses |
| --- | ---: | ---: | ---: |
| 1 | 42/42 | 6 | 2 |
| 3 | 42/42 | 8 | 0 |
| 5 | 42/42 | 2 | 0 |
| 7 | 42/42 | 2 | 0 |
| 9 | 42/42 | 1 | 0 |

Patrols recorded zero downs, relays recorded 16, and rescues recorded three. The following cells show the general minimum and the fire-support minimum when lower.

| District | Patrol | Relay | Rescue |
| --- | ---: | ---: | ---: |
| Northwestern | 1 | 3 / 1 | 1 |
| Southern | 1 | 5 / 1 | 5 / 1 |
| North Caucasian | 1 | 7 / 1 | 7 / 1 |
| Volga | 3 / 1 | 9 / 5 | 1 |
| Ural | 1 | 3 / 1 | 9 / 3 |
| Siberian | 1 | 1 | 3 |
| Far Eastern | 3 / 1 | 9 / 1 | 3 / 1 |

The guidance uses the first tested level from which the applicable squads cleared with zero downs and every operative finished above a quarter of maximum HP at that level and at each higher tested level. Three general thresholds use Level 9 as cautious advice because at that level close control finished with one operative at 2 HP in Turbine Relay and one at 4 HP in Mine Office Rescue, and took a down in Clifftop Relay. Fire support reached the lower recommended level in all three. The recommendations reflect one scripted playstyle and one attempt per site, level and composition. Deployment remains open at any level.

## Original three-room chain

| Run | Room 2 radio | Room 3 at entry | Outcome |
| --- | --- | --- | --- |
| Timely disable | Destroyed in player Round 1. The room report said `DESTROYED ON TIME`. | 7 enemies, including 3 hounds and zero Alert Hounds. | Mission complete in Round 5 with 3 operatives still up. |
| Missed deadline | Destroyed in player Round 4. Room 2 cleared in Round 6 and the report said `ALERT SENT (+3 HOUNDS)`. | 10 enemies, including 6 hounds and exactly 3 Alert Hounds. Late destruction left the reinforcement call in effect. | Squad wiped in Round 5 with 2 enemies remaining. The radio and transition checks passed. |

Both runs advanced twice with Enter. In the timely run, Razor entered Room 2 at 3 HP and Biochemist at 8 HP, matching their Room 1 exit values. Room 3 began with the same HP values as the Room 2 exit for all five operatives. Razor's armour refreshed from 1 to 2, living operatives returned to 3 AP, and Engineer and Biochemist's open cooldowns reset.

In the missed-deadline run, Razor, Sentinel and Engineer went down for the first time in Room 2. They entered Room 3 with their down counts retained at one and with 5/9, 6/11 and 4/8 HP respectively. All three were marked permanently lost when they went down a second time. Marksman and Biochemist retained their Room 2 exit HP of 8 and 5 on entry.

## Other mission fixtures

| Fixture | Observed outcomes |
| --- | --- |
| Assassination | Both runs reached Room 3 through normal transitions. Killing Orlov and clearing the escorts produced mission success in Round 4. When Orlov escaped in Round 3 after all four escorts were defeated, the mission failed with three operatives still up. |
| Sabotage | Destroying the pod before activation, destroying the generator and clearing the guards produced success in Round 3. Letting the prototype activate, then defeating the robot and guards and destroying the generator, produced success in Round 7. |
| Rescue | Freed both prisoners in Round 2 while all five guards were alive, then won after clearing the guards in Round 5. In the reverse run, cleared the guards first and freed B before A, winning in Round 4. |
| Defence | Waves started in player Rounds 1, 3, 5 and 7. Holding through enemy Round 8 succeeded at 20/20 safehouse HP with six attackers still alive. An idle squad lost in Round 4 at 0 safehouse HP with all five operatives still up. A separate squad wipe failed in Round 5 while the safehouse still had 10 HP. |

## Assassination debrief retest

The original escape run showed `Defeated enemies: 5/5` after only the four guards were defeated. The after-action report and Room 3 squad activity now share a defeat tally that excludes an escaped Orlov while keeping him in the total enemy count.

Both assassination outcomes were replayed through all three rooms using the normal controls in a rendered Godot 4.7.2 Windows session.

| Outcome | Mission result | After-action and Room 3 activity tallies |
| --- | --- | --- |
| Orlov killed and all four guards defeated | Success in Round 4, three operatives up | 5/5 |
| Orlov escaped after all four guards were defeated | Failure in Round 3, three operatives up | 4/5 |

The scripted runs checked outcome rules and inputs. Manual pacing and balance assessment remain open.

## Bunker operation playthroughs

23 November 2026 • Godot 4.7.2 on Windows • OpenGL Compatibility at 1460 × 900

The playthrough driver deployed through **USSR → Region 1**, then used the normal combat handlers for tile clicks, abilities, reloads, Overwatch, turns and room transitions. It accelerated animation and read battle state to choose actions. These playthroughs left enemy AI, AP, wounds and objectives to resolve in the game. They used no room jumps or edits to deployed squads, health, enemy state or objectives.

| Operation | Cases verified |
| --- | --- |
| Assassination | Three successful rendered runs with distinct squads. All crossed Room 2 via the normal transition. A fourth squad was defeated in Room 3 and reached the failure report. Two additional mixed-squad runs succeeded headlessly. |
| Sabotage | Three successful rendered runs. The prototype was stopped before activation in two runs and destroyed after activation in one. |
| Rescue | Three successful rendered runs, including freeing prisoners before clearing the guards and clearing the guards first. |
| Defence | Three successful rendered runs through all four waves and enemy Round 8. The safehouse finished with 12–20 HP. |

The targeted edge checks use direct state setup. Sabotage now disables the terminal once the pod is destroyed or the robot activates. The inactive terminal cannot consume AP through an objective interaction. When Orlov's escape ends Assassination, the live round now matches the report and the game skips the next player-phase setup.

The reported Room 2 window closure was not reproduced. The bunker build writes room entry, room clearance and operation outcome to Godot's log for the next playtest. The original log only contained startup information.

## Build 10 checkpoint retest

23 November 2026 • Godot 4.7.2 stable on Windows

- Editor import completed and **F5** opened the Resistance Bunker. The rendered OpenGL Compatibility checks passed for the Personnel dossier and all 13 bunker operation runs. Twelve runs reached success and one Assassination run reached the failure report after a squad wipe.
- Headless checks passed all 30 bunker integration assertions and five targeted checks for the sabotage terminal and Orlov's escape.
- The bunker now opens the test selector with **M** and returns from it with **F9**. A headless input driver deployed all six fixtures through their loadout screens. It replayed fixture 1 through both normal room transitions and verified HP carry-over for standing operatives and magazine refills. Room 3 had seven enemies after an on-time radio disable and ten after the alert. Both runs reached the final report.
- Manual pacing and balance remain open. The previously reported Room 2 closure did not recur in the checkpoint operation runs.

## First-down recovery and battlefield visuals

Replayed the original three-room chain on Windows with Godot 4.7.2 using the normal controls. Both runs advanced with Enter and used no room jumps.

| Radio branch | Recovery and mission result |
| --- | --- |
| Timely disable | Destroyed the radio in Round 1 and entered Room 3 with 7 enemies. Razor stood in Round 4 at 5 HP after missing two player turns. The squad won in Round 5 with four operatives standing. |
| Missed deadline | Destroyed the radio in Round 4 and entered Room 3 with 10 enemies, including the 3 Alert Hounds. Razor and Sentinel recovered on the timer in Room 2 at 5 and 6 HP. Engineer was still down when Room 2 cleared and entered Room 3 at 4 HP. All three were permanently lost on their second downs. The squad lost in Round 5 when no operatives remained standing, with four enemies left. |

A controlled Windows run separately verified that a Round 1 down blocks movement and targeting, clears statuses and reactions, and removes all AP through player Rounds 2 and 3. The operative stood in Round 4 with refreshed AP and armour. Field Treatment restored only the missing HP under the ceiling and refused treatment at the ceiling, including after a room transition. Permanent loss carried into a later room, and a wipe produced no transition recovery.

Rendered checks covered the three cover tiers, walls, barrels, hazard tiles, radio and mission props. The battlefield retained its colour and letter cues. A downed operative's tile marker, squad tab and hover panel showed the scheduled recovery round.

## Playable class rename retest

Replayed both radio branches through all three rooms using normal controls on Windows in Godot 4.7.2. The squad tabs, operative inspector, room activity and debrief displayed Scythe, Anvil, Needle, Iskra and Alkhimik with their existing kits and sprites. Glaz had no playable slot. A focused check verified Anvil Breach still cost 1 AP and used the new name in the hit ledger and ability-use counts.

The timely radio run entered Room 3 with seven enemies and won in Round 5 with four operatives standing. The late run entered with ten enemies, including three Alert Hounds, and ended in a Round 5 wipe with four enemies left. Operative HP, timed recovery, room carry-over and second-down losses matched the pre-rename runs.

## Ammunition and reload retest

Godot 4.7.2 on Windows showed Shoot and Reload at 1/3 rounds and only Reload at 0/3. Focused checks verified 1 AP reloads with unlimited replacements, ammunition use for gunfire and Overwatch, armed AI reloads, and ammo-free adjacent strikes on objectives. Empty weapons could not shoot units, barrels, or objectives.

Both radio runs used normal controls and verified full magazines on each room entry. The on-time run entered Room 3 with seven enemies and won in Round 5 with three operatives standing. The late run entered with ten enemies, including three Alert Hounds, and ended in a Round 8 squad wipe with one enemy left.

## Starter loadout retest

Godot 4.7.2 on Windows opened the four-slot loadout through the mission selector and deployed with Enter. Equipping a two-handed rifle cleared and blocked the melee slot, including for Needle's issued rifle. Switching to a Service Pistol made the melee slot available again. Chosen firearm and armour stats applied at deployment and gear stayed locked after leaving a draft without deploying.

Focused checks verified that the knife costs 1 AP and uses no ammunition. The Medkit spends one charge and 1 AP only when it restores HP. Treatment respected the wound cap and appeared in room activity. Spent charges and equipment carried into Room 2, magazines refilled, and restarting with the same gear restored the Medkit.

Both original-chain radio branches matched the ammunition baseline with the issued guns and armour. The timely run won in Round 5 with three operatives standing. The late run added three Alert Hounds and ended in a Round 8 squad wipe.

## Scythe test range

On Windows in Godot 4.7.2, fixture 6 opened from the mission selector and cleared through normal controls. Focused checks verified the two-step limit, route and landing preview, 1 AP cost, once-per-turn use, and rejection of invalid targets. The sentry's nonlethal Overwatch stopped Scythe on the first step before the strike, spending one enemy round and leaving Charge used for the turn.

An uninterrupted Charge dealt one strike and did not reduce maximum armour. A follow-up Wolverine Claw attack reduced the armoured guard's maximum from 4 to 3, and its next refresh restored only 3 armour. Switching to Standard Scythe restored the normal melee slot for comparison.

Both original-chain radio branches matched the prior baseline. Scythe kept Area Shred, the timely run won in Round 5, and the late run added three Alert Hounds and ended in a Round 8 squad wipe.

## Scythe origin retest

In Godot 4.7.2 on Windows, the loadout cards and battlefield showed distinct Wolverine, Arachnid, Blink and Standard sprites. Arachnid walked five tiles for 1 AP, rejected a six-tile walk, and completed a three-tile Charge. Wolverine retained the two-tile Charge, opening Overwatch interruption, and lasting claw armour reduction.

Short Blink rejected occupied, blocked and out-of-range destinations. A four-tile Blink cost 1 AP and relocated Scythe directly. The landing fire hazard applied, the intermediate radiation tile did not, and the sentry fired on landing. Scythe could still use Charge in the same turn and could Blink again on the next turn.

Both original-chain radio branches matched the prior outcomes. Scythe kept the original sprite, four-tile movement and Area Shred.

## Diagonal movement and square footprints

Player and enemy move actions cost 1 AP within each unit's step allowance. Diagonals count as one step. The destination and both orthogonal offsets must fit the entire unit. Charge and Area Shred use the same pathfinding within their own step allowances. Sentinel Breach still travels in a straight cardinal line.

Author a larger unit with an integer `footprint_size` on its unit data. It defaults to 1 and specifies the side length in tiles. The unit's `pos` marks its top-left tile. The battlefield outlines large units and previews the full footprint at a legal destination. Weapon range, LOS and cover still use the unit position while large-unit targeting rules are open.

A rendered Godot 4.7.2 Windows run using OpenGL Compatibility passed 42 automated checks. It deployed fixtures 1–6 using the M selector, number keys and Enter. Added test setups checked player clicks, enemy AI, AP and step accounting, legal detours, Overwatch, hazard entry, footprint overlap and board bounds for 2×2, 3×3 and 4×4 units. The original chain was accelerated by staging the final shot in each of the first two rooms. Input-driven clearance and Enter transitions preserved wounded HP and the zero-or-three Alert Hounds consequence in Room 3. The editor opened the imported project, but Windows automation timed out focusing it for the F5 check. Full unassisted playthroughs and large-unit encounter balance remain unchecked.

### Sabotage IRON GIANT

The IRON GIANT is Sabotage's 2×2 movement test. Press M, choose fixture 3, deploy with Enter and leave the pod active through the end of player Round 3. Its spawn checks all four tiles and uses the nearest legal anchor if the preferred spot is blocked. If no footprint fits, the pod remains active and activation retries at the end of the next player round.

A rendered Godot 4.7.2 Windows run passed 23 automated checks. The default squad used End Turn without moving or firing. The IRON GIANT activated on schedule, and the normal enemy AI took 13 legal steps including five diagonals. Additional setups verified a blocked spawn, a successful retry, single activation and the disable terminal. A full mission clear and F5 launch were outside this retest.

The visual follow-up used the same Godot version and reran activation and movement. At 1460 × 900, the 65 × 60 pixel sprite spanned all four cells of the 72 × 72 pixel footprint. The health and armour bars sat along the bottom of the footprint below the sprite.

### V3 player classes

A rendered Godot 4.7.2 Windows run with OpenGL Compatibility passed 434 checks. A temporary driver staged targets and exercised the normal **Q** menu and tile clicks for 87 active variants, including branch choices, multi-tile targeting, and all Darwinian forms. Focused passive and resource checks covered opportunity attacks, armour break, healing, reactions, smoke, drone cooling and end-of-turn Heat loss. Treatment and broken armour persisted into the next Assassination room.

The driver opened all six original fixtures through **M**, number keys and **Enter**. In fixture 1, staged final shots and normal **Enter** transitions preserved wounded HP and produced zero or three Alert Hounds in Room 3 according to the radio result. Full unassisted V3 playthroughs and balance tuning remain open. The editor opened the imported project, but window activation timed out, so this pass verified launch directly in Godot and left F5 unchecked.

### V3 bunker mission playthroughs

The imported project launched to the Resistance Bunker with **F5** in the Windows Godot 4.7.2 editor. A portable editor copy kept its cache in the workspace. A separate OpenGL Compatibility run at 1460 × 900 used the ordinary bunker menus, Level 9 origin picks, and combat inputs. The driver accelerated animation time and read state to choose moves. It used no room jumps or edits to unit stats, enemies, or objectives during these missions.

| Operation | Result | Origin actions exercised |
| --- | --- | --- |
| Assassination | Cleared the first two rooms and killed Orlov in Room 3. A squad wipe prevented mission completion. | Wolverine Charge, Eye Powers Core Melter, Healing Cell Mender |
| Sabotage | Completed in round 4. Generator and prototype objectives both secured. | Scorpion Deathsting, Psionic Armour Force Shell, Hawk Wings Wing Hop, Artillery Suit Micro-Rocket, Telekinesis Kinetic Slam |
| Rescue | Completed in round 5. Both prisoners freed. | Darwinian Adaptive Technique and Telepathy Intrusive Thought, plus Wolverine, Psionic Armour and Hawk Wings |
| Defence | Completed all eight rounds with 18/20 safehouse HP. | Steel Skin Hammerfist and Drone Command Crossfire Protocol, plus Scorpion, Healing and Telekinesis |

Focused regressions verified that Intrusive Thought reduces a safehouse assault, Mind Lock prevents a second attack, and Gravity Well ends the interrupted movement path at the displaced tile. Fixture 1 preserved HP carry-over and produced zero or three Alert Hounds through normal room transitions after staged final shots. Fixtures 2–6 opened through the selector. The visual check covered fourteen distinct sprites, including the three Darwinian forms. Bunker and mission sprites matched for each deployed origin, and a tactical Darwinian Shift updated the board and squad tab. Personnel armour and movement now include the selected origin's modifiers. The objective panel's help text has its own line.

### Assassination wipe investigation and full clear

The reproduced wipe started Room 3 with all five armour pools already broken and three operatives carrying a prior down. Two Needles eliminated Orlov in round 1. The surviving bodyguards then dealt 13 HP damage in their first phase, permanently taking out both Scythes. Subsequent escort fire wiped the remaining squad. The damage ledger showed ordinary rifle attacks and one shock-hazard hit, with no damage event tied to Orlov's death.

The exit now accepts a living Orlov only after the round-three enemy-phase trigger. The trigger skips an already eliminated Orlov. The objective panel shows the remaining escort count after elimination or escape, and the debrief distinguishes a squad wipe from an escaped target.

The full clear used a rendered Windows Godot 4.7.2 session with OpenGL Compatibility. A driver used the normal Personnel and bunker deployment menus, combat inputs and room transitions with two Level 9 Steel Skin Anvils, two Eye Powers Needles and a Healing Alkhimik. It advanced through the first two rooms in 2 and 8 rounds. The two Needles eliminated Orlov in Room 3 round 1. The squad used ranged fire, cover, healing and retreat to clear all four escorts by round 6. The report recorded 8/8, 6/6 and 5/5 enemies defeated, with all five operatives standing at 1, 1, 6, 11 and 4 HP. The run used no room jumps or state edits. Focused checks staged early exit entry, escape, elimination and a wipe to verify the different outcomes.

## Sabotage visual pass

On 24 November 2026 the imported project ran with **F5** in Godot 4.7.2 on Windows using OpenGL Compatibility. **M → 3 → Enter** opened the 22×16 facility. **F4** restarted in the 28×20 annex. The cover tiers use different widths and markings on their shared edges. Damaged cover gains a notch and destroyed cover disappears as the debris effect plays. The pod opens and the Iron Giant rises into the 2×2 footprint chosen by the spawn rules, including when the preferred spawn is occupied. Enemy actions resume after the reveal.

A separate rendered input run passed 74 checks. It verified move interpolation, melee and shooting playback, barrel detonation with cover loss and fire, the adjacent terminal disable, activation timing and fallback placement, hover on the far corner of the robot, and the mapping from every board cell to its screen position and back. Focused cases staged unit positions. Fixture 1 used targeted final shots and normal room transitions to verify wounded HP carry-over and the 0/3 Alert Hound outcomes on both radio branches. A separate bunker Sabotage run through normal inputs cleared both objectives in round 4 with five survivors.

The annex showed every tile and the full inspector at 1460 × 900. The 20% board reduction still left the walls, cover tiers and Iron Giant footprint visible. At a 720-pixel window height, small objective glyphs and unit details were harder to read. The annex is a comparison layout. A full annex clear and its round-three approach balance remain to be playtested.

## Supersuit and base attacks

The later equipment pass passed 95 integration checks in both headless and rendered Godot 4.7.2 Windows runs. These covered all twelve origins, all three Darwinian forms, ranged charges, Medkits and both radio outcomes. The standard rendered launch exited cleanly. The test harness logged cleanup warnings. The editor F5 recheck timed out during window activation. [Run details](IMPLEMENTATION_NOTES.md#supersuit-and-base-attack-verification).


## Angled battlefield

25 November 2026, Godot **4.7.2** on Windows with OpenGL Compatibility. The editor launched the project with **F5**. **M → 3 → Enter** deployed the 22×16 Sabotage facility, and a live mouse click moved Scythe onto the tile behind the wall at (5, 5). The mouse wheel zooms, middle-button drag pans within the room bounds, and **Home** fits the room. Each new room starts fitted. The finished-game screenshots on pages 3 and 18 guided the tile angle, board edge and placement of terrain and sprites. [Subset Games postmortem](https://media.gdcvault.com/gdc2019/presentations/Into%20the%20Breach%20Postmortem%20Final.pdf).

The input driver passed 83 rendered assertions and 75 headless assertions. It deployed all six selector fixtures and all four bunker operations, moved an operative and ran an enemy phase in each. It checked projected cells at fit and after zoom and pan, board-edge clicks, HUD exclusion, Scythe Charge, and the bunker class ability Siege Momentum. Visual checks covered the 18×14 final arena and 28×20 Sabotage annex. [Sabotage before](angled-view-before.png) · [Sabotage after](angled-view-after.png).

- **Assassination.** The bunker operation cleared Room 2 in round 6. Fixture 2 cleared it in round 11. Both runs cleared Room 1 and used **Enter** for both transitions. The check ended on entry to Room 3.
- **Original three-room chain.** Both runs used normal room transitions. The runs verified wounded HP carry-over and magazine refills on Room 3 entry. The on-time radio destruction produced seven Room 3 enemies. The alert produced ten, including three additional hounds. Both runs reached the final report after squad defeats. The [follow-up](#original-chain-room-3-regression) cleared Room 3 on both branches.
- **Existing validation.** The archived validation file records historical checks. The active workspace contains no runnable copy of that harness. The rendered driver and Godot import covered the current build.

## Original chain Room 3 regression

25 November 2026, Godot **4.7.2** on Windows with OpenGL Compatibility. A rendered input driver started both runs from **M → 1 → Enter** with the default fixture loadout, armour, and tactical AI. It sent keys and projected tile clicks through the Godot viewport and used **Enter** after clearing Rooms 1 and 2. The runs accelerated playback through Godot's time scale. Combat rules and balance stayed as authored. Headless rehearsals produced the same room outcomes.

| Radio branch | Room 3 roster | Room 3 result |
| --- | --- | --- |
| Radio destroyed on time in Room 2 round 1 | 7 enemies, 0 Alert Hounds | Victory in round 5. All 7 enemies defeated and all 5 operatives standing. |
| Radio left active through the deadline | 10 enemies, 3 Alert Hounds | Victory in round 6. All 10 enemies defeated and 3 operatives standing. |

Both runs carried wounded HP forward and refilled magazines on room entry. The final reports recorded all three rooms cleared. Operatives finished at 5, 11, 4, 2 and 5 HP on the timely branch, and 5, 11, 6, 0 and 0 HP on the alert branch, in squad order.

## Camera and combat HUD

Godot **4.7.2** on Windows with OpenGL Compatibility. The wheel zooms around the pointer to a scale of 3.2, about five times the fitted size on the 22×16 facility and six times on the 28×20 annex. Hold **WASD** or drag with the middle mouse button to pan. **Q** and **E** pivot left and right by 90 degrees and wrap through all four views. **Home** fits the current view. Room entry resets the orientation and zoom. **E** remains a shortcut for the Extract to HQ button between cleared bunker rooms.

The selected operative's square buttons expose ranged attacks, melee, reload or recharge, Overwatch, Medkit, and the unlocked abilities and modes for that operative. The Development dropdown exposes the ledger, attack links, threat, AI diagnostics, fixture options and report views where available.

A rendered driver passed 54 checks, including tile picking across all four orientations on 18×14, 22×16 and 28×20 boards, zoom and pan limits, HUD exclusion, the dropdown and rotated fixture and bunker ability targeting. Two rendered original-chain replays used a different orientation in each room and the action bar to select signature abilities. The timely radio branch cleared Room 3 in round 5 with five operatives standing. The alert branch cleared it in round 6 with three operatives standing.

### Action tray and animated pivots

The square action buttons now sit in the bottom-right tray above **End Turn**, as shown in the review markup. The top-right Development dropdown retains its placement. **Q** and **E** animate each 90-degree pivot over 0.34 seconds while keeping the camera tilt. Tile picking follows the intermediate projection throughout the turn.

On Godot **4.7.2** for Windows, the rendered input driver passed 60 checks. These included intermediate projection and picking, queued quarter-turns, zoom anchoring, action clicks in the relocated tray, and dropdown checks. Headless input replays cleared both original-chain radio branches again, with the same seven- and ten-enemy rosters and the same Room 3 clear rounds as the prior rendered runs.

## Unit facing and action playback

25 November 2026. The active project is `source/Hammer_Ash_Godot_2D_Build10/project.godot`. Godot **4.7.2** on Windows ran it with OpenGL Compatibility. Unit facing starts east in logical grid coordinates on each room spawn and persists across actions and turns. **Development → Unit facing arrows** toggles the projected markers. The current cutouts share a foot anchor. Walk, leap, turn and attack timing live in `scripts/unit_playback.gd`.

- **Walk and interruption.** Open **M → 6 → Enter**. Select Anvil with **2** and move from (1, 5) to (4, 6), using zero-based grid coordinates. The path goes through (2, 5) and (3, 5) before turning diagonally. Restart with **R**, then select Scythe's Charge and click the Armoured Guard at (4, 2). The sentry interrupts Charge after its first step. Scythe holds that step's facing, and the sentry faces the tile where it fired.
- **Leap, attack and self-buff.** Set Needle to **Hawk Wings** and Anvil to **Psionic Armour** in Personnel. Deploy **Assassination** from the Central Federal District, choosing Needle first. In the tested run, Needle walked via (5, 1) to (9, 1) and ended the round. On round 2, **Wing Hop** carried Needle to (11, 0) in one arc. Hovering the hound at (10, 0) preserved the landing facing. Clicking turned Needle toward it before the melee sweep. Anvil's **Force Shell** preserved Anvil's last walk facing.
- **Enemy phase and room entry.** End Turn in Assassination showed enemy slides and turns into attacks. In fixture 1, **Enter** loaded each cleared room and accepted input with fresh facing. Both radio branches preserved wounded HP and produced the expected seven- or ten-enemy Room 3 roster.

The rendered input driver passed **73 checks** using the normal action tray, keys and tile clicks. The eight arrow directions were verified against rendered pixels, and the mid-hop frame was inspected. The chain transition checks in that run staged the final attacks. Separate full headless replays cleared Room 3 in round 5 on the timely branch and round 6 on the alert branch, with magazine refills and wounded HP carry-over verified. The existing camera/pivot and Sabotage drivers passed **56/56** and **61/61** headless checks in local copies updated for the current projection and playback wait. The older bunker layout check still expects retired equipment tabs.

The editor opened the imported project. Windows window activation timed out twice before the F5 check. The rendered run launched the active project directly with Godot and exercised its normal input handlers.

## Battlefield-first combat HUD

25 November 2026. Godot **4.7.2** on Windows ran the source project at **1460 × 900** with OpenGL Compatibility. The new viewport, squad bar, labelled actions and contextual details were inspected in Sabotage, the original chain and a Level 9 bunker Assassination setup.

The rendered input driver passed **84 checks**. It opened fixtures **1–6** with **M** and the number keys, deployed with **Enter**, exercised squad and action clicks, movement, wheel zoom, camera pivot and fit, and opened the ledger and Sabotage annex through **Development**. Fixture 1 used staged final attacks and normal board clicks and room transitions. Wounded HP and a spent Medkit carried forward, and the missed radio added three hounds in Room 3. The editor opened the imported project. Window activation timed out twice, so this pass used a direct Godot launch.

The Level 9 bunker layout also fit in a **1280 × 720** window. The smallest captions were harder to read at that size. One launch hit an Intel OpenGL crash during shader initialization. A direct retry rendered all four HUD captures successfully. Full manual playthroughs and readability below 1280 × 720 remain open. [Presentation direction](design/VISION.md#confirmed-presentation-baseline)

## Overwatch in the mixed enemy trials

27 November 2026. Godot **4.7.2** on Windows. The input driver opened Cordon, Foundry, Choir and Vanguard with **M → 7–9 or 0 → Enter** and cleared all nine rooms under three opening and movement policies. Each room started with a fresh fixture squad. The driver chose player actions and used ordinary key and board inputs. Enemy turns used the tactical AI. Choir crossings were replayed from matched positions, with a rendered OpenGL Compatibility capture of the crossing preview.

| Player approach | Enemy cones | Cones with two shots available | Cones that fired twice | Shots on player moves | Overwatch losses |
| --- | ---: | ---: | ---: | ---: | --- |
| Choose moves without considering cones | 4 | 1 | 1 | 4 shots across 213 moves | 4 armour |
| Penalise threatened routes | 4 | 1 | 0 | 0 shots across 211 moves | 0 |
| End the opening turn without acting, then choose moves without considering cones | 16 | 4 | 0 | 3 shots across 164 moves | 4 armour, 1 HP |

- **AI aim.** In the two runs that ignored cones, all 20 cones faced the nearest standing operative. In 18 cases a wall blocked the line to that operative, and 13 cones contained no tile with clear line of sight from the shooter. The slow opening exposed this in several rooms. In Vanguard Room 1, the Siberian twice aimed from (10, 14) at Alkhimik at (8, 14), directly through the wall. In Cordon Room 2 the Grenadier covered 14 tiles and had line of sight to zero of them.
- **Repeat fire in a normal clear.** One Clergy cone in Choir Room 1 spent both shots on separate moves by Scythe and Anvil. Across the two runs that ignored cones, only five cones had the AP and ammo for two shots. None of the observed Overwatch damage downed an operative.
- **Matched routes.** In Choir Room 1, Iskra's four-step, 1 AP route from (15, 10) to (17, 8) took two Clergy shots for 1 armour and 1 HP. The eight-step route through (13, 8) reached the same tile for 2 AP without taking a shot. In Room 2, Anvil's 1 AP route from (12, 12) to (13, 10) cost 1 armour. The 2 AP route through (15, 12) avoided it.
- **Marksman stress case.** In Cordon Room 1, the driver staged Iskra at (12, 0) and set the Marksman's fully loaded cone from its authored position. Clicking (15, 2) drew two 4-damage shots. Full-health Iskra finished at 1 HP from 8 HP and 1 armour. Starting at 6 HP with the same armour, the second shot downed Iskra. The staged position tested the cost of crossing a high-damage cone and did not contribute to the natural AI shot counts.

Repeat fire created manageable pressure in these fresh-room clears. A two-shot Marksman crossing can effectively spend an operative's health bar in one move. The rendered route preview showed the red cone and normal movement cost, so it gave no shot count for the selected path. The strongest follow-ups are to show expected shots on the hovered route and have enemy AI weigh visible approach tiles when it aims. Linked-room attrition and overlapping high-damage cones were outside this sample. [Overwatch rules](design/COMBAT.md#overwatch)
