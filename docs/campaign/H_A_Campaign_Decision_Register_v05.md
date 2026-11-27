# HAMMER & ASH: UPRISING — CAMPAIGN DECISION REGISTER v0.5

> Historical audit of workshop choices. See the [current campaign specification](../design/CAMPAIGN.md) and [open decisions](../design/OPEN_DECISIONS.md#campaign-and-headquarters).

**Date:** 23 November 2026\
**Scope:** Every numbered campaign workshop decision, plus important later unnumbered commitments.\
**Companion record:** `H_A_Campaign_Design_Master_v05.md`.\

**24 November reconciliation.** The numbered audit records the campaign workshop decisions at v0.5. Decision 32 now uses the Supersuit as the single persistent player equipment piece. Workshop production stays consumables-only. Suit acquisition and upgrades remain open. Decision 3's eight-district map is playable in the trial. Confirm which districts can be liberated and how Moscow counts before implementing the four-liberation and five-lockout rules. Decision 33's three research branches remain the campaign design, with two boards visible in Build 10. [Open Questions](../OPEN_QUESTIONS.md).

## Interpretation

- **Confirmed:** Explicitly selected by the player; implementation parameters can still be OPEN.
- **Confirmed direction:** Selected concept, but details/limits still need decisions and testing.
- **Superseded:** Earlier broad choice refined by a later explicit decision; retain history, enforce the later one.
- **OPEN:** Options were presented but no choice was made. Do not assume the assistant recommendation was approved.
- **Trial:** Engineer-facing initial hypothesis, not a player-approved permanent mechanic.

## Numbered decision audit

| No. | System | Workshop decision | Status at transfer | Master section |
|---:|---|---|---|---|
| 1 | Campaign progression | Hybrid: open regional choice + authored milestones | **Confirmed** | §1 |
| 2 | Campaign length | 15–30 hours; higher difficulties may run longer (supersedes 15–25) | **Confirmed** | §1 |
| 3 | Geography | Stylised eight-region Russian map + individual tactical locations | **Confirmed** | §1 |
| 4 | Campaign variability | Partially randomised; authored story spine | **Confirmed** | §1 |
| 5 | Strategic pressure | Global Soviet victory countdown | **Confirmed** | §1–3 |
| 6 | Campaign time | Calendar-based progression | **Confirmed** | §1 |
| 7 | Mission availability | Limited choices / mutually exclusive or expiring regional opportunities | **Confirmed** | §1–2 |
| 8 | Regional control | Territorial liberation / conquest objective | **Confirmed** | §1–2 |
| 9 | Management depth | Primarily tactical preparation, not deep economic management | **Confirmed** | §0, §4 |
| 10 | Global countdown form | Escalating Soviet stages | **Confirmed** | §2–3 |
| 11 | Liberating a region | Regional progress from missions; decisive liberation mission unlocks | **Confirmed** | §2 |
| 12 | Regional boss | Mandatory boss defeat; variable builds/behaviour across runs | **Confirmed direction** | §2 |
| 13 | Regional lockout | Visible Soviet regional pressure meter; permanent lockdown at threshold | **Confirmed** | §2 |
| 14 | Countdown pacing | Variable Soviet countdown affected by outcomes | **Confirmed** | §2–3 |
| 15 | Liberated-region security | Liberated region permanently secure | **Confirmed** | §1–2 |
| 16 | Economic resources | Two currencies: Supplies and Intel | **Confirmed** | §5 |
| 17 | Research direction | Hybrid research; later refined into 3-branch internal tech tree | **Superseded by D33** | §7 |
| 18 | Recruitment direction | Mission/event recruits; later expanded with slow base recruitment | **Superseded by D34** | §8 |
| 19 | Injury / attrition | Severe attrition; roster depth exceeding one five-person squad essential | **Confirmed** | §4, §8 |
| 20 | Equipment direction | Research + equipment hybrid; later clarified as mission-obtained permanent gear, consumable workshop | **Superseded by D32** | §6–7 |
| 21 | Liberation rewards | Choose a permanent regional specialisation + smaller one-time prize | **Confirmed direction** | §2 |
| 22 | Soviet escalation effects | Stage 5 options proposed; no selection made | **OPEN** | §12 |
| 23 | Soviet response system depth | Stage 5 options proposed; no selection made | **OPEN** | §12 |
| 24 | Regional boss strategic activity | Stage 5 options proposed; no selection made | **OPEN** | §3, §12 |
| 25 | Strategic events frequency / role | Stage 5 options proposed; no selection made | **OPEN** | §12 |
| 26 | Moscow finale format | Stage 5 options proposed; no selection made | **OPEN** | §1, §12 |
| 27 | Campaign defeat handling | Stage 5 options proposed; no selection made | **OPEN** | §12 |
| 28 | Next-region selection | Choose one of two randomly offered eligible regions; exact offer rules OPEN | **Confirmed direction** | §1 |
| 29 | Reward after regional defeat | Keep secured mission rewards + one limited recovery opportunity | **Confirmed direction; mechanics OPEN** | §2 |
| 30 | Intel expenditure | Hybrid: some support prepared pre-mission; some spent during combat | **Confirmed** | §5, §9 |
| 31 | Tactical Soviet adaptation | Track combat behaviours; introduce typically 1–2 soft counters | **Confirmed direction; tuning OPEN** | §3 |
| 32 | Equipment acquisition revision | Mission/event/capture for persistent gear; Workshop creates consumables only | **Confirmed** | §6 |
| 33 | Research organisation revision | Internal tech tree: Workshop recipes, in-mission Stratagems, strategic Intel Ops; regional gates | **Confirmed direction; tree details OPEN** | §7 |
| 34 | Recruitment revision | Mission/event recruits + slow class-selectable base recruitment/training | **Confirmed direction; timing OPEN** | §8 |

## Additional explicitly agreed commitments

| System | Decision | Status | Master section |
|---|---|---|---|
| Regional counts | Eight regions; liberate any four to attack the Politburo in Moscow; five locked = no victory path | Confirmed | §1–2 |
| Other Soviet victory paths | Terminal global countdown or resistance destroyed; destruction trigger unresolved | Confirmed principle | §1 |
| Regional commitment | After choosing, stay until liberating or permanently losing that region | Confirmed | §1–2 |
| Regional bosses | Unique bosses per region; 2–3 modular variants suggested, exact system open | Confirmed direction / trial suggestion | §2 |
| Regional networks | Liberation opens resistance network; losing may retain partial earned access | Confirmed / partial benefits OPEN | §2, §7 |
| Soviet strategic programmes | Unselected regional programmes may unlock enemy tech such as toxic rounds | Confirmed direction | §3 |
| HQ look and construction | Hybrid immersive HQ, underground bunker for now; swappable skins; not a walkable level for trial | Confirmed direction | §4 |
| Base improvements | Constrained, meaningful facility upgrades; exact list OPEN | Confirmed direction | §4 |
| Shared roster and deployment | One shared operative pool; individually choose five every mission; NO squad presets | Confirmed | §4, §8 |
| Soviet programmes vs adaptation | Programmes affect enemy capabilities; behaviour-driven adaptation influences tactics/composition | Confirmed direction | §3 |
| Research naming | "Resistance network" is a working name; functional tree matters more than label | Provisional naming | §7 |
| Resource sinks and project timings | Supplies likely fund research/consumables/recruitment; Intel funds support; project durations/costs NOT final | Trial assumption | §5, §7–9 |
| Mission rewards | Only actually secured objectives/rewards persist; region defeat can retain them | Confirmed | §2, §10 |
| Tactical compatibility | Existing five-member squads, mission rooms, extraction and permadeath mechanics must not be overwritten | Existing tactical design dependency | §11, §13 |
| Anti-runaway balance | Guard against both death spiral and victory snowball; flexibility > passive stats | Design constraint | §2, §11 |

## Ambiguities Codex must not silently resolve

- Stage 5 Decisions 22–27 are all unselected. The Stage 5 proposal shown in chat was not submitted.
- Whether the unchosen region remains eligible, can lock before selection, or has a guaranteed return offer; edge cases when fewer than two choices remain.
- Liberation progress/pressure numbers, global countdown timing/stage effects, regional unlock rewards, boss variants.
- How much partial network access follows a loss; mechanics of the limited defeat-recovery opportunity.
- Research tree size/prerequisites, supplies costs, durations, simultaneous projects, facility upgrades, interface naming.
- Persistent equipment drop/recovery rules, basic recruit kit, weapon scarcity and inventory limits.
- Starting roster size, injury durations, base recruit training timing/cost, capacity and anti-death-spiral conditions.
- Exact Intel support costs, slot limits, AP/activation rules, room-preview timing and orbital-strike semantics.
- Most proposed numeric values and capability examples are test fixtures, not approved balance.

## Explicit supersessions / avoid regressions

1. Campaign length is **15–30 hours**, not 15–25.
2. The Workshop manufactures **consumables only**. Never manufacture permanent weapons/armour, even if older wireframes illustrate it.
3. Every mission picks **five operatives from one shared roster**. No fixed or saved squad presets.
4. The internal research tree has **Workshop / Stratagem / Intel Ops** branches; earlier vague "hybrid research" language is not sufficient.
5. Recruitment includes **slow base recruitment with player-selected class** and mission/event rewards; not mission-only.
6. Region selection is **two random offers** followed by **exclusive commitment** to one region until win/loss, not simultaneous regional campaigns.
7. Region victory permanently secures territory; region loss preserves earned, secured rewards and offers limited recovery.
8. Enemy adaptation must be **soft, behaviour-driven**, separate from optional/ignored-region enemy tech programmes.

## Audit conclusion

**Coverage:** 34/34 numbered entries accounted for: 28 numbered decision entries with player selections or later supersession (1–21, 28–34), plus 6 explicitly OPEN Stage 5 entries (22–27). Unnumbered follow-up commitments are listed above. This confirms *documentation coverage*, not implementation or playtest verification.
