# Mission structure and objectives

## Regional playtest operations

**27 November 2026, creator's campaign cleanup request in chat.** Move mission and combat testing into the campaign. Each open district has four operations with different enemy combinations and battlefield layouts. Use the approved roster and author some high cover and high ground. Defer bosses. Retire the old bunker operations and stand-alone combat tests. Keep the original three-room chain accessible for regression as specified in the project handoff.

**Current playtest content.** The four operation patterns are patrol clearance, generator sabotage, two-prisoner rescue and a three-stage depot sweep. Sites vary formations and terrain by district. Clear the hostiles in each room. Relay and rescue operations also require their stated objectives. A successful relay operation secures 6 Supplies and 2 Intel. A successful rescue secures a Needle recruit and 4 Supplies. These are trial rewards. Sweeps support controlled extraction after a cleared intermediate room. Reinforced cover uses the current cover rules. Relay sites and final sweep yards mark walkable high ground for High Perch testing. Elevated shot geometry, climb and range tuning remain in review. Production mission selection, final layouts and canon remain open. [Campaign availability](CAMPAIGN.md#regional-campaign-playtest) · [Elevation](COMBAT.md#elevation)

**27 November 2026, creator’s sweep balance request in chat.** Build 10 trials stronger five-enemy formations in the Inner Checkpoint and Upper Depot Yard across all seven regional sweeps. Keep the same enemy stat profiles, posts, terrain and Depot Approach formations. Checkpoints introduce a durable threat alongside screening or support units. Final yards pair threats that reward target selection and flanking. The comparison uses the same five operatives at each site at Levels 1, 3, 5, 7 and 9 against the previous and trial lineups. In the follow-up that day, the creator confirmed keeping the stronger lineups for the current playtest and requested different squads at the same five levels for Northwestern and Volga. Minimum-level advice from that test remains provisional. [Sweep formation comparison](../BUILD_10_PLAYTEST.md#27-november-sweep-formation-comparison)

**27 November 2026, creator’s briefing decision in chat.** The Freight Yard Sweep briefing recommends Level 9 for general squads and Level 7 with fire support. The Weir Compound Sweep briefing recommends Level 9 for general squads and Level 3 with fire support. Both sweeps remain open at any level. [Squad retest](../BUILD_10_PLAYTEST.md#27-november-northwestern-and-volga-squad-retest)

**27 November 2026, creator’s follow-up in chat.** Add advisory minimums to the other five sweep briefings using the alternate-squad retest. Floodplain recommends Level 3 and Coastal Depot recommends Level 7 for all squads. Pass Road recommends Level 9 or Level 5 with fire support. Ore Terminal recommends Level 9 or Level 3 with fire support. Timber Depot recommends Level 7 or Level 1 with fire support. Deployment remains open at any level. [Remaining five sweep retests](../BUILD_10_PLAYTEST.md#27-november-remaining-five-sweep-retests)

**27 November 2026, creator’s patrol, relay and rescue follow-up in chat.** All 21 one-room operations show advisory minimum levels drawn from the two-squad retest at Levels 1, 3, 5, 7 and 9. Where fire support supports a lower minimum, show that value alongside the general advice. The values are briefing guidance and deployment remains open at any level. [Retest and briefing values](../BUILD_10_PLAYTEST.md#27-november-patrol-relay-and-rescue-retest)

### Original chain regression

From HQ, press **M → 1 → Enter** to open the retained three-room fixture. Progress with **Enter** after each clear to test HP and wound carry-over. Disable the Room 2 transmitter before the end of player Round 3 and before clearing the room to preserve the baseline Room 3 lineup. A missed deadline or an intact radio at room clear adds three Alert Hounds. **F6–F8** are isolated room jumps with a fresh squad. [Fixture history](../MISSIONS.md#build-10-test-fixtures) · [Current controls](../../source/Hammer_Ash_Godot_2D_Build10/README_FIRST.txt)

## Confirmed operation rules

- A standard operation has at most four played stages, usually an entrance, up to two intermediate rooms and a final room. Special operations can vary. Authored branches go forward and completed rooms cannot be revisited.
- Most rooms clear when all hostiles are defeated. Authored objectives can use different gates. An optional failure or an escaped primary target can affect the mission outcome while the room still clears. Author any terminal exceptions explicitly.
- Voluntary extraction happens between rooms. Keep explicitly secured rewards, resources and intelligence. Completed physical consequences such as sabotage can persist after withdrawal. Track casualties separately from objective outcomes.
- Route intelligence can depend on preparation, acquired intelligence and earlier choices. Cross-room consequences can change enemies, readiness, hazards, resources, information and outcomes. Difficulty generally rises across the operation with room-to-room variation.
- HP, consumed items, downs, healing ceilings and deaths carry forward. Equipment locks for the mission. Room entry clears temporary combat statuses, resets cooldowns and applies the [room-entry armour rules](COMBAT.md#confirmed-rules-and-working-baselines). Apply the [recovery rules](COMBAT.md#downing-and-recovery). The creator confirmed the status reset on 25 November 2026 in the Open Decisions review.
- Assassination places the named target in the final room. The target can escape if the authored scenario allows it.

## Confirmed objective model

Track the room-clear gate, lead primary mission objective (PMO), each additional PMO and each secondary mission objective (SMO) separately. PMOs change campaign state. SMOs generally affect the current or later rooms of the same operation. An explicitly authored objective can do both. Record completion, failure, abandonment or whether the objective was never reached, and track whether portable rewards were secured.

Separate mission alert consequences stack by default. Each triggered alert applies its own consequence unless the mission explicitly overrides how the alerts combine. The creator confirmed this rule on 25 November 2026 in the Open Decisions review.

## Secured rewards

Define the securing condition for each reward-bearing objective and show it in that objective’s text. Securing a reward and winning the overall operation are tracked separately. For example, an objective can secure its reward as soon as the squad gathers it in a specified room, allowing the player to keep it when extracting early even if the overall mission is lost.

The creator confirmed this rule on 25 November 2026 in the Open Decisions review. Individual securing conditions are authored with their missions. [Open mission decisions](OPEN_DECISIONS.md#missions)
