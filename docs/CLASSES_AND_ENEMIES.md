# Classes and Enemies

## Confirmed class structure

Six fixed combat roles retain their battlefield identity across genetic, technological and hybrid builds. A Razor remains a close-assault operative throughout progression. Conventional equipment stays useful, major enhancements carry understandable loadout trade-offs, and general equipment should support baseline defence and first aid.

| Rank | Design contract |
| --- | --- |
| 1 | Shared class foundation, signature action, and starting loadout. |
| 2 | Display the mutually exclusive Genetic and Technology paths together. The chosen architecture grants an immediately usable capability. Preview equipment restrictions, doctrines, and masteries. |
| 3 | Choose one of two early refinements for that architecture. Both keep later doctrine and mastery choices viable. |
| 4 | Choose one of two doctrines shown together within the chosen architecture. The doctrine changes how the class performs its role. |
| 5 | Pick one of four shared compatible talents for the class. Limited cross-discipline abilities can appear here. |
| 6 | Pick one of two advanced refinements for the chosen doctrine. |
| 7 | Pick a different talent from the same shared pool. |
| 8 | Choose a pure or hybrid mastery within the original architecture. Hybrids borrow a limited capability from the other discipline and retain the Rank 2 exclusivity. |

The older three-tree, four-specialization/five-enhancement, level-9 model in `Player_Unit_Archetypes.docx` is historical. The current six-class, eight-rank model comes from the 19 November class framework and 21 November master design. Exact XP, respec, and loadout schema remain open.

## Provisional class designs

The figures and names in these kits are candidates. See the preserved [Provisional Class Compendium](../references/design/Hammer_Ash_Provisional_Class_Compendium.docx) for all Rank 3 and Rank 6 choices, shared talents, masteries, interactions, and equipment restrictions. Its camouflage, accuracy, and suppression wording predates the corresponding exclusions and deterministic combat decisions.

| Class | Fixed tactical role | Draft foundation | Genetic path and doctrines | Tech path and doctrines |
| --- | --- | --- | --- | --- |
| Razor | Close assault, melee breach, and elimination | Breach, a move-and-strike melee action | Claw Graft replaces the primary weapon. Hunter repositions after claw strikes against exposed enemies. Survivor emphasises regeneration. | Shock Frame enables powered melee. Pursuer closes distance for strikes. Breaker shreds armour and displaces enemies. |
| Sentinel | Protection, defensive control and ally safety | Interpose, an adjacent ally interception | Morphic Matrix switches steel and elastic forms. Adaptive Matter adds another form. Elastic Guardian emphasises pulling allies to safety. | Bastion Chassis provides directional shielding. Barrier Guardian extends ally protection. Entrenched Bastion anchors a position. |
| Observer | Reconnaissance, target designation, and situational information | Spot, a mark and tracking action | Wing Graft offers limited repositioning. Sky Surveyor gathers information. Raptor Stalker improves aerial approach. | Recon Harness offers sensors and proposed concealment. Ghost Operative explores limited evasion. Intelligence Controller coordinates sensors and marks. |
| Marksman | Ranged precision and priority-target elimination | Aim, preparation for a better shot | Radiant Ocular Organ adds a line-of-sight beam. Ocular Emitter develops beam fire. Biological Seer develops target perception. Firearms remain available. | Cybernetic Retinas enhance firearm targeting. Coil Gunner uses electromagnetic rifles and piercing ammo. Neural Sniper develops Aim and reaction fire. |
| Engineer | Machinery, equipment, and battlefield utility | Sabotage, disruption of eligible devices | Magnetogenic Organs manipulate tagged metal. Magnetic Manipulator displaces or disarms. Magnetic Defender deflects metallic projectiles. | Neural Interface Rig enables drones and interference. Electronic Infiltrator targets compatible electronics. Drone Commander develops support drones. |
| Biochemist | Recovery, stabilisation, and ally enhancement | Stabilise, adjacent emergency assistance | Symbiotic Organ System produces limited close-range treatments. Tissue Regenerator focuses on recovery. Endocrine Specialist supplies temporary physical buffs. | Pharmaceutical Rig supplies limited ranged doses. Combat Medic develops safe treatment. Pharmaceutical Controller distributes effects across small areas. |

Draft equipment trade-offs include claws occupying the Razor primary slot, Sentinel forms restricting rigid armour, wings competing with an integrated Scout harness, biological and cybernetic eyes being physically exclusive, and major Engineer or Biochemist architectures occupying integrated capacity. The class framework proposes a primary, sidearm, armour, two utilities and an architecture commitment. Final slots and per-class access are open.

## Build 10 combat kits

| Operative | Actual prototype actions |
| --- | --- |
| Razor | **Area Shred.** Charge zero to three walkable tiles, then sweep three consecutive adjacent tiles for 2 damage each. The charge can trigger enemy reactions. The sweep ignores unit cover and can damage light cover. |
| Sentinel | **Fortify.** +2 temporary armour to the Sentinel and an ally within two tiles. **Sentinel Breach.** Charge in a straight cardinal line up to four tiles, break eligible light or reinforced cover, and deal 5 collision damage with a weight- and destination-checked push. |
| Marksman | **Precision Shot.** Basic weapon damage +2, ignores one cover level, uses normal weapon range and LOS. |
| Engineer | **Arc Disruptor.** Weapon damage +1 and target loses 1 AP next phase. Normal weapon range and LOS. |
| Biochemist | **Field Treatment.** Heal up to 3 HP on a living ally within three tiles. |
| Observer | Design class. Build 10 deploys the other five classes. |

These special actions cost 1 AP in the current test balance. Area Shred, Fortify and Precision Shot are once per turn. Arc Disruptor and Field Treatment each skip the next full player turn before reuse. The prototype abilities and costs do not fix their place in the production rank tree.

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

Design sources are the [Class Design Framework](../references/design/Hammer_Ash_Class_Design_Framework.docx), provisional compendium, 21 November master and combat documents, and Enemy Design conversation evidence. Build behavior comes from the preserved Build 10 script, changelog, and on-screen ability text.
