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
