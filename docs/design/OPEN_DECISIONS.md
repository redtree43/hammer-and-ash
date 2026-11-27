# Open design decisions

These items need creator review before they become permanent rules. Each item names the decision still needed and, where relevant, how the prototype can mislead a reviewer. The owner documents govern the approved parts.

## Review status

Updated for the 27 November 2026 regional playtest and class implementation. The items below track unresolved rules, tuning and verification.

## Combat

| Decision | What needs review |
| --- | --- |
| Damage, armour and cover | Decide whether untyped damage uses general resistance or ability-specific mitigation. If percentage resistance is kept, review the earlier model of additive reductions with a cap below 100%, after cover and before armour, with full immunity only by explicit rule. Exact percentages and rounding were open for tuning. Tune the flat half-cover reduction and define cover edge priority and other modifier ordering. Assign piercing and maximum-armour loss or protection to specific effects. Reconcile earlier burst, explosive and move-and-strike proposals with the confirmed attack rules. [Cover and armour rules](COMBAT.md#confirmed-rules-and-working-baselines) · [Damage resolution](COMBAT.md#damage-resolution) · [Armour piercing](COMBAT.md#armour-piercing) |
| Footprints, movement and elevation | Confirm corner shots and line ties, climbing paths, the size and eligibility of the high-ground range bonus, melee reach and how previews show firing and target tiles for multi-tile units. Define which drops count as falls. Fall damage bypasses armour. [Movement and targeting](COMBAT.md#confirmed-rules-and-working-baselines) · [Elevation rule](COMBAT.md#elevation) · [Fall damage](COMBAT.md#collision-and-displacement) |
| Reactions | The 27 November Overwatch decisions define the visible cone, reach, far-end width, movement lock, shot costs, route shot preview and wall-aware enemy aim. Playtest cone coverage at diagonal angles and on large footprints, the two-move AI approach horizon, and overlapping high-damage cones. Confirm class-specific triggers and priority when reactions overlap. [Overwatch rules](COMBAT.md#overwatch) |
| Ranged resource tuning | Charge eligibility is confirmed and attack assignments will come from the creator’s class redesign. After that, confirm capacity, recharge cost, room-entry refills and Emergency Reload. Build 10 gives Sightline, Arc Pistol and Suit Cannon three charges and a 1 AP recharge. Enemy and fixture kits use firearm magazines. The 1 AP special-ability costs are prototype tuning. [Confirmed rule](COMBAT.md#ranged-attack-resources) |
| Statuses and hazards | Confirm Irradiated tick damage, additional Blinded and Bleeding application sources beyond the playable class abilities, and the full effect list, durations and immunity. Confirm the damage floor and modifier order for Blinded. Specify when hazards apply a status again and which effects shorten or prevent it. Define ordering relative to armour and AP refresh, cover materials and the abilities or hazards that explicitly damage them. [Confirmed status effects](COMBAT.md#status-effects) · [Room transitions](MISSIONS.md#confirmed-operation-rules) |
| Recovery pacing | Test the confirmed two-turn recovery, healing ceiling, and carry-over for attrition and tactical pacing. Long-term wounds and treatment are a [campaign decision](#campaign-and-headquarters). |

## Classes, equipment and enemies

**Class trees in creator review, 25–26 November 2026.** The creator supplied Jaguar as the reference and requested [eleven companion trees](ORIGIN_TREES_REVIEW.html). The creator subsequently reviewed origin and shared nodes in chat. Build 10 uses the reviewed origin trees for bunker operations. The [staged class checks](../IMPLEMENTATION_NOTES.md#class-review-implementation-preview) cover branch choices, capstones and linked-room carry-over. [Creator’s revisions](CLASSES_AND_ENEMIES.md#confirmed-redesign-direction)

**Charge interaction, 26 November 2026.** Jaguar and Scorpion share the movement-only Charge. Verify the bonus on standard moves and basic melee approaches. [Basic melee rule](COMBAT.md#confirmed-rules-and-working-baselines)

Pinion Guard and Heat Jacket use flat 1 damage reduction in the playtest. Verify eligible hits and expiration timing.

| Decision | What needs review |
| --- | --- |
| Scorpion redesign | Playtest the once-per-room Moulting Skin cleanse and Venom Jet’s cone on maps with mixed hazards. Confirm whether non-attack damage qualifies for Burrow Defense and when immunity ends if it triggers in the player phase. Confirm Claw Grab duration, Burrowing Strike traversal and Venom interactions. |
| Shared Anvil nodes | Confirm Taunt targeting exceptions and fallback if no legal attack exists. Set the Protecting Interceptor zone, movement allowance and reaction priority. Playtest the confirmed Linebreaker charge on narrow and diagonal approaches. |
| Steel Skin | Confirm Throw eligibility for heavy or multi-tile targets and playtest the 27 November collision rules. Confirm the area-taunt radius and friendly fire for the Gleaming Armour cone. Confirm Plastic Skin expiry, area and hazard interactions, and the ranged damage floor for Shining Knight. |
| Psionic Armour | Playtest Level 1 Lend Armour, Returning Mantle and Returning Defence with both protection actions. Confirm Encasing Armour range. Compare Pressure Front’s new armour-scaled damage with retaining armour for the enemy phase. |
| Revised node tuning | Set AP costs, cooldowns and use limits for revised nodes where the creator did not specify them. Plastic Skin carries forward its prior provisional cost, limit and expiry for review. |
| Iskra redesign | Compare Assault’s Overwatch disruption with Guardian’s route protection in live encounters. Review the frequency and severity of early drone loss and how useful the operator remains afterward. For Artillery, compare the value of committing to Anchor and spending Heat on open maps and in cramped rescues. [Approved trees](CLASSES_AND_ENEMIES.md#27-november-iskra-redesign) |
| Healing rework | Track the share of active player turns spent in each form across linked rooms. Aim for roughly two Jekyll turns per Hyde turn. Test the proposed once-per-room transformation, one- or two-turn burst and reduced-AP recovery across short and long rooms. Confirm duration and penalty after playtesting. Verify rescue movement, quarantine and hospital entry timing, and identical shared-node behavior in all five Alkhimik forms. |
| Needle revisions | Playtest the owner-only Designate Target bonus, the updated Eye Powers damage and blindness, and flight targeting in tight maps. Confirm Stooping Strike Slow and target immunities to Freeze. Compare High Perch openings on relay platforms and the final sweep yards. |
| Glaz revisions | Confirm organic and boss eligibility for Telepathy and test Feedback Spike against enemies with available, spent or suppressed reactions. Check displacement weights, collision resolution and Hurl Debris preview. Test the shared repositioning abilities against hazard and reaction timing, and Telepathy in a robot-heavy room with an organic controller or escort. Fold Space remains an optional teleport proposal, outside the current review trees. |
| Class progression and balance | Playtest shared XP and the Level 1-3 trial, then set campaign-wide XP pacing and the Level 4-9 curve. Respecialisation and experienced-recruit progression remain open. Manual Levels 1-9 remain available for development. Review class and origin stat bonuses and mission balance against the confirmed [level 1 baseline](CLASSES_AND_ENEMIES.md#level-1-base-stats). Verify ability gates, resistance, range and costs through linked rooms. Alternate class names are still candidates. |
| Darwinian forms and copy effects | Test switching versus staying in each of the three forms, including room-entry persistence and whether separate signature cooldowns encourage rotation without making it compulsory. Verify Frog landing and pulls, Jellyfish Stun eligibility and expiry, Skunk trail entry timing and counterplay, and multi-signature targeting. Confirm final art. Decide which layouts need smoke or water. |
| Supersuit and consumables | Define the variant roster and tiers, reward sources and requisition details, inventory, field securing conditions and how innate and suit protection combine. Decide whether variants have requirements beyond class. Set default consumable capacity and specific class and Supersuit allowances. Confirm inventory limits, Medkit tuning, recipe batch size, queue and refund rules. Build 10 issues one suit and allows one consumable slot. [Supersuit and consumable rules](COMBAT.md#equipment) |
| Enemy roster and behaviour | Playtest the [regional operations](MISSIONS.md#regional-playtest-operations) with mixed and single-role squads, then set production encounter budgets, specialist rarity and XP pacing. Retest advanced equipment and stratagem combinations as they become playable. Confirm awareness, target scoring, role priorities, morale, escalation and intent previews. Decide how often specialist gates occur and how they are telegraphed. |

[Scorpion and Anvil review trees](ORIGIN_TREES_REVIEW.html#tree0) · [Build 10 class controls and tuning](../IMPLEMENTATION_NOTES.md#class-review-implementation-preview)

## Missions

- **First authored branch.** Production mission selection and canon are open. When authoring the first production branch, confirm its name, forward room graph, gates, lead and optional objectives, and campaign consequences. Cold Signal is a worked example and Red Ledger is a proposed vertical-slice candidate. [Regional playtest operations](MISSIONS.md#regional-playtest-operations) · [Earlier mission handoff](../MISSIONS.md#provisional-authored-examples)
- **Objective resolution.** Define deadlines, alert effects and authored stacking overrides, reinforcements, partial success, wipe and other scripted exceptions. Apply the per-objective securing rule when writing individual missions. Decide which rescue variants require escort and when recruitment or intelligence becomes persistent. [Alert and objective rules](MISSIONS.md#confirmed-objective-model) · [Secured rewards](MISSIONS.md#secured-rewards)
- **Content scope.** Run the four regional mission patterns through full play and tune authored pressure per room. Confirm final mission layouts, repeatability and eligible routes. [Regional playtest operations](MISSIONS.md#regional-playtest-operations)

## Campaign and headquarters

| Decision | What needs review |
| --- | --- |
| Regional progress and rewards | Author skip consequences per operation and define other events that raise local pressure. Set liberation progress amounts and liberation and lockout thresholds. Define boss variants and specialisations and the conditions and amounts of limited HQ recovery help. |
| Strategic timing and adaptation | Define each modifier’s end condition and geographic reach, which outcomes change the escalation meter, how adaptation is measured and signalled, and soft-counter selection. |
| HQ, research and Intel | Decide the facility list, visual scope, research catalogue, prerequisites and costs. Define support slots, charges, AP and activation timing, deduction and refunds, counterplay and the allowed mission hooks. [Immediate research unlocks](CAMPAIGN.md#economy-workshop-and-research) |
| Roster, wounds and recovery | Decide starting roster, recruit quality and restrictions, recruitment conditions and costs, emergency recruit details, lasting injuries, and how much recovery each operation outcome or skip provides. Define other effects of Skip Operation. [Deployment and recovery rules](CAMPAIGN.md#headquarters-and-personnel) |
| Decision 22 | Choose the specific effects of each permanent Soviet escalation stage. The approved scope covers campaign conditions and newly deployed tactical missions. The meter caps at the final stage. [Escalation rules](CAMPAIGN.md#victory-defeat-and-soviet-response) |
| Decision 23 | Choose the depth of the Soviet strategic response. |
| Decision 24 | Define each boss’s strategic actions, what triggers them and how they are signalled to the player. Bosses can act before the liberation operation. [Regional campaign rules](CAMPAIGN.md#confirmed-campaign-structure) |
| Decision 25 | Define the catalogue, eligibility, frequency and consequences of strategic events. Milestones can use authored triggers or random draws. [Campaign structure](CAMPAIGN.md#confirmed-campaign-structure) |
| Decision 26 | Define the Moscow operations, their sequence and objectives. [Confirmed finale rules](CAMPAIGN.md#victory-defeat-and-soviet-response) |
| Decision 27 | Define how defeat is presented. The two campaign defeat conditions and what counts as a Politburo loss are confirmed. [Campaign defeat rules](CAMPAIGN.md#victory-defeat-and-soviet-response) |

The six numbered Stage 5 items were documented as unselected in the workshop transfer. [Campaign decision audit](../campaign/H_A_Campaign_Decision_Register_v05.md#numbered-decision-audit)

### Escalation and Soviet programmes

Specify which outcomes change the escalation meter and set the size of the uniform increase from district liberation. Define activation limits for each threshold. Each programme can activate once per campaign, and its modifier defines when the effect ends. Build 10 has an HQ calendar and player research, with the Soviet systems still to be implemented. [Campaign rules](CAMPAIGN.md#victory-defeat-and-soviet-response)

## Presentation, production and evidence

- **Battlefield readability.** Review the angled projection, unit scale, selection, cover edges, platform markings, occlusion and pan/zoom on regional layouts. Bounded pan and pivot are playable. [Angled battlefield checks](../BUILD_10_PLAYTEST.md#angled-battlefield)
- **Combat animation.** Review action pacing, impact readability and effect overlap in busy enemy phases after the 27 November presentation pass. [Build 10 visual pass](../IMPLEMENTATION_NOTES.md#27-november-combat-presentation-pass)
- **Combat interface.** Review the left squad selectors and yellow action icons in regular play, especially readability at smaller window sizes and with advanced builds. Final UI art remains open. [Presentation baseline](VISION.md#confirmed-presentation-baseline)
- **Production scope.** Confirm final art and animation scope, audio, accessibility, interface and content volume, release model and target platforms.
- **Missing evidence.** Complete original project instructions, full conversation transcripts and the attachment inventory were unavailable during migration. The missing Enemy Design Framework and any standalone Red Ledger spec could clarify the roster or mission decisions. Keep conflicting or unattested details open until the creator confirms them. [Migration coverage](../DEVELOPMENT_STATUS.md#migration-coverage-and-gaps)

**26 November enemy roster review.** Test the cost of screens, support and anchor combinations across families. The 27 November level check found low down rates even with fresh Level 1 squads. The creator kept the stronger checkpoint and final-yard lineups for the current Build 10 playtest. Permanent formation tuning remains open. The creator set advisory minimums for Northwestern and Volga, requested playtest-derived minimums for the other five sweeps and confirmed deployment stays open at any squad level. [Squad retest](../BUILD_10_PLAYTEST.md#27-november-northwestern-and-volga-squad-retest) No universal family power tier is approved. The nuclear Grenadier, a second Man of Steel chassis, Red Star's proposed energy role and the detailed tuning of other prototype signatures remain open.
