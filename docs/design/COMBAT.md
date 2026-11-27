# Tactical combat

## Confirmed rules and working baselines

| System | Governing rule |
| --- | --- |
| Squad and phases | Deploy at most five operatives. Player and enemy faction phases alternate. The player can switch between operatives with AP remaining. A standard operative starts with 3 AP. |
| Movement | A standard 1 AP move has a baseline of four steps for either faction. Player class, form and Supersuit modifiers can change the allowance. Diagonals count as one step. A diagonal requires the unit’s full footprint to fit at the destination and at both adjacent orthogonal positions. Units may have square footprints larger than one tile. Occupied or blocked cells constrain movement. Logical height changes use authored connections such as stairs and ramps. [Player baseline](CLASSES_AND_ENEMIES.md#level-1-base-stats) |
| Attacks | Basic attacks cost 1 AP. Legal ordinary attacks deal deterministic damage without accuracy or critical-hit rolls. Ordinary ranged attacks require valid range and line of sight and pass through intervening units unless an ability explicitly says otherwise. For shot range, use the larger of the absolute row and column differences, so a diagonal counts as one tile. The effective range, including applicable bonuses, is a hard maximum. Previews and resolution must agree. |
| Basic melee | An operative can approach an enemy and make one basic melee attack for 1 AP total. The approach uses up to one normal move and ends within melee reach. An operative already in reach strikes from their current tile for 1 AP. |
| Cover | Cover uses shared directional edges with none, half and full tiers. Half cover subtracts a flat amount from incoming ranged damage and leaves at least 1 point of damage from a legal ordinary ranged hit before armour. The reduction amount is open for tuning. Full cover blocks the damage and hit effects of ordinary ranged shots from its protected angle. Firing still spends AP and ammo or charge. Attacks from an unprotected angle bypass the edge, and a power can bypass full cover when it explicitly permits that. Solid geometry blocks line of sight. Both sides use the same rules. Melee gains no separate flank bonus. Only effects that explicitly specify cover damage can damage destructible cover. |
| Armour and HP | Eligible damage removes armour before HP. Armour refreshes to its current maximum at the start of its faction phase and on room entry. Reductions to maximum armour carry across rooms for the rest of the mission. HP persists and healing requires an item, ability or authored effect. |
| Overwatch | Both sides can set a visible ranged cone and hold position for the rest of their turn. The cone extends to the base weapon’s range and widens to four tiles at its far end. Each movement-triggered shot costs 1 AP and 1 ammo or charge. |
| Melee reactions | A player or enemy unit with a basic melee attack may strike an opposing unit that walks out of adjacency. The playtest uses one departure reaction per unit per round. Resolve it before the departure step. Forced moves and leaps skip the trigger. Class passives can suppress or extend reaction behavior. |
| Powers | Abilities use their own readable costs, such as AP, cooldowns, charges or ammunition. There is no global Willpower meter. |
| Status and terrain | Eligible effects apply deterministically, subject to immunity. Reapplying a status refreshes its remaining duration to the full duration for that application. Ongoing status damage ticks at the start of the affected side’s phase. Hazards and breakable terrain are in scope. |

The baseline excludes universal Guard, universal melee retaliation, and dedicated suppression and stealth subsystems. [Earlier combat handoff](../GAME_DESIGN.md#superseded-or-excluded)

The creator confirmed the combined basic melee action on 26 November 2026 in the melee change request. Build 10 uses the shortest legal approach and resolves ordinary movement hazards and reactions along the path. The strike resolves on arrival if the attacker can still hit the target.

An ordinary ranged shot can target any tile a multi-tile unit occupies. A multi-tile attacker can fire from any occupied tile that gives it a legal shot. Check range, line of sight and directional cover from the chosen firing tile to the selected target tile. The creator confirmed diagonal clearance, targeting, range, cover and intervening units on 25 November 2026 in the Open Decisions review. [Open movement and targeting details](OPEN_DECISIONS.md#combat)

A ranged ability can specify that it hits eligible units behind cover and damages the cover protecting them in the same attack. When an attack affects both units and their cover, resolve the hits using the protection in place at the start of the attack. Apply cover damage afterward. The creator confirmed explicit cover damage and this resolution order on 25 November 2026 in the Open Decisions review.

On 25 November 2026 the creator revised the armour rule in the Open Decisions review to make maximum armour loss last through the mission. A class or Supersuit can prevent these reductions if its rules specify that protection. Anvil is an example of the intended design. Specific class and Supersuit eligibility remains open. Ordinary damage to current armour still applies.

The creator confirmed basic-melee departure reactions for both sides on 26 November 2026 in the class implementation review. Slipping Guard can prevent the foe you hit from taking its first eligible departure reaction against you. On 27 November 2026 the creator gave Scythe a second departure reaction per round through Threatening Presence and changed Silent Landing to prevent the first eligible departure reaction after Hawk Wings lands. [Class update](CLASSES_AND_ENEMIES.md#27-november-class-update)

Safe Passage and Adrenal Rescue bypass melee departure reactions. Overwatch still checks each legal step. Safe Passage resolves hazards along the route, and Adrenal Rescue checks hazards at its landing. [Glaz and Alkhimik rules](CLASSES_AND_ENEMIES.md#27-november-glaz-and-alkhimik-implementation)

**27 November 2026, creator confirmation in chat.** Physical full cover blocks direct ranged fire from its protected side for both factions, including basic shots, Overwatch, and drone shots. A follow-up creator decision in chat that day confirms that a shot fired into full cover still spends its regular AP and ammo or charge. A ranged power or drone order spends its usual resources on activation. A blocked shot deals zero damage and applies no hit effects. Build 10 uses a 1-point half-cover reduction as provisional tuning. Solid walls prevent firing. Armour-piercing shots still respect full cover. Melee, area effects, and explicit cover-bypass or cover-destruction rules use their own targeting rules. Destroying a cover edge opens the firing angle immediately. [Campaign retest](../BUILD_10_PLAYTEST.md#27-november-full-cover-campaign-retest)

## Damage resolution

Damage uses one untyped value. The creator retired the Kinetic and Energy distinction on 25 November 2026. **Irradiated** remains a status.

Each hit has its own base damage. An ability can resolve multiple hits in one use. Resolve them in sequence, using the armour remaining after earlier hits. For example, two hits for 2 damage each deal 4 total base damage.

Apply half cover and its one-point minimum where applicable, then resolve the hit under the armour rules below. The replacement for the former resistance model is open. [Resistance review](OPEN_DECISIONS.md#combat)

Define status immunity and any effect that shortens a status in the relevant status or ability rules. The creator confirmed status reapplication and tick timing on 25 November 2026 in the Open Decisions review.

## Status effects

| Status | Confirmed effect |
| --- | --- |
| Irradiated | Deals ongoing damage directly to HP. Its ticks bypass armour and leave current and maximum armour intact. |
| Blinded | Reduces the damage of basic ranged and melee attacks by 2. |
| Bleeding | Deals 1 direct HP damage per tick. |
| Vulnerable | Each attack hit on the affected unit deals 2 additional direct HP damage. Current armour does not absorb that bonus. Needle’s Designate Target lets only the owner of the active designation apply this bonus and spend its three qualifying hits. It expires on the third hit or the owner’s next turn. A new designation refreshes the allowance and transfers ownership. |

The creator confirmed Irradiated, Blinded and Bleeding in the status review on 26 November 2026, and defined Vulnerable and the Wingover application of Bleeding in the Needle review that day. Tick damage for Irradiated, durations, remaining application sources, and status-specific immunity and removal remain open. [Current Needle rules](CLASSES_AND_ENEMIES.md#27-november-class-update) · [Open decisions](OPEN_DECISIONS.md#combat)

## Armour piercing

Armour piercing is a yes-or-no property of an attack. After applicable cover and damage modifiers, a piercing attack bypasses all armour. Other attacks let armour absorb damage normally before HP. Piercing skips armour absorption for that hit, leaving current and maximum armour intact unless a separate effect changes them. The creator confirmed all-or-nothing piercing on 25 November 2026 in the Open Decisions review.

## Elevation

High ground can change line of sight and whether a shot clears cover. It also grants a range bonus to eligible ranged attacks. The creator confirmed these effects on 25 November 2026 in the Open Decisions review. The size of the range bonus, the height difference required and eligibility details remain open. [Open elevation details](OPEN_DECISIONS.md#combat)

**27 November 2026, creator's campaign cleanup request in chat.** Include high cover and high ground on campaign maps for testing. Build 10 marks walkable raised platforms that trigger Needle's High Perch when a round starts there. The shot geometry, movement restrictions and range bonus remain open. [Regional playtest operations](MISSIONS.md#regional-playtest-operations)

## Area attacks

Damaging area attacks hit allies in the affected area by default. An ability can explicitly spare allies. The creator confirmed this default on 25 November 2026 in the Open Decisions review.

## Overwatch

A unit hit by Overwatch continues moving unless it is downed or an effect or ability explicitly stops it. The creator confirmed this rule on 25 November 2026 in the Open Decisions review.

The creator approved visible cones for both sides on 27 November 2026 in the Overwatch implementation request. The cone starts at the unit, runs the length of its base ranged weapon’s reach and widens to four tiles at the far end. Once the cone is set, the unit cannot voluntarily move again that turn. Shots use the AP and ammo the unit has left, and a shot requires both.

In Build 10, press **O** and click a tile to aim and set the cone. Setting it costs no AP. Each hostile movement step that puts any part of the mover’s footprint in the cone can trigger one shot from that watcher, including later steps inside the cone. A legal landing can also trigger a shot. The cone defines reaction range. Line of sight, cover, armour and weapon restrictions still apply. Each shot spends 1 AP and 1 ammo or charge. The cone expires when the watcher’s next phase begins and drops if the watcher is moved or disrupted.

The creator requested a shot count on hovered movement routes and enemy aim that covers visible, feasible approaches on 27 November 2026 after the mixed-trials playtest. Build 10 estimates the shots along the displayed route using each watcher’s current AP, ammo and firing restrictions. It accounts for Scythe’s Charge stopping after the first step that draws fire. Other combat events can interrupt or change the route. Enemy AI looks for tiles standing operatives could reach within two moves, favors cones covering more of the nearer approaches, and skips Overwatch when none offers a legal shot. Enemy cones exclude wall-blocked tiles. [Remaining reaction decisions](OPEN_DECISIONS.md#combat)

**27 November Iskra clarification.** A moving Drone Command drone can trigger enemy Overwatch along its route. The enemy spends the usual shot resources. If the drone is destroyed, it stops moving and any pending attack or shield projection is cancelled. [Iskra redesign](CLASSES_AND_ENEMIES.md#27-november-iskra-redesign)

## Collision and displacement

A blocked push stops. It deals impact damage only when the ability or hazard explicitly specifies it.

Confirmed by the creator on 25 November 2026 in the Open Decisions review. [Build 10 difference](../DEVELOPMENT_STATUS.md#gaps-between-design-and-code)

A fall deals 3 base damage by default. Fall damage bypasses armour and goes directly to HP. The creator confirmed the amount and armour bypass on 25 November 2026 in the Open Decisions review. Which drops count as falls remains open. [Open elevation details](OPEN_DECISIONS.md#combat)

## Equipment

The **Supersuit** is the operative’s single persistent equipment piece. It replaces separate weapon and armour items. Consumables remain. Base attacks come from the operative’s class, origin and active Darwinian or Healing form. [Base attacks](CLASSES_AND_ENEMIES.md#base-attacks)

Players can equip different Supersuit variants between missions. Variants are restricted by class and can grant abilities, change operative stats such as HP or damage, or change the stats of existing abilities. Each suit retains its tier after acquisition. Players acquire higher-tier suits separately. The creator confirmed variants, effects, class restrictions and fixed tiers on 25 November 2026 in the Open Decisions review. Requirements beyond class remain open. [Acquisition and recovery](CAMPAIGN.md#economy-workshop-and-research)

An operative’s class or Supersuit can change how many consumables they carry. The creator confirmed variable capacity on 25 November 2026 in the Open Decisions review. The default capacity and specific allowances remain open. [Equipment review](OPEN_DECISIONS.md#classes-equipment-and-enemies)

## Ranged attack resources

Only designated ranged base attacks use charges. Build 10 trials three charges for Sightline, Arc Pistol and Suit Cannon, with a 1 AP recharge and room-entry refills. Final attack assignments, capacity, recharge cost, room-entry refill and Emergency Reload remain open.

Confirmed by the creator on 25 November 2026 in the Open Decisions review. [Ranged resource review](OPEN_DECISIONS.md#combat)

## Downing and recovery

- On a first down, the operative misses the next two full player turns. They stand at the start of the third at half maximum HP rounded up, before the normal armour and AP refresh. A first down in Round 1 means missing Rounds 2 and 3 and standing at the start of player Round 4.
- While down, the operative blocks their tile, clears temporary statuses and cannot be targeted or treated. If the room clears before the timer ends, the operative stands at half HP during the transition.
- The first-down count and half-HP healing ceiling persist for the linked mission. A second down is permanent loss. Zero standing operatives is a wipe even with recovery scheduled. Returning to HQ removes the mission ceiling. Campaign wounds and treatment are tracked separately. [Campaign](CAMPAIGN.md#headquarters-and-personnel)

## Feedback and accounting

Show legal destinations, AP, range and line of sight, cover, expected damage and known reactions and effects before commitment. Expose downing and healing ceilings. Track actual HP and armour removed, excluding prevented damage and overkill. Record distinct damage events per affected target and treat healing and protection as support events. Keep previews, the ledger, room activity and debrief totals consistent.

Sources include the 21 November master and combat specifications and later creator decisions captured in the current handoffs. [Combat handoff](../GAME_DESIGN.md) · [Original combat specification](../../references/design/Hammer_Ash_Combat_Specification_v1.0_2026-11-21.docx)
