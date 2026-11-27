# Project Overview

> Earlier vision handoff. The current specification is [Vision and presentation](design/VISION.md).

**Hammer & Ash: Uprising** · Development handoff · 24 November 2026

## Vision and setting

**Confirmed direction.** A single-player, squad-based turn-based tactics game with a compact strategic campaign. The setting is an alternate Soviet Union around 1980. Genetic engineering, cybernetics, and miniaturised nuclear technology account for extraordinary powers and equipment. The fiction excludes magic and supernatural causes.

The player commands an outlaw revolutionary agency from a resistance headquarters envisioned as an underground bunker. Its conventional fighters, engineered operatives, and advanced-tech specialists raid facilities, recruit allies, recover research, and support resistance movements as the Soviet state advances its own programmes. State security and police, criminal networks, rogue enhanced individuals, foreign actors, and competing resistance factions create different pressures. Soviet bureaucracy, propaganda, architecture, shortages, and black markets give the setting its identity. The tone combines serious insurgency with occasional pulp spectacle, dry humour, and market-oriented satire grounded in situations.

## Intended player experience

- Win through complementary operatives. An enhanced specialist can dominate a specific matchup. Conventional teammates provide distributed positioning, gunfire, objective work, protection, scouting, and first aid.
- Use deliberate positioning, aggressive breaches, focus fire, holding actions, and timely withdrawal as the situation changes. Readable previews make ordinary attacks predictable while enemy decisions, route information, and competing objectives create uncertainty.
- Make imperfect commitments. A failed objective can leave a costly later encounter, a surviving adversary, or a strategic setback. A partial success or early withdrawal with secured intelligence can justify preserving a veteran squad.
- Face a competent opponent. Local alerts and reinforcements react to mission events. Repeated assassinations or laboratory raids can change future security doctrine. Intelligence and debriefs should communicate the broad consequences.
- Progress from precarious survival through capable insurgency and coalition-building to an uprising. A compact HQ and strategic map support mission and personnel decisions.

## Core gameplay loop

1. **Assess.** Review mission opportunities, faction relationships, threats, and incomplete intelligence about Soviet development.
2. **Commit and prepare.** Choose a region when one is offered, then select an operation and equip five individuals from the shared roster. Other opportunities may evolve or expire.
3. **Fight through the operation.** Resolve grid-based encounters and pursue tactical objectives alongside campaign-significant goals.
4. **Choose between rooms.** Review squad condition and secured gains, use available healing, commit to a forward route, or extract.
5. **Resolve consequences.** Apply partial successes, losses, injuries, secured rewards, faction effects, and shifts in Soviet programmes or security.
6. **Develop and advance.** Recover and recruit personnel, research and equip the roster, strengthen allies, and advance campaign time.

## Presentation and scope

| Status | Direction |
| --- | --- |
| Confirmed | Godot 4.x and GDScript. Fixed-view, square-grid 2D combat and final pixel-art direction. Elevation is represented as a logical property with readable 2D cues. |
| Current prototype | The Resistance Bunker connects four operations to a shared roster. Combat uses a fixed angled board and pixel-art avatars. Sabotage tests animated action playback, destructible cover and the Iron Giant's pod reveal at two map sizes. See [Development Status](DEVELOPMENT_STATUS.md). |
| Latest visual direction | Combat uses an angled 2D view with quarter-turn camera pivots, projected square tiles, upright sprites, raised walls and occlusion cues. Sabotage retains its action and activation effects. Its facility and annex offer two sizes for testing board readability and bounded camera controls. |
| Provisional | Premium PC release, final asset and animation scope, interface, and content volume. |
| Superseded | Pixelated or rotatable 3D pipeline. The 20 November visual amendment takes precedence over the older vision. |

Design sources are the 21 November Master Game Design, 20 November 2D Visual Direction Amendment, and earlier Game Vision in [original design references](../references/design/). Earlier visions retain setting context where compatible with the latest design.

The [23 November campaign master](campaign/H_A_Campaign_Design_Master_v05.md) records the original campaign transfer. See the [current campaign specification](design/CAMPAIGN.md).
