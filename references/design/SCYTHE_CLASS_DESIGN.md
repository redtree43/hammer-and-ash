# Hammer & Ash: Uprising — Scythe Class Design

**Document status:** **PROVISIONAL — SUBJECT TO PLAYTESTING AND REVISION**  
**Version:** 0.1 (design baseline)  
**Date:** 22 November 2026  
**Class:** Scythe  
**Role:** Close-quarters damage dealer  
**Prototype status:** Design specification, **not a claim that these abilities are already implemented**.

> **Change policy:** This document captures the currently agreed Scythe concept for further design and prototyping. All ability effects, AP costs other than the explicitly updated Charge cost, damage values, ranges, cooldowns, thresholds, progression gates, and interactions remain **provisional** and may change significantly following testing. Do not treat this as a locked implementation or final balance specification.

## 1. Class identity

**Tactical problem:** How does the squad close distance, break into enemy positions, and eliminate opponents at short range?

Scythe is an aggressive close-quarters combat class. Every Scythe should be able to approach and threaten an enemy, but its power origin determines *how* it closes distance, deals damage, and survives the counterattack.

- **Wolverine:** Anti-armour, regeneration, sustained melee pressure. Excels after committing to combat; has relatively poor disengagement and mobility tools.
- **Arachnid:** Rapid movement, web-based control, evasive defence. Excels at positioning and handling mobile or numerous enemies; lacks Wolverine's dedicated armour destruction.
- **Blink:** Intrinsic teleportation, burst attacks, ally relocation, and escape. Has the greatest positioning flexibility, but is the least durable when caught.

The origins are **mutually exclusive**: an operative selects one at Level 1. Their signature biology/powers are not transferable across origins. Shared Scythe training and explicitly shared power abilities can be used across origins; in particular, Wolverine and Arachnid can learn the limited teleport ability **Phase Surge** without gaining the broader Blink power set.

### Combat context

The working combat model has a **3 AP** player-turn economy, deterministic attacks within effective range, directional cover, and armour that can be damaged or permanently destroyed for the mission. Scythe's mobility and attack effects should create choices within this system rather than invalidate positioning. Melee opportunity attacks are class-specific and do not trigger from forced movement or teleportation.

## 2. Tree structure and notation

- **Active:** Player activates an ability; its exact AP cost/cooldown may still need specifying.
- **Passive:** Automatic or conditional effect; no separate activation.
- **Shared:** Available to any Scythe origin.
- **Exclusive:** Available only to the specified origin.
- **Choose one:** Two mutually exclusive nodes at the same decision point; the Scythe does not gain both by default.

**Progression note:** Levels 1–9 are **proposed unlock gates**. Skill-point costs, prerequisites, and whether some nodes are automatically granted are not finalized by this document.

## 3. Ability progression (Levels 1–9)

### Level 1 — Shared action and exclusive origin

**Charge — Shared · Active**  
**AP cost: 1 AP (explicitly updated)**. Rush a **single enemy** and make one close-range attack. Charge is the common aggressive approach tool; charge range, route requirements, reaction interactions and any per-turn restrictions are **TBD**.

Select **exactly one** origin:

| Origin | Ability | Type | Provisional effect |
|---|---|---|---|
| **Wolverine** | **Claws** | Passive | Each **basic attack** destroys **1 enemy armour**. Armour destruction is intended to be lasting rather than only depleting temporarily regenerating armour. |
| **Arachnid** | **Spider Agility** | Passive | Gain **+1 movement tile** when performing a movement action. Exact interaction with Charge and other movement abilities is TBD. |
| **Blink** | **Short Blink** | Active | Teleport a short distance to a valid destination cell. Specific range, AP cost, line-of-sight restrictions and cooldown are TBD. |

### Level 2 — Origin signature

| Origin | Ability | Type | Provisional effect |
|---|---|---|---|
| Wolverine | **Regrowth** | Passive | Restore some HP at the start of the operative's phase, respecting the mission's healing and incapacitation limits. Amount TBD. |
| Arachnid | **Web Snare** | Active | Shoot webs at a target to **immobilise it for 1 turn**; movement is disabled, but other actions and escape conditions are TBD. |
| Blink | **Phase Strike** | Passive | Gain bonus damage on an attack made after teleporting. Magnitude and qualifying timing window TBD. |

### Level 3 — Shared training

**Threatening Presence — Shared · Passive**  
**Once per round**, make a melee opportunity attack against an adjacent enemy that **moves away normally**. Teleportation and forced movement **do not** trigger it. Exact reaction limits and resolution timing are TBD.

### Level 4 — Exclusive branch choice

Choose **one of the two options within the selected origin**:

| Origin | Option A | Type | Option B | Type |
|---|---|---|---|---|
| **Wolverine** | **Plate Ripper:** Claw attacks destroy **1 additional armour** (normally 2 total for a qualifying basic attack). | Passive | **Fast Knit:** If the operative ends their turn with **at least 1 AP remaining**, Regrowth heals additional HP at the start of their next phase. | Passive |
| **Arachnid** | **Tether Yank:** Pull an enemy **up to 2 tiles toward the operative** using webbing. Range, collision and boss-size interactions TBD. | Active | **Arachnid Sense:** Activate so the **next targeted attack** against this operative **misses**. Expiration, AP cost, cooldown and interactions with area damage TBD. | Active |
| **Blink** | **Spatial Exchange:** Swap positions with an **adjacent enemy**; validity, size/boss restrictions and AP cost TBD. | Active | **Rift Lunge:** Teleport around one enemy and **strike twice**. Attack and teleport positioning, AP cost and cooldown TBD. | Active |

### Level 5 — Shared mutually exclusive choice

Choose **one**:

- **Pursuit — Passive:** After a **close-range kill**, move **up to 2 tiles**. Trigger frequency, timing and enemy reaction handling TBD.
- **Execution Drill — Passive:** Deal additional close-range damage against an **isolated enemy**, defined for now as a target with **no other enemies adjacent to it**. Damage bonus TBD.

### Level 6 — Power-based mobility/utility

| Eligible origins | Ability | Type | Provisional effect |
|---|---|---|---|
| **Wolverine and Arachnid** | **Phase Surge** | Active | Unleash a **limited short-range teleport burst**. This is an **ability/power, not an item**, and uses **no equipment slot**. Exact range, AP cost, cooldown and in-world power explanation TBD. |
| **Blink only** | **Rift Relay** | Active | Select an **ally standing adjacent** to Blink and teleport that ally to a valid cell **within 6 tiles**. AP cost, cooldown, destination/line-of-sight rules and interaction with occupied tiles TBD. |

These nodes give all origins additional tactical flexibility without removing Blink's identity as the superior teleportation specialist.

### Level 7 — Shared training

**Opening Blow — Shared · Passive**  
The **first close-range hit each round** makes its target take **+1 damage from the next allied close-range attack**. This does **not** grant a free additional attack. Mark expiry and whether the originating Scythe qualifies as the next attacker remain TBD.

### Level 8 — Exclusive origin capstone

| Origin | Ability | Type | Provisional effect |
|---|---|---|---|
| Wolverine | **Rabid Frenzy** | Active | A heavy **double strike** that applies lasting armour reduction. Whether each hit inherits Claws/Plate Ripper, AP cost and cooldown require explicit balancing. |
| Arachnid | **Silkstorm** | Active | Apply **area webbing** and inflict **poison for 2 rounds** on affected enemies. Exact area, whether webbing immobilises/slows, damage per poison tick and friendly-fire rules TBD. |
| Blink | **Rift Reaper** | Active | Teleport to attack an **isolated target**, then return to the **original square**. Strike damage, destination requirements, valid isolation condition and cooldown TBD. |

### Level 9 — Shared class capstone

**Overdrive — Shared · Active**  
**Once per room**, activate an assault state that increases **movement and close-range damage for 1 turn**. Bonus values, AP cost and stacking with origin abilities are TBD. The same underlying capstone supports different playstyles: a committed Wolverine brawler, an agile Arachnid controller or a Blink assassin.

## 4. Tactical differentiation and intended trade-offs

| Dimension | Wolverine | Arachnid | Blink |
|---|---|---|---|
| Defining strength | Sustained melee and persistent armour shredding | Mobility, movement control and attack avoidance | Extreme repositioning and burst attacks |
| Survival mechanism | Regeneration and staying power | Evasion, range control and avoidance | Escape and avoiding exposure |
| Anti-armour performance | **Highest** through Claws, Plate Ripper and Rabid Frenzy | Relatively limited | Relies on target selection and burst; armour remains a challenge |
| Area / multi-target utility | Limited by melee commitment | Web Snare, Tether Yank and Silkstorm | Position swapping, ally teleporting and selective target access |
| Biggest weakness | Being kited, isolated or unable to disengage | Heavy armour and resistant enemies | Fragility when stranded or abilities are on cooldown |

A powerful origin should be **different**, not simply a stronger version of another. No origin should gain all three of Wolverine's anti-armour/sustain, Arachnid's control/evasion and Blink's extensive teleport toolkit.

## 5. Implementation and balance questions — deliberately unresolved

These are **not** confirmed mechanics and should be tested before final implementation:

1. **Charge at 1 AP:** What maximum charge distance and path restrictions prevent a move-and-attack ability from making normal movement or attacks obsolete? Does it provoke reactions?
2. **Claws and armour:** Confirm how permanent armour destruction stacks with multiple hits, ordinary damage, Plate Ripper and Rabid Frenzy; test against enemies with regenerating armour.
3. **Healing limits:** Confirm Regrowth/Fast Knit obey the 50% HP post-downed cap and any other mission-specific recovery restrictions.
4. **Spider Agility:** Specify whether it modifies only ordinary movement or also Charge, leap-style actions and post-kill Pursuit.
5. **Arachnid Sense:** Set activation cost, expiry, cooldown and whether it avoids only targeted attacks (not hazards or area effects).
6. **Mobility powers:** Specify Phase Surge's short teleport limits and how it remains meaningfully weaker than dedicated Blink abilities despite being available to two other origins.
7. **Control effects:** Specify immobilisation, pulling and poison interactions with large enemies, elites and bosses; avoid binary hard counters.
8. **Opportunity attacks:** Check Threatening Presence's frequency, action costs, reactions, and interaction with ordinary movement versus teleport/knockback.
9. **Action economy:** Check Pursuit, Rift Lunge, Opening Blow and Overdrive for excessive mobility, damage bursts or unintended action chains.
10. **Progression economy:** Resolve ability costs, prerequisites, whether shared nodes are automatic, and how choices interact with the wider operative progression system.
11. **Room persistence:** Define per-room cooldowns and once-per-room effects consistently with multi-room missions, extraction and persistent HP.
12. **Ability tooltips:** Preview AP, damage, armour destruction, affected cells and movement destination before confirming actions.

## 6. Testing goals

In Godot prototype encounters, assess whether:

- Three Scythe origins **solve the same close-range problem differently** and produce recognisably distinct turns.
- Wolverine can crack Steel Men and other armoured threats without completely eclipsing Needle or Iskra.
- Arachnid is useful against hounds, enemy formations and protected ranged troops without overwhelming them with guaranteed control.
- Blink can reach and eliminate dangerous support enemies, but suffers real consequences when caught after committing.
- A five-Scythe squad has important weaknesses against diverse opposition, rather than trivialising encounters.
- The **1 AP Charge** is impactful without dominating other AP uses.

**Approval scope:** Current class identity, chosen abilities, naming and broad node placement are recorded here as the working design. **This entire class tree remains provisional pending gameplay testing and further design review.**
