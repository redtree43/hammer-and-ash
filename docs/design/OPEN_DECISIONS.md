# Open design decisions

These items need creator review before they become permanent rules. Each item names the decision still needed and, where relevant, how the prototype can mislead a reviewer. The owner documents govern the approved parts.

## Review status

The 25 November 2026 review pass is complete. The items below track unresolved rules, deferred redesigns, content, tuning and verification.

## Combat

| Decision | What needs review |
| --- | --- |
| Damage, armour and cover | Decide whether untyped damage uses general resistance or ability-specific mitigation. If percentage resistance is kept, review the earlier model of additive reductions with a cap below 100%, after cover and before armour, with full immunity only by explicit rule. Exact percentages and rounding were open for tuning. Tune the flat half-cover reduction and define cover edge priority and other modifier ordering. Assign piercing and maximum-armour loss or protection to specific effects. Reconcile earlier burst, explosive and move-and-strike proposals with the confirmed attack rules. [Cover and armour rules](COMBAT.md#confirmed-rules-and-working-baselines) · [Damage resolution](COMBAT.md#damage-resolution) · [Armour piercing](COMBAT.md#armour-piercing) |
| Footprints, movement and elevation | Confirm corner shots and line ties, climbing paths, the size and eligibility of the high-ground range bonus, melee reach and how previews show firing and target tiles for multi-tile units. Define which drops count as falls. Fall damage bypasses armour. [Movement and targeting](COMBAT.md#confirmed-rules-and-working-baselines) · [Elevation rule](COMBAT.md#elevation) · [Fall damage](COMBAT.md#collision-and-displacement) |
| Reactions | Overwatch redesign is deferred at the creator’s request. The intended area is set and visible. Later, define how it is set, its shape, trigger and resolution order, expiry and resource spending. Confirm class-specific triggers, enemy eligibility and priority when events overlap. [Overwatch rules](COMBAT.md#overwatch) |
| Ranged resource tuning | Charge eligibility is confirmed and attack assignments will come from the creator’s class redesign. After that, confirm capacity, recharge cost, room-entry refills and Emergency Reload. Build 10 gives Sightline, Arc Pistol and Suit Cannon three charges and a 1 AP recharge. Enemy and fixture kits use firearm magazines. The 1 AP special-ability costs are prototype tuning. [Confirmed rule](COMBAT.md#ranged-attack-resources) |
| Statuses and hazards | Confirm Irradiated tick damage, Blinded and Bleeding application sources, and the full effect list, durations and immunity. Confirm the damage floor and modifier order for Blinded. Specify when hazards apply a status again and which effects shorten or prevent it. Define ordering relative to armour and AP refresh, cover materials and the abilities or hazards that explicitly damage them. [Confirmed status effects](COMBAT.md#status-effects) · [Room transitions](MISSIONS.md#confirmed-operation-rules) |
| Recovery pacing | Test the confirmed two-turn recovery, healing ceiling, and carry-over for attrition and tactical pacing. Long-term wounds and treatment are a [campaign decision](#campaign-and-headquarters). |

## Classes, equipment and enemies

**Class trees in creator review, 25–26 November 2026.** The creator supplied Jaguar as the reference and requested [eleven companion trees](ORIGIN_TREES_REVIEW.html). The creator subsequently reviewed origin and shared nodes in chat. Build 10 uses the reviewed origin trees for bunker operations. The [staged class checks](../IMPLEMENTATION_NOTES.md#class-review-implementation-preview) cover branch choices, capstones and linked-room carry-over. [Creator’s revisions](CLASSES_AND_ENEMIES.md#confirmed-redesign-direction)

**Charge interaction, 26 November 2026.** Jaguar and Scorpion share the movement-only Charge. Verify the bonus on standard moves and basic melee approaches. [Basic melee rule](COMBAT.md#confirmed-rules-and-working-baselines)

Pinion Guard and Heat Jacket use flat 1 damage reduction in the playtest. Verify eligible hits and expiration timing.

| Decision | What needs review |
| --- | --- |
| Scorpion redesign | Test Moulting Skin after armour-breaking hits, including lethal spillover. Confirm whether non-attack damage qualifies for Burrow Defense and when immunity ends if it triggers in the player phase. Confirm Claw Grab duration, Burrowing Strike traversal and Venom interactions. |
| Shared Anvil nodes | Confirm Taunt targeting exceptions and fallback if no legal attack exists. Set the Protecting Interceptor zone, movement allowance and reaction priority. Confirm Linebreaker’s two-tile knockback, travel distance, cover damage and impact damage. |
| Steel Skin | Set Throw’s weight, landing and damage rules. Set the radii for Gleaming Armour and Thundering Taunt and confirm friendly fire for the blind. Confirm Plastic Skin expiry, area and hazard interactions, and the ranged damage floor for Shining Knight. |
| Psionic Armour | Test Long Mantle, Returning Mantle, Shock Grapple and Mantle Recall with either Level 3 protection. Confirm Encasing Armour range. Pressure Front’s two-tile radius, 3 damage and one skipped refresh and Shelter Reflex’s next-turn expiry passed staged checks using creator-approved playtest values. |
| Revised node tuning | Set AP costs, cooldowns and use limits for revised nodes where the creator did not specify them. Plastic Skin carries forward its prior provisional cost, limit and expiry for review. |
| Drone Command rework | Compare Chain Arc and Rolling Barricade over linked rooms. Verify arc visibility and target previews around walls, shield-edge placement and angles, and how swaps and mines interact with movement reactions. Review activation costs, drone HP, room-entry placement, and recovery between operations. Test whether the light suit can still contribute after early drone loss. Confirm Emergency Rebuild eligibility and placement. |
| Healing rework | Track the share of active player turns spent in each form across linked rooms. Aim for roughly two Jekyll turns per Hyde turn. Test the proposed once-per-room transformation, one- or two-turn burst and reduced-AP recovery across short and long rooms. Confirm duration and penalty after playtesting. Verify rescue movement, quarantine and hospital entry timing, and identical shared-node behavior in all five Alkhimik forms. |
| Needle revisions | Confirm damage and reach tuning at Level 6, and Slow’s amount and timing. The creator approved a second designation refreshing the Vulnerable allowance to three. Test staggered designations in a live squad for balance. Confirm target immunities to Freeze. Verify cover bypass against protected angles and solid geometry, and confirm Burning and Bleeding timing on the capstones. |
| Glaz revisions | Confirm organic and boss eligibility for Telepathy and test Feedback Spike against enemies with available, spent or suppressed reactions. Check displacement weights, collision resolution and Hurl Debris preview. Test the shared repositioning abilities against hazard and reaction timing, and Telepathy in a robot-heavy room with an organic controller or escort. Fold Space remains an optional teleport proposal, outside the current review trees. |
| Class progression and balance | Playtest shared XP and the Level 1-3 trial, then set campaign-wide XP pacing and the Level 4-9 curve. Respecialisation and experienced-recruit progression remain open. Manual Levels 1-9 remain available for development. Review class and origin stat bonuses and mission balance against the confirmed [level 1 baseline](CLASSES_AND_ENEMIES.md#level-1-base-stats). Verify ability gates, resistance, range and costs through linked rooms. Alternate class names are still candidates. |
| Darwinian forms and copy effects | Test switching versus staying in each of the three forms, including room-entry persistence and whether separate signature cooldowns encourage rotation without making it compulsory. Verify Frog landing and pulls, Jellyfish Stun eligibility and expiry, Skunk trail entry timing and counterplay, and multi-signature targeting. Confirm final art. Decide which layouts need smoke or water. |
| Supersuit and consumables | Define the variant roster and tiers, reward sources and requisition details, inventory, field securing conditions and how innate and suit protection combine. Decide whether variants have requirements beyond class. Set default consumable capacity and specific class and Supersuit allowances. Confirm inventory limits, Medkit tuning, recipe batch size, queue and refund rules. Build 10 issues one suit and allows one consumable slot. [Supersuit and consumable rules](COMBAT.md#equipment) |
| Enemy roster and behaviour | Playtest encounter budgets and XP pacing with the [assigned roster tiers](CLASSES_AND_ENEMIES.md#enemy-tiers). Confirm awareness, target scoring, role priorities, morale, escalation and intent previews. Test mixed and single-class squads and decide how often specialist gates occur and how they are telegraphed. |

[Scorpion and Anvil review trees](ORIGIN_TREES_REVIEW.html#tree0) · [Build 10 class controls and tuning](../IMPLEMENTATION_NOTES.md#class-review-implementation-preview)

## Missions

- **First authored branch.** Production mission selection and canon are open. Build 10 missions are tests. When authoring the first production branch, confirm its name, forward room graph, gates, lead and optional objectives, and campaign consequences. Cold Signal is a worked example and Red Ledger is a proposed vertical-slice candidate. [Prototype mission scope](MISSIONS.md#prototype-mission-scope) · [Earlier mission handoff](../MISSIONS.md#provisional-authored-examples)
- **Objective resolution.** Define deadlines, alert effects and authored stacking overrides, reinforcements, partial success, wipe and other scripted exceptions. Apply the per-objective securing rule when writing individual missions. Decide which rescue variants require escort and when recruitment or intelligence becomes persistent. [Alert and objective rules](MISSIONS.md#confirmed-objective-model) · [Secured rewards](MISSIONS.md#secured-rewards)
- **Content scope.** Decide the first set of mission layouts, authored pressure per room and eligible routes. The four bunker operations and ten selector fixtures are regression and playtest content. [Build 10 fixtures](../MISSIONS.md#build-10-test-fixtures)

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

- **Battlefield readability.** Review the angled projection, unit scale, selection, cover edges, occlusion and pan/zoom on both Sabotage maps. Bounded pan and pivot are playable. Check the full 28×20 annex clear and round-three approach before locking the layout. [Angled battlefield checks](../BUILD_10_PLAYTEST.md#angled-battlefield)
- **Combat interface.** Review the Build 10 battlefield-first HUD in regular play, especially readability at smaller window sizes and the action bar on advanced builds. The creator confirmed the presentation direction on 25 November 2026. Final layout and art remain open. [Presentation baseline](VISION.md#confirmed-presentation-baseline)
- **Production scope.** Confirm final art and animation scope, audio, accessibility, interface and content volume, release model and target platforms.
- **Missing evidence.** Complete original project instructions, full conversation transcripts and the attachment inventory were unavailable during migration. The missing Enemy Design Framework and any standalone Red Ledger spec could clarify the roster or mission decisions. Keep conflicting or unattested details open until the creator confirms them. [Migration coverage](../DEVELOPMENT_STATUS.md#migration-coverage-and-gaps)

**26 November enemy roster review.** Test the cost of screens, support and anchor combinations across families. No universal family power tier is approved. The nuclear Grenadier, a second Man of Steel chassis, Red Star's proposed energy role and the detailed tuning of other prototype signatures remain open.
