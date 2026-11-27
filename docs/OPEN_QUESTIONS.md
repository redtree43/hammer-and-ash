# Open Questions

> Earlier review snapshot. Update and review unresolved decisions in the [current register](design/OPEN_DECISIONS.md).

## Combat decisions

| Decision | What is already agreed | What needs confirmation or testing |
| --- | --- | --- |
| First-down recovery | Miss the next two full player turns and stand at the start of the third at half HP rounded up. The half-HP ceiling persists for the mission. While down, the operative blocks their tile, clears temporary statuses, and cannot be targeted or treated. Second down is permanent. Zero standing operatives is a wipe. | Playtest timer pacing and attrition. Campaign medical and HQ rules are tracked below. |
| Class-specific reactions | In playable V3, Scythe's Threatening Presence reacts once per round to an adjacent enemy walking away, excluding forced movement and vaults. Anvil's Iron Lock can counter an approach. The redesign adds separate interception and retaliation cases. | Confirm which V3 reactions survive the redesigns, how overlapping triggers resolve, and enemy eligibility. |
| Armour and damage | Deterministic ordinary attacks, armour before HP, phase and room refresh to current maximum, directional cover. | Cover formulas, order of damage/cover/piercing/status modifiers, rounding, damage types and resistances, armour-break rules, changes to maximum armour, and cap persistence. |
| Movement and targeting | Standard move is four steps for 1 AP. Diagonals count as one step for both sides. Units may have square footprints larger than one tile. Geometry blocks LOS, and elevation is logical. | Playtest corner clearance with large units. Confirm footprint-based attack range, LOS and cover sampling, corner shots, LOS edge ties, climbing paths, height modifier, reach, deterministic extended-range behavior and preview semantics. |
| Ranged attack resources | Bunker ranged base attacks use three charges with a 1 AP recharge in the prototype. Enemy and fixture firearms use three-round magazines. Room entry replenishes both pools. | Confirm charge capacity, whether all powered ranged attacks should recharge, and how Emergency Reload should work in the final system. |
| Hazards and statuses | Effects apply deterministically when eligible, and the prototype exercises selective destruction and hazards. | Final status list, durations and owner ticks, extension rules, immunity, hazard/armour order, friendly-fire exceptions, and whether to adopt collision damage from Build 10 despite the earlier design baseline. |
| Medical campaign rules | Injury and loss persist across encounters. HQ removes the mission-only half-HP cap on return. | Lasting wounds and severity, downtime, treatment resources, triage, replacement cadence and cases that affect recruitment or redeployment. |

## Classes, equipment and enemies

- Playtest the [six V3 trees](IMPLEMENTATION_NOTES.md#v3-player-classes) at each ability gate and across linked rooms. Manual level and node selection drives the current implementation. Campaign XP, unlock pacing and respecialisation remain open.
- Tune V3 targeting ranges, damage, enemy resistance and cooldowns against full missions. The prototype represents one-point effects as integers, so Catalytic Cascade currently rounds a half-strength one-point effect up to one. Confirm how to distinguish copied effects at the final combat scale and which mission layouts should contain smoke and water.
- Playtest the issued Supersuit and one-use Medkit. Decide whether suits have variants or upgrades, how these would be acquired or recovered, and how to represent innate protection alongside suit protection. Frog and Jellyfish currently reuse Komodo's mobility and Snail's defence mechanics and placeholder art. Confirm their final form-specific abilities and visuals. Supply budget, respecialisation, XP pacing and experienced recruits remain open.
- Resolve the [Scorpion and Anvil revisions](CLASSES_AND_ENEMIES.md#scorpion-and-anvil-design-revisions) against V3. Confirm Scorpion's Claw Grab duration, whether Moulting Skin can repair permanent cap loss, and what Burrowing Strike bypasses. Confirm Anvil's Interpose eligibility and timing, the final nodes for both origins, and AP, range and cooldown tuning. Class rename candidates remain undecided.
- Choose the first named opposition roster and encounter budget. Test role synergies and mixed vs homogeneous rosters against swarm, control, protected and support enemies. Establish how often special gates can occur and how intelligence telegraphs them.
- Confirm enemy awareness, target scoring, role priorities, morale or escalation triggers, and how reaction and hazard previews expose enemy intent.

## Missions and campaign

- Confirm the first branching mission, its canon name, room graph and gate logic. Operation Red Ledger is a proposed candidate and Cold Signal is a documented worked example.
- Define objective deadlines and consequences, overlapping alarms, partial success, additional PMOs, what constitutes securing a reward, extraction behavior, wipe and scripted exceptions. Decide which rescue variants require escort and when recruitment or information becomes persistent.
- The [v0.5 decision register](campaign/H_A_Campaign_Decision_Register_v05.md) keeps Stage 5 decisions 22–27 open: escalation effects, Soviet response depth, regional boss activity, strategic events, the Moscow finale format and defeat handling.
- The current USSR screen has eight map districts, including the Central Federal District. An earlier bunker layout showed seven regional slots and Moscow. Confirm whether Moscow is a separate final operation within the Central district and which districts count toward liberation and lockouts. The v0.5 thresholds of four liberations and five lockouts assume eight eligible regions.
- Confirm regional offer edge cases, progress and pressure thresholds, programme timings, adaptation signals, partial network access after regional loss, and the limited recovery opportunity.
- Confirm the bunker HQ's facility upgrades, research prerequisites, project concurrency and costs, starting roster, recruitment/recovery timing, equipment recovery and Intel activation limits. The HQ sandbox uses provisional values.
- Decide where Workshop recipe research from campaign v0.5 belongs in the bunker interface. The current layout reference shows Stratagems and Intelligence Operations. Their open slots are presentation placeholders pending the project list and prerequisite design.

## Presentation, production and migration

- Test the fixed angled 2D view in Sabotage. Decide the projection, sprite scale, occlusion handling, tile and cover-edge markings, and whether the 28×20 map needs panning. Art and animation scope, audio, accessibility and final target platforms remain open.
- Recheck editor F5 after the Supersuit pass and manually play full missions with the current loadouts. Complete the 28×20 Sabotage annex playthrough and assess the round-three approach. [Recorded checks](BUILD_10_PLAYTEST.md).
- Recover missing project instructions, conversation transcripts and known legacy files if they are still available. [Development Status](DEVELOPMENT_STATUS.md) records the named gaps.

Use the [current design specification](design/README.md) for intended behavior and record new issues in the [current review register](design/OPEN_DECISIONS.md).
