HAMMER & ASH: UPRISING — BUILD 10 / MODULAR MISSION OBJECTIVES
Godot 4.7-compatible project / no external art assets required.

INSTALL
1. Import this folder's project.godot in Godot Project Manager.
2. Open the project and press F5.
3. The Resistance Bunker opens. Use USSR to deploy a bunker operation.
4. Press M for the regression and mixed-enemy fixtures. Click a card or
   press 1–9 or 0, then press Enter to deploy.

LOADOUT AND BASE ATTACKS
- Each operative receives a Supersuit and can pack one consumable.
- In bunker operations, click a target to use the selected operative's
  melee or ranged base attack. J aims melee and K aims the Medkit.
- Click an enemy with a melee attack selected to approach and strike
  for 1 AP total. Hover the enemy to see the route and damage preview.
  In regression fixtures, press J to select the operative's melee strike.
- X recharges Sightline, Arc Pistol or Suit Cannon, or reloads fixture firearms.

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
   activates into the 2x2 Iron Giant with 13 HP, 3 armour and 3 AP.
   Kill it, destroy the generator and clear the guards to finish.
4 RESCUE: one KGB detention facility. Free both prisoners marked [1] and
   [2] with a 1-AP adjacent interaction and eliminate guards. Freed
   prisoners are secured automatically after the room; no escort action.
5 DEFENCE: one map, 20-HP safehouse [HQ], hold for 8 FULL enemy rounds.
   Waves spawn on the START of player rounds 1, 3, 5, and 7. The next
   wave's east entry lane is highlighted one round early. Enemy AI can
   damage the safehouse directly. Remaining enemies do NOT prevent success
   if the safehouse and some player operatives survive through round 8.
6 SCYTHE TEST RANGE: choose Wolverine, Arachnid, Blink or Standard.
   Select the Charge, melee (Wolverine's Claws), or Short Blink action.

TEST CONTROLS
[M] Mission selector. Use 1–9 or 0, then Enter.
[R] Restart selected mission from its beginning.
[Mouse wheel] Zoom around the pointer. [WASD] or [Middle drag] pan.
[Q] Rotate left 90 degrees. [E] Rotate right 90 degrees. The camera keeps its tilt.
[Home] Fit the room at the current orientation. New rooms reset the view.
Click a unit or objective's ground tile to select or target it.
[F4] Restart fixture 3 and switch between the 22x16 facility and the
  28x20 annex. The bunker Sabotage operation uses the facility.
[F6]/[F7]/[F8] Developer jump to room 1/2/3 of the active THREE-ROOM
  mission. When playing a single-room test these shortcuts load rooms of
  the original chain for regression. Jumps give a fresh squad.
[1]–[5] Select units while fighting; [Tab] next operative.
[Space] End turn. Use the labelled action buttons beside the squad bar.
Hover a button for details. [Esc] cancels targeting.
Hover a battlefield target for its stats and your action preview.
The Development dropdown contains test missions, restart, the ledger,
combat log, overlays and AI options. Unit facing arrows are off by default.
Cutouts slide on each resolved walk step, hop on leaps and turn before an effect.
For a quick check, use M / 6 / Enter to open the Scythe Test Range. Select
Anvil and move from (1,5) to (4,6) for a bent route with a diagonal. Use
Scythe's opening Charge on the Armoured Guard to check Overwatch.
For a leap, use Needle's Hawk Wings origin and Wing Hop in a bunker operation.
[B] Anvil Breach in legacy fixtures;
[O] Overwatch; [F] green base-attack lines; [H] threat;
[L] damage ledger; [P] squad activity after mission; [V] final report.
[Enter] Continue to next room after clearing a linked room.
[E] Extract between cleared Assassination rooms in the bunker operation.
[G] Use Emergency Reload if prepared. [F9] Return to the bunker from
  the report or mission selector.

COMMON RULES RETAINED FROM BUILD 09.3
- Deploy five operatives. Legacy special-ability costs use 1 AP test
  tuning. Bunker review-tree abilities use their own playtest costs.
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
See ../../docs/BUILD_10_PLAYTEST.md for Godot 4.7.2 Windows results and
remaining checks. VALIDATION_10.txt records the original packaging pass.

Mixed enemy trials (26 November): M opens the selector. Press 7 for Cordon patrol, 8 for Foundry shift, 9 for The choir or 0 for Vanguard trials. Press Enter to deploy. Hover an enemy to inspect its weapon, family, signature and counter. Enter advances a cleared room.

Enemy tiers and earned levels (27 November): Hover an enemy for tier and kill XP. Development > Enemy tier mix shows counts for the room. Deploy from the bunker to earn XP on success or controlled extraction. Open Personnel to see earned levels and XP progress. The Dev level picker supports manual builds, and a deployment with a manual level pauses XP.
