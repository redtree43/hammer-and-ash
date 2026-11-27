HAMMER & ASH: UPRISING — BUILD 10 REGIONAL CAMPAIGN PLAYTEST
Godot 4.7 / GL Compatibility / no external art assets required.

START A CAMPAIGN OPERATION
1. Import this folder's project.godot in Godot Project Manager and press F5.
2. In the Resistance Bunker, use USSR to choose one of seven open districts.
   Moscow is locked. Each open district has four missions.
3. Select a mission from its map pin or district list. Open Deploy, select
   five ready operatives, then use Gear & build to edit each loadout.
   For testing, choose Earned or a Dev level from 1–9, choose an origin,
   and click the unlocked ability choices. Reset to Personnel restores
   that operative's usual build. Deploy again to lock in the squad.
   Build edits apply to this operation. Manual levels pause campaign XP.

REGIONAL OPERATIONS
- Patrol: clear the hostile patrol.
- Relay: destroy the generator with basic attacks and clear its defenders.
- Rescue: free both prisoners by interacting from an adjacent tile (1 AP)
  and clear the guards.
- Sweep: clear three linked rooms. Press Enter after clearing an
  intermediate room to advance or E to extract. HP, spent consumables and
  down counts carry forward. AP, current armour, charges and cooldowns reset.
- Relay stations and final sweep yards mark high ground with gold chevrons.
  Needle's High Perch activates when her turn begins on one of those tiles.
  Elevation-based range, line of sight and movement rules are still in review.
- F9 returns to HQ from the mission report. Campaign state is kept for
  the running session.

COMBAT CONTROLS
- Click a squad selector on the left or an operative on the battlefield.
  The 1–5 keys select directly, and Tab selects the next ready operative.
- Use the yellow icons at the lower left or click tiles to move, attack or
  interact. Hover an icon or arm an ability to see its cost and details below.
  Click a reachable enemy with a melee operative to approach and strike
  for 1 AP total. Hover a target for its stats and the action preview.
- X reloads or recharges. J selects melee. K selects the Medkit.
  G uses Emergency Reload if prepared. O aims Overwatch, then click to set
  the cone. Space ends the turn. Esc cancels armed targeting, dismisses
  overlays, or goes back through the HQ briefing and loadout screens.
- F toggles base attack lines. H toggles enemy threat. L opens the damage
  ledger. P opens room activity after a mission, and V opens the final report.
  Development also includes the combat log, enemy tier mix and facing arrows.
- Mouse wheel zooms. WASD or middle drag pans. Q and E rotate the board
  90 degrees during combat. Home fits the room at its current orientation.
- Each operative wears a Supersuit and can pack one consumable. The loadout
  is locked on deployment. Enemy firearms and eligible player ranged
  weapons use three rounds or charges and refill at room entry.
- Light and high cover have 2 and 5 structural HP. Ordinary gunfire does
  not damage cover. Explosions and eligible special attacks can break it.
  Full cover blocks direct ranged hits from its protected side. A committed
  shot still spends AP and ammo or charge. Impervious cover is indestructible.
  Walls block line of sight and prevent firing.

ORIGINAL CHAIN REGRESSION
- From HQ use M, 1, then Enter to open the original three-room fixture.
  R restarts the fixture. F6–F8 jump to a room with a fresh squad.
  B aims Anvil Breach. F9 returns to HQ from the regression selector.
- Use Enter between cleared rooms to exercise squad carry-over.
  The Room 2 radio adds three hounds to Room 3 if it sends its alert.

VERIFICATION
See ../../docs/IMPLEMENTATION_NOTES.md for current checks and playtest gaps.
VALIDATION_10.txt records the original packaging pass.
