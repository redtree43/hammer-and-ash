# Missions

> Earlier mission handoff with worked examples and fixture rules. The active build deploys through the [regional campaign operations](design/MISSIONS.md#regional-playtest-operations).

## Confirmed mission structure

- Standard operations have at most four played stages, usually an entrance, up to two intermediate rooms, and a final room. Special operations can vary. Authored branches progress forward. Completed rooms cannot be revisited.
- Most rooms clear when all hostiles are defeated. Authored objectives can use a different gate. An optional failure or an escaped primary target can affect the mission outcome while the squad still clears the room. Specify any terminal exceptions in advance.
- Voluntary extraction occurs between rooms. Retain explicitly secured rewards, resources, and intelligence. Completed physical consequences such as sabotage can persist after withdrawal. Track casualties and objective outcomes separately.
- Route intelligence varies with preparation, acquired intelligence, and earlier decisions. Cross-room consequences may change enemies, readiness, hazards, resources, information, or outcomes. The intended difficulty trend rises overall with room-to-room variation.
- HP, used consumables, downs, wound ceilings and deaths persist. A still-downed first-down operative stands with half HP between rooms. Healing requires an item or ability. Armour starts the next room at the current maximum, cooldowns reset, and bunker ranged charges and fixture magazines refill. Equipment stays locked for the mission.
- Assassination missions place the named target in the final room. Targets can escape. The approved prototype defence test uses escalating waves on one map.

## Objective model

Track the **room-clear gate**, **lead primary mission objective (PMO)**, any **additional PMO**, and each **secondary mission objective (SMO)** separately. PMOs change campaign state. SMOs generally affect the current or later rooms in the same operation. An objective can have both effects when explicitly authored. Record whether it completed, failed, was abandoned, or was never reached, and whether a portable reward was secured.

| Selected PMO | Tactical demand | Example campaign effect |
| --- | --- | --- |
| Assassinate target | Reach and eliminate a named protected or fleeing target | Disrupt leadership or a programme |
| Destroy facility | Destroy infrastructure or critical systems | Delay production, research, or communications |
| Steal research | Obtain data or samples and secure their transfer or withdrawal | Enable research or a countermeasure |
| Rescue prisoners | Free and secure captives | Retain allies, recruits, or intelligence |
| Seize supplies | Secure resources for recovery | Increase stockpiles and deny logistics |
| Liberate stronghold | Remove occupiers and secure a location | Strengthen local resistance and control |
| Intercept convoy | Stop a moving transport before escape | Interrupt a transfer or obtain its payload |
| Defend base / resistance | Protect an asset, group, or evacuation route | Preserve faction capacity |
| Eliminate prototype threat | Neutralise a specific experimental unit or weapon | Remove immediate danger and affect a technology programme |
| Major boss fight | Win an authored climactic encounter | Change story or command state |

| Selected SMO | Illustrative effect |
| --- | --- |
| Take out officer before alert sounded | Stops or reduces a coordinated alert |
| Disable radio transmitter | Prevents a communications-based readiness or reinforcement modifier |
| Capture intelligence | Reveals likely enemies, routes, or hazards |
| Destroy reinforcement beacon | Cancels a particular wave, potentially despite another alert |
| Secure ammo/supplies cache | Grants a bounded supply benefit |

The guide proposes a lead PMO plus an optional additional PMO, usually zero to two SMOs, a clear tactical pressure per room, and concrete outcome flags. These are working authoring guidelines. Explicitly specify when overlapping alerts combine and when separate reinforcement sources apply. A route trade-off can offer an easier final fight or a different campaign gain.

### Provisional authored examples

**Operation Cold Signal** is the worked example in the mission guide. Its checkpoint radio sets an alert. The next stage offers officer barracks or a supplies cache. The following stage offers an intelligence archive or a reinforcement beacon. The director's command suite is the final assassination room and offers optional research theft. A reported alert affects readiness, while the beacon separately controls a particular wave. Assassination and secured research are independent. Either can succeed with the other failed.

**Operation Red Ledger** is a separate proposed branching vertical-slice candidate named in the 21 November master design. Its final room graph, canon and acceptance status are unverified. Build 10's selectable tests are prototype fixtures. The first complete authored branch with extraction and campaign outcomes remains pending.

## Build 10 test fixtures

The original chain remains playable from HQ via **M → 1 → Enter**. Entries 2–0 below describe retired tests and their historical controls. Campaign deployments now use the [regional operations](design/MISSIONS.md#regional-playtest-operations).

| Selector | Implemented test |
| --- | --- |
| 1. Original chain | Three linear rooms. Kennel/hounds, KGB cordon, elite response. Defeat hostiles to clear. In Room 2 destroy the 2 HP radio before the end of player Round 3. An intact radio at room clear or a missed deadline queues three extra hounds for Room 3. A timely disable preserves the baseline lineup. A pending first down resolves at half HP on transition. The healing cap and second-down loss carry across rooms. |
| 2. Assassination | Three linear rooms. Officer Orlov, 9 HP and 1 armour, appears in Room 3 with four escorts. If alive, he can flee through the east exit from enemy phase 3. A full clear requires eliminating Orlov and all four escorts with at least one operative standing. The report distinguishes Orlov's escape from a squad wipe. |
| 3. Sabotage | One map. Destroy a 6 HP generator and neutralise a 6 HP prototype pod. An adjacent terminal disables the pod for 1 AP. If the pod remains active at the end of player Round 3, the 2×2 IRON GIANT emerges at the nearest clear spawn and killing it substitutes for disabling the pod. Clear the guards and meet the objectives. Bunker success grants 6 Supplies and 2 Intel at current trial values. |
| 4. Rescue | One map. Release two prisoners with 1 AP adjacent interactions and defeat the guards, in either order. The prototype secures released prisoners on completion and has no escort movement. |
| 5. Defence | One map. Protect a 20 HP safehouse through eight full enemy rounds. Waves enter at the start of player Rounds 1, 3, 5 and 7. The entry-lane warning appears one round ahead. Success allows surviving attackers at Round 8. |
| 6. Scythe | One test room with an armoured guard, an Overwatch sentry and a hound. Choose Wolverine, Arachnid, Blink or Standard on Scythe's loadout tab. Use the **Charge** action button. **J** aims Claws when Wolverine is selected, and **Z** aims Short Blink when Blink is selected. The sentry starts with Overwatch reserved. |
| 7. Cordon patrol | Two rooms mixing KGB troops with Collectivist Drones and Hammer. |
| 8. Foundry shift | Two rooms built around robot escorts and anchors, with KGB support and Red Star. |
| 9. The choir | Two rooms built around abominations, with KGB Riflemen and Sickle. |
| 0. Vanguard trials | Three rooms featuring Proletariat and Siberian, New Soviet Man and New Soviet Woman, and Vanguard. |

The mixed trials show room XP for comparison. Campaign XP is awarded through bunker operations. [Enemy tiers and XP verification](IMPLEMENTATION_NOTES.md#enemy-tier-and-xp-trial-verification)

The earlier bunker trial put Assassination, Sabotage, Rescue and Defence in Central. The Sabotage fixture also had a 28×20 annex selected with **F4**. Its verification is preserved in the [Sabotage visual playtest](BUILD_10_PLAYTEST.md#sabotage-visual-pass).

Primary sources are the [Mission Objectives Master Guide](../references/design/Hammer_and_Ash_Mission_Objectives_Master_Guide.docx), 21 November master and combat documents, mission conversation excerpts, and Build 10 README, changelog, and source.
