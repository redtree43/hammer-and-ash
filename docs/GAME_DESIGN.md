# Game Design

**Confirmed** means an accepted direction or working rule. **Provisional** means a tuning choice, candidate implementation, or illustrative design. **Superseded** identifies a retired direction. Build-specific behavior and design gaps are in [Development Status](DEVELOPMENT_STATUS.md).

## Tactical rules

| System | Confirmed baseline | Provisional details |
| --- | --- | --- |
| Squad and turns | Deploy at most five operatives. Alternate player and enemy faction phases. The player can switch among operatives with AP remaining. A standard operative starts with 3 AP. | Unit exceptions, supply and loadout budget. |
| Movement | A standard 1 AP move reaches four tiles along a legal path. Occupied/blocked cells constrain movement. Logical height changes require authored connections such as stairs or ramps. | Diagonals, elevation benefits and special movement. |
| Attacks | Basic attacks cost 1 AP. Legal ordinary attacks hit for deterministic damage, with neither accuracy rolls nor critical hits. Ordinary ranged attacks require valid range and LOS. Previews and resolution must agree. | Range metric and any extended-range damage falloff, exact modifier order, rounding, and body/weapon exceptions. |
| Cover | Protection uses shared directional edges with none, half and full tiers. Attacks from an unprotected angle bypass that edge. Solid geometry blocks LOS. The same rules apply to both sides. Melee gains no separate flank bonus. Cover can be selectively destroyed. | Cover reduction vs block, diagonals and edge priority, materials, structural HP, weapon eligibility, elevation interactions. |
| Armour and HP | Eligible damage removes armour before HP. Each side refreshes its armour at the beginning of its phase to each unit's current maximum. Room entry also refills to the current maximum. HP persists and healing needs an item, ability, or explicit authored effect. | Armour cap loss and persistence, armour-piercing order, damage type resistances, and the final rules for armour destruction. |
| Overwatch | Working baseline of 1 AP reserved for one valid basic-weapon reaction against eligible enemy movement. Normal range, LOS, armour, and cover apply. | Trigger geometry, resolution order, expiry and interaction with charges. |
| Melee reactions | Opportunity attacks are class-specific. Eligibility can be innate, passive-enabled, or modified by a passive. | Scythe's Threatening Presence draft triggers once per round when an adjacent enemy moves away normally. Teleportation and forced movement are excluded from that trigger. Final class eligibility, timing, costs and trigger limits remain open. |
| Powers and resources | Use readable ability-specific costs such as AP, cooldowns, charges or ammunition. The design has no global Willpower meter. | The combination of costs for each ability and whether heat, strain or exhaustion apply. |
| Status and terrain | Valid effects apply deterministically subject to immunity. Reapplication may extend duration under the design baseline. Hazards and breakable terrain are in scope. | Status catalogue and caps, individual immunity and tick rules, hazard trigger order, and friendly-fire exceptions. The 21 November spec carries forward a displacement baseline without incidental collision or fall damage. Build 10 tests collision damage. |

### Ammunition and equipment

Firearms use magazines with unlimited replacements. The first tuning pass gives every allied and enemy firearm three rounds per magazine. Later weapon types can use different capacities. A loaded weapon can shoot or reload while partially spent. An empty weapon cannot fire, and its Shoot control is replaced by Reload. Build 10 uses the existing 1 AP working reload cost. Reloading fills the magazine, and entering the next room refills all magazines automatically.

Overwatch requires a loaded firearm and spends a round when it fires. Armed AI reloads an empty magazine. Build 10 also counts Precision Shot, Arc Disruptor and ranged shots against objectives or barrels as gunfire. Melee attacks, adjacent objective strikes and utility actions use no rounds.

The starting loadout has four slots for a ranged weapon, a melee weapon, armour and one equipment item. Gear locks at deployment. Two-handed rifles block the melee slot. Wolverine Claws also block it in the Scythe fixture. Arachnid and Blink may equip melee weapons where their gear allows it. Restrictions for other weapons, armour and classes remain open. Class powers use no equipment slots.

The prototype offers issued firearms, a Service Rifle, a Service Pistol, a Utility Knife, issued armour, a Field Vest and a Medkit. The Service Rifle and Needle's issued rifle are two-handed. The Utility Knife deals 2 damage to an adjacent enemy for 1 AP. The Medkit heals up to 3 HP on the user or an adjacent living ally for 1 AP and respects the mission healing cap. Medkits have one charge each, and spent charges carry forward between rooms.

### Earlier combat decisions retained for reconciliation

Conversation evidence describes single shots as the default, class-specific bursts, deterministic explosives with friendly fire, and move-and-strike melee. It also describes kinetic, thermal, chemical, and electrical damage families, small elevation modifiers, falloff outside effective range, and teleport or forced movement bypassing melee opportunity triggers. These details need reconciliation against weapon legality, reaction exception and damage formula questions in the 21 November combat spec. Seven initial statuses and an eventual range of roughly ten to twelve are reported working scope, with the catalogue still open.

### Downing, recovery and attrition

1. First down starts a timer. The operative cannot act normally while down and stands automatically at half maximum HP when the timer ends.
2. Half maximum HP is also the healing ceiling for the rest of that linked mission. The first-down flag and ceiling carry into later rooms.
3. If the room ends while the operative is down, the working transition rule brings them back at half HP in the between-room flow. A second down anywhere in the linked mission causes permanent loss.
4. Returning to HQ resolves the mission tracking and removes the temporary ceiling. Campaign medical treatment and long-term injury rules remain open. Lasting wounds and a recovery debuff are part of earlier design discussion.

The operative misses the next two full player turns after the round of their first down. A first down in Round 1 means missing Rounds 2 and 3 and standing at the start of player Round 4, before the normal armour and AP refresh. Half HP rounds up. A downed operative blocks their tile, cannot be targeted or treated, and loses temporary statuses. The mission fails if no operative is standing, even with recoveries scheduled.

### Feedback and accounting

Show legal destinations, AP, shot range and LOS, cover, expected damage and effects, and known reactions before commitment. Expose downing and wound-cap state when implemented. Track actual HP and armour removed, excluding prevented damage and overkill. Each affected target produces a distinct damage event. Healing and protection are support events. Keep previews, ledger, room activity, and debrief totals consistent.

## Campaign and roster

- The [campaign master v0.5](campaign/H_A_Campaign_Design_Master_v05.md) governs strategy and progression. Choose one of two regional offers and commit until liberation or permanent loss. Liberate four of eight regions to unlock Moscow. Five regional lockouts or the terminal Soviet countdown can end the run. The target is 15–30 hours, with room for longer runs on higher difficulty.
- The HQ is envisioned as a reskinnable underground resistance bunker. Choose five individuals from one shared roster before each campaign mission. Mission and event recruits supplement timed, class-selectable base recruitment.
- Supplies and Intel fund campaign decisions. The Workshop produces consumables. Permanent gear comes from missions, salvage, events or contacts. Research spans Workshop recipes, in-mission Stratagems and Intel Ops. Intel can be spent during preparation and combat.
- The six class identities are defined by tactical role. Power archetypes vary playstyle within each class, and skill-tree abilities use no equipment slots. Current class names and provisional archetypes are in [Classes and Enemies](CLASSES_AND_ENEMIES.md). Forward-only mission flow, extraction, and carry-over are in [Missions](MISSIONS.md).

## Superseded or excluded

Eight-unit deployment, the provisional two-AP class-framework example, universal Guard, universal melee retaliation, dedicated suppression and stealth, conventional percentage-to-hit and critical hits, 3D combat presentation, voluntary extraction during a live room, first-down recovery only at transitions as a design rule, and a purely linear or fully procedural campaign. Routine binary hard counters were replaced with moderate counters and strong incentives for diverse squads. Some old class entries use accuracy, detection, or suppression language that needs reinterpretation under the current rules.

Primary sources are the 21 November [Combat Specification and Master Game Design](../references/design/), with conversation evidence used for earlier mechanical details and later decisions.
