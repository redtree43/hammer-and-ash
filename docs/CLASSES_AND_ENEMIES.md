# Classes and Enemies

## Confirmed class identities

The [22 November Class Design Update](../references/design/CLASS_DESIGN_UPDATE_2026-11-22.md) defines six classes by the tactical problems they solve. Each class has a common role and shared abilities, with distinct powers and meaningful weaknesses across its archetypes. Exclusive powers keep their advantages where hybrid builds are allowed. Skill trees grant abilities and passives without consuming equipment slots. Complementary squads should have an advantage while retaining viable responses to unfavourable matchups.

| Class | Former name | Confirmed tactical role | Provisional power archetypes |
| --- | --- | --- | --- |
| **Scythe** | Razor | Close-quarters damage dealer | Wolverine, Arachnid, Blink |
| **Anvil** | Sentinel | Defence and squad protection | Steel Skin, Shieldbearer, Plastic Skin |
| **Glaz** | Observer | Enemy disruption and battlefield control | Gravity manipulation, neural disruption, sensory manipulation |
| **Needle** | Marksman | Precision target elimination | Sniper, aerial or Hawk-style assassin, armour-piercing specialist |
| **Iskra** | Engineer | Technology and environmental manipulation | Magnetism, robot deployment, fortification and terrain manipulation |
| **Alkhimik** | Biochemist | Healing, biological enhancement and chemical warfare | Healing, mutagenic enhancement, toxins and chemical warfare |

Glaz adopts the Distorter concept, manipulating enemy position, movement and actions in place of Observer's reconnaissance focus. Needle can eliminate priority targets with rifles, aerial strikes or other powers.

## Provisional progression

### Scythe

[Scythe Class Design v0.1](../references/design/SCYTHE_CLASS_DESIGN.md) is the detailed working tree and the reference model for the five remaining class trees. Scythe chooses one origin at Level 1. Wolverine emphasises armour destruction and regeneration, Arachnid emphasises mobility and web control, and Blink specialises in teleportation and burst damage. Limited Phase Surge is shared by Wolverine and Arachnid. Blink retains the broader teleport toolkit.

**Charge costs 1 AP**, superseding the earlier 2 AP cost. The Level 1–9 gates, other ability costs, values, cooldowns and balance remain provisional. The draft gives Scythe the Threatening Presence opportunity attack. Detailed trees for Anvil, Glaz, Needle, Iskra and Alkhimik remain open.

### Historical class references

The [Class Design Framework](../references/design/Hammer_Ash_Class_Design_Framework.docx) and [Provisional Class Compendium](../references/design/Hammer_Ash_Provisional_Class_Compendium.docx) preserve the earlier eight-rank Genetic and Technology structure. The repository also preserves the earlier three-tree model in `Player_Unit_Archetypes.docx`. The 22 November update governs current class design.

## Build 10 combat kits

Build 10 uses the current names for its five playable operatives and retains the prototype kits below. Glaz has no playable slot in this build.

| Operative | Actual prototype actions |
| --- | --- |
| Scythe | **Area Shred.** Charge zero to three walkable tiles, then sweep three consecutive adjacent tiles for 2 damage each. The charge can trigger enemy reactions. The sweep ignores unit cover and can damage light cover. |
| Anvil | **Fortify.** +2 temporary armour to Anvil and an ally within two tiles. **Anvil Breach.** Charge in a straight cardinal line up to four tiles, break eligible light or reinforced cover, and deal 5 collision damage with a weight- and destination-checked push. |
| Needle | **Precision Shot.** Basic weapon damage +2, ignores one cover level, uses normal weapon range and LOS. |
| Iskra | **Arc Disruptor.** Weapon damage +1 and target loses 1 AP next phase. Normal weapon range and LOS. |
| Alkhimik | **Field Treatment.** Heal up to 3 HP on a living ally within three tiles. |

These special actions cost 1 AP in the current test balance. Area Shred, Fortify and Precision Shot are once per turn. Arc Disruptor and Field Treatment each skip the next full player turn before reuse.

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
