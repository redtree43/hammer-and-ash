# Classes and enemies

## Confirmed class identities

Six classes have distinct tactical roles. Each class has shared skills and two exclusive origins. Class abilities occupy no equipment slots. The identities below are the current baseline. Complete ability trees, progression and tuning remain subject to review. [Class handoff](../CLASSES_AND_ENEMIES.md)

| Class | Role | Origins |
| --- | --- | --- |
| Scythe | Close-quarters striker | Jaguar / Scorpion |
| Anvil | Frontline bruiser | Steel Skin / Psionic Armour |
| Glaz | Battlefield distorter | Telepathy / Telekinesis |
| Needle | Priority-target eliminator | Eye Powers / Hawk Wings |
| Iskra | Remote support and heavy-fire specialist | Drone Command / Artillery Suit |
| Alkhimik | Adaptive generalist and field medic | Darwinian / Jekyll / Hyde |

## Level 1 base stats

**27 November 2026, creator’s player-class stat change in chat.** Every level 1 player operative starts from the following shared values. Apply class, origin, form and equipped Supersuit modifiers to this baseline.

| Stat | Base value |
| --- | ---: |
| Starting and maximum HP | 12 |
| Standard attack damage | 4 |
| Starting and maximum armour | 0 |
| Standard ranged attack reach | 8 tiles |
| Standard move | 4 tiles per 1 AP |

Individual class and Supersuit stat bonuses are defined by their own rules. [Movement and attack resolution](COMBAT.md#confirmed-rules-and-working-baselines) · [Supersuit rules](COMBAT.md#equipment)

**27 November 2026, creator’s HP progression decision in chat.** Every class and origin gains 1 maximum HP per level after Level 1. Before bonuses, an operative has 12 max HP at Level 1 and 20 at Level 9. Add unlocked class and origin HP bonuses and the equipped Supersuit’s HP bonus. Personnel displays the same maximum HP the operative has in combat. Fresh deployments start at full HP. Wounds carry across rooms under the existing recovery rules. [Armour and HP rules](COMBAT.md#confirmed-rules-and-working-baselines)

## Base attacks

| Class | Melee | Ranged |
| --- | --- | --- |
| Scythe | Jaguar, Scorpion | |
| Anvil | Steel Skin, Psionic Armour | |
| Glaz | | Telepathy, Telekinesis |
| Needle | Hawk Wings | Eye Powers |
| Iskra | | Drone Command, Artillery Suit |
| Alkhimik | Darwinian Frog and Jellyfish, Healing (Hyde) | Darwinian Skunk, Healing (Jekyll) |

Changing Darwinian or Healing form immediately changes the active base attack. In Build 10, Sightline, Arc Pistol and Suit Cannon use rechargeable charges. Origin and form modifiers can change the shared Level 1 damage and reach, as in the [Iskra redesign](#27-november-iskra-redesign) and the [Darwinian update](#27-november-glaz-and-alkhimik-implementation). Operatives with a melee base attack can approach an enemy and strike for 1 AP total. The attack table fixes the intended melee/ranged identity. Ability and form details are tracked for review. [Combat rules](COMBAT.md#confirmed-rules-and-working-baselines) · [Open decisions](OPEN_DECISIONS.md#classes-equipment-and-enemies)

## Confirmed redesign direction

**25 November 2026, creator's Jaguar reference and eleven-origin design brief.** Jaguar is the reference for the intended Scythe identity and tree structure. Wolverine appeared in the retired Scythe test range. The [eleven companion trees](ORIGIN_TREES_REVIEW.html) are proposals for creator review. The Jaguar sheet grants both nodes at level 1, independent choices at levels 2, 3, 5, 6 and 9, a shared passive at 4, a shared active at 7 and an origin passive at 8.

| Origin | Creator direction from the brief |
| --- | --- |
| Scorpion | Make carapace, a venomous tail and grasping claws central to the close-quarters striker. |
| Steel Skin | Heavily armoured bruiser with heavy single-target damage. Include a high-level, short-lived Plastic Skin with different durability strengths. A short-range steel shotgun blast is a candidate. |
| Psionic Armour | Heavily armoured tank that protects allies and deals area damage. A powerful expenditure can remove its armour for a time. |
| Eye Powers / Hawk Wings | Both eliminate priority targets and struggle in sustained melee. Eye specialises in range, area attacks and piercing. Hawk can fly and hits hard but is fragile. |
| Drone Command / Artillery Suit | Drone Command pairs one persistent drone with a light-power-armour operator. Artillery Suit is slow with powerful ranged and area attacks, heat management and some effectiveness against robots. |
| Darwinian / Healing | Darwinian covers several roles at lower specialist power. Healing alternates between Jekyll’s squad treatment and Hyde’s stronger attacks at a mounting cost. |
| Telepathy / Telekinesis | Telepathy affects organics in ways beyond damage. Telekinesis repositions units or objects and hits hard. Both are relatively fragile in melee. Teleportation is a candidate. |

### Scorpion and Anvil revisions

**26 November 2026, creator’s class-tree review in chat.** The following changes established the [26 November Scorpion and Anvil review trees](ORIGIN_TREES_REVIEW.html#tree0). The [27 November class update](#27-november-class-update) supersedes the affected nodes.

- **Scorpion.** Charge adds two tiles of movement for the activation turn per AP spent and has a two-turn cooldown. Moulting Skin refills current armour immediately after an incoming hit depletes it, once per room, after HP spillover if still standing. Burrow Defense replaces Living Carapace. Once per operation, an attack that would down Scorpion leaves them at 1 HP and sends them underground, immune to damage for the rest of the round. They emerge at the start of the next player turn at 1 HP with status effects cleared. Burrowing Strike remains the other capstone.
- **Shared Anvil nodes.** Taunt replaces Breakthrough. It forces one enemy within four tiles to attack the Anvil for one turn when an attack is legal. Protecting Interceptor replaces Impact Stance. Anvil reacts when an enemy moves within a visible overwatch area, moves to intercept if able, attacks and stops the enemy’s movement. Linebreaker charges through cover, can knock enemies back two tiles and deals light damage.
- **Steel Skin.** Throw replaces Interpose and throws an adjacent enemy up to three tiles. Gleaming Armour blinds units in an area around Steel Skin. Thundering Taunt forces nearby enemies to attack Steel Skin on their next turn when legal. The other revisions grant +1 movement speed at Level 6, reduce incoming ranged attack damage by 1 with Shining Knight and add +2 armour capacity at Level 8. Plastic Skin removes current armour and grants temporary immunity to melee and ranged attacks. Colossal Combo replaces Pile Driver with three hits at base melee damage each.
- **Psionic Armour.** Lend Armour replaces Mind Challenge and sends current armour to an ally within five tiles. Shelter Reflex grants +3 armour for the turn to Psionic Armour and one adjacent ally. Encasing Armour deals 4 damage, immobilises the enemy for the turn and leaves Psionic Armour without armour for the next enemy turn. Pressure Front damages units in an area around Psionic Armour, depletes the caster’s armour and delays its recovery. Returning Mantle grants the recipient the benefits of full cover. Shock Grapple strengthens returned armour. Mantle Recall can sacrifice an ally’s protection to absorb up to 2 damage from an incoming direct hit.

See [Open decisions](OPEN_DECISIONS.md#classes-equipment-and-enemies) for timing and interactions that still need review. The [class handoff](../CLASSES_AND_ENEMIES.md#scorpion-and-anvil-design-revisions) records the earlier designs. The playable V3 trees are described in [Implementation Notes](../IMPLEMENTATION_NOTES.md#v3-player-classes).

### 26 November Drone Command and Healing reworks

The [Iskra redesign](#27-november-iskra-redesign) supersedes the earlier Drone Command playtest below.

**26 November 2026, creator’s class-tree review in chat.** Drone Command always deploys alongside one destructible drone. Its light-power-armour operator supports the drone and can improve or specialise it through the tree, while retaining suit abilities for fights after its loss. Destruction carries through all remaining rooms or missions in that operation. A high-level restoration ability is a candidate.

**26 November 2026, creator’s Drone Command follow-up in chat.** Level 2 sets the drone’s role with an offensive or defensive choice. The operator can command the drone from anywhere in the room. The operator remains primarily a support unit for the drone. The shared Iskra nodes from the previous draft are approved for this review tree.

Healing now follows a Dr Jekyll and Mr Hyde dynamic. Jekyll treats the squad. Hyde deals stronger damage and pays an ongoing cost while transformed. Shared class abilities should remain relevant to both origins of Iskra and Alkhimik.

**26 November 2026, creator’s request for a stronger and more distinctive Drone Command tree.** The revised proposal gives each Level 2 chassis a signature order. Assault uses Chain Arc to hit several enemies from one firing angle. Guardian uses Rolling Barricade to move and project temporary full cover. The operator can set up arcs by pulling enemies, swap the drone with an exposed ally or lay a Shock Mine from either unit. Emergency Rebuild and the chassis-specific Overclock Link compete at Level 9. Shared Iskra abilities retain their approved effects. [Drone Command tree](ORIGIN_TREES_REVIEW.html#tree5)

**26 November 2026, creator’s Jekyll and Hyde follow-up in chat.** Switching should be a tactical choice. Both forms need distinctive abilities, with meaningful downsides for Hyde. Target roughly two-thirds of turns in Jekyll and one-third in Hyde. The shared Alkhimik abilities must remain useful for Darwinian.

**Proposed Healing tree.** Jekyll can rescue allies or create treatment and protection zones. The latest trial gives Hyde one transformation per room and a reduced-AP recovery turn, including across linked-room transitions. Proposed costs, timing and tuning await review. [Healing tree](ORIGIN_TREES_REVIEW.html#tree8)

**26 November 2026, creator’s clarification in chat.** Field Formula, Clinical Eye and Reserve Dose have identical targeting, effects, costs and limits in Jekyll, Hyde and all three Darwinian forms. Both modes of Field Formula are available in all forms. Form-specific abilities provide each origin’s distinct playstyle.

### Darwinian rework

**26 November 2026, creator’s Darwinian follow-up in chat.** Frog should specialise in mobility and crowd control, Jellyfish should be slow and may stun, and Skunk should be the ranged form. Switching should answer tactical conditions and feel distinct from the Jekyll and Hyde cycle. The shared Alkhimik abilities retain their existing effects on both origins.

**Proposed Darwinian tree.** Frog hops and repositions enemies. Jellyfish slows a target and can learn a short-range stun through Express Trait. Skunk pressures enemies from range and can foul a route with a Blinding musk trail. Shifting costs AP and keeps existing cooldowns. Darwinian can stay in a useful form indefinitely. Mobility, control and ranged attack values remain proposed. [Darwinian tree](ORIGIN_TREES_REVIEW.html#tree7)

### Needle revisions

**26 November 2026, creator’s Needle class review in chat.** The [27 November class update](#27-november-class-update) supersedes the affected nodes. Designate Quarry applies Vulnerable to one enemy. Each attack hit on that enemy adds 2 direct HP damage, regardless of who attacks. Eye Powers chooses between greater damage and range at Level 6 and gains immunity to Blinded and cover-ignoring attacks at Level 8. Pinhole Sun applies Burning. Prismatic Burst hits a single enemy and immobilises it with Freeze for one turn. Hawk Wings applies Slow with Stooping Strike, gains immunity to Slow and immobilisation through High Perch, and adds armour piercing and Bleeding to Wingover. Level 6 bonus sizes and Slow strength remain draft tuning. [Eye Powers tree](ORIGIN_TREES_REVIEW.html#tree3) · [Hawk Wings tree](ORIGIN_TREES_REVIEW.html#tree4)

### Glaz revisions

**26 November 2026, creator’s Glaz class review in chat.** Make Telepathy and Telekinesis play distinctly and give both useful shared abilities. Use existing mechanics for the redesign and keep new mechanics at the proposal stage.

**Proposed trees.** Telepathy interrupts organic reactions, support actions and targeting. It can turn removing a reaction into a stronger Feedback Spike. Telekinesis pulls, pushes or slides units to expose them, line up impacts or rescue allies. Its damage options exploit walls and destructible cover. Both origins share Distort Aim to weaken a direct hit from an organic or machine, Residual Distortion to reposition the squad member who survives it, and Safe Passage for a short move that avoids walking reactions.

Fold Space remains a separate teleport proposal. The review tree uses Safe Passage and its ordinary path and hazard rules. [Telepathy tree](ORIGIN_TREES_REVIEW.html#tree9) · [Telekinesis tree](ORIGIN_TREES_REVIEW.html#tree10)

### Cross-class balance trials

**26 November 2026, creator’s request to apply the class balance review in chat.** Designate Quarry ends after three hits or at its normal expiry. Protecting Interceptor triggers once per round and requires a reachable intercept. Thundering Taunt costs 2 AP. Scorpion’s armour refill and lethal-hit protection have room and operation limits respectively. Both Level 6 Psionic Armour choices work with either Level 3 protection. Chain Arc costs 2 AP and Rolling Barricade costs 1 AP. Jellyfish may inflict its Express Trait stun once per operative per room across all activation routes. Field Hospital treats up to three distinct patients per cast.

**Hyde alternative for creator review.** The creator suggested one limited transformation per room followed by a weaker Jekyll. Proposed tuning gives Hyde up to two player turns including activation and reduces Jekyll’s next AP refresh by one. It replaces Stability and escalating HP strain for this trial. The intended approximate two-to-one Jekyll/Hyde playtime remains a playtest target.

### Class implementation decisions

**26 November 2026, creator’s implementation review in chat.** Jaguar and Scorpion share Charge. Spend 1–3 AP for two extra movement tiles per AP for the current turn, with a two-turn cooldown. Charge grants movement only. Colossal Combo costs 2 AP and has a two-turn cooldown. Pinion Guard reduces the first direct ranged hit after flight by 1. Heat Jacket reduces direct attack hits by 1 while at three or four heat.

Mantle Recall replaces Afterimage. It recalls a selected ally’s remaining mantle once per round, absorbing up to 2 damage on the triggering hit and ending that ally’s protection. In this playtest, select the ally before the enemy phase to arm the optional reaction. Lend Armour transfers up to 3 current armour until the next Anvil turn and returns any unused points. Returning Mantle protects from the side facing Anvil. Shock Grapple gives Anvil 1 temporary armour until its next turn when either protection ends.

The creator accepted a three-tile Interceptor radius, a two-tile radius for the area taunt and blind, and up to three tiles of Linebreaker movement with two-tile knockback as provisional playtest tuning.

**26 November 2026, creator’s branch playtest decisions in chat.** Pressure Front keeps its provisional two-tile radius, deals 3 damage, spends all current armour and skips the next refresh. Shelter Reflex expires at the start of Anvil’s next turn. A second Needle designating a Vulnerable target refreshes its single allowance to three hits. The newest designation owns that target's mark.

### 27 November class update

The creator approved the following changes and clarified targeting, cover, designation ownership and High Perch in chat on 27 November 2026. The [Build 10 class-tree data](../../source/Hammer_Ash_Godot_2D_Build10/data/player_class_review.json) contains the full progression and current tooltips.

| Class or origin | Updated nodes |
| --- | --- |
| Scythe | **Threatening Presence** raises the round limit for walking-away melee reactions to two. Each eligible departure triggers at most one hit. |
| Jaguar | **Bounding Pounce** leaps up to four tiles for 1 AP. **Rake** targets up to three distinct adjacent tiles for 1 AP. **Crush Bite** costs 1 AP and shreds four armour capacity before the hit. **Open the Seam** costs 1 AP. |
| Scorpion | **Venom Jet** sprays three rows one, two and three tiles wide. **Moulting Skin** clears Burning and Irradiated at the end of the enemy phase if either is present, once per room. |
| Anvil | **Linebreaker** travels up to four tiles, deals five structural damage to crossed destructible cover, and hits each enemy encountered once for one damage and up to two tiles of knockback. |
| Steel Skin | **Throw** costs 1 AP. An adjacent eligible enemy can be thrown up to three tiles. An enemy collision deals two damage to both units. A destructible low or high cover collision destroys that edge and deals two damage to the thrown unit. **Gleaming Armour** blinds enemies in a three-row cone one, two and three tiles wide. **Colossal Combo** makes three basic-damage hits for 2 AP with a two-turn cooldown. The first hit shreds two armour capacity and the final hit knocks a survivor back up to two tiles. |
| Psionic Armour | **Living Mantle** grants Lend Armour at Level 1. For 1 AP transfer up to three current armour to an ally within four tiles until Anvil’s next turn. Unused points return. **Defence is the Best Offense** replaces the Level 3 Lend Armour choice and grants two temporary armour and +1 attack damage until Anvil’s next turn for 1 AP and a two-turn cooldown. **Encasing Armour** deals six damage for 1 AP. **Pressure Front** costs 1 AP, spends all current armour, deals that much damage to enemies within two tiles and skips the next refresh. **Returning Mantle** gives the protected ally low cover from every direction for either mantle ability. **Returning Defence** grants Anvil one temporary armour on the next player turn when either mantle expires. **Mental Fortress** adds one armour capacity and persistent low cover from every direction. |
| Needle | **Designate Target** replaces Designate Quarry. Only the Needle who owns the active designation receives the +2 direct HP damage or spends one of its next three hits. A new designation refreshes the limit and transfers ownership. |
| Eye Powers | **Focal Lens** keeps the long-range +1 and drops the close-range penalty. **Long Focus** adds two basic attack range. **Short-Sighted** replaces Afterglow and gives +2 damage to direct Eye attacks within four tiles. **Split Focus** deals four damage per target. **Corneal Lance** applies one turn of Blind instead of Slow. **Sweep Beam** costs 1 AP. **Steady Gaze** gives basic attacks +2 damage. **Fiery Gaze** replaces Peripheral Vision and gives basic attacks Burning. **Rangefinder** lets Sweep Beam destroy destructible cover and gives Corneal Lance three turns of Blind. **The Void’s Gaze** renames Prismatic Burst and retains the single-target Freeze. **Pinhole Sun** deals eight armour-piercing damage and loses Burning. |
| Hawk Wings | **Spread Your Wings** renames Long Primaries and retains the +1 to Fly range. **Silent Landing** automatically skips the first eligible walking-away melee reaction after landing. **Banking Turn** flies up to three tiles. **Raking Pass** flies up to three tiles and deals four damage to enemies beneath the route for 1 AP and a two-turn cooldown. **Strike and Drop** hits an adjacent foe, then flies up to three tiles and drops the surviving foe on a player-selected legal tile adjacent to the landing. **High Perch** grants +2 damage on the first attack of a round started on high ground. Relay stations and final sweep yards provide authored high ground. |

### 27 November Iskra redesign

The creator approved both redesigned origins in chat on 27 November 2026. They kept one destructible drone and one heavy-fire suit, then confirmed that enemy Overwatch can destroy the drone mid-order, that Flak Curtain reaches six tiles and is blocked by walls, and that Incendiary Shell lights all three affected tiles, including occupied tiles. The [playable trees](../../source/Hammer_Ash_Godot_2D_Build10/data/player_class_review.json) contain the current branch values and descriptions.

| Level | Drone Command | Artillery Suit |
| --- | --- | --- |
| 1 | **Paired Deployment** gives +1 armour and one drone with 4 HP and 1 armour. **Scout Run** costs 1 AP from the operator, moves up to two tiles and can fire a 2-damage Arc Bolt within four tiles. | **Siege Mount** gives +2 armour, **Anchor**, **Vent** and **Breach Shell**. Breach Shell costs 2 AP and 2 Heat with CD2. It strikes an edge four to eight tiles away for five structural damage and hits units on either side for two. |
| 2 | **Assault Chassis** gives **Pincer Run**. Move up to three tiles, fire for three damage within four and cancel the target’s active Overwatch if the drone fires from a different cover-facing side than the operator. **Guardian Chassis** adds one drone armour and gives **Shield Run**. Move up to three tiles and project three full-cover edges in a chosen direction. Both orders cost 1 AP with CD2. | **Quick-Lock** allows Anchor after exactly one standard move once per room. **Cooling Fins** makes Vent remove three Heat. |
| 3 | **Field Service** repairs two drone HP and resets its chassis cooldown for 1 AP once per room. **Recovery Winch** swaps the drone with a visible single-tile ally within three tiles of it, gives the ally two temporary armour and uses the drone’s order. It costs 1 AP with CD2. | **Mortar Cup** deals three damage in a cross centred four to seven tiles away. **Walking Barrage** deals four damage on three consecutive visible tiles within eight. Both cost 2 AP and 2 Heat with CD2. |
| 5 | **Hardpoint Upgrade** gives Pincer Run an optional second target within two tiles of the first for two damage, or Shield Run an optional adjacent ally who gains two temporary armour. **Shock Mine** costs 1 AP with CD2, can originate from the operator or drone, and hits the first enemy to enter for two damage and Shocked. | **Flak Curtain** arms a marked three-tile-wide lane up to six tiles away. Walls block it. The first enemy entering triggers a three-damage cross blast, with friendly fire. **Incendiary Shell** deals two damage along three tiles within six and leaves fire hazards on all three. Survivors on those tiles become Burning. Both cost 2 AP and 2 Heat with CD2. |
| 6 | **Hardened Frame** adds two maximum drone HP. **Tandem Drive** grants up to two free drone movement steps after the operator’s standard move, once per turn. | **Feed Mechanism** makes Vent restore a cannon charge. **Hot Breech** adds one damage per target to the first heavy shot fired at two or more Heat each turn. |
| 8 | **Remote Breach** adds a drone origin to Breach Kit, with the same cost and cooldown and no order spent. | **Breach Follow-Up** makes the next basic cannon attack that turn against a unit bordering cover an Iskra heavy shot just destroyed charge-free. The attack still costs 1 AP. |
| 9 | **Emergency Rebuild** restores the destroyed drone adjacent to the operator at half its upgraded HP, rounded up, for 2 AP once per operation. Orders resume next turn. **Overclock Link** bypasses the chassis cooldown and sets CD2. Assault moves up to four tiles and chains for 4/3/2/1 damage. Guardian moves up to three tiles, projects two distinct cover lines and can give two nearby allies two temporary armour each. It costs 2 AP once per room and uses the turn’s drone order. | **Siege Salvo** costs 2 AP and 3 Heat once per room. It destroys destructible cover in a cross centred four to eight tiles away, then deals six damage at the centre and four on its cardinal neighbours. **Rolling Thunder** costs 2 AP and 2 Heat once per room. Move up to three steps under normal reactions, then deal four damage on a straight four-tile firing line and hold position. |

Both origins gain **Breach Kit** at Level 1, **Shock Mounts** at Level 4 and **Emergency Cells** at Level 7. Breach Kit deals three structural damage to a visible cover edge within three tiles for 1 AP with CD2. Shock Mounts reduces the first Overwatch hit against the operator in a round by one. Emergency Cells restores up to two basic weapon charges and gives two temporary armour for 1 AP once per room.

Drone Command’s Arc Pistol has three base damage at six tiles. Drone orders use the operator’s AP and one drone order per turn from any distance in the room. Enemy Overwatch uses the normal AP and ammunition cost per shot against the drone along its route. A lethal hit cancels the rest of the order. Recovery Winch swaps positions as forced movement. Shield Run ends when the drone moves, is destroyed, or reaches the next player turn. Drone HP and destruction carry across rooms.

Artillery Suit’s cannon has four base damage at six tiles and spends a charge without adding Heat. Anchor is free before voluntary movement. It locks voluntary movement until the next player turn, and forced movement breaks the mount and cancels an armed Flak Curtain. All heavy shots require Anchor except Rolling Thunder. Heat caps at four, cools by one at the start of the player turn, and Vent costs 1 AP to remove two. Blast and line attacks can hit allies. [Combat rules](COMBAT.md)

### 27 November Glaz and Alkhimik implementation

The creator requested completion of the playable Glaz and Alkhimik origins on 27 November 2026. The [Build 10 trees](../../source/Hammer_Ash_Godot_2D_Build10/data/player_class_review.json) retain the current trial values. The [open decisions](OPEN_DECISIONS.md#classes-equipment-and-enemies) track balance and final tuning.

- **Telepathy.** Surface Thought offers a free suppression action after a qualifying Synaptic Prick. Reaction checks include melee departure strikes. Feedback Spike’s extra damage requires the same Glaz to have removed an available reaction this turn. Aphasia disables heals and buffs for the affected turn, while normal movement and attacks remain available.
- **Telekinesis.** Impulse offers a free follow-up after a Force Bolt hit when the target can be pushed. Vector Pull offers one- and two-tile targeting modes.
- **Shared Glaz.** Safe Passage bypasses melee departure reactions and still resolves Overwatch and hazards. Residual Distortion grants a free targeted step. If triggered in the enemy phase, the step is available at the start of the next player turn.
- **Darwinian.** Frog and Jellyfish use two-damage melee basics. Skunk uses a two-damage Spray with four-tile reach. Musk Trail affects a foe on entry or at enemy phase start, once per cast per foe. Jellyfish’s Passing Trait reduces the first forced move by one tile. Skunk’s Passing Trait adds reach to the next ranged basic attack that player turn. Shed Skin clears one status in the order Burning, Venom, then Blinded.
- **Jekyll / Hyde.** Quarantine Field and Field Hospital use the centre tile and four cardinal neighbours. Hurl Aside resolves unit collisions. Adrenal Rescue can skip melee departure reactions and applies terrain hazards on landing. Adrenal Rebound applies when returning to Jekyll on the battlefield or after clearing a room as Hyde.
- **Shared Alkhimik.** Field Formula, Clinical Eye and Reserve Dose have the same rules in all five forms. Reserve Dose’s damage bonus applies once to a basic attack on the player turn it is used.

## Confirmed enemy design direction

Use moderate counters based on understandable mechanics and composition. Swarms can pressure slow heavy attacks, support units can sustain an armoured anchor, and ranged units or zoning can punish an all-melee approach. Reward complementary squads. Keep imperfect responses available through positioning, gear, hazards, objectives, allies or between-room withdrawal. Exceptional specialist gates need clear warning and a credible alternative. Enemies work toward objectives and can act outside immediate player view within their awareness rules. [Open decisions](OPEN_DECISIONS.md#classes-equipment-and-enemies)

### Initial enemy roster and mixed encounters

**26 November 2026, creator's enemy roster and follow-up in chat.** Families communicate identity and expected tools. Encounters can freely mix families, and power can vary within and between families. KGB formations often field several conventional troops supported by specialists. Robots tend toward armour, abominations toward less armour and monstrous genetic capabilities, and Supers toward rare, dangerous specialists.

| Family | Initial roster |
| --- | --- |
| KGB | Rifleman, Assault Operative (aggressive shotgun), Marksman (long-range rifle), Grenadier, Captain (leader and stronger rifleman), Pravda Man (support) |
| Robots | Collectivist Drone (numerous, simple swarm), Man of Steel (heavy armour), Matryoshka (nested doll), Nevalyashka (weighted toy), Combine (harvester) |
| Abominations | Kulak (numerous, simple swarm), Kapitalist, Noble, Clergy, Individualist |
| Supers | Hammer, Sickle (ranged), Proletariat (combines both weapons), Red Star, Siberian, New Soviet Man, New Soviet Woman, Vanguard |

**Playtest implementation.** The Captain's command reaches allies of any family. Pravda Man's broadcast strengthens the next allied attack and the Clergy's choir restores allied HP. The Kapitalist feeds on HP damage, the Individualist gains damage when isolated, and the nested Matryoshka deploys one small drone. The Proletariat switches to a hammer impact at adjacent range. These signatures, unit stats and encounter compositions are provisional.

### Enemy tiers

**27 November 2026, creator's approval of the enemy tier and levelling plan in chat.** Assign each enemy archetype a threat tier independent of its family. Use the tier as a rough encounter-balancing tool and to set its kill XP. Continue to author individual unit stats and assess synergies when composing encounters.

| Tier | Role | Trial kill XP |
| --- | --- | ---: |
| Low | Screen, swarm or basic pressure | 1 |
| Mid | Regular threat with a clear combat role | 2 |
| High | Specialist or anchor that changes target priorities or positioning | 3 |
| Mini-boss | Encounter anchor with a signature mechanic | 5 |
| Boss | Main threat in a dedicated boss encounter | 8 |

**27 November 2026, creator's roster assignments in chat.**

| Tier | Initial roster |
| --- | --- |
| Low | Rifleman, Assault Operative, Marksman, Grenadier, Collectivist Drone, Kulak |
| Mid | Captain, Pravda Man, Man of Steel, Kapitalist, Clergy, Hammer, Sickle, Vanguard, Red Star |
| High | Matryoshka, Nevalyashka, Combine, Noble, Individualist, Proletariat, Siberian, New Soviet Man, New Soviet Woman |

Matryoshka's nested drone retains its Low threat tier with zero separate kill XP. Use the inspector and Development's Enemy tier mix to review assignments.

**27 November 2026, creator's campaign cleanup request in chat.** Field the 24 explicitly defined enemy archetypes in the regional campaign. Retire prototype-only enemies from regular play and defer bosses, including the Iron Giant. The original regression chain retains its historical spawns for reproducing its radio and carry-over outcomes.

### Enemy balance across progression

**27 November 2026, creator's rebalancing request in chat.** Balance for squad growth through levels, equipment and stratagems. Judge a unit alongside its possible escorts, screens and supports. Allow different encounter frequencies and a range of individual threat levels within a tier. A strong specialist can appear alone with weaker escorts before later operations combine several specialists.

**Build 10 playtest tuning.** Use regional operations to compare low-threat screens, support-backed anchors and scarce High-tier specialists across squad levels. Northwestern patrol placements combine line infantry and a drone screen. Ural operations emphasise armoured machines, southern and Siberian rescues test pack support, and the final Far Eastern sweep pairs New Soviet Woman's command with New Soviet Man's formation bonus. Unit stats, deployment frequency and encounter budgets are provisional. [Regional playtest operations](MISSIONS.md#regional-playtest-operations)
