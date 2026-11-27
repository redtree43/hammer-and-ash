# Vision and presentation

## Confirmed direction

Hammer & Ash: Uprising is a single-player, squad-based turn-based tactics game with a compact strategic campaign. It takes place in an alternate Soviet Union around 1980. Extraordinary abilities and equipment come from genetic engineering, cybernetics and miniaturised nuclear technology. The setting excludes magic and supernatural causes.

The player commands an outlaw revolutionary agency from a resistance headquarters envisioned as an underground bunker. Operatives raid facilities, recruit allies, recover research and support resistance movements while the Soviet state advances its programmes. State security, criminal networks, rogue enhanced individuals, foreign actors and competing resistance factions can shape the conflict. Soviet bureaucracy, propaganda, architecture, shortages and black markets establish the setting. The tone combines serious insurgency with occasional pulp spectacle, dry humour and situational satire.

The player prepares a complementary squad, makes readable tactical choices under uncertain intelligence, pursues objectives, weighs forward progress against extraction and brings the consequences back to HQ. The campaign arc moves from survival through insurgency and coalition-building to uprising. [Combat](COMBAT.md) · [Missions](MISSIONS.md) · [Campaign](CAMPAIGN.md)

## Confirmed presentation baseline

Use Godot and GDScript, a fixed-view 2D battlefield on a logical square grid, and pixel art. Represent elevation logically with readable 2D cues. The angled view and quarter-turn pivots are playable presentation experiments within that baseline. Final projection, readability, asset scope and platform decisions are tracked for review. [Open decisions](OPEN_DECISIONS.md#presentation-production-and-evidence)

On 25 November 2026, the creator asked in the combat prototype UI discussion for a cleaner, battlefield-first presentation closer to the intended game. Give the map more room, show selected-operative details in one place, and keep developer options in a collapsed menu during play. The tactical rules remain governed by the [combat specification](COMBAT.md).

On 27 November 2026, the creator asked in the Build 10 playtest discussion for a substantial upgrade to combat graphics and to attack and ability animation. Use stronger battlefield materials and visible action playback that distinguishes movement, weapon fire, close attacks, and support abilities. Keep the grid, cover and unit feedback readable during play. [Build 10 visual pass](../IMPLEMENTATION_NOTES.md#27-november-combat-presentation-pass)

On 27 November 2026, the creator marked up the Smelter Relay screenshot in the combat HUD request. Stack the squad selectors along the battlefield's left edge and place yellow action icons along its lower-left edge. Hover an icon or select an ability to show its AP cost and details. Escape cancels an armed ability or goes back from the current screen or overlay. [HUD controls and verification](../IMPLEMENTATION_NOTES.md#27-november-combat-hud-and-escape-verification)

Sources include the 20 November visual amendment, the 21 November master design and the earlier Game Vision. [Vision handoff](../PROJECT_OVERVIEW.md) · [Original design references](../../references/design/)
