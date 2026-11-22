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
| Melee reactions | Opportunity attacks are class-specific. Eligibility can be innate, passive-enabled, or modified by a passive. Razor is an example candidate. A typical Marksman lacks the reaction. | Final class assignment, trigger geometry, timing, costs and trigger limits. |
| Powers and resources | Use readable ability-specific costs such as AP, cooldowns, charges or ammunition. The design has no global Willpower meter. | The combination of costs for each ability and whether heat, strain or exhaustion apply. |
| Status and terrain | Valid effects apply deterministically subject to immunity. Reapplication may extend duration under the design baseline. Hazards and breakable terrain are in scope. | Status catalogue and caps, individual immunity and tick rules, hazard trigger order, and friendly-fire exceptions. The 21 November spec carries forward a displacement baseline without incidental collision or fall damage. Build 10 tests collision damage. |

### Earlier combat decisions retained for reconciliation

Conversation evidence describes single shots as the default, class-specific bursts, magazine-based ammunition with a 1 AP reload, deterministic explosives with friendly fire, and move-and-strike melee. It also describes kinetic, thermal, chemical, and electrical damage families, small elevation modifiers, falloff outside effective range, and teleport or forced movement bypassing melee opportunity triggers. These details need reconciliation against weapon legality, reaction exception and damage formula questions in the 21 November combat spec. Build 10 does not establish final weapon, damage-type, or ammunition systems. Seven initial statuses and an eventual range of roughly ten to twelve are reported working scope, with the catalogue still open.

### Downing, recovery and attrition

1. First down starts a timer. The operative cannot act normally while down and stands automatically at half maximum HP when the timer ends.
2. Half maximum HP is also the healing ceiling for the rest of that linked mission. The first-down flag and ceiling carry into later rooms.
3. If the room ends while the operative is down, the working transition rule brings them back at half HP in the between-room flow. A second down anywhere in the linked mission causes permanent loss.
4. Returning to HQ resolves the mission tracking and removes the temporary ceiling. Campaign medical treatment and long-term injury rules remain open. Lasting wounds and a recovery debuff are part of earlier design discussion.

The proposed timer is two to three turns. Exact timing, targetability, tile occupancy, medical intervention, and half-HP rounding remain open. Build 10 currently applies the room-transition recovery and second-down loss. It has no mid-room recovery timer or half-HP healing ceiling.

### Feedback and accounting

Show legal destinations, AP, shot range and LOS, cover, expected damage and effects, and known reactions before commitment. Expose downing and wound-cap state when implemented. Track actual HP and armour removed, excluding prevented damage and overkill. Each affected target produces a distinct damage event. Healing and protection are support events. Keep previews, ledger, room activity, and debrief totals consistent.

## Campaign and roster

- **Confirmed direction.** Model C combines an authored narrative backbone and regional milestones with reactive events and a partly hidden Soviet programme simulation. The player receives broad explanations and increasingly precise forecasts with better intelligence.
- **Confirmed direction.** Resistance capacity, Soviet suppression/technological capacity, and adaptive security doctrine drive change conceptually. Mission outcomes may change faction support, recruits, resources, research, or later threats and routes. Exact currencies, formulas, and which information is shown remain open.
- **Confirmed direction.** The mobile HQ supports mission selection, roster/recovery, research, equipment, recruitment, and faction communication. Aim for a compact strategic layer and credible recovery from ordinary setbacks.
- Six persistent class identities and genetic/technology build paths are described in [Classes and Enemies](CLASSES_AND_ENEMIES.md). Forward-only mission flow, extraction, and carry-over are in [Missions](MISSIONS.md).

## Superseded or excluded

Eight-unit deployment, the provisional two-AP class-framework example, universal Guard, universal melee retaliation, dedicated suppression and stealth, conventional percentage-to-hit and critical hits, 3D combat presentation, voluntary extraction during a live room, first-down recovery only at transitions as a design rule, and a purely linear or fully procedural campaign. Routine binary hard counters were replaced with moderate counters and strong incentives for diverse squads. Some old class entries use accuracy, detection, or suppression language that needs reinterpretation under the current rules.

Primary sources are the 21 November [Combat Specification and Master Game Design](../references/design/), with conversation evidence used for earlier mechanical details and later decisions.
