# Classes and enemies

## Confirmed class identities

Six classes have distinct tactical roles. Each class has shared skills and two exclusive origins. Class abilities occupy no equipment slots. The identities below are the current baseline. Complete ability trees, progression and tuning remain subject to review. [Class handoff](../CLASSES_AND_ENEMIES.md)

| Class | Role | Origins |
| --- | --- | --- |
| Scythe | Close-quarters striker | Jaguar / Scorpion |
| Anvil | Frontline bruiser | Steel Skin / Psionic Armour |
| Glaz | Battlefield distorter | Telepathy / Telekinesis |
| Needle | Priority-target eliminator | Eye Powers / Hawk Wings |
| Iskra | Power-armour specialist | Drone Command / Artillery Suit |
| Alkhimik | Adaptive generalist and field medic | Darwinian / Healing |

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

Changing Darwinian form immediately changes the active base attack. In Build 10, Healing also switches its base attack on transformation, and Sightline, Arc Pistol and Suit Cannon use rechargeable charges. Operatives with a melee base attack can approach an enemy and strike for 1 AP total. The attack table fixes the intended melee/ranged identity. Ability and form details are tracked for review. [Combat rules](COMBAT.md#confirmed-rules-and-working-baselines) · [Open decisions](OPEN_DECISIONS.md#classes-equipment-and-enemies)

## Confirmed redesign direction

**25 November 2026, creator's Jaguar reference and eleven-origin design brief.** Jaguar is the reference for the intended Scythe identity and tree structure. Wolverine remains available in the legacy Scythe fixture. The [eleven companion trees](ORIGIN_TREES_REVIEW.html) are proposals for creator review. The Jaguar sheet grants both nodes at level 1, independent choices at levels 2, 3, 5, 6 and 9, a shared passive at 4, a shared active at 7 and an origin passive at 8.

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

**26 November 2026, creator’s class-tree review in chat.** The following changes govern the current [Scorpion and Anvil review trees](ORIGIN_TREES_REVIEW.html#tree0).

- **Scorpion.** Charge adds two tiles of movement for the activation turn per AP spent and has a two-turn cooldown. Moulting Skin refills current armour immediately after an incoming hit depletes it, once per room, after HP spillover if still standing. Burrow Defense replaces Living Carapace. Once per operation, an attack that would down Scorpion leaves them at 1 HP and sends them underground, immune to damage for the rest of the round. They emerge at the start of the next player turn at 1 HP with status effects cleared. Burrowing Strike remains the other capstone.
- **Shared Anvil nodes.** Taunt replaces Breakthrough. It forces one enemy within four tiles to attack the Anvil for one turn when an attack is legal. Protecting Interceptor replaces Impact Stance. Anvil reacts when an enemy moves within a visible overwatch area, moves to intercept if able, attacks and stops the enemy’s movement. Linebreaker charges through cover, can knock enemies back two tiles and deals light damage.
- **Steel Skin.** Throw replaces Interpose and throws an adjacent enemy up to three tiles. Gleaming Armour blinds units in an area around Steel Skin. Thundering Taunt forces nearby enemies to attack Steel Skin on their next turn when legal. The other revisions grant +1 movement speed at Level 6, reduce incoming ranged attack damage by 1 with Shining Knight and add +2 armour capacity at Level 8. Plastic Skin removes current armour and grants temporary immunity to melee and ranged attacks. Colossal Combo replaces Pile Driver with three hits at base melee damage each.
- **Psionic Armour.** Lend Armour replaces Mind Challenge and sends current armour to an ally within five tiles. Shelter Reflex grants +3 armour for the turn to Psionic Armour and one adjacent ally. Encasing Armour deals 4 damage, immobilises the enemy for the turn and leaves Psionic Armour without armour for the next enemy turn. Pressure Front damages units in an area around Psionic Armour, depletes the caster’s armour and delays its recovery. Returning Mantle grants the recipient the benefits of full cover. Shock Grapple strengthens returned armour. Mantle Recall can sacrifice an ally’s protection to absorb up to 2 damage from an incoming direct hit.

See [Open decisions](OPEN_DECISIONS.md#classes-equipment-and-enemies) for timing and interactions that still need review. The [class handoff](../CLASSES_AND_ENEMIES.md#scorpion-and-anvil-design-revisions) records the earlier designs. The playable V3 trees are described in [Implementation Notes](../IMPLEMENTATION_NOTES.md#v3-player-classes).

### Drone Command and Healing reworks

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

**26 November 2026, creator’s Needle class review in chat.** Designate Quarry applies Vulnerable to one enemy. Each attack hit on that enemy adds 2 direct HP damage, regardless of who attacks. Eye Powers chooses between greater damage and range at Level 6 and gains immunity to Blinded and cover-ignoring attacks at Level 8. Pinhole Sun applies Burning. Prismatic Burst hits a single enemy and immobilises it with Freeze for one turn. Hawk Wings applies Slow with Stooping Strike, gains immunity to Slow and immobilisation through High Perch, and adds armour piercing and Bleeding to Wingover. Level 6 bonus sizes and Slow strength remain draft tuning. [Eye Powers tree](ORIGIN_TREES_REVIEW.html#tree3) · [Hawk Wings tree](ORIGIN_TREES_REVIEW.html#tree4)

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

Iron Giant is a Mini-boss. Matryoshka's nested drone retains its Low threat tier with zero separate kill XP. Use the inspector and Development's Enemy tier mix to review assignments.
