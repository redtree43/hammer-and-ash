HAMMER & ASH: UPRISING — BUILD 09 / ENVIRONMENT COMBAT TEST
Godot 4.x / 2D / self-contained project; no art assets required.

HOW TO RUN
1. Extract this ZIP to its own folder, separate from Build 08.2.
2. Godot Project Manager > Import > select project.godot.
3. Open the project and press F5.

NEW: DEVELOPER-ONLY ROOM JUMP (TESTING SHORTCUT)
- Click ROOM 1 / ROOM 2 / ROOM 3 at the top right, or press F6 / F7 / F8.
- Jumping RESETS the chosen encounter with a FRESH FIVE-OPERATIVE SQUAD.
- It clears prior room history and starts without the Room 2 radio-alert penalty.
- The real game will NOT allow this shortcut. Regular mission progression
  still requires clearing each room, and HP/down history normally persists.
- [R] still restarts the entire three-room chain from Room 1.

NEW: DESTRUCTIBLE COVER
- Cover remains a physical shared edge, defending either adjacent tile.
- SELECT cover edges in ALL THREE rooms have tiny WHITE HP markers:
  light sections = 2 structural HP; reinforced = 5 structural HP.
- Ordinary rifle and pistol attacks CANNOT damage or directly target cover.
- Razor AREA SHRED (Q, 2 AP) damages affected cover edges for 2 structural
  damage, even if no enemy stands inside its three-tile arc.
- Fuel explosions damage nearby cover for 3 structural damage;
  radioactive-waste barrel blasts deal 2 structural damage.
- Sentinel's *temporary test action* BREACH (B, 2 AP, once per turn):
  select Sentinel, press B, click the neighbouring tile BEYOND a destructible
  cover edge. The barrier is destroyed (5 structural damage).
  If that tile is empty Sentinel steps into it; if an enemy occupies it,
  Sentinel stays put and deals 3 damage to that unit (armour still absorbs it).
  Fortify (Q) is UNCHANGED. B is a provisional mechanics test, not a locked
  second signature ability or a final class-tree decision.

NEW: TARGETABLE EXPLOSIVE BARRELS
- Fuel barrel: orange 'F', 1 HP, can be shot normally for 1 AP.
  Explosion radius: 2 Manhattan tiles; 2 direct impact damage; push strength 3.
  Produces FIRE hazards on its tile and the four adjacent tiles.
- Nuclear-waste barrel: lime-green 'R', 1 HP, targetable normally.
  Explosion radius: 1 tile; 1 direct impact damage; push strength 2.
  Produces RADIATION hazards on its tile and adjacent tiles.
  This is a waste-container rupture, NOT a nuclear detonation.
- Explosions hit FRIENDLY and ENEMY units equally (HP/armour), can destroy
  nearby breakable cover, and may trigger an adjacent barrel in a CHAIN.
- Some barrels are deliberately grouped for easy chain-reaction testing.
- Intact barrels block movement but do not block line of sight.
- Normal shots still do not damage cover. Click a BARREL, not its adjacent
  cover edge, to shoot the explosive object.

NEW: WEIGHT, KNOCKBACK, HAZARDS AND STATUS EFFECTS
- Weights: hounds = 1 (light), standard humans = 2, Sentinel and elite = 3.
- Push distance = min(2, max(0, explosion strength - weight)); never more
  than TWO TILES. The push goes away from the explosion. Obstacles stop it.
  Contact with a solid blockage causes 1 additional damage.
- Pushed units may land in environmental hazards; effects are not faction-safe.
- FIRE, RADIATION and ELECTRICAL/SHOCK hazards can be placed in rooms from
  the outset or created by combat. Every hazard lasts THREE FULL ROUNDS,
  counting the round in which it appears (expires at start of round 4).
  All hazards deal 1 damage on entry and when a unit starts its phase in one.
- Entering FIRE applies BURNING (2 affected own turns; 1 HP/armour damage
  each start of that unit's faction turn).
- Entering RADIATION applies IRRADIATED (2 affected own turns;
  -1 armour at the start of the unit's faction turn).
- Entering ELECTRICAL hazard applies SHOCKED (1 affected own turn;
  -1 AP at the next AP refresh).
- Standing in an active hazard can refresh its status. Statuses are cleared
  between rooms; HP damage is NOT healed for free.
- Icons: orange F = fire ground; green R = radiation; blue S = shock.
  Selected unit card lists statuses and durations. Weight shown as WT.
- AI combatants consider hazards in movement scoring; hounds are reckless.

EXISTING MISSION STRUCTURE PRESERVED
Room 1: Kennel Breach — seven hounds and a support technician.
Room 2: KGB Cordon — six defenders plus optional 2-HP radio transmitter.
        Destroy by END of third player turn, or Room 3 gets +3 hounds.
Room 3: Elite Response — hounds, KGB rifles, and an elite enforcer.
Clear every enemy in sequence to win. Previous HP/downs persist between
rooms; armour, AP, cooldowns, and temporary effects reset between rooms.
First down: incapacitated for remainder of room; recovers next room at
half maximum HP. Second down: permanent loss for this mission.

OTHER CONTROLS
Left-click: select/move/attack, radio, or explosive object
Q: class ability     B: Sentinel Breach test       O: Overwatch (1 AP)
1-5 / TAB: select operative   SPACE: end player turn
F: range overlay     H: enemy threat     L: damage ledger
P: per-room squad activity on end screen   LEFT/RIGHT: review rooms
V: battle/report after victory/failure  R: restart chain
F6/F7/F8 or top-right buttons: developer-only room jump

SUGGESTED PLAYTESTS
1. F6: Verify both normal shooting and Sentinel's Breach/Area Shred
   affect cover exactly as specified. Test lightweight and reinforced.
2. F6: Shoot orange F barrel near lime-green R barrel and inspect chain;
   ensure friendly fire, knockback and 3-turn hazards are visible.
3. F7: Verify radio consequence still works while testing KGB defensive
   cover and the room's pre-existing electrical hazard.
4. F8: Test the mixed elite battle plus breakable barriers/hazards.
5. Compare health, damage log [L], and per-room activity screens.
6. If any error appears, send the FIRST red error from the Godot Debugger.

VALIDATION
Project and map setup have been statically checked, but Godot itself could
not be launched in this environment. Your F5 test establishes runtime behavior.
