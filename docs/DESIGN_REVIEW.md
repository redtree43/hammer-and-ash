# Hammer & Ash: Uprising Design Review

> This earlier review is retained as a dated snapshot. See the [current specification](design/README.md) and [open decisions](design/OPEN_DECISIONS.md).

**24 November 2026**

Hammer & Ash is a five-operative tactics game set in an alternate Soviet Union around 1980. Build 10 now links the Resistance Bunker to four playable operations. The latest equipment decision is playable. The Scorpion and Anvil revisions are the next design changes to review. The angled battlefield is playable.

## Operatives and combat

The **Supersuit** replaces separate ranged weapon, melee weapon and armour items. Build 10 issues a suit and lets each operative pack one consumable. Base attacks come from the operative's class and origin, or from Alkhimik's current Darwinian form.

| Class | Melee base attack | Ranged base attack |
| --- | --- | --- |
| Scythe | Wolverine, Scorpion | |
| Anvil | Steel Skin, Psionic Armour | |
| Needle | Hawk Wings | Eye Powers |
| Glaz | | Telepathy, Telekinesis |
| Iskra | | Drone Command, Artillery Suit |
| Alkhimik | Darwinian Frog and Jellyfish | Darwinian Skunk, Healing |

Combat uses a square grid, diagonal movement, deterministic attacks, directional cover and armour that refreshes each phase. A first down costs the next two full player turns and imposes a half-HP healing ceiling for the mission. A second down is permanent. Build 10 uses manual Level 1–9 build selection and three rechargeable charges for bunker ranged attacks as playtest rules. [Combat rules](GAME_DESIGN.md) · [Class details](CLASSES_AND_ENEMIES.md).

**Scorpion revision.** Keep Charge and Tail Sting. Add a grab that pins both units, Venom Jet that applies venom to the three tiles ahead, and choices built around armour recovery, retaliation and a burrowing strike.

**Anvil redesign.** Shared skills make Anvil an armoured frontline bruiser. Steel Skin resists permanent armour shred and protects allies by intercepting hits. Psionic Armour handles taunts and armour lending and can spend armour on ranged area attacks. Both redesigns sit ahead of the playable V3 trees. [Scorpion and Anvil revisions](CLASSES_AND_ENEMIES.md#scorpion-and-anvil-design-revisions).

## Bunker and campaign

Choose five individuals from one shared roster. Reinforce it with mission recruits and timed, class-selectable bunker recruitment. Supplies support the Workshop, which produces consumables. Intel funds preparation and combat support. Build 10 shows Stratagems and Intelligence Operations, with Emergency Reload and Facility Recon as the two playable projects. Workshop recipes remain the third research branch in the campaign design.

The USSR screen shows eight federal districts. Central has Assassination, Sabotage, Rescue and Defence. Assassination plays across three linked rooms and allows between-room extraction. The campaign adds forward branches, secured rewards and consequences that carry into later rooms. At campaign scale, the target is 15–30 hours. The current rules propose choosing one of two regional offers, committing until liberation or loss, and unlocking the Moscow finale after four liberations. [Missions](MISSIONS.md) · [Campaign design](campaign/H_A_Campaign_Design_Master_v05.md).

## Battlefield presentation

The fixed angled 2D view adds visual depth while keeping the logical square grid. Sabotage retains cover destruction, action animations and the Iron Giant emerging into a 2×2 footprint. The 28×20 annex fits on deployment and supports zoom and pan for a closer look. [Angled battlefield playtest](BUILD_10_PLAYTEST.md#angled-battlefield).

## Decisions to review

1. **Supersuit progression.** Decide whether suits have variants or upgrades and how players obtain them.
2. **Class revisions.** Settle Scorpion's grab duration and armour recovery, and Anvil's interception timing. Then tune costs, range and cooldowns in combat.
3. **Research layout.** Decide where Workshop recipe research belongs in the bunker.
4. **Campaign map.** Decide which districts can be liberated and how Moscow counts before applying the four-liberation and five-lockout thresholds. The finer rules for Soviet escalation and the finale remain open.
5. **Battlefield readability.** Evaluate the angled view on both Sabotage maps, especially tile selection, cover edges, occlusion and the large map's unit scale.

The latest Supersuit pass recorded 95 checks in both headless and rendered Godot 4.7.2 runs. The editor F5 recheck, manual playthroughs with the current loadouts and a full annex clear remain open. [Verification](IMPLEMENTATION_NOTES.md#supersuit-and-base-attack-verification) · [Open questions](OPEN_QUESTIONS.md).
