# HAMMER & ASH: UPRISING — CAMPAIGN DESIGN MASTER v0.5

> Historical campaign transfer and provenance. The current specification is [Campaign and headquarters](../design/CAMPAIGN.md).

**Master campaign design v0.5 · 23 November 2026**\
**Status:** WORK IN PROGRESS — for directional review, not final production balance\
**This v0.5 transfer consolidated the campaign workshop alongside `H_A_Campaign_Decision_Register_v05.md`.**

> **Status legend:** **CONFIRMED** = player-selected direction; **TRIAL** = suggested initial implementation to test, not approved balance; **OPEN** = undecided / requires a separate decision.

**24 November update.** Build 10 uses an issued Supersuit as the single persistent equipment piece, plus one consumable slot. Separate player weapon and armour items are superseded. The USSR screen shows eight federal districts, with four trial operations in Central. Confirm which districts count toward liberation and how Moscow fits before implementing the thresholds below. Workshop recipe research remains part of the campaign design. Its place in the current two-board bunker layout is open. [Current bunker](../IMPLEMENTATION_NOTES.md) · [Open decisions](../OPEN_QUESTIONS.md#missions-and-campaign).

## 0. Design vision

*Hammer & Ash: Uprising* is a squad-based tactical resistance game set in an alternate-history 1980s Soviet Union. The campaign is a sequence of high-stakes **regional liberation attempts**, not a conventional base-building strategy game. The player chooses **one of two randomly offered regions**, commits until it is liberated or permanently lost, and carries forward operatives, captured equipment, researched resistance capabilities, and the consequences of Soviet adaptation. A loss hurts, but surviving operatives and secured mission rewards can keep the campaign alive. Each attempt should feel different due to offers, regional networks, Soviet programmes, commander variants and the player's own tactical behaviour.

**Design pillars**

1. **Consequential regional campaigns** — one region at a time; four successful liberations unlock Moscow.
2. **Tactical focus** — most of the experience is missions and squad preparation, with streamlined headquarters decisions.
3. **Persistent, scarce equipment** — recover valuable non-consumable gear through missions; manufacture only consumables.
4. **Resistance versatility** — research unlocks tactical support, information and consumable options, not a runaway ladder of passive stats.
5. **Recoverable setbacks** — regional loss and operative death matter without routinely creating unwinnable death spirals.
6. **An adapting adversary** — strategic Soviet research and softer, behaviour-driven tactical counters reshape future encounters.

## 1. Campaign shape and victory conditions

| Topic | Decision | Status |
|---|---|---|
| Campaign length | **15–30 hours** per successful campaign; higher difficulty may take longer | CONFIRMED |
| Campaign form | Hybrid strategic freedom and authored milestones | CONFIRMED |
| Geography | Stylised map of **eight federal-Russian regions** plus specific tactical locations | CONFIRMED |
| Randomness | Partially randomised mission offers / threats, with an authored narrative spine | CONFIRMED |
| Regional selection | **Two randomly offered eligible regions**, choose one; exact offer fairness algorithm OPEN | CONFIRMED direction |
| Commitment | After selection, remain in that regional campaign until **liberation or permanent loss** | CONFIRMED |
| Time | Calendar-based progression; missions, research, recruitment and recovery interact with the calendar | CONFIRMED |
| Mission choices | Limited mission opportunities; some expire or compete with each other | CONFIRMED |
| Victory | Liberate **four regions**, then successfully attack the **Politburo in Moscow** | CONFIRMED in v0.5. Eligible regions under the current map are OPEN. |
| Defeat | **Five regions locked**, terminal Soviet countdown, or destruction of resistance | CONFIRMED principle. Lockout count under the current map and the exact resistance-destruction condition are OPEN. |
| Liberated regions | Permanently secure; no obligatory reconquest loop | CONFIRMED |
| Moscow | Final operation; detailed structure not yet selected | OPEN (Stage 5) |

**Eligibility / timing notes:** Regions not chosen can continue Soviet research or consolidation in the background. Whether an unchosen region becomes permanently inaccessible before selection, the fate of the second offered region, and last-region offer fallback all need explicit rules. Random offers must not silently create mathematically impossible campaigns.

## 2. Regional campaign structure

- **Regional progress:** Complete a variety of tactical missions to increase liberation progress, eventually opening a decisive operation (**CONFIRMED**).
- **Mandatory boss:** Defeat the region's Soviet commander to liberate it (**CONFIRMED**). Each boss should have a recognisable identity and a small number of replayable variations in ability choices, behaviour and/or support units (**CONFIRMED direction; specifics OPEN**).
- **Regional pressure:** A visible measure of Soviet consolidation rises through failures, ignored opportunities and other regional outcomes; reaching its limit permanently locks the region (**CONFIRMED direction; rates OPEN**).
- **Global pressure:** A separate variable Soviet countdown advances through escalating stages. Mission outcomes can hasten or delay it; terminal completion is defeat (**CONFIRMED**).
- **Victory reward:** Liberated region gives access to its resistance network, **a chosen permanent regional specialisation** and a smaller immediate prize (equipment, recruit, resources etc.) (**CONFIRMED direction**).
- **Defeat consequence:** Region locks, boss remains unbeaten, Soviet progress continues. All **successfully secured rewards** remain; player gets a **limited post-defeat recovery opportunity** (**CONFIRMED**). Form, restrictions, and potential partial network access **OPEN**.

**Design requirement — dual anti-snowball / anti-death-spiral:** Success should expand *choices* and capabilities rather than unlimited passive statistics. Defeat must take meaningful territory, time, people and opportunity without eliminating a plausible recovery route. Never give more total value for deliberately losing than for winning the same region.

## 3. Soviet opposition

| System | Selected direction | Still open |
|---|---|---|
| Strategic research | Unselected/ignored Soviet regional programmes progress; successful programmes grant enemy tech (e.g., KGB toxic ammunition) | Completion rate, geographical/global scope, signalling |
| Tactical adaptation | Track **player combat behaviours**, not only class counts, and introduce typically **one or two soft counters** in following regions | Metric definitions, trigger thresholds, counter pools, player warning, tuning |
| Global escalation | Variable countdown with distinct escalating stages, potentially irreversible milestones | Stage effects, clock manipulation caps, terminal trigger |
| Regional boss activity | One boss threatens each region; detailed strategic agenda undecided | Stage 5 decision 24 |

Research programmes change **what the enemy can field**. Adaptation changes **which available responses become more common** in reaction to player tactics. Both should be readable, avoid hard class invalidation, and never be hidden arbitrary punishment for success.

## 4. Headquarters and roster

| Topic | Decision | Status |
|---|---|---|
| Headquarters form | Attractive **hybrid visual headquarters**, currently envisioned as an **underground resistance bunker** | CONFIRMED direction |
| Flexibility | Function/UI/data must be separate from bunker art so backdrop/theme can be changed later | CONFIRMED |
| Base upgrades | A relatively **constrained** set of meaningful improvements | CONFIRMED direction; facilities and costs OPEN |
| Personnel | **One shared roster**; select **five operatives** afresh before each mission | CONFIRMED |
| Squad presets | **No** fixed squads or saved squad presets | CONFIRMED |
| Attrition | Severe wounds, treatment time and permadeath make having more than one five-operative team’s worth of personnel important | CONFIRMED direction; starting roster, timers, treatment OPEN |

**Possible hub screens (TRIAL):** War Room / Operations, Barracks & Medbay, Armoury, Workshop, Research / Networks, and After-Action. Clickable screen navigation and a strong visual backdrop; **do not build a walking/explorable base** for the initial trial. UI names, room art and base layout are provisional.

## 5. Economy — two resources

**CONFIRMED resource structure:** **Supplies** and **Intelligence (Intel)** are the two main spendable currencies. Actual rates, caps and balance numbers are **OPEN**.

- **Supplies:** Provisional default funding for **consumable production**, **research projects**, **recruitment / training** and **medical recovery**. May also fund modest base upgrades. These uses are **TRIAL**, subject to balance testing.
- **Intel:** Primarily used for **pre-mission Intel Ops** and **in-mission Stratagems / support**. The player can prepare some support before deployment and spend Intel reactively during combat (**CONFIRMED**).
- Avoid a third crafting currency unless evidence justifies it. Research should not consume Intel by default, or the same pool may become too precious to use on tactical support (**TRIAL recommendation**).

## 6. Equipment acquisition and Workshop

### Confirmed principles

- **Supersuit** is the operative's single persistent equipment piece. Build 10 issues a basic suit. Suit variants, progression and acquisition are open. Missions, captured equipment, major rewards, events and contacts were the approved acquisition channels for the earlier permanent gear model.
- **Workshop manufacture is exclusively for consumables**: medical supplies, grenades, antidotes, single-use gadgets and similar mission-use items.
- The earlier shared armoury assumed interchangeable permanent gear. Confirm whether suit variants or upgrades would use a shared inventory.
- **Basic functional kit** should be available to new recruits so attrition does not strand the roster with unusable operatives (**TRIAL safety rule**; source/quality to refine).

### Earlier trial acquisition categories

These examples preserve the acquisition model used before the Supersuit decision. Future permanent player rewards need to fit the suit model.

| Channel | What it provides |
|---|---|
| Mission objective / cache | Curated gear or a choice of rewards |
| Captured/salvaged enemy equipment | Scarce recoverable gear where mission rules permit |
| Regional boss / liberation | Distinctive, often higher-impact gear |
| Resistance event / contact | Occasional specialist equipment |
| Workshop | **Consumables only**; never persistent weapons / armour |

**TRIAL loss/recovery principle:** Gear from a downed or dead operative can be recovered if the player secures the room; failed or abandoned operations may lose unsecured gear. Exact extraction and item-loss behaviour need testing. No durability/repair economy is proposed for the first trial. Equipment should mostly create tactical tradeoffs and horizontal options rather than automatic linear stat inflation.

## 7. Research and resistance networks

### Confirmed three-branch internal tech tree

| Branch | What research unlocks | How the benefit is used |
|---|---|---|
| **Workshop** | New **consumable recipes** and perhaps improvements to consumable capabilities | Player spends **Supplies** to produce limited-use items |
| **Stratagems** | **In-mission** support abilities (e.g., communications jamming, partisan assistance, high-tier orbital strike) | Player selects/prepares eligible support, spends **Intel** on activation according to mission rules |
| **Intel Ops** | **Campaign map, mission preparation and information** abilities (e.g., reveal room intel, sabotage a tangible enemy threat, inspect Soviet programmes) | Player spends **Intel** before the mission or at a specified information decision point |

**Confirmed direction:** This is an **internal, visible research tree**. Regional resistance networks, captured intelligence or certain objectives may unlock branches or projects. Research should emphasise **new decisions and options**, not large passive bonuses. The name “Resistance Network” is provisional; function matters more than label.

### Trial rules to implement first (not production requirements)

1. A compact **shared project catalogue** with three branch filters; start with a few always-accessible basic projects.
2. Unlock advanced projects through **mission discoveries** and/or **regional network state**. Do **not** build eight independent complete trees.
3. **One active research project at a time**, consuming Supplies and campaign days (**TRIAL default**, not final).
4. On completion, the unlock is permanent for the current campaign. Unlocking a Stratagem/Intel Op does **not** make its use free; using it spends Intel. Unlocking a Workshop recipe does not grant infinite consumables.
5. **Orbital strike** is a potential later-game Stratagem; not automatically available at campaign start. Exact AP interaction, targeting, AoE and friendly fire need dedicated tactical testing.

**Key OPEN questions:** how much access a defeated region leaves behind; which network unlocks which branch; ability costs/charges, support slot count, time scaling, whether projects can be queued/cancelled, and whether facility improvements affect project speed.

## 8. Recruitment, recovery and the shared roster

### Confirmed direction

- **Mission rewards / narrative events** can grant additional recruits (potentially unusual or experienced).
- The **base slowly recruits or trains new operatives** as a reliable replenishment path.
- For **base-generated recruits**, the player **chooses their class**.
- All recruits enter the **same shared roster**; deployment is selected from that pool every mission. No squad lock-in or squad presets.
- Attrition should require squad depth and careful deployment, but losses must not create a default unwinnable spiral.

### Trial recruitment model

- One base recruitment/training job at a time, costing Supplies and calendar time (**TRIAL**, configurable).
- New base recruits enter at a dependable entry-level baseline with serviceable standard gear (**TRIAL**).
- Mission/event recruits can join immediately, be more experienced or have fixed narrative characteristics (**TRIAL**, not a fixed balance promise).
- Wounded operatives remain in the shared roster but can be unavailable until recovery. Medical treatment and recovery rate are **OPEN**.
- If available operatives drop below the minimum required deployment, the design needs an explicit **recovery/replacement safety valve**; what this entails is **OPEN**. Never silently make the campaign mathematically impossible while suggesting it can continue.

## 9. Intelligence activation and mission interface

**CONFIRMED:** A hybrid system supports committing some Intel-backed support *before deployment* and paying for other approved abilities *during tactical play*.

**TRIAL examples** (not all required in first test):

- **Intel Op: Facility Recon** — pay Intel during mission preparation to reveal next-encounter information.
- **Intel Op: Sabotage** — pay Intel to reduce a named threat (e.g., reinforcements, starting armour or a security system); avoid generic “-20% mission difficulty.”
- **Stratagem: Radio Jam** — pay Intel during combat to block a communication/reinforcement event when the tactic system supports it.
- **Stratagem: Orbital Strike** — later-game support that costs Intel and has explicit targeting constraints, telegraph and friendly-fire rules; **EXAMPLE / NOT A FIRST-TRIAL REQUIREMENT**.

**OPEN:** support slots, charge limits, action timing, when Intel is deducted/refunded, how enemy counters interact with support, and how between-room Intel Ops fit the current tactical mission interface.

## 10. Cross-system progression example (ILLUSTRATIVE)

**Mission: Raid a Soviet chemical laboratory**

- Primary outcome: damage/disable a Soviet programme and affect regional liberation/pressure.
- Optional secured objective A: recover a cache of finished antidote consumables for the Workshop inventory.
- Optional secured objective B: steal an antidote formula (unlock **Workshop Research → Antidote Consumable Recipe**; still requires research and later Supply production).
- Optional secured objective C: rescue a scientist (event recruit / specialist contact).
- On extraction, **only objectives explicitly secured** carry forward; if region is later lost, these earned rewards remain. The reward list is illustrative, not a promised mission design.

## 11. Balancing, UX and implementation guardrails

1. **Regional defeat is not synonymous with campaign defeat.** Preserve secured rewards and present one limited recovery opportunity; costs and exact effects are TBD.
2. **Regional victory should not explode power.** Stronger options, limited Intel, finite consumables, scarce gear and continuing Soviet escalation must coexist.
3. **Equipment and Research.** Workshop research unlocks consumable recipes. Permanent rewards need to fit the Supersuit model once its progression is defined.
4. **Display consequences.** Preview operation rewards, programme progress, research unlock prerequisites, recruit completion, Intel costs, and any regional-lock warning.
5. **Don't duplicate tactics code.** The prototype should reuse existing tactical abilities, inventory and mission-event hooks where possible. Add campaign systems incrementally and behind toggles if useful.
6. **Difficulty:** Aiming for **15–30 hours** requires restrained content scope. Longer high-difficulty runs should result from gameplay, not mandatory administrative grind.
7. **No irreversible design through testing values.** Any example costs/durations/roster sizes are placeholders until playtested.

## 12. Outstanding decisions (not silently resolved)

### Campaign and Soviet systems

- **Stage 5, Decisions 22–27** remain **OPEN**: escalation stage effects, Soviet reactive AI, boss regional operations, strategic event density, Moscow final mission structure, and how hard defeat is enforced.
- Regional offer algorithm when one eligible region remains; skip penalties / unchosen programmes; global vs regional research tech distribution.
- Regional progress and pressure thresholds; global clock progression and anti-stalling rules; boss variants and adaptation trigger metrics.
- Recovery opportunity after regional defeat: mission, choice event or other; what partial network rewards are earned or guaranteed.

### Research and HQ

- Base upgrade list, prerequisites, costs and time; whether facilities change project speed/capacity.
- Research tree size, per-region unlock mapping, project time/cost, parallelism and prerequisite design.
- Stratagem slot/activation rules; precise Intel Ops timing, UI and combat hooks.
- Final visual/art direction of bunker and extensibility of base hub.

### Equipment, personnel and recovery

- Persistent gear mission drop rules, item scarcity, extraction loss, starting-kit policy and inventory limits.
- Consumable production batch sizes, stack sizes, carry limits, workshop queue and refund policy.
- Recruitment pipeline, initial and target roster, train/recover durations, injury treatment costs, training capacity and recruit class restrictions.
- An explicit anti-death-spiral policy that does not grant free rewards for poor decisions.

## 13. Original headquarters trial milestone

The original milestone called for a **headquarters progression sandbox** before the first full regional campaign. Build 10 now provides a playable version. The permanent gear inventory and three-branch screen described below were assumptions at the time. See the [current playtest](../IMPLEMENTATION_NOTES.md) for what's implemented.

- Shared roster → choose five every deployment; recruits from a class-selectable timed base job or a simulated mission reward.
- Shared persistent equipment inventory → gear comes only from rewards/salvage; no crafting of weapons or armour.
- Workshop → manufacture finite consumables using Supplies.
- Research → three branches, minimal data-driven projects, Supplies + calendar time, persistent unlocks.
- Intel → one pre-deployment Intel Op plus one in-mission Stratagem interface/hook (simple test effects acceptable).
- After-action → secured rewards credited once and reflected at HQ, with enough logging/debug affordances to test attrition and both resources.

**Companion document:** [HQ Trial Implementation Brief](H_A_Codex_Trial_Implementation_Brief_v05.md) contains scope, suggested architecture, acceptance criteria and trial test scenarios. Do not treat that companion brief's proposed numbers or placeholder effects as approved design decisions.

---

**Review checklist:** Confirm strategic direction, distinguish actual player-selected commitments from trial defaults, and revise any system before scaling content. **Do not begin the first full regional campaign design yet.**


## 14. Transfer audit and authority order (v0.5)

All campaign-workshop Decisions **1–21 and 28–34** have been reviewed and entered in the companion numbered register. **Decisions 22–27 were presented but the player has not selected them; all remain OPEN.** The updated HQ / roster / presentation decisions are captured separately as unnumbered decisions. See `H_A_Campaign_Decision_Register_v05.md` for the full coverage matrix and status, not just summarized prose.

The transfer distinguished creator decisions from prototype assumptions in the HQ trial brief. The current [design index](../design/README.md) provides the governing rules and review process.

**Old artwork warning:** An older base wireframe displayed "armour plating — CRAFTABLE" before equipment rules were settled. It is **obsolete** and excluded from the transfer package. Only consumables may be manufactured in the Workshop.

**Current milestone:** Build 10 has a playable headquarters trial. Its balance, Workshop research placement, Supersuit progression and regional eligibility remain open. The full regional campaigns, Soviet escalation behaviours and Moscow finale await design decisions.
