# Build 10 Windows playtest

22 November 2026 · Godot 4.7.2 stable · Windows · OpenGL Compatibility at 1460 × 900

A temporary test driver ran the unchanged game scene in a rendered window. It sent the normal number keys, tile clicks, ability keys, Space, Enter and mission-menu controls through Godot's input API. It sampled game state for comparisons and accelerated the clock for movement and enemy phases. Tactical AI and armour stayed enabled. Neither room jumps nor direct state edits were used.

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
