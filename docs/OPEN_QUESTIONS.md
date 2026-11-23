# Open Questions

## Combat decisions

| Decision | What is already agreed | What needs confirmation or testing |
| --- | --- | --- |
| First-down recovery | Miss the next two full player turns and stand at the start of the third at half HP rounded up. The half-HP ceiling persists for the mission. While down, the operative blocks their tile, clears temporary statuses, and cannot be targeted or treated. Second down is permanent. Zero standing operatives is a wipe. | Playtest timer pacing and attrition. Campaign medical and HQ rules are tracked below. |
| Class-specific opportunity attacks | Eligibility can be innate, passive-enabled, or modified by a passive. | Which classes and enemies qualify, adjacency/reach, entry vs exit triggers, AP/reserve/cap, order relative to Overwatch, charge, displacement and teleport exceptions. |
| Armour and damage | Deterministic ordinary attacks, armour before HP, phase and room refresh to current maximum, directional cover. | Cover formulas, order of damage/cover/piercing/status modifiers, rounding, damage types and resistances, armour-break rules, changes to maximum armour, and cap persistence. |
| Movement and targeting | Standard move is four tiles for 1 AP, geometry blocks LOS, elevation is logical. | Diagonal costs, corner shots, LOS edge ties, climbing paths, height modifier, reach, deterministic extended-range behavior and preview semantics. |
| Weapons and ammunition | Unlimited replacement magazines, three rounds per firearm for the first tuning pass, and a 1 AP working reload cost. Reload before empty or refill automatically on room entry. AI and Overwatch respect ammo. | Weapon-specific capacities, reload exceptions, bursts and ammo costs for future special attacks. |
| Hazards and statuses | Effects apply deterministically when eligible, and the prototype exercises selective destruction and hazards. | Final status list, durations and owner ticks, extension rules, immunity, hazard/armour order, friendly-fire exceptions, and whether to adopt collision damage from Build 10 despite the earlier design baseline. |
| Medical campaign rules | Injury and loss persist across encounters. HQ removes the mission-only half-HP cap on return. | Lasting wounds and severity, downtime, treatment resources, triage, replacement cadence and cases that affect recruitment or redeployment. |

## Classes, equipment and enemies

- Playtest the provisional [Scythe tree](../references/design/SCYTHE_CLASS_DESIGN.md), including the fixture's two-tile, 1 AP Charge and the impact of Overwatch interruption. Origin balance, Level 1–9 gates and unlock rules remain open.
- Develop the five remaining class trees using Scythe as the reference. Define each archetype's shared and exclusive powers, meaningful weaknesses, and any hybrid options.
- Playtest the starter equipment and one-use Medkit. Two-handed rifles and Wolverine Claws block the melee slot. Decide whether other two-handed weapons or class abilities restrict additional slots. Supply budget, respecialisation, XP pacing and experienced recruits remain open.
- Choose the first named opposition roster and encounter budget. Test role synergies and mixed vs homogeneous rosters against swarm, control, protected and support enemies. Establish how often special gates can occur and how intelligence telegraphs them.
- Confirm enemy awareness, target scoring, role priorities, morale or escalation triggers, and how reaction and hazard previews expose enemy intent.

## Missions and campaign

- Confirm the first branching mission, its canon name, room graph and gate logic. Operation Red Ledger is a proposed candidate and Cold Signal is a documented worked example.
- Define objective deadlines and consequences, overlapping alarms, partial success, additional PMOs, what constitutes securing a reward, extraction behavior, wipe and scripted exceptions. Decide which rescue variants require escort and when recruitment or information becomes persistent.
- The [v0.5 decision register](campaign/H_A_Campaign_Decision_Register_v05.md) keeps Stage 5 decisions 22–27 open: escalation effects, Soviet response depth, regional boss activity, strategic events, the Moscow finale format and defeat handling.
- The latest bunker layout has seven regional slots and Moscow. Reconcile the progression and defeat thresholds in v0.5, which assumes eight liberation candidates before Moscow, when implementing the strategic campaign.
- Confirm regional offer edge cases, progress and pressure thresholds, programme timings, adaptation signals, partial network access after regional loss, and the limited recovery opportunity.
- Confirm the bunker HQ's facility upgrades, research prerequisites, project concurrency and costs, starting roster, recruitment/recovery timing, equipment recovery and Intel activation limits. The HQ sandbox uses provisional values.

## Presentation, production and migration

- Decide final camera angle and sprite scale, tile/edge markings, art and animation budget, audio, accessibility, and target platforms beyond the working PC direction.
- Verify Build 10 in Windows using Godot's normal controls and record the results. Decide how to set up and track baseline source in the existing Windows Git workspace, if there is one.
- Recover missing project instructions, conversation transcripts and known legacy files if they are still available. [Development Status](DEVELOPMENT_STATUS.md) records the named gaps.

For a conflicting source, apply the latest explicit creator decision, then the latest relevant specialist specification. Use the prototype to establish current execution behavior. Record unresolved interpretations before making them design defaults.
