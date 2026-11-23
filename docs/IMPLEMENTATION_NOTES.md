# Resistance Bunker playtest

Run `source/Hammer_Ash_Godot_2D_Build10/project.godot` in Godot and press **F5**. The game opens on **USSR** in the bunker. Press **M** in the bunker to open the test mission selector, then **1–6** to choose a fixture. Press **F9** from the selector to return to the bunker.

| Area | Playtest |
| --- | --- |
| USSR | Open **Region 1** and choose Assassination, Sabotage, Rescue or Defence. Regions 2–7 and Moscow are placeholders. Assassination retains its own three rooms. The previous linked trial is retired from the playable menu. |
| Squad loadout | Select five ready operatives. Use **Gear** to edit any selected operative's ranged weapon, melee weapon, armour and consumable for that deployment. Two-handed weapons clear the melee slot. Shared rifle and medkit stock limits deployment. |
| Personnel | Use the roster picker and sort by Type or Name. The dossier shows the operative's portrait, availability and combat stats on the left, class path in the centre, and four editable equipment cards on the right. Loadout changes update the displayed stats and become defaults for later deployments. |
| Workshop | Check consumable stock, purchase medkits with Supplies, and review ranged, melee and armour inventories. Issued alternatives use the existing item profiles. Sabotage success now grants the captured Service Rifle reward previously tied to the linked trial. |
| Research | Choose Stratagems or Intelligence Ops. Start research and use **Debug: Advance Day** to complete a project after two days. The right column shows unlocked support. Select Emergency Reload and buy Facility Recon during squad preparation. |
| Combat | Use **G** to refill the selected operative's magazine once per operation after preparing Emergency Reload. It costs 3 Intel on use and spends no AP. Facility Recon costs 2 Intel and previews that operation's existing objectives and events. **F9** returns to the bunker from the report. |

Campaign state lasts for the running session. Use **Enter** after clearing an Assassination room to advance or **E** to extract. Normal objectives, enemy schedules, combat rules and item effects use the existing Build 10 code. Existing tactical profiles supply the personnel portraits and stats.

Scythe's Wolverine, Arachnid and Blink tabs preview the provisional Levels 1–9 class path. The origin tabs browse the design. The prototype's current combat abilities appear separately. Other classes show their implemented abilities while their trees are in development.

## Verification

The redesigned Personnel dossier was checked in a rendered Godot 4.7.2 session. The check covered operative and origin selection, name sorting with selection preserved, recovery status, recruitment, two-handed melee compatibility, and transfer of edited equipment into a Rescue deployment.

Godot 4.7.2 stable on Windows. All 30 integration checks passed headlessly and in a rendered OpenGL Compatibility session at 1460 × 900. They cover bunker startup, roster sorting, all four equipment slots, consumable purchases, support research, Facility Recon, Emergency Reload, mission reports and the four operations' objective hooks. The checks use menu actions and combat event handlers with scripted setup for selected battle conditions. An earlier rendered run passed all assertions and exited abnormally during shutdown. Both repeat runs exited normally. Full manual playthroughs and balance remain open.
