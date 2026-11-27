# Classes and Enemies

> Earlier V3 class handoff with review drafts and Build 10 fixture behavior. See the [playable bunker trees and controls](IMPLEMENTATION_NOTES.md#class-review-implementation-preview). The current specification is [Classes and enemies](design/CLASSES_AND_ENEMIES.md).

## Confirmed class identities

The earlier V3 bunker trees gave each class shared skills and two exclusive origins. This baseline used manual level and node selection. [V3 controls](IMPLEMENTATION_NOTES.md#v3-player-classes) · [Tree data](../source/Hammer_Ash_Godot_2D_Build10/data/player_classes_v3.json).

| Class | Former name | V3 tactical role | V3 origins |
| --- | --- | --- | --- |
| **Scythe** | Razor | Close-quarters striker | Wolverine / Scorpion |
| **Anvil** | Sentinel | Frontline bruiser | Steel Skin / Psionic Armour |
| **Glaz** | Observer | Battlefield distorter | Telepathy / Telekinesis |
| **Needle** | Marksman | Priority-target eliminator | Eye Powers / Hawk Wings |
| **Iskra** | Engineer | Power-armour specialist | Drone Command / Artillery Suit |
| **Alkhimik** | Biochemist | Adaptive generalist and field medic | Darwinian / Healing |

## Base attacks

| Class | Melee | Ranged |
| --- | --- | --- |
| Scythe | Wolverine, Scorpion | |
| Anvil | Steel Skin, Psionic Armour | |
| Needle | Hawk Wings | Eye Powers |
| Glaz | | Telepathy, Telekinesis |
| Iskra | | Drone Command, Artillery Suit (powered armour) |
| Alkhimik | Darwinian Frog, Darwinian Jellyfish | Darwinian Skunk, Healing |

Darwinian Shift and Rapid Metamorph change the base attack immediately. The prototype uses 2 damage for melee and preserves each class's existing ranged damage and reach as playtest values.

## Scorpion and Anvil design revisions

The 26 November class-tree review supersedes the earlier proposals below. [Current class design](design/CLASSES_AND_ENEMIES.md#scorpion-and-anvil-revisions) · [Current review trees](design/ORIGIN_TREES_REVIEW.html#tree0)

These drafts record the proposals after the V3 playtest. The review diagrams contain candidate values and interactions.

**Scythe / Scorpion.** Keep Charge and Tail Sting. Segmented Carapace grants 1 armour, four-tile movement and venomous attacks. At Level 2, Deflective Plates grants 1 more armour or Stronger Poison extends Venom by one turn. Claw Grab starts with an adjacent base hit and holds both units in place. Level 5 offers Carapace Slam or Venom Jet, which applies Venom along the three tiles directly ahead with zero impact damage. Level 6 offers Moulting Skin, a once-per-room armour refill on the next turn after depletion, or Barbed Retort, a base-attack response to the first incoming melee attack each round. At Level 8, Numbing Sting adds a one-tile movement penalty to poison attacks. Level 9 offers Living Carapace, which reduces HP spillover on an armour-breaking hit, or Burrowing Strike, a short underground move and strike. Confirm hold duration, armour-cap restoration, travel rules and final tuning before implementation. [Open Questions](OPEN_QUESTIONS.md#classes-equipment-and-enemies).

**Anvil.** Shared skills focus on the armoured frontline bruiser. The review tree shows Breakthrough, Impact Stance and Linebreaker. Steel Skin keeps the Ferrous Body armour bonus and adds immunity to permanent armour shred. Its way to protect an ally is to intercept the hit personally, represented by Interpose in the review tree. Psionic Armour handles taunts and lending armour and can spend its own armour on ranged area attacks. Mind Challenge is the reviewed taunt. Final node costs, timings and reaction ordering remain open. [Open Questions](OPEN_QUESTIONS.md#classes-equipment-and-enemies).

The creator requested the Scorpion changes and Anvil direction in [Redesign Class Tech Trees](https://chatgpt.com/c/6b04f315-a3dc-83e8-800c-aae1c9c4599a). Alternative class names discussed in [Create Tech Trees](https://chatgpt.com/c/6b03fa34-493c-83ee-8ae6-c219b4025b26) remain candidates.

## Earlier class designs

### Scythe

[Scythe Class Design v0.1](../references/design/SCYTHE_CLASS_DESIGN.md) describes the previous Wolverine, Arachnid and Blink tree used as a reference for V3 and the original Scythe test fixture.

### Historical class references

The [Class Design Framework](../references/design/Hammer_Ash_Class_Design_Framework.docx) and [Provisional Class Compendium](../references/design/Hammer_Ash_Provisional_Class_Compendium.docx) preserve the earlier eight-rank Genetic and Technology structure. [Player Unit Archetypes](../references/design/Player_Unit_Archetypes.docx) and the [22 November Class Design Update](../references/design/CLASS_DESIGN_UPDATE_2026-11-22.md) capture earlier class directions.

## Build 10 regression kits

The mission-selector fixtures use the original five kits below. Glaz joins the playable roster in bunker operations.

| Operative | Actual prototype actions |
| --- | --- |
| Scythe | **Area Shred.** Charge zero to three walkable tiles, then sweep three consecutive adjacent tiles for 2 damage each. The charge can trigger enemy reactions. The sweep ignores unit cover and can damage light cover. |
| Anvil | **Fortify.** +2 temporary armour to Anvil and an ally within two tiles. **Anvil Breach.** Charge in a straight cardinal line up to four tiles, break eligible light or reinforced cover, and deal 5 collision damage with a weight- and destination-checked push. |
| Needle | **Precision Shot.** Basic weapon damage +2, ignores one cover level, uses normal weapon range and LOS. |
| Iskra | **Arc Disruptor.** Weapon damage +1 and target loses 1 AP next phase. Normal weapon range and LOS. |
| Alkhimik | **Field Treatment.** Heal up to 3 HP on a living ally within three tiles. |

These special actions cost 1 AP in the current test balance. Area Shred, Fortify and Precision Shot are once per turn. Arc Disruptor and Field Treatment each skip the next full player turn before reuse.

### Scythe test fixture

Fixture 6 gives Scythe **Charge** in place of Area Shred. For 1 AP once per turn, choose one enemy and move up to two walkable tiles to a legal adjacent landing. Arachnid extends Charge to three tiles. The innate strike deals 2 damage before armour. An Overwatch shot stops the move at the triggered tile and cancels the strike. The AP and once-per-turn use are spent.

Wolverine is the default test origin. **Claws** are an innate 2-damage melee option. Each claw strike lowers the target's maximum armour by 1, to a floor of zero, after resolving ordinary damage. The reduced maximum survives armour refreshes. Charge uses its own strike.

**Arachnid's Spider Agility** increases ordinary movement to five tiles and Charge movement to three. **Blink's Short Blink** costs 1 AP and can be used once per turn, independently of Charge. Press **Z** and choose a visible, unoccupied walkable tile up to four tiles away. Hazards and eligible Overwatch resolve on landing.

Choose an origin from the illustrated loadout cards or cycle with **W** before deploying. Standard Scythe remains available for comparison. Origins and their sprites apply only in fixture 6.

## Enemies and matchups

**Confirmed direction.** Use moderate counters based on understandable unit mechanics and composition. A horde pressures slow high-damage fire, a healer sustains an armoured anchor, and ranged threats or zoning punish an all-melee approach. Five copies of one class may incur substantial time, resource, casualty, or objective costs. Keep a plausible imperfect response through allies, gear, positioning, hazards, objective play, or between-room withdrawal. Exceptional specialist gates need conspicuous warning and a credible alternative. Enemies should work toward objectives and remain active beyond the player's immediate view subject to their awareness rules.

| Prototype enemy | Current function |
| --- | --- |
| Hounds | Fast melee pressure. The original chain uses 4 HP hounds with movement of five tiles per AP, subject to scenario scaling and data. |
| KGB rifle units and elite guards | Ranged pressure, cover use, firing lanes, and defensive or aggressive approaches depending on role. |
| KGB Biotechnician | Weak ranged attack, heals or buffs at range four for 1 AP, and weighs staying near active allies against safety and cover. |
| KGB Elite Enforcer | Original chain's final elite. Build 10 gives it 15 HP, 4 armour and 3 AP. |
| Commander Voronov | The archived Build 07.1 Command Bunker boss. Its Emergency Directive adds armour to self and improves an ally's next attack. Legacy logic remains in Build 10's script. |
| Officer Orlov and escorts | Fleeing assassination target and defensive bodyguards. See [Missions](MISSIONS.md) for the scheduled escape. |
| Activated prototype robot | Sabotage escalation with 13 HP, 3 armour and 3 AP. |
| Safehouse attackers | Scheduled hounds and rifle units that can attack either operatives or the defence objective. |

**Provisional encounter framework.** Consider swarms, cover holders, mobile flankers, armoured anchors, area threats, supports, controllers, specialist hunters, precision shooters, anti-enhancement units and commanders. Compare squad capability in crowd clearance, priority elimination, anti-armour, control, mobility, and resilience. Make enemy combinations detectable and disruptable. The retrieved Enemy Design discussion summarises further archetype and test proposals. Its full catalogue was unavailable.

Enemy design draws on the 21 November master and combat documents and the available Enemy Design conversation excerpts. Build behaviour comes from the Build 10 script, changelog and on-screen ability text.
