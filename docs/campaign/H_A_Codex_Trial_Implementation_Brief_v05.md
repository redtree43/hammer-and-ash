# HAMMER & ASH: UPRISING
# Codex Implementation Brief — Headquarters Progression Sandbox (TRIAL v0.2)

> Historical trial work order. See the [current design specification](../design/README.md) for intended behavior and the [bunker playtest](../IMPLEMENTATION_NOTES.md) for the active prototype.

**Brief version:** 0.2 · **Date:** 23 November 2026\
**Companion master design:** `H_A_Campaign_Design_Master_v05.md`; audit: `H_A_Campaign_Decision_Register_v05.md`\
**Scope:** First test of equipment acquisition, Workshop consumables, three-branch research, Intel support, and slow, class-selectable recruitment. **Do not build a complete regional campaign yet.**

**24 November status.** This brief records the original trial work order. Build 10 now uses an issued Supersuit and one consumable slot, so the permanent gear fixtures and equipment tests below are historical. The live bunker exposes Stratagems and Intelligence Operations with one shared research slot. Workshop recipe research remains a campaign branch awaiting placement in the interface. Use the current [bunker instructions and verification](../IMPLEMENTATION_NOTES.md) for active playtests.

## 0. Important handoff rules

- The original trial used the campaign master and register as its design inputs. The current [campaign specification](../design/CAMPAIGN.md) governs subsequent design work.
- Stage 5 Decisions **22–27** are **OPEN** and must not be implemented from recommendations or earlier prompts.
- Preserve any existing repo documentation for tactical combat, class abilities and mission objectives. If this brief conflicts with the repo, **report the conflict and propose a smallest change** rather than overwriting other design documents.
- The following legacy visual is **not authoritative and intentionally excluded**: `H_A_Base_Operations_Wireframe.png`, which incorrectly depicted craftable armour.
- Test fixtures and candidate architecture are not final balance decisions.

## 1. Copy/paste instruction for Codex

> Inspect the existing Hammer & Ash: Uprising Godot project, its current tactical prototype, scene/state structure, class registry, inventory/loadout model, and any existing campaign code **before editing**. Implement the **smallest playable headquarters-progression vertical slice** specified in this brief, using project-native architecture and coding conventions. Preserve the existing tactical combat rules, mission transitions and class abilities; do not rebuild or rewrite them. Where a relevant system already exists, extend it rather than duplicating it. Use data-driven definitions and configurable trial values. If the tactical API needed for one support effect does not exist, implement the state/UI path and a clearly labelled disabled or debug-only stub rather than pretend an effect works. Run the existing tests and report files changed, how to test each flow, screenshots if readily available, known gaps and tunable values. Do **not** add a full 8-region strategic campaign, Stage 5 systems, an explorable HQ, production of permanent weapons/armour, squad presets or a large research tree.

## 2. Read this first: rules vs temporary assumptions

### Player-approved direction — treat as requirements

- Campaign target **15–30 hours** (higher difficulties may run longer).
- Headquarters: immersive **hybrid visual HQ**, currently an **underground bunker**, but theme/art must be replaceable without altering mechanics. First trial may use a functional mock-up UI.
- One **shared operative roster**; choose **five individuals per mission**. **No fixed squads and no squad presets.**
- Severe attrition; eventual need for more than five combat-ready operatives. Keep recruitment and recovery possible after losses.
- Two spendable resources: **Supplies** and **Intel**.
- **All permanent equipment** (weapons/armour/reusable specialist gear) comes from mission rewards, salvage, events or contacts. **Workshop never crafts permanent equipment.**
- **Workshop only manufactures consumables.**
- Research is an **internal tech tree** with three branches: **Workshop** (consumable recipes), **Stratagems** (in-mission abilities) and **Intel Ops** (map / preparation / mission information effects).
- Research/new capabilities can connect to discoveries and regional **resistance networks**. Network unlock detail is not final.
- Base recruitment/training **takes campaign time** and the **player chooses the operative's class**. Missions/events can grant other operatives.
- Spend Intel in a **hybrid** way: on some support before deployment, on other actions during combat.
- Gear, supplies, personnel and unlocks persist across mission results; only **secured rewards** carry forward when applicable.

### Trial defaults only — make configurable; do not treat as design lock-in

- One active research project; one active recruitment job; a simple recipe-to-consumable production action.
- Projects cost **Supplies and days**; activating Intel Ops / Stratagems costs **Intel**.
- Start with a sample roster large enough to field five, plus a handful of test gear and starting resources.
- One Intel Op and one Stratagem sufficient for a working vertical slice. More branches/items can be demonstrated via data definitions without implementing a broad content catalogue.
- No equipment durability, equipment production, extra crafting materials, base room construction or automated strategic clock beyond explicit `advance_time` events.

## 3. Explicitly out of scope

- Full eight-region map, mission generator, regional progress/lockouts, major boss variations, Moscow finale and campaign victory/defeat UI.
- Complete Soviet research/adaptation AI; only expose safe future integration points if easy.
- Fully illustrated bunker or player walking around the base.
- A deep skill tree, shop, item quality system, weapon crafting, manufacturing queue, repair/durability economy or roster-wide automatic stat buffs.
- Designing all 6 class skill trees or changing the current ability balance.
- Final production values for mission rewards, drop rates, project/recruitment times, Intel costs, medical injuries or roster size.

## 4. User-facing trial loop

```text
HQ (resource summary, shared roster, armoury, research, workshop)
  → choose research project / train class-selectable recruit / produce consumables
  → pick any five available operatives + equip items
  → optionally pay Intel for a pre-mission Intel Op
  → existing tactical encounter (test a real Stratagem if practical)
  → after-action: credit explicitly secured rewards; apply casualties / time
  → HQ shows persistent loot, recruit progress, research progress and unlocked actions
```

No complete regional campaign is necessary to validate this loop. Use an existing tactical mission, a test mission or a **debug scenario selector** that explicitly identifies simulated rewards.

## 5. Implementation stages — priority order

### Stage A — Inspect and hook the existing project

1. Identify the Godot version, project entry scene, tactical mission controller, operative/class definitions, inventory model, existing save/persistence pattern, calendar or mission-time model, reward pipeline and tests.
2. Identify safe extension points. If a current system already handles items, consumables, recruitment or tech unlocks, extend it.
3. Record a short `IMPLEMENTATION_NOTES.md` listing relevant existing files and intended integration. Keep code churn narrow.
4. Build only the smallest viable HQ UI layer, using the current scene/theme system. Art is a swappable skin, not part of the progression rules.

**Acceptance:** Existing combat boots and runs unchanged. An HQ/test panel opens without destroying the existing menu/navigation flow.

### Stage B — Central state + data-driven definitions

Create or extend campaign progression state with **at least** these concepts (actual names/types should match project conventions):

| Concept | Required fields / behaviour |
|---|---|
| Economy | `supplies`, `intel`, `campaign_day` (all with safe nonnegative validation) |
| Roster | All operatives in one pool; individual identity, class, availability/injury, inventory/loadout reference |
| Inventory | Shared stacks of consumables; individually tracked permanent equipment instances/IDs; explicit equip/unequip |
| Research | Definitions with stable ID, `branch` (`workshop`, `stratagem`, `intel_op`), prerequisites, Supplies cost, duration, unlock result; researched IDs; one trial active job |
| Workshop | Consumable recipe definition, input Supplies, output consumable ID + quantity; availability requires researched/unlocked recipe |
| Recruiting | One trial recruitment job: class ID chosen from existing available classes, Supplies cost, days remaining/completed; creates operative on finish |
| Support | Unlock state, Intel cost, availability / timing (`pre_mission`, `in_mission`), optional targeting/effect hook |
| Reward transaction | Stable mission/reward transaction ID, secured flag, item/operative/resource/unlock payload, processed-IDs set |

Use existing **Godot Resources**, JSON/data assets or script constants according to project style. Avoid a giant hardcoded UI script containing game logic.

**Acceptance:** State operations are testable independently of UI and do not create negative resources, duplicate reward claims or impossible roster references.

### Stage C — Shared roster and recruitment

1. HQ Personnel screen lists available, injured/recovering, and candidate/new recruits.
2. Start base recruitment/training by choosing **one of the existing operative classes** (currently Scythe, Anvil, Glaz, Needle, Iskra and Alkhimik if that registry is up to date; **read actual project registry** instead of hardcoding these names).
3. Charge Supplies once; advance job only through campaign time changes; on completion add exactly one operative to the shared roster, ready under project-native starting equipment rules.
4. Mission rewards can add an operative without starting a base recruitment job.
5. Operations screen selects **any five eligible operatives**, no saved squad configurations.

**Acceptance:** Completing a job produces one correct-class operative; pausing/reloading does not duplicate them; repeated clicking does not charge twice or create extra operatives; cannot deploy unavailable operatives; five-person deployment check is enforced if consistent with existing prototype.

### Stage D — Equipment / Armoury / Workshop

1. Add or expose shared persistent inventory; mission reward can add a permanent item to inventory.
2. Equip/unequip persistent items for specific operatives through existing loadout rules, with **no duplication**.
3. Workshop interface lists **only consumable recipes**. Research unlock gates recipes. Producing a consumable spends Supplies and adds a finite item quantity.
4. During tactical missions, using a consumable deducts one from the correct inventory/mission loadout; unused consumables persist through the current inventory rules.
5. Do **not** create a way to craft weapons, armour or reusable gear.

**Acceptance:** One gear reward is visible in Armoury and can be equipped by one valid operative; one consumable can be manufactured with enough Supplies, used once, and not used again without inventory. Every workshop product must be tagged consumable.

### Stage E — Three-branch research

1. Research screen shows **Workshop**, **Stratagem**, **Intel Ops** tabs/filters and locked/unlocked/active/completed state.
2. Provide a small project catalogue with stable IDs and dependencies. Some entry-level projects are available immediately; one advanced example requires a **mocked mission discovery or network flag**.
3. Start an eligible project: charge Supplies once, schedule a completion day; time advances via existing campaign action or a clear **DEBUG: Advance Day** control.
4. Complete project exactly once; mark unlocked capabilities/recipes; maintain state on save/reload if project already has persistence infrastructure.
5. Do not automatically create permanent equipment on completion; Workshop research creates **consumable recipes** only.

**Acceptance:** Cannot launch an unavailable or completed project; completing one branch has a visible effect in its relevant screen; no free Intel actions or infinite consumables.

### Stage F — Intel Ops and Stratagem test hook

1. Add an Intel Ops selection/payment step at mission preparation (e.g., `Reconnaissance`: reveal an existing enemy/next-room information field where supported, otherwise display an explicitly marked debug report).
2. Add a tactical Stratagem entry point if an existing UI/ability hook allows it (e.g., `Radio Jam` applied to an existing reinforcement/radio event, or a clearly labelled simple one-use tactical prototype effect).
3. Both require unlocked research and sufficient Intel; deduct Intel **exactly once** at their specified decision moment; provide disabled state/reason if missing prerequisites.
4. If the existing tactical engine lacks safe Stratagem effect hooks, ship the UI/state contract with visible **not yet implemented** status and an integration TODO. Do **not** claim combat changes that don't occur.

**Acceptance:** Intel cannot go below zero, the same support action cannot be repeatedly charged or triggered by duplicate input, and tactical play remains deterministic apart from existing game rules.

### Stage G — After-action and integration test

1. Introduce a minimal reward adapter from the existing mission-end report, or a test-only reward fixture.
2. Only credit items/resources/operatives/discoveries marked **secured**. Record processed transaction IDs to avoid double granting on reopening an after-action screen.
3. Reflect inventory, research discoveries, resources, roster and progression changes at the HQ.
4. Include test scenarios for a success, failure/early extraction, injury/death and base-recruitment progress. **Do not invent or override existing downed/permadeath rules.**

**Acceptance:** Successful mission gives the selected secured items only once; unearned rewards are not granted on failure; no loss of other state; user can return to HQ, change roster and deploy again.

## 6. Seed content (TEST FIXTURES ONLY)

These are examples to prove the pipeline; avoid permanently encoding exact values.

| ID (suggested) | Category | Initial gate | Example test result |
|---|---|---|---|
| `medkit_basic` | Consumable / Workshop | Available basic recipe | Spend Supplies to add 1 medkit |
| `medkit_advanced_recipe` | Research / Workshop | Basic project | Project completion permits advanced medkit production |
| `comms_intercept` | Research / Intel Ops | Mocked network contact flag | Unlock reconnaissance purchase |
| `radio_jam` | Research / Stratagem | Mocked captured plans | Unlock in-mission jamming support where engine hooks exist |
| `prototype_rifle_01` | Persistent equipment reward | Secured mission/cache reward | One item added to Armoury; **not** produced in Workshop |
| `rescued_operative_01` | Personnel reward | Secured rescue objective | One operative added to roster |
| `trainee_01` | Base recruitment | Choose an actual class in Personnel | Operative created after Supplies + days |

**Tunable sample starting state** (purely for QA, not design balance): 10–12 roster entries with a mix of classes/availability, 1–2 consumable recipes, 2–4 visible research entries, one captured gear reward fixture, and enough Supplies/Intel for one test action in each subsystem. Project implementation should expose all these values in data, not bury them in UI logic.

## 7. Minimum UI (art-agnostic)

A simple operations hub can use compact tabs or panels:

- **HQ dashboard:** Supplies, Intel, campaign day, operatives available / injured, active research, active recruitment, shortcut to test mission.
- **Personnel:** shared roster, recruit class picker, progress until new operative arrives, individual availability.
- **Armoury:** persistent items, equipped owner, equip/unequip, consumable stacks.
- **Workshop:** unlocked consumable recipes, resource cost, craft/produce button, inventory count.
- **Research / Networks:** three branch filters, unlock reasons, Supplies cost, time, active project.
- **Operations:** select five operatives, optional Intel Op, prepare mission; after-action report.

**Presentation constraint:** Use a mock or existing bunker-themed background as a replaceable layer. Business logic should never depend on room artwork or physical coordinates. No unit walking around base.

## 8. Verification matrix

| Check | Expected result |
|---|---|
| Start campaign sandbox | HQ loads; valid resources and shared roster shown |
| Select five | Exactly five eligible operatives deploy; no permanent preset created |
| Base recruit | Select class → pay Supplies → advance days → one new class-correct operative |
| Mission recruit | Secured reward adds operative once; unsecured does not |
| Gear reward | One captured rifle appears in Armoury; equipping does not duplicate it |
| Workshop whitelist | Only consumables craftable; persistent gear cannot be crafted |
| Workshop cost | Not enough Supplies disables production; no negative balance |
| Research cost/time | Project charges once and completes once after elapsed days |
| Workshop research | New consumable recipe appears, no automatic free item |
| Intel Op | Requires unlock + Intel; payment occurs once; outcome shown honestly |
| Stratagem | Requires unlock + Intel; tactical effect works or UI explicitly marks unavailable |
| Mission completion | Secured rewards credited only once; re-entering after-action cannot farm rewards |
| Early extraction/loss | Unsecured rewards excluded; pre-existing persistent inventory remains intact |
| Regression | Existing tactical mission movement, AP, cover, armour, abilities and room transition still work |

If the project has no automated test harness, add minimal project-native test scripts or a repeatable manual debug checklist. Do not add heavy test dependencies for a small trial.

## 9. Explicit questions for the next design review (do not auto-decide)

- **Equipment:** loot tables versus curated rewards, gear loss when abandoned, drop rarity, basic gear policy, item slots, equipment rarity and upgrade pacing.
- **Workshop:** consumable recipe list, production timing, batch sizes, loadout/stack restrictions.
- **Research:** prerequisites, research project concurrency, network unlock map, whether projects can be cancelled and what happens to paid Supplies.
- **Intel:** support-slot rules, when Intel is charged, activation/AP rules, per-mission limits, refund policies, between-room Intel actions.
- **Recruitment:** starting roster size, recruitment/training duration, experience level, availability of classes, wounded capacity, recovery after regional loss.
- **Base:** upgrades, cost/impact, HQ visual direction, resistance network UI.
- **Balance:** guardrails against both snowballing after four victories and death spiral after multiple defeats.

## 10. Codex completion report required

When finished, provide:

1. **Implementation summary**, showing which sections are fully functional, mocked, or intentionally unimplemented.
2. **File list** and the relevant integration points to existing tactics, mission rewards and saves.
3. **How to launch and test** the HQ progression sandbox and repeat each verification scenario.
4. **Actual test results**, including tactical regression checks, with failures/gaps clearly identified.
5. **Tuneable configuration summary** and a concise list of gameplay design decisions still needed.

**Stop after this trial scope. Do not move on to designing or implementing the first complete regional campaign until the user has reviewed these mechanics.**


## 11. Integration/update protocol for existing repository

1. Inspect root docs, existing design decisions, any `AGENTS.md` instructions, Godot version, and current git status. **Do not overwrite unrelated work or assume repo is pristine.**
2. Put the transferred design documents under the project's existing design-document structure (e.g. `docs/design/campaign/` only if suitable). Keep original filenames unless the repository has naming conventions; note any mapping.
3. The trial transferred the campaign master, the decision register and this brief. The [current design index](../design/README.md) now points to the governing campaign specification.
4. Compare the repo's existing campaign design and prototype implementation with this master. Make a concise difference/impact list first: **already implemented / missing / conflicting / blocked by open design**.
5. Implement only the trial vertical slice. Use feature flags/fixtures for unapproved details; don't silently implement Stage 5.
6. Keep all copied design files readable in Markdown and commit them (plus code) in logical reviewable commits; don't force-push or delete unrelated assets. Report exact commit IDs if commits were made.
7. At completion, report which requirements passed tests and which remain mock-only. Provide next review questions, not further unrequested region-campaign code.
