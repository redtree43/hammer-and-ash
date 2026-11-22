# Open Questions

## Combat decisions

| Decision | What is already agreed | What needs confirmation or testing |
| --- | --- | --- |
| First-down recovery | Automatic recovery at half HP, mission-long half-HP ceiling, and permanent loss on the second down. | Two or three turns, countdown clock/tick order, half-HP rounding, targetability, tile occupancy, medic intervention, status handling, and wipe behavior with recovery pending. |
| Class-specific opportunity attacks | Eligibility can be innate, passive-enabled, or modified by a passive. | Which classes and enemies qualify, adjacency/reach, entry vs exit triggers, AP/reserve/cap, order relative to Overwatch, charge, displacement and teleport exceptions. |
| Armour and damage | Deterministic ordinary attacks, armour before HP, phase and room refresh to current maximum, directional cover. | Cover formulas, order of damage/cover/piercing/status modifiers, rounding, damage types and resistances, armour-break rules, changes to maximum armour, and cap persistence. |
| Movement and targeting | Standard move is four tiles for 1 AP, geometry blocks LOS, elevation is logical. | Diagonal costs, corner shots, LOS edge ties, climbing paths, height modifier, reach, deterministic extended-range behavior and preview semantics. |
| Weapons and ammunition | Equipment locks during the mission and magazines reload during room transitions. | Magazine sizes, confirmed reload AP for exceptions, ammo reserve/charge tracking, bursts, weapon access, resupply and special attacks. |
| Hazards and statuses | Effects apply deterministically when eligible, and the prototype exercises selective destruction and hazards. | Final status list, durations and owner ticks, extension rules, immunity, hazard/armour order, friendly-fire exceptions, and whether to adopt collision damage from Build 10 despite the earlier design baseline. |
| Medical campaign rules | Injury and loss persist across encounters. HQ removes the mission-only half-HP cap on return. | Lasting wounds and severity, downtime, treatment resources, triage, replacement cadence and cases that affect recruitment or redeployment. |

## Classes, equipment and enemies

- Lock costs, cooldowns, restrictions and advancement for the provisional kits. Resolve how draft Observer scouting and camouflage fit the exclusion of a general stealth system, and how older accuracy/suppression language maps to deterministic rules.
- Decide primary/secondary equipment and utility slots, overlap of equipment and powers, supply budget, whether an architecture can be respecialised, XP pacing, and how experienced recruits arrive.
- Choose the first named opposition roster and encounter budget. Test role synergies and mixed vs homogeneous rosters against swarm, control, protected and support enemies. Establish how often special gates can occur and how intelligence telegraphs them.
- Confirm enemy awareness, target scoring, role priorities, morale or escalation triggers, and how reaction and hazard previews expose enemy intent.

## Missions and campaign

- Confirm the first branching mission, its canon name, room graph and gate logic. Operation Red Ledger is a proposed candidate and Cold Signal is a documented worked example.
- Define objective deadlines and consequences, overlapping alarms, partial success, additional PMOs, what constitutes securing a reward, extraction behavior, wipe and scripted exceptions. Decide which rescue variants require escort and when recruitment or information becomes persistent.
- Define the size and pacing of the campaign, regional/faction relationships, Soviet programme timings, state adaptation rules, failure thresholds and comeback paths. Specify which changes the player can see or investigate.
- Confirm the mobile HQ's form, functions and upgrade scope. Define the agency's origin, major antagonists, allied factions, endgame milestones and victory/failure conditions.

## Presentation, production and migration

- Decide final camera angle and sprite scale, tile/edge markings, art and animation budget, audio, accessibility, and target platforms beyond the working PC direction.
- Verify Build 10 in Windows using Godot's normal controls and record the results. Decide how to set up and track baseline source in the existing Windows Git workspace, if there is one.
- Recover missing project instructions, conversation transcripts and known legacy files if they are still available. [Development Status](DEVELOPMENT_STATUS.md) records the named gaps.

For a conflicting source, apply the latest explicit creator decision, then the latest relevant specialist specification. Use the prototype to establish current execution behavior. Record unresolved interpretations before making them design defaults.
