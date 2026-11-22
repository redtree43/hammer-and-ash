HAMMER & ASH: UPRISING — BUILD 10 / MODULAR MISSION OBJECTIVES
Godot 4.7-compatible project / no external art assets required.

INSTALL
1. Extract the ZIP in its own new folder.
2. In Godot Project Manager, Import project.godot from that folder.
3. Open the project and press F5.
4. The TEST MISSION SELECTOR appears on launch. Click a card or press 1–5.

BUILD 10 MISSION SELECTOR (M to reopen anytime)
1 ORIGINAL CHAIN: three rooms, persistent injuries, timed radio TX secondary
   and conditional hounds in Room 3. Regression test of Build 09.3.
2 ASSASSINATION: three linked rooms. Final room has Officer Orlov (9 HP,
   1 armour) and four escorts. From the enemy phase after player turn 3,
   Orlov tries to reach the marked east EXIT. Kill him before he escapes;
   if he escapes, you can still clear guards but the mission FAILS.
3 SABOTAGE: one KGB facility. Destroy 6-HP power generator [G] AND
   disable/destroy 6-HP prototype pod [P]. The adjacent terminal [T]
   disables the prototype for 1 AP. Attack machines with basic guns or
   adjacent melee. If unfinished at end of player round 3, the prototype
   activates into a 13-HP, 3-armour, 3-AP robot [G]. Kill it and destroy
   the generator to finish the mission, but quick-sabotage bonus is lost.
4 RESCUE: one KGB detention facility. Free both prisoners marked [1] and
   [2] with a 1-AP adjacent interaction and eliminate guards. Freed
   prisoners are secured automatically after the room; no escort action.
5 DEFENCE: one map, 20-HP safehouse [HQ], hold for 8 FULL enemy rounds.
   Waves spawn on the START of player rounds 1, 3, 5, and 7. The next
   wave's east entry lane is highlighted one round early. Enemy AI can
   damage the safehouse directly. Remaining enemies do NOT prevent success
   if the safehouse and some player operatives survive through round 8.

TEST CONTROLS
[M] Mission selector; select 1–5 in selector.
[R] Restart selected mission from its beginning.
[F6]/[F7]/[F8] Developer jump to room 1/2/3 of the active THREE-ROOM
  mission. When playing a single-room test these shortcuts load rooms of
  the original chain for regression. Jumps give a fresh squad.
[1]–[5] Select units while fighting; [Tab] next operative.
[Space] End turn; [Q] class ability; [B] Sentinel Breach;
[O] Overwatch; [F] green base-attack lines; [H] threat;
[L] damage ledger; [P] squad activity after mission; [V] final report.
[Enter] Continue to next room after clearing a linked room.

COMMON RULES RETAINED FROM BUILD 09.3
- All five player operatives; all special abilities still cost 1 AP.
- Shared-edge cover: light 2 structure HP, reinforced 5, impervious
  indestructible, walls obstruct line of sight.
- Regular gunfire does not destroy cover; explosives and permitted class
  attacks do. Fuel and waste barrels are directly targetable.
- Environmental hazards, knockback, 3-round hazard durations, persistent
  status effects, health carry-over, armour/AP/cooldown reset between rooms.
- Damage ledger and individual room activity reports.

MODULAR ARCHITECTURE
Mission selection is separate from reusable objective configurations:
  mission_objectives: target conditions (kill/destroy/free/protect)
  mission_objects: interactive or destructible objects and their health
  mission_events: phase + round triggers mapped to reusable actions
  mission_flags: persistent consequences and objective state
The scenarios are intentionally small test configurations, not final
campaign levels or final enemy/ability balance. Recruitable allies,
nonlethal capture, campaign consequences, advanced escorting and alternate
extract timing are later objective variations.

VALIDATION
The GDScript source, map placements and archive underwent static checks.
Godot runtime was not available in this environment. F5 playtesting in
Godot is still necessary to confirm runtime behaviour.
