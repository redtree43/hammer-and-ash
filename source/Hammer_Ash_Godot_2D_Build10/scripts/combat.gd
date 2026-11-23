extends Node2D
## Hammer & Ash — Build 10: reusable objective modules, four selectable test missions, existing regression chain.
## Compare legacy vs tactical AI using I. D toggles debug decisions.
## New tactical AI scores short plans of movement + attack (2 enemy AP),
## with role-configurable self-preservation, aggression and target priorities.
## Cover is a *physical shared edge*, not owned exclusively by a tile.
## Artwork is drawn in 2D with embedded pixel sprites; no external assets required.

const UnitSprites = preload("res://scripts/unit_sprites.gd")
const StarterLoadouts = preload("res://scripts/starter_loadouts.gd")
const Headquarters = preload("res://scripts/hq_trial_screen.gd")
const HQ_BUTTON: Rect2 = Rect2(950, 751, 235, 46)

var headquarters: Headquarters = Headquarters.new()
var hq_deployment: bool = false

@onready var unit_sprites: Dictionary[String, Texture2D] = UnitSprites.create_textures()

var board_w: int = 22
var board_h: int = 16
const TILE: int = 36
const ORIGIN: Vector2 = Vector2(32, 88)
const DIRECTIONS: Array[Vector2i] = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
const MOVE_DISTANCE: int = 4
const SCYTHE_CHARGE_NAME: String = "Charge"
const SCYTHE_CHARGE_DISTANCE: int = 2
const SCYTHE_CHARGE_DAMAGE: int = 2
const WOLVERINE_CLAWS: String = "Wolverine Claws"
const SPIDER_AGILITY_BONUS: int = 1
const SHORT_BLINK: String = "Short Blink"
const SHORT_BLINK_RANGE: int = 4
const SHORT_BLINK_AP: int = 1
const DEFAULT_MAGAZINE_CAPACITY: int = 3
const RELOAD_AP_COST: int = 1
const EMPTY_MAGAZINE: String = "Magazine empty: reload [X]."
const SHOOT_BUTTON: Rect2 = Rect2(1187, 274, 96, 28)
const RELOAD_BUTTON: Rect2 = Rect2(1291, 274, 110, 28)
const EMPTY_RELOAD_BUTTON: Rect2 = Rect2(1187, 274, 214, 28)
const FIRST_DOWN_MISSED_TURNS: int = 2
const HORDE_MOVE_DISTANCE: int = 5
const SUPPORT_RANGE: int = 4
const SUPPORT_COST: int = 1
const SHRED_DAMAGE: int = 2
const SHRED_CHARGE_DISTANCE: int = 3
const SENTINEL_BREACH_DISTANCE: int = 4
const SENTINEL_BREACH_DAMAGE: int = 5
const SENTINEL_BREACH_AP: int = 1
const BREACH_ACTION_NAME: String = "Anvil Breach"
# Eight perimeter cells, clockwise. Three consecutive cells form a connected
# arc around Scythe; every cell touches Scythe (edge or corner). A direction
# clicked next to Scythe selects the centre of the 3-cell arc.
const SHRED_RING: Array[Vector2i] = [Vector2i(0,-1), Vector2i(1,-1), Vector2i(1,0), Vector2i(1,1), Vector2i(0,1), Vector2i(-1,1), Vector2i(-1,0), Vector2i(-1,-1)]
const NEXT_ROOM_BUTTON: Rect2 = Rect2(545, 733, 350, 64)
const REPORT_RESET: Rect2 = Rect2(1150, 802, 254, 54)
const END_BUTTON: Rect2 = Rect2(871, 758, 212, 51)
const RESET_BUTTON: Rect2 = Rect2(1095, 758, 212, 51)
const PANEL_X: float = 858.0

var walls: Array[Vector2i] = []
var cover_edges: Dictionary = {}
var arena_variant: int = 0
var armour_enabled: bool = true
const ARENA_NAMES: Array[String] = ["LARGE 22x16", "COMPACT 18x14"]
# Scenario selection is internal to the authored mission; C/T no longer skip rooms.
var scenario_index: int = 0
const ROOM_COUNT: int = 3
const ROOM_NAMES: Array[String] = ["01 / KENNEL BREACH", "02 / KGB CORDON", "03 / ELITE RESPONSE"]
var mission_stage: int = 0
var room_cleared: bool = false
var room_history: Array[Dictionary] = []
# Exactly one record per resolved action, separate from hit counts (AoE has several hits).
var unit_action_counters: Array[Dictionary] = []
var show_room_activity: bool = false
var activity_room_page: int = 0
var mission_victory: bool = false
# Room 2 secondary objective. An unanswered radio call adds three hounds to Room 3.
var radio_state: Dictionary = {}
var radio_reinforcements_queued: bool = false
const RADIO_POS: Vector2i = Vector2i(15, 8)
const RADIO_DEADLINE_ROUND: int = 3
const RADIO_HP: int = 2
const RADIO_EXTRA_HOUNDS: int = 3
# Environmental rules: 3 ROUND hazards, 2 own-phase status activations,
# Shocked lasts one activation and reduces the next AP refresh by 1.
const HAZARD_ROUNDS: int = 3
const STATUS_TURNS: int = 2
const SHOCK_TURNS: int = 1
const MAX_KNOCKBACK: int = 2
var destructible_edges: Dictionary = {}  # physical edge key -> {tile, face, hp, max_hp, level}
var barrels: Dictionary = {}             # Vector2i -> {kind, hp, max_hp}
var hazards: Dictionary = {}             # Vector2i -> {kind, expires_round, creator}
var breach_target_mode: bool = false      # B: Anvil straight-line four-tile charge / collision

var show_enemy_threat: bool = false  # H: while on, hover an enemy for next-phase threat.
var show_hit_ledger: bool = false  # L: inspect every resolved attack from either faction.
var ledger_scroll: int = 0
var damage_history: Array[Dictionary] = []
var damage_floaters: Array[Dictionary] = []
const DAMAGE_FLOAT_SECONDS: float = 1.35
const LEDGER_VISIBLE_ROWS: int = 17
# Resolves exactly one traversed tile per animation tick, including reactions.
var movement_task: Dictionary = {}
var movement_tick: float = 0.0
const MOVEMENT_STEP_SECONDS: float = 0.070
const REACTION_AP_COST: int = 1

var hovered_tile: Vector2i = Vector2i(-1, -1)
var units: Array[Dictionary] = []
var selected_id: int = -1
var side_to_play: String = "player"
var game_over: bool = false
var winner: String = ""
var turn_number: int = 1
var action_log: Array[String] = []
var status_message: String = ""
var enemy_action_order: Array[int] = []
var enemy_action_cursor: int = 0
var enemy_action_timer: float = 0.0
var last_acting_enemy: int = -1
var enemy_action_count: int = 0
var smart_ai_enabled: bool = true
var ai_debug_enabled: bool = false
var ai_focus_id: int = -1
var ai_last_decision: String = ""
var ai_move_count: int = 0
var ai_shot_count: int = 0
var ai_flank_count: int = 0
var special_mode: bool = false
# Noncommittal landing selection for Scythe Area Shred; movement occurs on attack.
var shred_landing_tile: Vector2i = Vector2i(-1, -1)
var show_report: bool = false
var show_firing_range: bool = true  # F toggles green base-attack links to enemies in range with clear LOS.
# Event counters persist for the entire encounter, including incapacitated units.
var battle_stats: Array[Dictionary] = []
var ability_damage_totals: Dictionary = {}
var ability_use_totals: Dictionary = {}
var enemy_horde_start: int = 5

# ===== Build 10: one mission controller, configurable objectives and events =====
const TEST_MISSION_IDS: Array[String] = ["chain", "assassination", "sabotage", "rescue", "defence", "scythe"]
const TEST_MISSION_TITLES: Array[String] = ["Original three-room chain", "Assassination: fleeing officer", "Sabotage: prototype activation", "Rescue: two prisoners", "Defence: safehouse waves", "Scythe: origin test range"]
const SCYTHE_ORIGINS: Array[String] = ["Wolverine", "Arachnid", "Blink", "Standard"]
const SCYTHE_ORIGIN_DETAILS: Array[String] = ["Innate claws", "Spider Agility", SHORT_BLINK, "Charge only"]
var test_mission_id: String = "assassination"
var mission_picker_open: bool = true
var loadout_open: bool = false
var pending_mission_id: String = ""
var loadout_operative: int = 0
var mission_loadouts: Array[Array] = StarterLoadouts.defaults()
var draft_loadouts: Array[Array] = []
var scythe_origin: String = "Wolverine"
var draft_scythe_origin: String = "Wolverine"
var scythe_portraits: Dictionary[String, Texture2D] = {}
var loadout_action: String = ""
const DEPLOY_BUTTON: Rect2 = Rect2(1015, 743, 216, 54)
const LOADOUT_BACK_BUTTON: Rect2 = Rect2(229, 743, 157, 54)
const SHORT_BLINK_BUTTON: Rect2 = Rect2(1187, 419, 214, 24)
const MELEE_BUTTON: Rect2 = Rect2(1187, 246, 96, 24)
const MEDKIT_BUTTON: Rect2 = Rect2(1291, 246, 110, 24)
var mission_objects: Dictionary = {}       # Vector2i -> objective object data
var mission_objectives: Array[Dictionary] = [] # reusable {id,type,label,required,complete}
var mission_events: Array[Dictionary] = []  # configurable {id,round,phase,action,fired}
var mission_flags: Dictionary = {}         # consequence flags and objective progression
var defence_wave_number: int = 0
const DEFENCE_LAST_ROUND: int = 8
const DEFENCE_HQ_POS: Vector2i = Vector2i(5, 8)
const ESCAPE_EXIT: Vector2i = Vector2i(17, 7)

func mission_room_total() -> int:
    return 3 if test_mission_id in ["chain", "assassination"] else 1

func mission_room_label(stage: int) -> String:
    if test_mission_id == "chain":
        return ROOM_NAMES[stage]
    if test_mission_id == "assassination":
        return ["01 / OUTER PATROL", "02 / KGB SECURITY", "03 / OFFICER'S ESCAPE"][stage]
    if test_mission_id == "sabotage": return "01 / PROJECT IRON GIANT"
    if test_mission_id == "rescue": return "01 / DETENTION BLOCK"
    if test_mission_id == "scythe": return "01 / SCYTHE TEST RANGE"
    return "01 / SAFEHOUSE DEFENCE"

func mission_picker_rect(idx: int) -> Rect2:
    return Rect2(265.0, 175.0 + float(idx) * 94.0, 920.0, 80.0)

func draw_mission_picker() -> void:
    draw_rect(Rect2(0, 0, 1460, 900), Color("#111b2b"), true)
    draw_label("HAMMER & ASH  /  BUILD 10 MISSION TEST SUITE", Vector2(258, 95), 29, Color("#edf2f8"))
    draw_label("Choose a scenario. [M] opens this selector at any time; [R] restarts selected test.", Vector2(266, 136), 16, Color("#acc6d8"))
    var descriptions: Array[String] = [
        "Regression: hounds > KGB cordon + radio > mixed elite; HP persists.",
        "Three linked rooms. Target in Room 3 attempts escape starting turn 3.",
        "Destroy two installations. At end of turn 3, an unfinished prototype activates.",
        "Unlock two cells (adjacent, 1 AP) and clear guards; no long escort walk.",
        "Single map, 8 rounds, 4 scheduled waves. Protect the 20-HP safehouse.",
        "Compare Wolverine Claws, Spider Agility and Short Blink with Charge."
    ]
    for i in range(TEST_MISSION_IDS.size()):
        var r: Rect2 = mission_picker_rect(i)
        var selected: bool = TEST_MISSION_IDS[i] == test_mission_id
        draw_rect(r, Color("#29495c") if selected else Color("#233347"), true)
        draw_rect(r, Color("#87d4bc") if selected else Color("#667f91"), false, 2.0)
        draw_label("%d  /  %s" % [i + 1, TEST_MISSION_TITLES[i]], r.position + Vector2(20, 32), 21, Color("#e9f1f5"))
        draw_label(descriptions[i], r.position + Vector2(22, 61), 14, Color("#a9c1d1"))
    draw_label("Click a scenario or press 1–6 to prepare the squad's loadout.", Vector2(265, 770), 14, Color("#e8d19a"))
    draw_label("Developer shortcuts: M menu  |  F6/F7/F8 original-room jump  |  L hit ledger", Vector2(265, 802), 13, Color("#9fb5c6"))
    draw_action_button(HQ_BUTTON, "HEADQUARTERS TRIAL [F9]", true)

func begin_loadout(id: String) -> void:
    if not TEST_MISSION_IDS.has(id):
        return
    pending_mission_id = id
    draft_loadouts = mission_loadouts.duplicate(true)
    draft_scythe_origin = scythe_origin
    loadout_operative = 0
    mission_picker_open = false
    loadout_open = true
    queue_redraw()

func deploy_loadout() -> void:
    if not loadout_open:
        return
    mission_loadouts = draft_loadouts.duplicate(true)
    if pending_mission_id == "scythe":
        scythe_origin = draft_scythe_origin
    loadout_open = false
    choose_test_mission(pending_mission_id)

func loadout_member_rect(idx: int) -> Rect2:
    return Rect2(229 + idx * 203, 179, 190, 54)

func loadout_item_rect(slot: int, option: int) -> Rect2:
    if slot == 0:
        return Rect2(423 + option * 268, 267, 256, 76)
    return Rect2(423 + option * 405, 267 + slot * 105, 391, 76)

func choosing_scythe_origin() -> bool:
    return pending_mission_id == "scythe" and loadout_operative == 0

func scythe_origin_rect(idx: int) -> Rect2:
    return Rect2(423 + idx * 202, 674, 190, 54)

func handle_loadout_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode in [KEY_ESCAPE, KEY_M]:
            loadout_open = false
            mission_picker_open = true
        elif event.keycode in [KEY_ENTER, KEY_KP_ENTER]:
            deploy_loadout()
        elif event.keycode in [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5]:
            loadout_operative = event.keycode - KEY_1
        elif event.keycode == KEY_W and choosing_scythe_origin():
            draft_scythe_origin = SCYTHE_ORIGINS[(SCYTHE_ORIGINS.find(draft_scythe_origin) + 1) % SCYTHE_ORIGINS.size()]
    elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        if DEPLOY_BUTTON.has_point(event.position):
            deploy_loadout()
        elif LOADOUT_BACK_BUTTON.has_point(event.position):
            loadout_open = false
            mission_picker_open = true
        else:
            for idx in range(5):
                if loadout_member_rect(idx).has_point(event.position):
                    loadout_operative = idx
                    break
            if choosing_scythe_origin():
                for idx in range(SCYTHE_ORIGINS.size()):
                    if scythe_origin_rect(idx).has_point(event.position):
                        draft_scythe_origin = SCYTHE_ORIGINS[idx]
                        break
            for slot in range(StarterLoadouts.SLOTS.size()):
                if slot == 1 and choosing_scythe_origin() and draft_scythe_origin == "Wolverine":
                    continue
                for option in range(StarterLoadouts.ITEMS[slot].size()):
                    if loadout_item_rect(slot, option).has_point(event.position):
                        StarterLoadouts.select_item(loadout_operative, draft_loadouts[loadout_operative], slot, option)
    queue_redraw()

func draw_loadout() -> void:
    draw_rect(Rect2(0, 0, 1460, 900), Color("#111b2b"))
    draw_label("SQUAD LOADOUT", Vector2(229, 94), 33, Color("#edf2f8"))
    var title: String = TEST_MISSION_TITLES[TEST_MISSION_IDS.find(pending_mission_id)]
    draw_label(title + "  ·  Gear locks at deployment", Vector2(230, 133), 17, Color("#b5cdda"))
    for idx in range(5):
        var tab: Rect2 = loadout_member_rect(idx)
        var current: bool = idx == loadout_operative
        draw_rect(tab, Color("#315a6b") if current else Color("#223449"))
        draw_rect(tab, Color("#8edac4") if current else Color("#435b72"), false, 1.0)
        var role: String = str(units[idx]["name"])
        if idx == 0 and pending_mission_id == "scythe":
            role = UnitSprites.scythe_role(draft_scythe_origin)
        draw_texture(unit_sprites[role], tab.position + Vector2(13, 15))
        draw_label("%d  %s" % [idx + 1, str(units[idx]["name"])], tab.position + Vector2(48, 34), 16, Color("#edf2f8"))
    var operative: Dictionary = units[loadout_operative]
    var choices: Array = draft_loadouts[loadout_operative]
    for slot in range(StarterLoadouts.SLOTS.size()):
        draw_label(StarterLoadouts.SLOTS[slot].to_upper(), Vector2(230, 301 + slot * 105), 15, Color("#bbd4e1"))
        if slot == 1 and choosing_scythe_origin() and draft_scythe_origin == "Wolverine":
            var claw_card: Rect2 = loadout_item_rect(slot, 0)
            draw_rect(claw_card, Color("#284b51"))
            draw_rect(claw_card, Color("#8edac4"), false, 1.0)
            draw_label(WOLVERINE_CLAWS, claw_card.position + Vector2(17, 29), 18, Color("#edf2f8"))
            draw_label("Innate · 2 damage · removes 1 maximum armour", claw_card.position + Vector2(17, 52), 13, Color("#b5cdda"))
            continue
        for option in range(StarterLoadouts.ITEMS[slot].size()):
            var item: Dictionary = StarterLoadouts.ITEMS[slot][option]
            var card: Rect2 = loadout_item_rect(slot, option)
            var equipped: bool = int(choices[slot]) == option
            var allowed: bool = StarterLoadouts.can_equip(loadout_operative, choices, slot, option)
            draw_rect(card, Color("#284b51") if equipped else (Color("#223449") if allowed else Color("#1a2737")))
            draw_rect(card, Color("#8edac4") if equipped else Color("#435b72"), false, 1.0)
            var item_name: String = str(item["name"])
            var detail: String = str(item["detail"]) if allowed else "Unavailable with a two-handed rifle"
            if slot == 0 and option == 0:
                var issued: Dictionary = operative["issued_firearm"]
                item_name = str(issued["name"])
                detail = "%d damage · %d range · 3 rounds" % [int(issued["damage"]), int(issued["range"])]
            elif slot == 2 and option == 0:
                detail = "%d armour" % int(operative["issued_armour"])
            draw_label(item_name, card.position + Vector2(17, 29), 18, Color("#edf2f8") if allowed else Color("#8497a4"))
            draw_label(detail, card.position + Vector2(17, 52), 13, Color("#b5cdda"))
            if slot == 0 and StarterLoadouts.blocks_melee(loadout_operative, option):
                draw_label("Two-handed · clears melee slot", card.position + Vector2(17, 68), 11, Color("#e9bb83"))
            if equipped:
                draw_label("EQUIPPED", card.position + Vector2(card.size.x - 81, 29), 11, Color("#ace6cc"))
    draw_rect(LOADOUT_BACK_BUTTON, Color("#293b50"))
    draw_label("BACK [ESC]", LOADOUT_BACK_BUTTON.position + Vector2(25, 34), 16, Color("#edf2f8"))
    if choosing_scythe_origin():
        draw_label("ORIGIN [W]", Vector2(230, 707), 15, Color("#bbd4e1"))
        for idx in range(SCYTHE_ORIGINS.size()):
            var origin: String = SCYTHE_ORIGINS[idx]
            var rect: Rect2 = scythe_origin_rect(idx)
            var selected: bool = origin == draft_scythe_origin
            draw_rect(rect, Color("#315a6b") if selected else Color("#223449"))
            draw_rect(rect, Color("#8edac4") if selected else Color("#435b72"), false, 1.0)
            draw_texture(scythe_portraits[origin], rect.position + Vector2(6, 3))
            draw_label(origin, rect.position + Vector2(66, 23), 15, Color("#edf2f8"))
            draw_label(SCYTHE_ORIGIN_DETAILS[idx], rect.position + Vector2(66, 42), 12, Color("#b5cdda"))
    draw_rect(DEPLOY_BUTTON, Color("#377760"))
    draw_label("DEPLOY [ENTER]", DEPLOY_BUTTON.position + Vector2(26, 34), 17, Color("#f3fff9"))

func choose_test_mission(id: String) -> void:
    if not TEST_MISSION_IDS.has(id):
        return
    test_mission_id = id
    restart_game()
    mission_picker_open = false
    status_message = "TEST: %s. [M] change scenario." % mission_room_label(0)
    queue_redraw()

func add_objective(id: String, kind: String, label: String, required: bool = true) -> void:
    mission_objectives.append({"id": id, "type": kind, "label": label, "required": required, "completed": false, "failed": false})

func add_event(id: String, when_round: int, phase: String, action: String) -> void:
    mission_events.append({"id": id, "round": when_round, "phase": phase, "action": action, "fired": false})

func mission_object_at(tile: Vector2i) -> bool:
    if not mission_objects.has(tile):
        return false
    var obj: Dictionary = mission_objects[tile]
    if str(obj.get("kind", "")) == "prisoner":
        return not bool(obj.get("released", false))
    if obj["kind"] == "terminal":
        var target: Vector2i = mission_object_named(str(obj["target_id"]))
        return int(obj["hp"]) > 0 and target.x >= 0 and int(mission_objects[target]["hp"]) > 0
    return int(obj.get("hp", 0)) > 0

func mission_object_named(id: String) -> Vector2i:
    for pos in mission_objects.keys():
        if str(mission_objects[pos].get("id", "")) == id:
            return pos
    return Vector2i(-1, -1)

func setup_test_objectives() -> void:
    mission_objects.clear()
    mission_objectives.clear()
    mission_events.clear()
    if test_mission_id == "assassination" and mission_stage == 2:
        add_objective("officer", "kill_target", "Eliminate KGB Officer Orlov (before escape)")
        add_event("officer_flees", 3, "enemy_start", "enable_escape")
        mission_flags["officer_escaped"] = false
    elif test_mission_id == "sabotage":
        mission_objects[Vector2i(13, 7)] = {"id": "generator", "kind": "machine", "label": "POWER GENERATOR", "hp": 6, "max_hp": 6}
        mission_objects[Vector2i(16, 9)] = {"id": "prototype", "kind": "machine", "label": "PROTOTYPE POD", "hp": 6, "max_hp": 6}
        mission_objects[Vector2i(15, 9)] = {"id": "terminal", "kind": "terminal", "label": "DISABLE TERMINAL", "target_id": "prototype", "hp": 1, "max_hp": 1}
        add_objective("generator", "destroy", "Destroy power generator")
        add_objective("prototype", "destroy_or_disable", "Disable prototype or eliminate activated robot")
        add_event("prototype_activation", 3, "player_end", "activate_prototype")
        mission_flags["prototype_activated"] = false
        mission_flags["prototype_neutralized"] = false
        mission_flags["generator_destroyed"] = false
    elif test_mission_id == "rescue":
        mission_objects[Vector2i(12, 8)] = {"id": "prisoner_a", "kind": "prisoner", "label": "PRISONER A", "hp": 1, "released": false}
        mission_objects[Vector2i(18, 9)] = {"id": "prisoner_b", "kind": "prisoner", "label": "PRISONER B", "hp": 1, "released": false}
        add_objective("prisoner_a", "free", "Free prisoner A")
        add_objective("prisoner_b", "free", "Free prisoner B")
    elif test_mission_id == "defence":
        mission_objects[DEFENCE_HQ_POS] = {"id": "safehouse", "kind": "protect", "label": "RESISTANCE SAFEHOUSE", "hp": 20, "max_hp": 20}
        add_objective("safehouse", "survive", "Protect safehouse through enemy round 8")
        add_event("wave_2", 3, "player_start", "spawn_wave")
        add_event("wave_3", 5, "player_start", "spawn_wave")
        add_event("wave_4", 7, "player_start", "spawn_wave")
    for p in mission_objects.keys():
        assert(not walls.has(p), "Mission object spawned in wall")
        assert(find_unit_at(p) < 0, "Mission object overlaps unit")
        assert(not barrel_is_active(p), "Mission object overlaps barrel")

func run_mission_events(phase: String) -> void:
    # Generic trigger/action table: changing the round or action needs no AI rewrite.
    for i in range(mission_events.size()):
        var event: Dictionary = mission_events[i]
        if bool(event["fired"]) or str(event["phase"]) != phase or turn_number < int(event["round"]):
            continue
        event["fired"] = true
        mission_events[i] = event
        match str(event["action"]):
            "enable_escape":
                mission_flags["escape_active"] = true
                add_log("OFFICER ORLOV IS FLEEING! Intercept before he reaches the east exit.")
            "activate_prototype":
                if not bool(mission_flags.get("prototype_neutralized", false)):
                    mission_flags["prototype_activated"] = true
                    var pod: Vector2i = mission_object_named("prototype")
                    if pod.x >= 0:
                        var obj: Dictionary = mission_objects[pod]
                        obj["hp"] = 0
                        mission_objects[pod] = obj
                    spawn_prototype_robot()
                    add_log("PROTOTYPE ACTIVATED! Defeat the robot; sabotage can still succeed.")
            "spawn_wave":
                spawn_defence_wave(defence_wave_number + 1)
    queue_redraw()

func next_defence_wave_round() -> int:
    if test_mission_id != "defence":
        return -1
    for event in mission_events:
        if str(event["action"]) == "spawn_wave" and not bool(event["fired"]):
            return int(event["round"])
    return -1

func objective_complete(id: String) -> bool:
    if id == "officer":
        if bool(mission_flags.get("officer_escaped", false)):
            return false
        for enemy in units:
            if bool(enemy.get("mission_target", false)):
                return int(enemy["hp"]) <= 0
        return false
    if id == "generator": return bool(mission_flags.get("generator_destroyed", false))
    if id == "prototype":
        if not bool(mission_flags.get("prototype_activated", false)):
            return bool(mission_flags.get("prototype_neutralized", false))
        for enemy in units:
            if bool(enemy.get("prototype_robot", false)) and int(enemy["hp"]) > 0:
                return false
        return true
    if id in ["prisoner_a", "prisoner_b"]:
        var pos: Vector2i = mission_object_named(id)
        return pos.x >= 0 and bool(mission_objects[pos].get("released", false))
    if id == "safehouse": return turn_number >= DEFENCE_LAST_ROUND and int(mission_objects[DEFENCE_HQ_POS]["hp"]) > 0
    return false

func all_required_objectives_met() -> bool:
    for objective in mission_objectives:
        if bool(objective["required"]) and not objective_complete(str(objective["id"])):
            return false
    return true

func get_objective_progress_line() -> String:
    if test_mission_id == "scythe":
        return "Clear the range. Scythe's Charge can be stopped by Overwatch."
    if test_mission_id == "chain":
        if mission_stage == 1:
            return "OPTIONAL: Destroy radio TX by end of turn 3"
        if mission_stage == 2 and radio_reinforcements_queued:
            return "RADIO ALERT: +3 hounds in final room"
        return "Eliminate all enemies to clear room."
    if test_mission_id == "assassination":
        if mission_stage < 2: return "Advance to the final room; preserve squad HP."
        return "TARGET ESCAPED — objective failed" if bool(mission_flags.get("officer_escaped", false)) else ("TARGET ELIMINATED" if objective_complete("officer") else ("ORLOV FLEEING TO EAST EXIT!" if bool(mission_flags.get("escape_active", false)) else "Orlov begins escape on player turn 3"))
    if test_mission_id == "sabotage":
        return "Generator: %s | Prototype: %s" % ["DONE" if objective_complete("generator") else "ACTIVE", "DONE" if objective_complete("prototype") else ("ROBOT ACTIVE" if bool(mission_flags.get("prototype_activated", false)) else "POD ACTIVE")]
    if test_mission_id == "rescue":
        return "Cells freed %d/2. Click each adjacent prisoner for 1 AP." % [int(objective_complete("prisoner_a")) + int(objective_complete("prisoner_b"))]
    return "SAFEHOUSE %d/20 HP | WAVE %d/4 | SURVIVE ROUND %d/8" % [int(mission_objects[DEFENCE_HQ_POS]["hp"]), defence_wave_number, mini(turn_number, 8)]

func objective_action(actor_idx: int, tile: Vector2i) -> bool:
    if actor_idx < 0 or not mission_object_at(tile) or int(units[actor_idx]["ap"]) < 1:
        return false
    var obj: Dictionary = mission_objects[tile]
    var kind: String = str(obj["kind"])
    var adjacent: bool = grid_distance(units[actor_idx]["pos"], tile) == 1
    if kind in ["prisoner", "terminal"]:
        if not adjacent:
            status_message = "Move adjacent to interact with this objective (1 AP)."
            return false
        units[actor_idx]["ap"] = int(units[actor_idx]["ap"]) - 1
        record_ability_use(actor_idx, "Objective Interaction")
        if kind == "prisoner":
            obj["released"] = true
            mission_objects[tile] = obj
            status_message = "%s FREE! Once guards are defeated the prisoner evacuates safely." % str(obj["label"])
        else:
            var target_pos: Vector2i = mission_object_named(str(obj["target_id"]))
            mission_objects[target_pos]["hp"] = 0
            mission_flags["prototype_neutralized"] = true
            status_message = "Prototype disabled through adjacent terminal (1 AP)."
            obj["hp"] = 0
            mission_objects[tile] = obj
        add_log(status_message)
        assess_winner()
        queue_redraw()
        return true
    if kind != "machine":
        status_message = "Your squad cannot attack this protected objective."
        return false
    var dist: int = grid_distance(units[actor_idx]["pos"], tile)
    if not adjacent and (dist > int(units[actor_idx]["range"]) or not has_line_of_sight(units[actor_idx]["pos"], tile)):
        status_message = "Objective outside range or line of sight."
        return false
    if not adjacent and not spend_shot(actor_idx):
        status_message = EMPTY_MAGAZINE
        return false
    units[actor_idx]["ap"] = int(units[actor_idx]["ap"]) - 1
    unit_action_counters[actor_idx]["basic_attacks"] = int(unit_action_counters[actor_idx]["basic_attacks"]) + 1
    battle_stats[actor_idx]["attacks"] = int(battle_stats[actor_idx]["attacks"]) + 1
    var damage: int = 2 if adjacent else int(units[actor_idx]["damage"])
    var dealt: int = mini(damage, int(obj["hp"]))
    obj["hp"] = maxi(0, int(obj["hp"]) - damage)
    mission_objects[tile] = obj
    unit_action_counters[actor_idx]["objective_damage"] = int(unit_action_counters[actor_idx]["objective_damage"]) + dealt
    damage_history.append({"number": damage_history.size() + 1, "round": turn_number, "team": "objective", "attacker": str(units[actor_idx]["name"]), "defender": str(obj["label"]), "ability": "Objective Strike", "arm": 0, "hp": dealt, "cover": 0, "running": dealt})
    damage_floaters.append({"pos": tile, "arm": 0, "hp": dealt, "ttl": DAMAGE_FLOAT_SECONDS})
    if int(obj["hp"]) <= 0:
        if str(obj["id"]) == "generator": mission_flags["generator_destroyed"] = true
        if str(obj["id"]) == "prototype": mission_flags["prototype_neutralized"] = true
    status_message = "%s takes %d damage (%d HP left)." % [str(obj["label"]), dealt, int(obj["hp"])]
    add_log(status_message)
    assess_winner()
    queue_redraw()
    return true

func append_enemy_to_battle(enemy: Dictionary) -> void:
    enemy["id"] = units.size()
    fill_magazine(enemy)
    enemy["statuses"] = {}
    enemy["reaction_type"] = ""
    enemy["reaction_available"] = false
    enemy["special_used_turn"] = -99
    enemy["special_ready_turn"] = -99
    enemy["stim_bonus"] = 0
    enemy["jammed_actions"] = 0
    enemy["weight"] = 3 if bool(enemy.get("prototype_robot", false)) else (1 if str(enemy.get("kind", "")) == "horde" else 2)
    units.append(enemy)
    battle_stats.append({"dealt_hp": 0, "dealt_arm": 0, "taken_hp": 0, "taken_arm": 0, "tiles": 0, "kills": 0, "attacks": 0, "healing": 0, "buffs": 0, "ability_uses": 0, "reactions": 0})
    unit_action_counters.append({"moves": 0, "basic_attacks": 0, "overwatch_set": 0, "objective_damage": 0, "env_triggers": 0, "cover_broken": 0, "named_abilities": {}})

func make_test_hound(label: String, pos: Vector2i) -> Dictionary:
    return {"id": -1, "team": "enemy", "kind": "horde", "name": label, "letter": "H", "pos": pos, "hp": 4, "max_hp": 4, "ap": 2, "max_ap": 2, "damage": 2, "range": 1, "move": HORDE_MOVE_DISTANCE, "armour": 0, "max_armour": 0, "basic_attack": "Ravenous Bite", "ai_profile": "horde", "ai_role": "melee", "ai_traits": {"self_preservation": 0.0}}

func spawn_prototype_robot() -> void:
    var pos: Vector2i = Vector2i(18, 9)
    if not tile_is_open(pos):
        for p in [Vector2i(18, 8), Vector2i(19, 9), Vector2i(17, 10), Vector2i(19, 10)]:
            if tile_is_open(p):
                pos = p
                break
    var robot: Dictionary = make_chain_rifle("IRON GIANT Prototype", pos, true, "aggressive")
    robot["letter"] = "G"
    robot["hp"] = 13
    robot["max_hp"] = 13
    robot["armour"] = 3
    robot["max_armour"] = 3
    robot["ap"] = 3
    robot["max_ap"] = 3
    robot["damage"] = 3
    robot["range"] = 5
    robot["prototype_robot"] = true
    append_enemy_to_battle(robot)

func find_wave_spawn() -> Vector2i:
    for x in [20, 19, 18, 17, 16, 15]:
        for y in [2, 5, 8, 11, 14, 1, 4, 7, 10, 13, 3, 6, 9, 12]:
            var pos: Vector2i = Vector2i(x, y)
            if tile_is_open(pos):
                return pos
    return Vector2i(-1, -1)

func spawn_defence_wave(wave: int) -> void:
    defence_wave_number = wave
    var compositions: Array = [["rifle", "rifle", "rifle"], ["hound", "hound", "hound", "hound"], ["rifle", "rifle", "rifle", "hound", "hound"], ["elite", "rifle", "hound", "hound", "hound", "rifle"]]
    if wave < 1 or wave > compositions.size():
        return
    var composition: Array = compositions[wave - 1]
    for i in range(composition.size()):
        var pos: Vector2i = find_wave_spawn()
        if pos.x < 0:
            add_log("Wave spawn full: unit queued but no free space.")
            continue
        var role: String = str(composition[i])
        var new_enemy: Dictionary = make_test_hound("Wave %d Hound %d" % [wave, i + 1], pos) if role == "hound" else make_chain_rifle("Wave %d KGB %d" % [wave, i + 1], pos, role == "elite", "aggressive")
        if role == "elite":
            new_enemy["name"] = "Wave %d Elite Enforcer" % wave
            new_enemy["letter"] = "X"
            new_enemy["hp"] = 12
            new_enemy["max_hp"] = 12
            new_enemy["armour"] = 3
            new_enemy["max_armour"] = 3
            new_enemy["ap"] = 3
            new_enemy["max_ap"] = 3
        append_enemy_to_battle(new_enemy)
    status_message = "DEFENCE WAVE %d/4 incoming — protect the 20-HP safehouse!" % wave
    add_log(status_message)

func enemy_attack_safehouse(idx: int) -> bool:
    if not mission_object_at(DEFENCE_HQ_POS) or int(units[idx]["ap"]) <= 0:
        return false
    var enemy: Dictionary = units[idx]
    if grid_distance(enemy["pos"], DEFENCE_HQ_POS) > int(enemy["range"]) or not has_line_of_sight(enemy["pos"], DEFENCE_HQ_POS):
        return false
    if not spend_shot(idx):
        return false
    units[idx]["ap"] = int(units[idx]["ap"]) - 1
    battle_stats[idx]["attacks"] = int(battle_stats[idx]["attacks"]) + 1
    var obj: Dictionary = mission_objects[DEFENCE_HQ_POS]
    var damage: int = mini(int(enemy["damage"]), int(obj["hp"]))
    obj["hp"] = maxi(0, int(obj["hp"]) - damage)
    unit_action_counters[idx]["objective_damage"] = int(unit_action_counters[idx]["objective_damage"]) + damage
    damage_history.append({"number": damage_history.size() + 1, "round": turn_number, "team": "objective", "attacker": str(enemy["name"]), "defender": "Resistance Safehouse", "ability": "Safehouse Assault", "arm": 0, "hp": damage, "cover": 0, "running": damage})
    mission_objects[DEFENCE_HQ_POS] = obj
    add_log("%s attacks SAFEHOUSE: -%d HP (%d/20)." % [str(enemy["name"]), damage, int(obj["hp"])])
    damage_floaters.append({"pos": DEFENCE_HQ_POS, "arm": 0, "hp": damage, "ttl": DAMAGE_FLOAT_SECONDS})
    if int(obj["hp"]) <= 0:
        mission_flags["safehouse_destroyed"] = true
        assess_winner()
    return true

func move_enemy_toward(idx: int, target: Vector2i) -> bool:
    var destinations: Dictionary = reachable(units[idx]["pos"], int(units[idx].get("move", MOVE_DISTANCE)), int(units[idx]["id"]))
    var choice: Vector2i = units[idx]["pos"]
    var best: int = grid_distance(choice, target)
    for pos in destinations.keys():
        var d: int = grid_distance(pos, target)
        if d < best and not hazards.has(pos):
            best = d
            choice = pos
    if choice == units[idx]["pos"]:
        return false
    start_unit_movement(idx, choice, 1)
    return true

func defence_enemy_step(idx: int) -> void:
    if int(units[idx]["ap"]) <= 0:
        return
    if enemy_attack_safehouse(idx):
        return
    var player: int = nearest_attackable_player(idx)
    if player >= 0 and grid_distance(units[idx]["pos"], DEFENCE_HQ_POS) > 3:
        perform_attack(idx, player)
        return
    move_enemy_toward(idx, DEFENCE_HQ_POS)

func fleeing_officer_step(idx: int) -> void:
    if not bool(mission_flags.get("escape_active", false)):
        smart_enemy_step(idx)
        return
    if units[idx]["pos"] == ESCAPE_EXIT:
        officer_escapes(idx)
        return
    if not move_enemy_toward(idx, ESCAPE_EXIT):
        smart_enemy_step(idx)

func officer_escapes(idx: int) -> void:
    if bool(mission_flags.get("officer_escaped", false)):
        return
    mission_flags["officer_escaped"] = true
    units[idx]["hp"] = 0
    add_log("OFFICER ORLOV ESCAPED — assassination objective FAILED. Defeat remaining guards.")
    status_message = "Assassination objective failed: Orlov escaped to east exit."
    assess_winner()

func draw_mission_objects() -> void:
    for pos in mission_objects.keys():
        var obj: Dictionary = mission_objects[pos]
        var kind: String = str(obj["kind"])
        var active: bool = mission_object_at(pos)
        var center: Vector2 = ORIGIN + Vector2((float(pos.x) + 0.5) * TILE, (float(pos.y) + 0.5) * TILE)
        var col: Color = Color("#e8bd67") if kind in ["machine", "terminal"] else (Color("#93ddac") if kind == "prisoner" else Color("#73c7e4"))
        if not active: col = Color("#697681")
        var base: Color = col.darkened(0.46)
        var light: Color = col.lightened(0.24)
        var corner: Vector2 = center - Vector2(14, 14)
        draw_rect(Rect2(corner + Vector2(1, 3), Vector2(28, 28)), Color("#111c28"))
        draw_rect(Rect2(corner, Vector2(28, 28)), base)
        draw_rect(Rect2(corner + Vector2(1, 1), Vector2(26, 2)), light)
        draw_rect(Rect2(corner + Vector2(2, 24), Vector2(24, 2)), col.darkened(0.66))
        if kind == "terminal":
            draw_rect(Rect2(corner + Vector2(4, 4), Vector2(20, 9)), Color("#18293a"))
            draw_rect(Rect2(corner + Vector2(7, 6), Vector2(14, 5)), col)
        elif kind == "prisoner":
            for x in [4, 11, 18]:
                draw_rect(Rect2(corner + Vector2(x, 4), Vector2(2, 9)), light)
        else:
            for x in [5, 11, 17]:
                draw_rect(Rect2(corner + Vector2(x, 6), Vector2(4, 4)), light)
        draw_rect(Rect2(corner + Vector2(4, 13), Vector2(20, 11)), col)
        var glyph: String = "HQ"
        if str(obj["id"]) == "generator": glyph = "G"
        elif str(obj["id"]) == "prototype": glyph = "P"
        elif kind == "terminal": glyph = "T"
        elif str(obj["id"]) == "prisoner_a": glyph = "1"
        elif kind == "prisoner": glyph = "2"
        draw_label(glyph, center + Vector2(-8 if glyph == "HQ" else -4, 9), 11, Color("#10232e"))
        if kind in ["machine", "protect"] and active:
            draw_label("%d" % int(obj["hp"]), center + Vector2(8, -15), 11, Color("#ffffff"))
    if test_mission_id == "assassination" and mission_stage == 2:
        var gate: Vector2 = ORIGIN + Vector2((float(ESCAPE_EXIT.x) + 0.5) * TILE, (float(ESCAPE_EXIT.y) + 0.5) * TILE)
        draw_rect(Rect2(gate - Vector2(15, 15), Vector2(30, 30)), Color("#b75b4e"), false, 3.0)
        draw_label("EXIT", gate + Vector2(-13, -19), 10, Color("#efbc97"))



# ===== Build 09: environmental geometry and persistence =====
func edge_key(tile: Vector2i, face: String) -> String:
    # Canonical shared edge: east/south edges normalize to neighbour's west/north.
    var norm: Vector2i = tile
    var f: String = face
    if face == "E":
        norm = tile + Vector2i(1, 0)
        f = "W"
    elif face == "S":
        norm = tile + Vector2i(0, 1)
        f = "N"
    return "%d,%d,%s" % [norm.x, norm.y, f]

func direction_to_face(from_tile: Vector2i, to_tile: Vector2i) -> String:
    var delta: Vector2i = to_tile - from_tile
    if delta == Vector2i(0, -1): return "N"
    if delta == Vector2i(1, 0): return "E"
    if delta == Vector2i(0, 1): return "S"
    if delta == Vector2i(-1, 0): return "W"
    return ""

func setup_environment_for_room(stage: int) -> void:
    barrels.clear()
    hazards.clear()
    destructible_edges.clear()
    # All level-1/2 physical cover edges are breakable, regardless of map position.
    # Level 3 is IMPERVIOUS: full cover but never destructible; walls block LOS.
    # Each room contains one sample impervious edge for validating that distinction.
    if stage == 0:
        barrels[Vector2i(11, 7)] = {"kind": "fuel", "hp": 1, "max_hp": 1}
        barrels[Vector2i(10, 11)] = {"kind": "waste", "hp": 1, "max_hp": 1}
        spawn_hazard(Vector2i(12, 9), "fire", -1)
    elif stage == 1:
        barrels[Vector2i(11, 4)] = {"kind": "fuel", "hp": 1, "max_hp": 1}
        barrels[Vector2i(18, 10)] = {"kind": "waste", "hp": 1, "max_hp": 1}
        spawn_hazard(Vector2i(11, 9), "shock", -1)
    else:
        barrels[Vector2i(10, 6)] = {"kind": "fuel", "hp": 1, "max_hp": 1}
        barrels[Vector2i(11, 9)] = {"kind": "waste", "hp": 1, "max_hp": 1}
        spawn_hazard(Vector2i(8, 8), "shock", -1)
    var impervious_samples: Array[Dictionary] = [
        {"tile": Vector2i(10, 8), "face": "W"},
        {"tile": Vector2i(7, 4), "face": "E"},
        {"tile": Vector2i(7, 6), "face": "E"}
    ]
    var sample: Dictionary = impervious_samples[stage]
    var sample_tile: Vector2i = sample["tile"]
    var sample_face: String = str(sample["face"])
    assert(cover_edges.has(sample_tile) and cover_edges[sample_tile].has(sample_face), "Missing impervious sample edge")
    cover_edges[sample_tile][sample_face] = 3

    # Normalize authored edges to their physical shared-edge keys. If both
    # neighbouring tiles authored the same edge, use the stronger cover type.
    var edge_definitions: Dictionary = {}
    for tile in cover_edges.keys():
        var anchor: Vector2i = tile
        for face in cover_edges[anchor].keys():
            var neighbour: Vector2i = anchor + tile_offset_for_face(str(face))
            if not is_in_bounds(neighbour):
                continue
            var key: String = edge_key(anchor, str(face))
            var level: int = int(cover_edges[anchor][face])
            if not edge_definitions.has(key) or level > int(edge_definitions[key]["level"]):
                edge_definitions[key] = {"tile": anchor, "face": str(face), "level": level}
    for key in edge_definitions.keys():
        var edge: Dictionary = edge_definitions[key]
        var level: int = int(edge["level"])
        if level == 1 or level == 2:
            var hp: int = 2 if level == 1 else 5
            destructible_edges[key] = {
                "tile": edge["tile"], "face": edge["face"],
                "hp": hp, "max_hp": hp, "level": level
            }
    assert(destructible_edges.size() > 20, "Expected every authored light/reinforced cover edge to be destructible")
    assert(barrels.size() == 2, "Each test room needs exactly two barrels")
    var fuel_count: int = 0
    var waste_count: int = 0
    var barrel_positions: Array = barrels.keys()
    for position in barrel_positions:
        if str(barrels[position]["kind"]) == "fuel":
            fuel_count += 1
        elif str(barrels[position]["kind"]) == "waste":
            waste_count += 1
    assert(fuel_count == 1 and waste_count == 1, "One fuel and one waste barrel per test room")
    assert(grid_distance(barrel_positions[0], barrel_positions[1]) > 2, "Barrels must be separated beyond blast range")
    for pos in barrels.keys():
        assert(is_in_bounds(pos) and not walls.has(pos), "Environmental barrel in a wall")
        assert(find_unit_at(pos) < 0, "Environmental barrel overlaps living unit")
        assert(not (radio_is_active() and pos == RADIO_POS), "Barrel overlaps radio")

func dev_button_rect(idx: int) -> Rect2:
    return Rect2(1060.0 + float(idx) * 117.0, 51.0, 105.0, 25.0)

func squad_tab_rect(idx: int) -> Rect2:
    # Compact selector replaces the former five-row squad roster.
    return Rect2(875.0 + float(idx) * 108.0, 202.0, 101.0, 33.0)

func draw_developer_room_buttons() -> void:
    draw_label("DEV ROOM JUMP:", Vector2(886, 69), 12, Color("#f1c982"))
    for idx in range(3):
        var rect: Rect2 = dev_button_rect(idx)
        draw_rect(rect, Color("#5f4e39"), true)
        draw_rect(rect, Color("#bd945c"), false, 1.0)
        draw_label("ROOM %d [F%d]" % [idx + 1, idx + 6], rect.position + Vector2(9, 17), 11, Color("#fff1cd"))

func dev_jump_to_room(stage: int) -> void:
    if test_mission_id not in ["chain", "assassination"]:
        test_mission_id = "chain"
    # Developer-only testing shortcut: resets squad to full HP, removes history.
    # Does NOT simulate clearing prior rooms. Never available in retail missions.
    room_history.clear()
    radio_reinforcements_queued = false
    radio_state.clear()
    mission_flags.clear()
    defence_wave_number = 0
    load_mission_room(clampi(stage, 0, ROOM_COUNT - 1), [])
    status_message = "DEV JUMP to ROOM %d: fresh squad, no radio-alert consequence. [F6/F7/F8]" % (stage + 1)
    add_log(status_message)
    queue_redraw()

func barrel_is_active(tile: Vector2i) -> bool:
    return barrels.has(tile) and int(barrels[tile].get("hp", 0)) > 0

func barrel_preview(attacker_idx: int, tile: Vector2i) -> Dictionary:
    var result: Dictionary = {"valid": false, "reason": "Barrel unavailable", "distance": 0}
    if not barrel_is_active(tile) or attacker_idx < 0 or attacker_idx >= units.size():
        return result
    if not has_attack_ammo(attacker_idx):
        result["reason"] = EMPTY_MAGAZINE
        return result
    var dist: int = grid_distance(units[attacker_idx]["pos"], tile)
    result["distance"] = dist
    if dist > int(units[attacker_idx]["range"]):
        result["reason"] = "Out of basic-attack range"
    elif not has_line_of_sight(units[attacker_idx]["pos"], tile):
        result["reason"] = "Wall blocks line of sight"
    else:
        result["valid"] = true
        result["reason"] = "Click to shoot (1 AP) — detonation damages both sides"
    return result

func attack_barrel(actor_idx: int, tile: Vector2i) -> bool:
    var preview: Dictionary = barrel_preview(actor_idx, tile)
    if not bool(preview["valid"]):
        status_message = str(preview["reason"])
        return false
    if int(units[actor_idx]["ap"]) < 1:
        status_message = "Need 1 AP to shoot barrel."
        return false
    if not spend_shot(actor_idx):
        return false
    units[actor_idx]["ap"] = int(units[actor_idx]["ap"]) - 1
    unit_action_counters[actor_idx]["basic_attacks"] = int(unit_action_counters[actor_idx]["basic_attacks"]) + 1
    battle_stats[actor_idx]["attacks"] = int(battle_stats[actor_idx]["attacks"]) + 1
    record_ability_use(actor_idx, str(units[actor_idx]["basic_attack"]))
    hit_barrel(tile, int(units[actor_idx]["damage"]), actor_idx, "Gunfire")
    units[actor_idx]["stim_bonus"] = 0
    queue_redraw()
    return true

func hit_barrel(tile: Vector2i, damage: int, creator: int, source: String) -> void:
    if not barrel_is_active(tile):
        return
    var barrel: Dictionary = barrels[tile]
    barrel["hp"] = maxi(0, int(barrel["hp"]) - damage)
    barrels[tile] = barrel
    if int(barrel["hp"]) <= 0:
        detonate_barrel(tile, creator, source)

func detonate_barrel(tile: Vector2i, creator: int, source: String) -> void:
    if not barrels.has(tile):
        return
    var barrel: Dictionary = barrels[tile]
    barrels.erase(tile)  # Remove before chain checks: never detonate twice.
    var kind: String = str(barrel["kind"])
    var radius: int = 2 if kind == "fuel" else 1
    var damage: int = 2 if kind == "fuel" else 1
    var knockback: int = 3 if kind == "fuel" else 2
    add_log("%s barrel EXPLODES at %s (%s)." % [kind.to_upper(), str(tile), source])
    if creator >= 0 and creator < unit_action_counters.size():
        unit_action_counters[creator]["env_triggers"] = int(unit_action_counters[creator]["env_triggers"]) + 1
    # Break cover first, then damage/knockback units and create enduring hazards.
    damage_cover_in_radius(tile, radius, 3 if kind == "fuel" else 2, creator, kind.to_upper() + " blast")
    var impacted: Array[int] = []
    for idx in range(units.size()):
        if int(units[idx]["hp"]) > 0 and grid_distance(tile, units[idx]["pos"]) <= radius:
            impacted.append(idx)
    for idx in impacted:
        if int(units[idx]["hp"]) <= 0:
            continue
        environment_hit_unit(creator, idx, damage, kind.to_upper() + " Explosion")
        if int(units[idx]["hp"]) > 0:
            push_from_explosion(idx, tile, knockback, creator)
    var hazard_kind: String = "fire" if kind == "fuel" else "radiation"
    spawn_hazard(tile, hazard_kind, creator)
    for direction in DIRECTIONS:
        spawn_hazard(tile + direction, hazard_kind, creator)
    # Chain reactions are deterministic and terminate because destroyed barrels
    # are removed before recursion. Each additional barrel can ignite nearby fuel.
    var to_chain: Array[Vector2i] = []
    for another in barrels.keys():
        if grid_distance(tile, another) <= radius:
            to_chain.append(another)
    for another in to_chain:
        hit_barrel(another, 999, creator, "Chain reaction")
    status_message = "%s barrel detonated: blast / push / %s (3 rounds)." % [kind.to_upper(), hazard_kind]
    assess_winner()

func environment_hit_unit(creator: int, idx: int, raw_damage: int, label: String) -> void:
    if idx < 0 or idx >= units.size() or int(units[idx]["hp"]) <= 0 or raw_damage <= 0:
        return
    var taken_arm: int = mini(int(units[idx]["armour"]), raw_damage)
    var taken_hp: int = mini(int(units[idx]["hp"]), maxi(0, raw_damage - taken_arm))
    units[idx]["armour"] = int(units[idx]["armour"]) - taken_arm
    units[idx]["hp"] = int(units[idx]["hp"]) - taken_hp
    battle_stats[idx]["taken_hp"] = int(battle_stats[idx]["taken_hp"]) + taken_hp
    battle_stats[idx]["taken_arm"] = int(battle_stats[idx]["taken_arm"]) + taken_arm
    var who: String = "ENVIRONMENT"
    if creator >= 0 and creator < units.size():
        battle_stats[creator]["dealt_hp"] = int(battle_stats[creator]["dealt_hp"]) + taken_hp
        battle_stats[creator]["dealt_arm"] = int(battle_stats[creator]["dealt_arm"]) + taken_arm
        var key: String = ("REBEL | " if units[creator]["team"] == "player" else "ENEMY | ") + label
        ability_damage_totals[key] = int(ability_damage_totals.get(key, 0)) + taken_hp + taken_arm
        record_damage_feedback(creator, idx, label, taken_arm, taken_hp, 0)
        who = str(units[creator]["name"])
    else:
        damage_history.append({"number": damage_history.size() + 1, "round": turn_number, "team": "environment", "attacker": "ENVIRONMENT", "defender": str(units[idx]["name"]), "ability": label, "arm": taken_arm, "hp": taken_hp, "cover": 0, "running": summed_ledger_damage("environment") + taken_arm + taken_hp})
        damage_floaters.append({"pos": units[idx]["pos"], "arm": taken_arm, "hp": taken_hp, "ttl": DAMAGE_FLOAT_SECONDS})
    add_log("%s -> %s [%s]: -%d ARM / -%d HP" % [who, str(units[idx]["name"]), label, taken_arm, taken_hp])
    if int(units[idx]["hp"]) <= 0:
        if creator >= 0 and creator < units.size():
            battle_stats[creator]["kills"] = int(battle_stats[creator]["kills"]) + 1
        if units[idx]["team"] == "player":
            register_player_down(idx)
        else:
            add_log(str(units[idx]["name"]) + " eliminated by environment.")

func push_from_explosion(idx: int, epicentre: Vector2i, force: int, creator: int) -> void:
    var weight: int = int(units[idx].get("weight", 2))
    var distance: int = mini(MAX_KNOCKBACK, maxi(0, force - weight))
    var delta: Vector2i = units[idx]["pos"] - epicentre
    var dir: Vector2i = Vector2i.ZERO
    if absi(delta.x) >= absi(delta.y):
        dir.x = 1 if delta.x >= 0 else -1
    else:
        dir.y = 1 if delta.y >= 0 else -1
    for _step in range(distance):
        var dest: Vector2i = units[idx]["pos"] + dir
        if not tile_is_open(dest, int(units[idx]["id"])):
            environment_hit_unit(creator, idx, 1, "Knockback Collision")
            break
        units[idx]["pos"] = dest
        battle_stats[idx]["tiles"] = int(battle_stats[idx]["tiles"]) + 1
        apply_hazard_entry(idx)
        if int(units[idx]["hp"]) <= 0:
            break

func spawn_hazard(tile: Vector2i, kind: String, creator: int) -> void:
    if not is_in_bounds(tile) or walls.has(tile) or barrel_is_active(tile):
        return
    hazards[tile] = {"kind": kind, "expires_round": turn_number + HAZARD_ROUNDS, "creator": creator}

func age_hazards() -> void:
    var expired: Array[Vector2i] = []
    for tile in hazards.keys():
        if turn_number >= int(hazards[tile]["expires_round"]):
            expired.append(tile)
    for tile in expired:
        hazards.erase(tile)

func apply_status(idx: int, kind: String) -> void:
    if int(units[idx]["hp"]) <= 0:
        return
    var effects: Dictionary = units[idx].get("statuses", {})
    effects[kind] = maxi(int(effects.get(kind, 0)), SHOCK_TURNS if kind == "shocked" else STATUS_TURNS)
    units[idx]["statuses"] = effects

func apply_hazard_entry(idx: int) -> void:
    if int(units[idx]["hp"]) <= 0:
        return
    var tile: Vector2i = units[idx]["pos"]
    if not hazards.has(tile):
        return
    var hazard: Dictionary = hazards[tile]
    var effect: String = "burning" if str(hazard["kind"]) == "fire" else ("irradiated" if str(hazard["kind"]) == "radiation" else "shocked")
    var existing_effects: Dictionary = units[idx].get("statuses", {})
    if int(existing_effects.get(effect, 0)) > 0:
        return  # Already affected: no new entry hit or duration refresh.
    environment_hit_unit(int(hazard["creator"]), idx, 1, str(hazard["kind"]).capitalize() + " Hazard")
    if int(units[idx]["hp"]) > 0:
        apply_status(idx, effect)

func process_environment_phase(team: String) -> void:
    # Status durations refer to affected unit's OWN faction activations.
    # Ongoing environmental damage is not caused by traversing animation frames.
    for idx in range(units.size()):
        if units[idx]["team"] != team or int(units[idx]["hp"]) <= 0:
            continue
        var effects: Dictionary = units[idx].get("statuses", {})
        var names: Array = effects.keys()
        for effect in names:
            if int(units[idx]["hp"]) <= 0:
                break
            var remaining: int = int(effects[effect])
            if remaining <= 0:
                effects.erase(effect)
                continue
            match str(effect):
                "burning": environment_hit_unit(-1, idx, 1, "Burning Status")
                "irradiated": units[idx]["armour"] = maxi(0, int(units[idx]["armour"]) - 1)
                "shocked":
                    if team == "enemy":
                        # Enemy AP will be refreshed later in end_player_turn.
                        units[idx]["jammed_actions"] = int(units[idx]["jammed_actions"]) + 1
                    else:
                        units[idx]["ap"] = maxi(0, int(units[idx]["ap"]) - 1)
            if int(units[idx]["hp"]) <= 0:
                break
            remaining -= 1
            if remaining <= 0:
                effects.erase(effect)
            else:
                effects[effect] = remaining
        units[idx]["statuses"] = effects
        if int(units[idx]["hp"]) > 0 and hazards.has(units[idx]["pos"]):
            apply_hazard_entry(idx)
    assess_winner()

func arc_has_barrel(arc: Array[Vector2i]) -> bool:
    for tile in arc:
        if barrel_is_active(tile):
            return true
    return false

func arc_has_breakable_cover(arc: Array[Vector2i]) -> bool:
    for key in destructible_edges.keys():
        var edge: Dictionary = destructible_edges[key]
        var tile: Vector2i = edge["tile"]
        if int(edge["level"]) == 1 and (arc.has(tile) or arc.has(tile + tile_offset_for_face(str(edge["face"])))):
            return true
    return false

func damage_cover_in_tiles(tiles: Array[Vector2i], strength: int, actor_idx: int, cause: String, light_only: bool = false) -> void:
    var to_impact: Array = destructible_edges.keys()
    for key in to_impact:
        if not destructible_edges.has(key):
            continue
        var e: Dictionary = destructible_edges[key]
        if light_only and int(e["level"]) != 1:
            continue
        var edge_tile: Vector2i = e["tile"]
        if tiles.has(edge_tile) or tiles.has(edge_tile + tile_offset_for_face(str(e["face"]))):
            damage_cover_edge(str(key), strength, actor_idx, cause)

func damage_cover_in_radius(center: Vector2i, radius: int, strength: int, actor_idx: int, cause: String) -> void:
    var keys: Array = destructible_edges.keys()
    for key in keys:
        if not destructible_edges.has(key):
            continue
        var e: Dictionary = destructible_edges[key]
        var anchor: Vector2i = e["tile"]
        var other: Vector2i = anchor + tile_offset_for_face(str(e["face"]))
        if mini(grid_distance(center, anchor), grid_distance(center, other)) <= radius:
            damage_cover_edge(str(key), strength, actor_idx, cause)

func damage_cover_edge(key: String, structural_damage: int, actor_idx: int, cause: String) -> void:
    if not destructible_edges.has(key):
        return
    var edge: Dictionary = destructible_edges[key]
    edge["hp"] = maxi(0, int(edge["hp"]) - structural_damage)
    if int(edge["hp"]) <= 0:
        var tile: Vector2i = edge["tile"]
        var face: String = str(edge["face"])
        var levels: Dictionary = cover_edges.get(tile, {})
        levels.erase(face)
        cover_edges[tile] = levels
        var opposite: Vector2i = tile + tile_offset_for_face(face)
        if cover_edges.has(opposite):
            var adjacent_edges: Dictionary = cover_edges[opposite]
            adjacent_edges.erase(opposing_face(face))
            cover_edges[opposite] = adjacent_edges
        destructible_edges.erase(key)
        if actor_idx >= 0 and actor_idx < unit_action_counters.size():
            unit_action_counters[actor_idx]["cover_broken"] = int(unit_action_counters[actor_idx]["cover_broken"]) + 1
        add_log("COVER SHATTERED (%s): %s / %s" % [cause, str(tile), face])
    else:
        destructible_edges[key] = edge
        add_log("%s cover damaged by %s." % ["Light" if int(edge["level"]) == 1 else "Reinforced", cause])

func breach_push_destination(victim_idx: int, direction: Vector2i) -> Vector2i:
    # Deterministic displacement: straight forward, then clockwise, then counterclockwise.
    # Not a physics force: one tile only. Existing explosion knockback still has a 2-tile cap.
    var side: Vector2i = Vector2i(-direction.y, direction.x)
    var candidates: Array[Vector2i] = [direction, side, -side]
    for offset in candidates:
        var destination: Vector2i = units[victim_idx]["pos"] + offset
        if tile_is_open(destination, int(units[victim_idx]["id"])):
            return destination
    return Vector2i(-1, -1)

func breach_plan(target_tile: Vector2i) -> Dictionary:
    # Single authoritative preflight used for both preview and execution.
    # The charge cannot turn, jump walls, target allies or shove equally heavy enemies.
    var plan: Dictionary = {"valid": false, "reason": "Select a destination", "path": [], "edges": [], "enemy": -1, "push": Vector2i(-1, -1), "lethal": false}
    if operative_kit(selected_id) != 1 or int(units[selected_id]["hp"]) <= 0:
        plan["reason"] = "Anvil is unavailable"
        return plan
    if int(units[selected_id]["ap"]) < SENTINEL_BREACH_AP or int(units[selected_id].get("breach_used_turn", -99)) == turn_number:
        plan["reason"] = "Breach not ready: requires 1 AP, once per turn"
        return plan
    var origin: Vector2i = units[selected_id]["pos"]
    var delta: Vector2i = target_tile - origin
    var length: int = grid_distance(origin, target_tile)
    if length < 1 or length > SENTINEL_BREACH_DISTANCE or (delta.x != 0 and delta.y != 0):
        plan["reason"] = "Choose a straight N/E/S/W charge of 1-4 tiles"
        return plan
    if not is_in_bounds(target_tile):
        plan["reason"] = "Outside the battlefield"
        return plan
    var direction: Vector2i = Vector2i(signi(delta.x), signi(delta.y))
    var face: String = direction_to_face(origin, origin + direction)
    var path: Array[Vector2i] = []
    var edges: Array[String] = []
    for n in range(1, length + 1):
        var current: Vector2i = origin + direction * n
        var previous: Vector2i = current - direction
        if walls.has(current):
            plan["reason"] = "Solid wall blocks the charge"
            return plan
        if barrel_is_active(current) or (radio_is_active() and current == RADIO_POS):
            plan["reason"] = "Barrel or radio transmitter blocks the charge"
            return plan
        var edge: String = edge_key(previous, face)
        if destructible_edges.has(edge):
            edges.append(edge)
        elif shared_cover_on_side(previous, face) > 0:
            plan["reason"] = "Impervious cover blocks the charge"
            return plan
        var occupant: int = find_unit_at(current, true)
        if occupant >= 0:
            if units[occupant]["team"] == "player":
                plan["reason"] = "An ally blocks the charge"
                return plan
            if n != length:
                plan["reason"] = "Enemy blocks the path: target its tile instead"
                return plan
            if int(units[occupant].get("weight", 2)) >= int(units[selected_id].get("weight", 3)):
                plan["reason"] = "TARGET TOO HEAVY: cannot displace this enemy"
                return plan
            plan["enemy"] = occupant
            var hit_hp: int = maxi(0, SENTINEL_BREACH_DAMAGE - int(units[occupant]["armour"]))
            var lethal: bool = int(units[occupant]["hp"]) <= hit_hp
            plan["lethal"] = lethal
            if not lethal:
                var push: Vector2i = breach_push_destination(occupant, direction)
                if push.x < 0:
                    plan["reason"] = "NO PUSH SPACE: enemy has no valid adjacent tile"
                    return plan
                plan["push"] = push
        path.append(current)
    plan["valid"] = true
    plan["reason"] = "VALID: %d-step Breach; 5 impact damage on collision" % length
    plan["path"] = path
    plan["edges"] = edges
    return plan

func sentinel_breach(target_tile: Vector2i) -> bool:
    if operative_kit(selected_id) != 1:
        return false
    var actor: Dictionary = units[selected_id]
    if side_to_play != "player" or game_over or int(actor["hp"]) <= 0:
        return false
    if int(actor["ap"]) < SENTINEL_BREACH_AP or int(actor.get("breach_used_turn", -99)) == turn_number:
        status_message = "Breach needs 1 AP and can be used once per turn."
        return false
    var plan: Dictionary = breach_plan(target_tile)
    if not bool(plan["valid"]):
        status_message = "BREACH BLOCKED: " + str(plan["reason"])
        return false
    units[selected_id]["ap"] = int(units[selected_id]["ap"]) - SENTINEL_BREACH_AP
    units[selected_id]["breach_used_turn"] = turn_number
    record_ability_use(selected_id, BREACH_ACTION_NAME)
    unit_action_counters[selected_id]["moves"] = int(unit_action_counters[selected_id]["moves"]) + 1
    var steps: Array = plan["path"]
    movement_task = {"unit_idx": selected_id, "kind": "sentinel_breach", "path": steps, "cursor": 0, "after": {}}
    movement_tick = 0.03
    status_message = "BREACH: Anvil charging %d tiles; cover shatters on contact." % steps.size()
    add_log("Anvil begins %d-tile Breach charge (1 AP)." % steps.size())
    return true

func draw_sentinel_breach_preview() -> void:
    # The same breach_plan() drives blue valid endpoints, red blocked tiles,
    # orange breakable edges and the exact green landing spot for displaced foes.
    if operative_kit(selected_id) != 1 or int(units[selected_id]["hp"]) <= 0:
        return
    var origin: Vector2i = units[selected_id]["pos"]
    for direction in DIRECTIONS:
        for length in range(1, SENTINEL_BREACH_DISTANCE + 1):
            var destination: Vector2i = origin + direction * length
            if not is_in_bounds(destination):
                continue
            var candidate: Dictionary = breach_plan(destination)
            if bool(candidate["valid"]):
                var marker: Rect2 = Rect2(ORIGIN + Vector2(destination.x * TILE + 3, destination.y * TILE + 3), Vector2(TILE - 6, TILE - 6))
                draw_rect(marker, Color(0.33, 0.73, 1.0, 0.16), true)
                draw_rect(marker, Color("#77d4ff"), false, 1.5)
    var hovered: Dictionary = breach_plan(hovered_tile)
    var diff: Vector2i = hovered_tile - origin
    if not is_in_bounds(hovered_tile) or grid_distance(origin, hovered_tile) > SENTINEL_BREACH_DISTANCE or (diff.x != 0 and diff.y != 0):
        return
    var tile_rect: Rect2 = Rect2(ORIGIN + Vector2(hovered_tile.x * TILE + 2, hovered_tile.y * TILE + 2), Vector2(TILE - 4, TILE - 4))
    if not bool(hovered["valid"]):
        draw_rect(tile_rect, Color(0.86, 0.19, 0.23, 0.32), true)
        draw_rect(tile_rect, Color("#ff666b"), false, 3.0)
        draw_line(tile_rect.position + Vector2(5, 5), tile_rect.end - Vector2(5, 5), Color("#ff666b"), 3.0)
        draw_line(tile_rect.position + Vector2(tile_rect.size.x - 5, 5), tile_rect.position + Vector2(5, tile_rect.size.y - 5), Color("#ff666b"), 3.0)
        return
    for step_tile in hovered["path"]:
        var step_rect: Rect2 = Rect2(ORIGIN + Vector2(step_tile.x * TILE + 6, step_tile.y * TILE + 6), Vector2(TILE - 12, TILE - 12))
        draw_rect(step_rect, Color(0.34, 0.72, 1.0, 0.23), true)
    for key in hovered["edges"]:
        var edge: Dictionary = destructible_edges[key]
        var tile: Vector2i = edge["tile"]
        var centre: Vector2 = ORIGIN + Vector2((float(tile.x) + 0.5) * TILE, (float(tile.y) + 0.5) * TILE)
        match str(edge["face"]):
            "N": centre.y -= TILE * 0.5
            "S": centre.y += TILE * 0.5
            "W": centre.x -= TILE * 0.5
            "E": centre.x += TILE * 0.5
        draw_circle(centre, 10.0, Color("#ffa34b"), false, 3.0)
    var enemy_idx: int = int(hovered["enemy"])
    if enemy_idx >= 0:
        var enemy_tile: Vector2i = units[enemy_idx]["pos"]
        var enemy_screen: Vector2 = ORIGIN + Vector2((float(enemy_tile.x) + 0.5) * TILE, (float(enemy_tile.y) + 0.5) * TILE)
        draw_label("5 DMG", enemy_screen + Vector2(-15, -22), 11, Color("#ffe49c"))
        if not bool(hovered["lethal"]):
            var pushed: Vector2i = hovered["push"]
            var pushed_screen: Vector2 = ORIGIN + Vector2((float(pushed.x) + 0.5) * TILE, (float(pushed.y) + 0.5) * TILE)
            draw_rect(Rect2(ORIGIN + Vector2(pushed.x * TILE + 3, pushed.y * TILE + 3), Vector2(TILE - 6, TILE - 6)), Color("#6feeaa"), false, 3.0)
            draw_line(enemy_screen, pushed_screen, Color("#6feeaa"), 3.0)
            draw_circle(pushed_screen, 4.0, Color("#6feeaa"))

func draw_barrels() -> void:
    for tile in barrels.keys():
        var barrel: Dictionary = barrels[tile]
        var c: Vector2 = ORIGIN + Vector2((float(tile.x) + 0.5) * TILE, (float(tile.y) + 0.5) * TILE)
        var fuel: bool = str(barrel["kind"]) == "fuel"
        var fill: Color = Color("#e99552") if fuel else Color("#b4cf50")
        var shade: Color = fill.darkened(0.36)
        var rim: Color = fill.lightened(0.34)
        draw_rect(Rect2(c + Vector2(-11, 11), Vector2(23, 5)), Color("#131e2c"))
        draw_rect(Rect2(c + Vector2(-10, -10), Vector2(20, 22)), shade)
        draw_rect(Rect2(c + Vector2(-8, -9), Vector2(14, 21)), fill)
        draw_rect(Rect2(c + Vector2(-8, -14), Vector2(16, 6)), rim)
        draw_rect(Rect2(c + Vector2(-10, -12), Vector2(20, 3)), rim)
        draw_rect(Rect2(c + Vector2(-6, -12), Vector2(12, 2)), shade)
        draw_rect(Rect2(c + Vector2(3, -13), Vector2(3, 2)), Color("#27333a"))
        for y in [-7, 9]:
            draw_rect(Rect2(c + Vector2(-11, y), Vector2(22, 2)), Color("#3a4145"))
        draw_rect(Rect2(c + Vector2(-6, -4), Vector2(12, 12)), Color("#f7dfa0") if fuel else Color("#e0efa3"))
        draw_label("F" if fuel else "R", c + Vector2(-4, 6), 12, Color("#192934"))
        draw_label(str(barrel["hp"]), c + Vector2(10, -12), 11, Color("#ffffff"))

func _ready() -> void:
    for origin in SCYTHE_ORIGINS:
        scythe_portraits[origin] = UnitSprites.create_texture(UnitSprites.scythe_role(origin), 4)
    restart_game()
    mission_picker_open = false
    var playable_classes: Array[String] = []
    for idx in range(5):
        var kit: String = units[idx]["name"]
        playable_classes.append(kit)
        headquarters.kit_profiles[kit] = units[idx].duplicate(true)
        headquarters.kit_profiles[kit]["ability_text"] = ability_description(idx)
        headquarters.portraits[kit] = unit_sprites[kit]
    add_child(headquarters)
    headquarters.campaign.seed(playable_classes)
    headquarters.deployed.connect(deploy_hq_operation)
    headquarters.open()

func deploy_hq_operation(operation: String) -> void:
    hq_deployment = true
    test_mission_id = operation
    mission_picker_open = false
    restart_game()

func hq_operative_id(idx: int) -> int:
    return int(headquarters.campaign.mission["squad"][idx])

func operative_kit(idx: int) -> int:
    return int(units[idx].get("kit_index", idx)) if idx >= 0 and idx < 5 else -1

func extract_hq_operation() -> void:
    if not hq_deployment or not room_cleared or headquarters.campaign.mission.is_empty():
        return
    headquarters.campaign.finish("Extracted after Room %d" % (mission_stage + 1), units)
    room_cleared = false
    game_over = true
    show_report = false
    headquarters.open()
    queue_redraw()

func restart_game() -> void:
    # Restart always begins the full chain, not the current room.
    room_history.clear()
    unit_action_counters.clear()
    show_room_activity = false
    activity_room_page = 0
    breach_target_mode = false
    mission_victory = false
    radio_state.clear()
    radio_reinforcements_queued = false
    mission_objects.clear()
    mission_objectives.clear()
    mission_events.clear()
    mission_flags.clear()
    defence_wave_number = 0
    load_mission_room(0, [])

func load_mission_room(stage: int, carry: Array[Dictionary]) -> void:
    mission_stage = stage
    breach_target_mode = false
    loadout_action = ""
    room_cleared = false
    mission_victory = false
    if test_mission_id == "chain" and stage == 1:
        radio_state = {"pos": RADIO_POS, "hp": RADIO_HP, "max_hp": RADIO_HP, "damage": 0, "destroyed_in_time": false, "destroyed_round": -1}
        radio_reinforcements_queued = false
    else:
        radio_state.clear()
    # Three distinct maps: open kennels, fortified bunker, compact final arena.
    var layout_stage: int = stage if test_mission_id in ["chain", "assassination"] else (0 if test_mission_id in ["defence", "scythe"] else 1)
    scenario_index = 1 if layout_stage == 1 else 0
    arena_variant = 1 if layout_stage == 2 else 0
    setup_legacy_arena()
    var authored: Array[Dictionary] = []
    for idx in range(5):
        if not hq_deployment:
            authored.append(units[idx].duplicate(true))
            continue
        var id: int = hq_operative_id(idx)
        var kit: String = headquarters.campaign.roster[id]["kit"]
        var kit_index: int = headquarters.campaign.classes.find(kit)
        var operative: Dictionary = units[kit_index].duplicate(true)
        operative["kit_index"] = kit_index
        operative["kit_name"] = kit
        operative["name"] = headquarters.campaign.operative_name(id)
        operative["pos"] = units[idx]["pos"]
        authored.append(operative)
    if test_mission_id == "defence":
        # Wave controller will spawn enemies after the battle arrays initialise.
        pass
    elif test_mission_id == "scythe":
        var armoured_guard: Dictionary = make_chain_rifle("Armoured Guard", Vector2i(4, 2), true, "defensive")
        armoured_guard["max_hp"] = 9
        armoured_guard["hp"] = 9
        armoured_guard["max_armour"] = 4
        authored.append(armoured_guard)
        authored.append(make_chain_rifle("Overwatch Sentry", Vector2i(6, 2), false, "defensive"))
        authored.append(make_test_hound("Test Hound", Vector2i(8, 6)))
    elif test_mission_id in ["sabotage", "rescue"]:
        var positions: Array[Vector2i] = [Vector2i(14, 3), Vector2i(19, 3), Vector2i(16, 6), Vector2i(19, 11), Vector2i(14, 12)]
        for idx in range(positions.size()):
            authored.append(make_chain_rifle("KGB Facility Guard %d" % (idx + 1), positions[idx], idx == 2, "defensive"))
    elif test_mission_id == "assassination" and stage == 2:
        var posts: Array[Vector2i] = [Vector2i(13, 3), Vector2i(16, 4), Vector2i(15, 10), Vector2i(12, 12)]
        for idx in range(posts.size()):
            authored.append(make_chain_rifle("Orlov Bodyguard %d" % (idx + 1), posts[idx], idx < 2, "defensive"))
        var officer: Dictionary = make_chain_rifle("KGB Officer Orlov", Vector2i(13, 7), false, "self_preserving")
        officer["letter"] = "O"
        officer["hp"] = 9
        officer["max_hp"] = 9
        officer["armour"] = 1
        officer["max_armour"] = 1
        officer["damage"] = 2
        officer["mission_target"] = true
        authored.append(officer)
    elif stage == 0:
        # Seven fast experiments and a supporting KGB biotechnician.
        for idx in range(5, 12):
            authored.append(units[idx].duplicate(true))
        var medic: Dictionary = units[14].duplicate(true)
        medic["pos"] = Vector2i(14, 8)
        authored.append(medic)
    elif stage == 1:
        # Rifle-only defensive cordon with overlapping fields of fire.
        var posts: Array[Vector2i] = [Vector2i(14, 3), Vector2i(19, 3), Vector2i(16, 6), Vector2i(17, 8), Vector2i(19, 11), Vector2i(14, 12)]
        for idx in range(posts.size()):
            var stronger: bool = idx in [2, 4]
            authored.append(make_chain_rifle("KGB Defender %s" % ["A", "B", "C", "D", "E", "F"][idx], posts[idx], stronger, "defensive" if idx < 4 else "balanced"))
    else:
        # Mixed final resistance: rapid hounds, trained riflemen, one elite.
        var hound_posts: Array[Vector2i] = [Vector2i(13, 2), Vector2i(13, 7), Vector2i(14, 11)]
        for idx in range(hound_posts.size()):
            var hound: Dictionary = units[5 + idx].duplicate(true)
            hound["pos"] = hound_posts[idx]
            authored.append(hound)
        for idx in range(3):
            var rifle_posts: Array[Vector2i] = [Vector2i(16, 3), Vector2i(16, 8), Vector2i(16, 12)]
            authored.append(make_chain_rifle("KGB Rifle %s" % ["A", "B", "C"][idx], rifle_posts[idx], idx == 1, "balanced"))
        if radio_reinforcements_queued:
            # All three are new enemies, not replacements for the original three hounds.
            var alert_posts: Array[Vector2i] = [Vector2i(12, 4), Vector2i(12, 9), Vector2i(15, 13)]
            for idx in range(RADIO_EXTRA_HOUNDS):
                var extra: Dictionary = units[8 + idx].duplicate(true)
                extra["name"] = "Alert Hound %02d" % (idx + 1)
                extra["pos"] = alert_posts[idx]
                authored.append(extra)
        var elite: Dictionary = make_chain_rifle("KGB Elite Enforcer", Vector2i(14, 6), true, "aggressive")
        elite["letter"] = "X"
        elite["hp"] = 15
        elite["max_hp"] = 15
        elite["armour"] = 4
        elite["max_armour"] = 4
        elite["ap"] = 3
        elite["max_ap"] = 3
        elite["damage"] = 3
        elite["range"] = 6
        elite["ai_traits"] = {"self_preservation": 0.9}
        authored.append(elite)
    units = authored
    for idx in range(units.size()):
        units[idx]["id"] = idx  # IDs and battle-stat indices always match.
        if idx < 5:
            if hq_deployment:
                var id: int = hq_operative_id(idx)
                StarterLoadouts.equip(units[idx], headquarters.campaign.mission["gear"][id])
            else:
                StarterLoadouts.equip(units[idx], mission_loadouts[idx])
        if idx == 0 and test_mission_id == "scythe":
            units[idx]["special"] = SCYTHE_CHARGE_NAME
            units[idx]["scythe_origin"] = scythe_origin
            if scythe_origin == "Wolverine":
                units[idx]["melee_weapon"] = WOLVERINE_CLAWS
                units[idx]["melee_damage"] = 2
            elif scythe_origin == "Arachnid":
                units[idx]["move"] = MOVE_DISTANCE + SPIDER_AGILITY_BONUS
            elif scythe_origin == "Blink":
                units[idx]["blink_used_turn"] = -1
        fill_magazine(units[idx])
        units[idx]["special_used_turn"] = -99
        units[idx]["special_ready_turn"] = -99
        units[idx]["stim_bonus"] = 0
        units[idx]["jammed_actions"] = 0
        units[idx]["reaction_type"] = ""
        units[idx]["reaction_available"] = false
        units[idx]["ap"] = int(units[idx]["max_ap"])
        if not units[idx].has("move"):
            units[idx]["move"] = MOVE_DISTANCE
        if idx < 5:
            units[idx]["downs"] = 0
            units[idx]["recovery_round"] = 0
            units[idx]["permanently_dead"] = false
            if carry.size() == 5:
                units[idx]["hp"] = int(carry[idx]["hp"])
                units[idx]["downs"] = int(carry[idx]["downs"])
                units[idx]["permanently_dead"] = bool(carry[idx]["permanently_dead"])
                units[idx]["medkit_charges"] = int(carry[idx].get("medkit_charges", units[idx]["medkit_charges"]))
            if int(units[idx]["hp"]) <= 0:
                units[idx]["ap"] = 0
        units[idx]["armour"] = int(units[idx]["max_armour"]) if armour_enabled and int(units[idx]["hp"]) > 0 else 0
    for i in range(units.size()):
        assert(not walls.has(units[i]["pos"]), "Room unit starts in wall")
        for j in range(i):
            if int(units[i]["hp"]) > 0 and int(units[j]["hp"]) > 0:
                assert(units[i]["pos"] != units[j]["pos"], "Room living units overlap")
    for idx in range(units.size()):
        var class_weight: int = 1 if str(units[idx].get("kind", "")) == "horde" else 2
        if operative_kit(idx) == 1 or str(units[idx].get("name", "")) == "KGB Elite Enforcer":
            class_weight = 3
        units[idx]["weight"] = class_weight
        units[idx]["statuses"] = {}
        units[idx]["breach_used_turn"] = -99
    setup_environment_for_room(layout_stage)
    reset_room_statistics()
    setup_test_objectives()
    if test_mission_id == "defence":
        spawn_defence_wave(1)
    elif test_mission_id == "scythe":
        reserve_reaction(6, "overwatch")
    selected_id = -1
    for idx in range(5):
        if int(units[idx]["hp"]) > 0:
            selected_id = idx
            break
    status_message = "%s — %s" % [mission_room_label(mission_stage), get_objective_progress_line()]
    if test_mission_id == "chain" and stage == 1:
        status_message = "Room 2: destroy the 2-HP radio by end of player turn 3, or Room 3 gains 3 hounds. Clear enemies to advance."
        add_log("SECONDARY: Destroy Radio Transmitter in 3 player turns (optional for clearance).")
    elif test_mission_id == "chain" and stage == 2 and radio_reinforcements_queued:
        status_message = "The radio alert succeeded: THREE EXTRA HOUNDS have joined Room 3."
        add_log("ALERT CONSEQUENCE: three additional hounds in the final room.")
    add_log("%s — room %d/%d begins." % [test_mission_id.to_upper(), mission_stage + 1, mission_room_total()])
    if hq_deployment:
        print("HQ operation %s: entered room %d/%d." % [test_mission_id, mission_stage + 1, mission_room_total()])
    queue_redraw()

func make_chain_rifle(label: String, at: Vector2i, stronger: bool, profile: String) -> Dictionary:
    var max_health: int = 8 if stronger else 6
    var max_protection: int = 2 if stronger else 1
    return {"id": -1, "team": "enemy", "kind": "ranged", "name": label, "letter": label.substr(label.length() - 1), "pos": at, "hp": max_health, "max_hp": max_health, "ap": 2, "max_ap": 2, "damage": 3 if stronger else 2, "range": 6, "move": MOVE_DISTANCE, "armour": max_protection, "max_armour": max_protection, "basic_attack": "KGB Service Rifle", "ai_profile": profile, "ai_role": "combatant", "ai_traits": {"self_preservation": 1.15}}

func reset_room_statistics() -> void:
    unit_action_counters.clear()
    battle_stats.clear()
    ability_damage_totals.clear()
    ability_use_totals.clear()
    damage_history.clear()
    damage_floaters.clear()
    for _unit in units:
        battle_stats.append({"dealt_hp": 0, "dealt_arm": 0, "taken_hp": 0, "taken_arm": 0, "tiles": 0, "kills": 0, "attacks": 0, "healing": 0, "buffs": 0, "ability_uses": 0, "reactions": 0})
        unit_action_counters.append({"moves": 0, "basic_attacks": 0, "overwatch_set": 0, "objective_damage": 0, "env_triggers": 0, "cover_broken": 0, "named_abilities": {}})
    show_room_activity = false
    activity_room_page = maxi(0, mission_stage)
    show_hit_ledger = false
    ledger_scroll = 0
    movement_task.clear()
    movement_tick = 0.0

func save_room_result(advances: bool = false) -> void:
    var after_hp: Array[int] = []
    for i in range(5):
        after_hp.append(int(units[i]["hp"]))
    var radio_result: String = "NOT APPLICABLE"
    if test_mission_id == "chain" and mission_stage == 1:
        if bool(radio_state.get("destroyed_in_time", false)):
            radio_result = "DESTROYED ON TIME"
        elif radio_reinforcements_queued:
            radio_result = "ALERT SENT (+3 HOUNDS)"
        else:
            radio_result = "ALERT NOT SENT"
    var activity: Array[Dictionary] = []
    var carry: Array[Dictionary] = carry_squad_to_next_room()
    for idx in range(5):
        var unit: Dictionary = units[idx]
        var counters: Dictionary = unit_action_counters[idx]
        var stats: Dictionary = battle_stats[idx]
        activity.append({
            "name": str(unit["name"]), "hp": int(unit["hp"]), "max_hp": int(unit["max_hp"]),
            "next_hp": int(carry[idx]["hp"]) if advances else int(unit["hp"]),
            "hp_cap": recoverable_hp(unit), "downs": int(carry[idx]["downs"]),
            "dead": bool(carry[idx]["permanently_dead"]),
            "moves": int(counters["moves"]), "tiles": int(stats["tiles"]),
            "basic_attacks": int(counters["basic_attacks"]),
            "overwatch_set": int(counters["overwatch_set"]),
            "overwatch_triggered": int(stats["reactions"]),
            "abilities": counters["named_abilities"].duplicate(true),
            "dealt_hp": int(stats["dealt_hp"]), "dealt_arm": int(stats["dealt_arm"]),
            "taken_hp": int(stats["taken_hp"]), "taken_arm": int(stats["taken_arm"]),
            "kills": int(stats["kills"]), "healing": int(stats["healing"]),
            "buffs": int(stats["buffs"]), "objective_damage": int(counters["objective_damage"]), "env_triggers": int(counters["env_triggers"]), "cover_broken": int(counters["cover_broken"])
        })
    room_history.append({"name": mission_room_label(mission_stage), "turns": turn_number, "player_damage": total_team_damage("player"), "enemy_damage": total_team_damage("enemy"), "hp": after_hp, "enemy_count": units.size() - 5, "enemies_defeated": defeated_enemy_count(), "radio": radio_result, "radio_bonus": radio_reinforcements_queued, "activity": activity, "advances": advances})
    activity_room_page = room_history.size() - 1

func carry_squad_to_next_room() -> Array[Dictionary]:
    var result: Array[Dictionary] = []
    for idx in range(5):
        var unit: Dictionary = units[idx]
        var health: int = int(unit["hp"])
        var downs: int = int(unit.get("downs", 0))
        var dead: bool = bool(unit.get("permanently_dead", false))
        if health <= 0 and downs == 1 and not dead:
            health = recoverable_hp(unit)
        result.append({"hp": health, "downs": downs, "permanently_dead": dead, "medkit_charges": int(unit["medkit_charges"])})
    return result

func next_mission_room() -> void:
    if not room_cleared or mission_stage >= mission_room_total() - 1 or not movement_task.is_empty():
        return
    var carry: Array[Dictionary] = carry_squad_to_next_room()
    load_mission_room(mission_stage + 1, carry)

func setup_legacy_arena() -> void:
    # Scenario 1 retains both familiar arenas; scenario 2 has a different layout,
    # roster, and a self-protecting officer with one emergency command ability.
    if scenario_index == 1:
        board_w = 22
        board_h = 16
        walls = []
        # Command-room compound: two entrance channels and a central stronghold.
        for y in range(0, 5):
            walls.append(Vector2i(9, y))
        for y in range(11, 16):
            walls.append(Vector2i(9, y))
        for x in range(13, 19):
            if x != 16:
                walls.append(Vector2i(x, 5))
        for x in range(13, 19):
            if x != 15:
                walls.append(Vector2i(x, 11))
        for block_tile in [Vector2i(11, 7), Vector2i(11, 8), Vector2i(18, 7), Vector2i(18, 8), Vector2i(5, 5), Vector2i(5, 10)]:
            walls.append(block_tile)
        cover_edges = {
            Vector2i(2, 2): {"E": 1, "S": 1},
            Vector2i(3, 5): {"N": 2, "E": 1},
            Vector2i(4, 8): {"E": 1, "S": 1},
            Vector2i(3, 12): {"N": 1, "E": 2},
            Vector2i(7, 4): {"N": 1, "E": 2},
            Vector2i(7, 8): {"W": 1, "S": 1},
            Vector2i(7, 12): {"N": 1, "E": 2},
            Vector2i(10, 5): {"N": 2, "S": 1},
            Vector2i(10, 10): {"N": 1, "E": 1},
            Vector2i(12, 3): {"E": 1, "N": 1},
            Vector2i(12, 12): {"E": 1, "S": 1},
            Vector2i(14, 7): {"N": 2, "E": 1},
            Vector2i(14, 9): {"S": 2, "E": 1},
            Vector2i(16, 7): {"N": 1, "E": 1},
            Vector2i(16, 9): {"S": 1, "W": 1},
            Vector2i(19, 4): {"W": 1, "S": 1},
            Vector2i(19, 8): {"W": 2, "N": 1},
            Vector2i(19, 12): {"W": 1, "N": 2}
        }
        var ally_tiles: Array[Vector2i] = [Vector2i(1, 2), Vector2i(1, 5), Vector2i(1, 8), Vector2i(1, 11), Vector2i(2, 14)]
        # The temporary full input list lets us reuse the same roster builder;
        # only seven escorts are then kept, plus one unique commander.
        var foe_tiles: Array[Vector2i] = [
            Vector2i(11, 4), Vector2i(12, 9), Vector2i(16, 12),
            Vector2i(20, 1), Vector2i(20, 2), Vector2i(20, 3),
            Vector2i(20, 4), Vector2i(20, 5), Vector2i(20, 6),
            Vector2i(16, 8), Vector2i(19, 3), Vector2i(19, 10),
            Vector2i(20, 13), Vector2i(18, 14)
        ]
        make_roster(ally_tiles, foe_tiles)
        make_boss_scenario_roster()
    elif arena_variant == 0:
        board_w = 22
        board_h = 16
        walls = [Vector2i(7, 3), Vector2i(11, 6), Vector2i(8, 10), Vector2i(14, 12), Vector2i(12, 2), Vector2i(17, 9)]
        cover_edges = {
            Vector2i(2, 2): {"E": 1, "N": 1},
            Vector2i(2, 6): {"E": 1, "S": 1},
            Vector2i(2, 10): {"E": 1, "N": 1},
            Vector2i(3, 13): {"E": 2, "S": 1},
            Vector2i(4, 3): {"E": 1, "N": 2},
            Vector2i(4, 8): {"E": 1, "S": 1},
            Vector2i(4, 12): {"E": 1, "N": 1},
            Vector2i(6, 5): {"E": 2, "N": 1},
            Vector2i(6, 9): {"E": 1, "S": 1},
            Vector2i(7, 13): {"N": 2, "E": 1},
            Vector2i(8, 2): {"S": 1, "E": 1},
            Vector2i(8, 6): {"W": 1, "S": 2},
            Vector2i(9, 11): {"E": 1, "S": 1},
            Vector2i(10, 4): {"E": 1, "N": 1},
            Vector2i(10, 8): {"W": 2, "S": 1},
            Vector2i(11, 13): {"E": 1, "N": 1},
            Vector2i(12, 5): {"E": 1, "S": 1},
            Vector2i(12, 10): {"W": 1, "N": 2},
            Vector2i(13, 2): {"E": 2, "S": 1},
            Vector2i(13, 7): {"E": 1, "S": 1},
            Vector2i(14, 14): {"N": 2, "E": 1},
            Vector2i(15, 4): {"W": 1, "N": 1},
            Vector2i(15, 9): {"E": 1, "S": 1},
            Vector2i(16, 12): {"W": 2, "N": 1},
            Vector2i(17, 2): {"W": 1, "S": 2},
            Vector2i(17, 6): {"W": 1, "N": 1},
            Vector2i(18, 10): {"W": 2, "S": 1},
            Vector2i(19, 4): {"W": 1, "S": 1},
            Vector2i(19, 8): {"W": 1, "N": 1},
            Vector2i(19, 13): {"W": 1, "N": 2}
        }
        var ally_tiles: Array[Vector2i] = [Vector2i(1, 2), Vector2i(1, 5), Vector2i(1, 8), Vector2i(1, 11), Vector2i(2, 14)]
        # Nine fast-moving experiments, one support technician and four riflemen.
        var foe_tiles: Array[Vector2i] = [
            Vector2i(15, 1), Vector2i(17, 2), Vector2i(16, 4),
            Vector2i(18, 5), Vector2i(16, 7), Vector2i(18, 8),
            Vector2i(16, 10), Vector2i(18, 12), Vector2i(16, 14),
            Vector2i(14, 7), Vector2i(20, 1), Vector2i(20, 4),
            Vector2i(20, 11), Vector2i(20, 14)
        ]
        make_roster(ally_tiles, foe_tiles)
    else:
        board_w = 18
        board_h = 14
        walls = [Vector2i(5, 2), Vector2i(9, 5), Vector2i(7, 9), Vector2i(13, 11)]
        cover_edges = {
            Vector2i(2, 2): {"E": 1, "N": 1},
            Vector2i(2, 6): {"E": 1, "S": 1},
            Vector2i(3, 10): {"E": 2, "N": 1},
            Vector2i(4, 4): {"E": 1, "S": 2},
            Vector2i(5, 7): {"E": 1, "N": 1},
            Vector2i(5, 11): {"E": 1, "S": 1},
            Vector2i(7, 3): {"E": 2, "N": 1},
            Vector2i(7, 6): {"E": 1, "S": 1},
            Vector2i(8, 11): {"E": 1, "N": 2},
            Vector2i(10, 2): {"W": 1, "S": 1},
            Vector2i(10, 7): {"W": 2, "N": 1},
            Vector2i(11, 10): {"E": 1, "S": 1},
            Vector2i(12, 4): {"E": 1, "N": 1},
            Vector2i(12, 8): {"E": 1, "S": 1},
            Vector2i(14, 1): {"W": 1, "S": 1},
            Vector2i(14, 6): {"W": 2, "N": 1},
            Vector2i(14, 10): {"W": 1, "S": 1},
            Vector2i(16, 4): {"W": 1, "S": 1},
            Vector2i(16, 8): {"W": 1, "N": 1}
        }
        var ally_tiles: Array[Vector2i] = [Vector2i(1, 1), Vector2i(1, 4), Vector2i(1, 7), Vector2i(1, 10), Vector2i(2, 12)]
        var foe_tiles: Array[Vector2i] = [
            Vector2i(12, 1), Vector2i(14, 2), Vector2i(13, 4),
            Vector2i(15, 5), Vector2i(13, 7), Vector2i(15, 8),
            Vector2i(13, 10), Vector2i(15, 11), Vector2i(12, 12),
            Vector2i(13, 8), Vector2i(16, 1), Vector2i(16, 4),
            Vector2i(16, 9), Vector2i(16, 12)
        ]
        make_roster(ally_tiles, foe_tiles)
    # Explicit test setup must never start units inside solid walls or overlap.
    for i in range(units.size()):
        assert(not walls.has(units[i]["pos"]), "Unit spawned in wall")
        for j in range(i):
            assert(units[i]["pos"] != units[j]["pos"], "Units spawned on same tile")
    if not armour_enabled:
        for i in range(units.size()):
            units[i]["armour"] = 0
    movement_task.clear()
    movement_tick = 0.0
    show_hit_ledger = false
    breach_target_mode = false
    ledger_scroll = 0
    damage_history.clear()
    damage_floaters.clear()
    battle_stats.clear()
    ability_damage_totals.clear()
    ability_use_totals.clear()
    for unit in units:
        battle_stats.append({"dealt_hp": 0, "dealt_arm": 0, "taken_hp": 0, "taken_arm": 0, "tiles": 0, "kills": 0, "attacks": 0, "healing": 0, "buffs": 0, "ability_uses": 0, "reactions": 0})
    special_mode = false
    shred_landing_tile = Vector2i(-1, -1)
    show_report = false
    selected_id = 0
    hovered_tile = Vector2i(-1, -1)
    side_to_play = "player"
    game_over = false
    winner = ""
    turn_number = 1
    enemy_action_order.clear()
    enemy_action_cursor = 0
    enemy_action_timer = 0.0
    enemy_action_count = 0
    last_acting_enemy = -1
    ai_focus_id = -1
    ai_last_decision = ""
    ai_move_count = 0
    ai_shot_count = 0
    ai_flank_count = 0
    action_log.clear()
    status_message = "Build 10: all light/reinforced cover is destructible; 1 AP abilities; green attack links."
    add_log("Scenario: %s. Armour %s." % [active_arena_name(), "ON" if armour_enabled else "OFF"])
    queue_redraw()

func make_roster(allies: Array[Vector2i], enemies: Array[Vector2i]) -> void:
    # One signature ability per player for initial class interaction testing.
    # Stats are intentionally provisional; 2D tokens remain placeholders.
    units = [
        {"id": 0, "team": "player", "name": "Scythe", "letter": "S", "pos": allies[0], "hp": 9, "max_hp": 9, "ap": 3, "max_ap": 3, "damage": 3, "range": 4, "armour": 2, "max_armour": 2, "basic_attack": "Scythe Carbine", "special": "Area Shred"},
        {"id": 1, "team": "player", "name": "Anvil", "letter": "A", "pos": allies[1], "hp": 11, "max_hp": 11, "ap": 3, "max_ap": 3, "damage": 2, "range": 5, "armour": 3, "max_armour": 3, "basic_attack": "Anvil SMG", "special": "Fortify"},
        {"id": 2, "team": "player", "name": "Needle", "letter": "N", "pos": allies[2], "hp": 8, "max_hp": 8, "ap": 3, "max_ap": 3, "damage": 3, "range": 8, "armour": 1, "max_armour": 1, "basic_attack": "Needle Rifle", "special": "Precision Shot"},
        {"id": 3, "team": "player", "name": "Iskra", "letter": "I", "pos": allies[3], "hp": 8, "max_hp": 8, "ap": 3, "max_ap": 3, "damage": 2, "range": 6, "armour": 1, "max_armour": 1, "basic_attack": "Iskra Carbine", "special": "Arc Disruptor"},
        {"id": 4, "team": "player", "name": "Alkhimik", "letter": "K", "pos": allies[4], "hp": 9, "max_hp": 9, "ap": 3, "max_ap": 3, "damage": 2, "range": 5, "armour": 2, "max_armour": 2, "basic_attack": "Alkhimik Sidearm", "special": "Field Treatment"}
    ]
    for n in range(9):
        units.append({"id": 5 + n, "team": "enemy", "kind": "horde", "name": "Experiment %02d" % (n + 1), "letter": "H", "pos": enemies[n], "hp": 4, "max_hp": 4, "ap": 2, "max_ap": 2, "damage": 2, "range": 1, "move": HORDE_MOVE_DISTANCE, "armour": 0, "max_armour": 0, "basic_attack": "Ravenous Bite", "ai_profile": "horde", "ai_role": "melee", "ai_traits": {"self_preservation": 0.0}})
    units.append({"id": 14, "team": "enemy", "kind": "support", "name": "KGB Biotechnician", "letter": "+", "pos": enemies[9], "hp": 7, "max_hp": 7, "ap": 2, "max_ap": 2, "damage": 1, "range": 5, "move": MOVE_DISTANCE, "armour": 1, "max_armour": 1, "basic_attack": "Support Pistol", "ai_profile": "self_preserving", "ai_role": "medic", "ai_traits": {"self_preservation": 1.5}})
    var guards: Array[Dictionary] = [
        {"name": "KGB Guard A", "letter": "A", "hp": 6, "damage": 2, "range": 5, "armour": 2, "basic_attack": "KGB Rifle", "ai_profile": "balanced"},
        {"name": "KGB Guard B", "letter": "B", "hp": 6, "damage": 2, "range": 5, "armour": 1, "basic_attack": "KGB Rifle", "ai_profile": "defensive"},
        {"name": "KGB Rifle C", "letter": "C", "hp": 7, "damage": 3, "range": 6, "armour": 1, "basic_attack": "KGB Rifle", "ai_profile": "aggressive"},
        {"name": "KGB Officer D", "letter": "D", "hp": 7, "damage": 2, "range": 6, "armour": 2, "basic_attack": "Officer Sidearm", "ai_profile": "self_preserving"}
    ]
    for n in range(guards.size()):
        var info: Dictionary = guards[n]
        units.append({"id": 15 + n, "team": "enemy", "kind": "ranged", "name": str(info["name"]), "letter": str(info["letter"]), "pos": enemies[10+n], "hp": int(info["hp"]), "max_hp": int(info["hp"]), "ap": 2, "max_ap": 2, "damage": int(info["damage"]), "range": int(info["range"]), "move": MOVE_DISTANCE, "armour": int(info["armour"]), "max_armour": int(info["armour"]), "basic_attack": str(info["basic_attack"]), "ai_profile": str(info["ai_profile"]), "ai_role": "combatant", "ai_traits": {"self_preservation": 1.4 if n == 3 else 1.0}})
    for idx in range(units.size()):
        units[idx]["special_used_turn"] = -99
        units[idx]["special_ready_turn"] = -99
        units[idx]["stim_bonus"] = 0
        units[idx]["jammed_actions"] = 0
        units[idx]["fortify_turn"] = -99
        units[idx]["treated_turn"] = -99
        units[idx]["reaction_type"] = ""
        units[idx]["reaction_available"] = false
        if not units[idx].has("move"):
            units[idx]["move"] = MOVE_DISTANCE

func active_arena_name() -> String:
    return mission_room_label(mission_stage)

func make_boss_scenario_roster() -> void:
    # Keep the five normal rebels, three hounds, one medic and three KGB rifles.
    # The unique officer is a high-value but not invulnerable mini-boss.
    var chosen: Array[Dictionary] = []
    for idx in [0, 1, 2, 3, 4, 5, 6, 7, 14, 15, 16, 17]:
        chosen.append(units[idx].duplicate(true))
    chosen.append({"id": 19, "team": "enemy", "kind": "boss", "name": "KGB Commander Voronov", "letter": "V", "pos": Vector2i(16, 8), "hp": 15, "max_hp": 15, "ap": 2, "max_ap": 2, "damage": 3, "range": 6, "move": 4, "armour": 4, "max_armour": 4, "basic_attack": "Command Rifle", "ai_profile": "self_preserving", "ai_role": "boss", "ai_traits": {"self_preservation": 1.45}, "boss_emergency_used": false})
    # The medic's authored spawn was (16,8); relocate it behind bunker cover.
    chosen[8]["pos"] = Vector2i(15, 9)
    # The third hound must not start in the newly created south bunker wall.
    units = chosen
    for idx in range(units.size()):
        units[idx]["special_used_turn"] = -99
        units[idx]["special_ready_turn"] = -99
        units[idx]["stim_bonus"] = 0
        units[idx]["jammed_actions"] = 0
        units[idx]["reaction_type"] = ""
        units[idx]["reaction_available"] = false
        if not units[idx].has("move"):
            units[idx]["move"] = MOVE_DISTANCE


func add_log(message: String) -> void:
    action_log.push_front(message)
    while action_log.size() > 7:
        action_log.pop_back()

func is_in_bounds(tile: Vector2i) -> bool:
    return tile.x >= 0 and tile.x < board_w and tile.y >= 0 and tile.y < board_h

func find_unit_at(tile: Vector2i, include_downed: bool = false) -> int:
    for idx in range(units.size()):
        var unit: Dictionary = units[idx]
        if unit["pos"] == tile and (int(unit["hp"]) > 0 or (include_downed and int(unit.get("recovery_round", 0)) > 0)):
            return idx
    return -1

func find_unit_by_id(unit_id: int) -> int:
    for idx in range(units.size()):
        if int(units[idx]["id"]) == unit_id:
            return idx
    return -1

func tile_is_open(tile: Vector2i, ignore_id: int = -1) -> bool:
    if not is_in_bounds(tile) or walls.has(tile):
        return false
    # A standing radio transmitter occupies one tile; it can be walked over
    # only after it is destroyed. The device is NOT a kill-required enemy.
    if radio_is_active() and tile == RADIO_POS:
        return false
    if mission_object_at(tile):
        return false
    if barrel_is_active(tile):
        return false
    var occupant := find_unit_at(tile, true)
    return occupant < 0 or int(units[occupant]["id"]) == ignore_id

func reachable(start: Vector2i, limit: int, ignore_id: int) -> Dictionary:
    # Breadth-first search through tiles unoccupied by walls, objects or units.
    var distances: Dictionary = {start: 0}
    var frontier: Array[Vector2i] = [start]
    var head: int = 0
    while head < frontier.size():
        var cell: Vector2i = frontier[head]
        head += 1
        var current_steps: int = int(distances[cell])
        if current_steps >= limit:
            continue
        for delta in DIRECTIONS:
            var next_tile: Vector2i = cell + delta
            if tile_is_open(next_tile, ignore_id) and not distances.has(next_tile):
                distances[next_tile] = current_steps + 1
                frontier.append(next_tile)
    return distances

func refill_armour_for_team(team: String) -> void:
    # At the beginning of each faction phase, each living unit of that faction
    # gets its entire armour pool back; lost HP does not regenerate.
    for i in range(units.size()):
        if units[i]["team"] != team or int(units[i]["hp"]) <= 0:
            continue
        var max_value: int = int(units[i]["max_armour"])
        var new_value: int = max_value if armour_enabled else 0
        var previous: int = int(units[i]["armour"])
        units[i]["armour"] = new_value
        if new_value > previous:
            add_log("%s ARM refresh: %d -> %d." % [str(units[i]["name"]), previous, new_value])

func grid_distance(a: Vector2i, b: Vector2i) -> int:
    return absi(a.x - b.x) + absi(a.y - b.y)

func has_line_of_sight(from_tile: Vector2i, target_tile: Vector2i) -> bool:
    # Basic grid ray tracing. Walls block shots, units do not (yet).
    var steps: int = maxi(absi(target_tile.x - from_tile.x), absi(target_tile.y - from_tile.y))
    if steps == 0:
        return true
    var last_tile: Vector2i = from_tile
    for step in range(1, steps):
        var fraction: float = float(step) / float(steps)
        var tile := Vector2i(
            roundi(lerpf(float(from_tile.x), float(target_tile.x), fraction)),
            roundi(lerpf(float(from_tile.y), float(target_tile.y), fraction))
        )
        if tile == last_tile:
            continue
        if walls.has(tile):
            return false
        last_tile = tile
    return true

func attacked_side(attacker_tile: Vector2i, defender_tile: Vector2i) -> String:
    # Dominant axis chooses an edge; horizontal wins exact diagonal ties.
    var dx: int = attacker_tile.x - defender_tile.x
    var dy: int = attacker_tile.y - defender_tile.y
    if absi(dx) >= absi(dy):
        return "E" if dx > 0 else "W"
    return "S" if dy > 0 else "N"

func tile_offset_for_face(face: String) -> Vector2i:
    match face:
        "N": return Vector2i(0, -1)
        "S": return Vector2i(0, 1)
        "W": return Vector2i(-1, 0)
        "E": return Vector2i(1, 0)
    return Vector2i.ZERO

func opposing_face(face: String) -> String:
    match face:
        "N": return "S"
        "S": return "N"
        "W": return "E"
        "E": return "W"
    return ""

func shared_cover_on_side(tile: Vector2i, face: String) -> int:
    # Two adjacent tiles share one physical cover barrier, whether the barrier
    # was authored on tile A's E edge or tile B's W edge (and analogously N/S).
    # This check also handles legacy layouts storing each edge on only one tile.
    var own_edges: Dictionary = cover_edges.get(tile, {})
    var cover: int = int(own_edges.get(face, 0))
    var neighbour: Vector2i = tile + tile_offset_for_face(face)
    if is_in_bounds(neighbour):
        var neighbour_edges: Dictionary = cover_edges.get(neighbour, {})
        cover = maxi(cover, int(neighbour_edges.get(opposing_face(face), 0)))
    return cover

func tile_has_adjacent_cover(tile: Vector2i) -> bool:
    for face in ["N", "E", "S", "W"]:
        if shared_cover_on_side(tile, face) > 0:
            return true
    return false

func cover_level_at(defender_tile: Vector2i, attacker_tile: Vector2i) -> int:
    # Cover is checked on the shared edge facing the attacker, rather than
    # only on the defender's tile. Eg. (6,2):S protects a unit at (6,3)
    # from shots coming from the NORTH, and also protects a unit at (6,2)
    # from shots coming from the SOUTH.
    return mini(2, shared_cover_on_side(defender_tile, attacked_side(attacker_tile, defender_tile)))

func radio_is_present() -> bool:
    return test_mission_id == "chain" and mission_stage == 1 and not radio_state.is_empty()

func radio_is_active() -> bool:
    return radio_is_present() and int(radio_state.get("hp", 0)) > 0

func fill_magazine(unit: Dictionary) -> void:
    var default_capacity: int = 0 if unit.get("kind", "") == "horde" else DEFAULT_MAGAZINE_CAPACITY
    unit["magazine_capacity"] = int(unit.get("magazine_capacity", default_capacity))
    unit["rounds"] = int(unit["magazine_capacity"])

func has_attack_ammo(idx: int) -> bool:
    var unit: Dictionary = units[idx]
    return int(unit["magazine_capacity"]) == 0 or int(unit["rounds"]) > 0

func spend_shot(idx: int) -> bool:
    if not has_attack_ammo(idx):
        return false
    if int(units[idx]["magazine_capacity"]) > 0:
        units[idx]["rounds"] = int(units[idx]["rounds"]) - 1
    return true

func reload_weapon(idx: int) -> bool:
    var unit: Dictionary = units[idx]
    if int(unit["hp"]) <= 0 or int(unit["ap"]) < RELOAD_AP_COST or int(unit["rounds"]) >= int(unit["magazine_capacity"]):
        return false
    unit["ap"] = int(unit["ap"]) - RELOAD_AP_COST
    fill_magazine(unit)
    status_message = "%s reloads %s (%d/%d)." % [str(unit["name"]), str(unit["basic_attack"]), int(unit["rounds"]), int(unit["magazine_capacity"])]
    add_log(status_message)
    queue_redraw()
    return true

func reload_selected_weapon() -> void:
    var idx: int = find_unit_by_id(selected_id)
    if idx < 0 or int(units[idx]["hp"]) <= 0:
        return
    if reload_weapon(idx):
        loadout_action = ""
        special_mode = false
        breach_target_mode = false
        shred_landing_tile = Vector2i(-1, -1)
    elif int(units[idx]["rounds"]) == int(units[idx]["magazine_capacity"]):
        status_message = "Magazine already full."
    else:
        status_message = "Reload needs %d AP." % RELOAD_AP_COST
    queue_redraw()

func emergency_reload() -> void:
    var idx: int = find_unit_by_id(selected_id)
    if idx < 0 or int(units[idx]["hp"]) <= 0:
        status_message = "Select a living operative."
    elif not headquarters.campaign.mission.get("emergency_reload", false):
        status_message = "Emergency Reload is unprepared or already spent."
    elif int(units[idx]["rounds"]) >= int(units[idx]["magazine_capacity"]):
        status_message = "Magazine already full."
    elif not headquarters.campaign.use_emergency_reload():
        status_message = "Emergency Reload requires %d Intel." % Headquarters.State.RELOAD_COST
    else:
        fill_magazine(units[idx])
        status_message = "Emergency Reload refilled %s's magazine." % str(units[idx]["name"])
        add_log(status_message)
    queue_redraw()

func radio_attack_preview(attacker_idx: int) -> Dictionary:
    var result: Dictionary = {"valid": false, "reason": "Radio unavailable", "damage": 0, "melee": false, "distance": 0}
    if not radio_is_active() or attacker_idx < 0 or attacker_idx >= units.size():
        return result
    var unit: Dictionary = units[attacker_idx]
    if unit["team"] != "player" or int(unit["hp"]) <= 0:
        return result
    var dist: int = grid_distance(unit["pos"], RADIO_POS)
    result["distance"] = dist
    if dist == 1:
        # Anyone immediately adjacent may strike the transmitter for 1 AP.
        result["valid"] = true
        result["melee"] = true
        result["damage"] = mini(2 + int(unit.get("stim_bonus", 0)), int(radio_state["hp"]))
        result["reason"] = "Adjacent melee strike (1 AP)"
    elif dist <= int(unit["range"]) and has_line_of_sight(unit["pos"], RADIO_POS):
        if not has_attack_ammo(attacker_idx):
            result["reason"] = EMPTY_MAGAZINE
            return result
        result["valid"] = true
        result["damage"] = mini(int(unit["damage"]) + int(unit.get("stim_bonus", 0)), int(radio_state["hp"]))
        result["reason"] = "Ranged attack (1 AP)"
    elif dist > int(unit["range"]):
        result["reason"] = "Radio outside weapon range"
    else:
        result["reason"] = "Wall blocks shot to radio"
    return result

func queue_radio_alert(cause: String) -> void:
    if mission_stage != 1 or radio_reinforcements_queued or bool(radio_state.get("destroyed_in_time", false)):
        return
    radio_reinforcements_queued = true
    status_message = "RADIO ALERT SENT! Room 3 gains three additional hounds."
    add_log("RADIO ALERT SENT (%s): Room 3 will contain +3 hounds." % cause)

func hit_radio(attacker_idx: int, raw_damage: int, attack_name: String, cost: int) -> bool:
    if not radio_is_active() or attacker_idx < 0 or int(units[attacker_idx]["ap"]) < cost:
        return false
    var actual: int = mini(int(radio_state["hp"]), maxi(0, raw_damage))
    if actual <= 0:
        return false
    units[attacker_idx]["ap"] = int(units[attacker_idx]["ap"]) - cost
    radio_state["hp"] = int(radio_state["hp"]) - actual
    radio_state["damage"] = int(radio_state["damage"]) + actual
    unit_action_counters[attacker_idx]["objective_damage"] = int(unit_action_counters[attacker_idx]["objective_damage"]) + actual
    if cost > 0:
        unit_action_counters[attacker_idx]["basic_attacks"] = int(unit_action_counters[attacker_idx]["basic_attacks"]) + 1
    battle_stats[attacker_idx]["attacks"] = int(battle_stats[attacker_idx]["attacks"]) + 1
    # The Area Shred action has already been counted on activation.
    # Normal radio attacks count as their own single ability/attack use.
    if cost > 0:
        record_ability_use(attacker_idx, attack_name)
    # Objective damage has its own ledger category and is excluded from combat-
    # damage totals so HP+armour reconciliation still measures unit damage only.
    damage_history.append({"number": damage_history.size() + 1, "round": turn_number, "team": "objective", "attacker": str(units[attacker_idx]["name"]), "defender": "Radio Transmitter", "ability": attack_name, "arm": 0, "hp": actual, "cover": 0, "running": int(radio_state["damage"])})
    damage_floaters.append({"pos": RADIO_POS, "arm": 0, "hp": actual, "ttl": DAMAGE_FLOAT_SECONDS})
    status_message = "%s hits RADIO TX for %d damage: %d/%d HP left." % [str(units[attacker_idx]["name"]), actual, int(radio_state["hp"]), RADIO_HP]
    add_log(status_message)
    if int(radio_state["hp"]) == 0:
        radio_state["destroyed_round"] = turn_number
        radio_state["destroyed_in_time"] = not radio_reinforcements_queued and turn_number <= RADIO_DEADLINE_ROUND
        if bool(radio_state["destroyed_in_time"]):
            status_message = "RADIO DISABLED on time! Room 3 will have its original enemy lineup."
        else:
            status_message = "RADIO DESTROYED TOO LATE — Room 3 reinforcement call was already sent."
        add_log(status_message)
    queue_redraw()
    return true

func attack_radio(attacker_idx: int) -> void:
    var preview: Dictionary = radio_attack_preview(attacker_idx)
    if not bool(preview["valid"]):
        status_message = str(preview["reason"])
        return
    if int(units[attacker_idx]["ap"]) < 1:
        status_message = "Attacking the transmitter costs 1 AP."
        return
    var attack_name: String = "Relay Melee" if bool(preview["melee"]) else str(units[attacker_idx]["basic_attack"])
    if not bool(preview["melee"]) and not spend_shot(attacker_idx):
        return
    if hit_radio(attacker_idx, int(preview["damage"]), attack_name, 1):
        units[attacker_idx]["stim_bonus"] = 0

func attack_preview(attacker_index: int, target_index: int, bonus_damage: int = 0, pierce: int = 0) -> Dictionary:
    if attacker_index < 0 or attacker_index >= units.size():
        return {"valid": false, "reason": "Invalid attacker", "damage": 0, "armour_damage": 0, "hp_damage": 0, "cover": 0, "base": 0, "side": ""}
    return attack_preview_from(attacker_index, target_index, units[attacker_index]["pos"], bonus_damage, pierce)

func attack_preview_from(attacker_index: int, target_index: int, from_tile: Vector2i, bonus_damage: int = 0, pierce: int = 0) -> Dictionary:
    # Shared deterministic calculation used for actual and hypothetical attacks.
    var result: Dictionary = {"valid": false, "reason": "Invalid target", "damage": 0, "armour_damage": 0, "hp_damage": 0, "cover": 0, "base": 0, "side": ""}
    if attacker_index < 0 or target_index < 0 or attacker_index == target_index:
        return result
    var attacker: Dictionary = units[attacker_index]
    var target: Dictionary = units[target_index]
    if int(attacker["hp"]) <= 0 or int(target["hp"]) <= 0 or attacker["team"] == target["team"]:
        return result
    if not has_attack_ammo(attacker_index):
        result["reason"] = EMPTY_MAGAZINE
        return result
    result["base"] = int(attacker["damage"]) + bonus_damage + int(attacker.get("stim_bonus", 0))
    result["side"] = attacked_side(from_tile, target["pos"])
    if grid_distance(from_tile, target["pos"]) > int(attacker["range"]):
        result["reason"] = "Out of range"
        return result
    if not has_line_of_sight(from_tile, target["pos"]):
        result["reason"] = "Solid wall blocks line of sight"
        return result
    # Close-combat bites / charges ignore cover; cover protects against fire.
    var melee: bool = str(attacker.get("kind", "")) == "horde"
    var cover: int = 0 if melee else maxi(0, cover_level_at(target["pos"], from_tile) - pierce)
    result["valid"] = true
    result["cover"] = cover
    result["damage"] = maxi(1, int(result["base"]) - cover)
    # Cover reduces impact first; armour absorbs remaining impact, then HP.
    # This preview is shared by real attacks and hypothetical movement previews.
    var remaining_armour: int = int(target["armour"])
    result["armour_damage"] = mini(remaining_armour, int(result["damage"]))
    result["hp_damage"] = mini(int(target["hp"]), maxi(0, int(result["damage"]) - int(result["armour_damage"])))
    result["reason"] = "Melee ignores cover" if melee else ("Flanking / unprotected" if cover == 0 else ("Half cover" if cover == 1 else "Full cover"))
    return result

func can_attack(attacker_index: int, target_index: int) -> bool:
    return bool(attack_preview(attacker_index, target_index)["valid"])

func record_ability_use(actor_idx: int, ability_name: String) -> void:
    # Only named signature abilities go in the player's ability-usage summary.
    # Ordinary weapon attacks already have their own action counter.
    if actor_idx < 5 and ability_name in [str(units[actor_idx].get("special", "")), BREACH_ACTION_NAME, StarterLoadouts.MEDKIT_NAME, SHORT_BLINK]:
        var counts: Dictionary = unit_action_counters[actor_idx]["named_abilities"]
        counts[ability_name] = int(counts.get(ability_name, 0)) + 1
    battle_stats[actor_idx]["ability_uses"] = int(battle_stats[actor_idx]["ability_uses"]) + 1
    var key: String = ("REBEL | " if units[actor_idx]["team"] == "player" else "ENEMY | ") + ability_name
    ability_use_totals[key] = int(ability_use_totals.get(key, 0)) + 1

func shortest_tile_path(start: Vector2i, destination: Vector2i, ignore_id: int) -> Array[Vector2i]:
    # Reconstruct a true shortest traversable path, not a teleport to the end.
    var result: Array[Vector2i] = []
    if start == destination:
        return result
    var distances: Dictionary = reachable(start, board_w * board_h, ignore_id)
    if not distances.has(destination):
        return result
    var cursor: Vector2i = destination
    while cursor != start:
        result.push_front(cursor)
        var previous: Vector2i = cursor
        for step in DIRECTIONS:
            var neighbour: Vector2i = cursor + step
            if distances.has(neighbour) and int(distances[neighbour]) == int(distances[cursor]) - 1:
                previous = neighbour
                break
        if previous == cursor:
            result.clear()
            return result
        cursor = previous
    return result

func start_unit_movement(unit_idx: int, destination: Vector2i, ap_cost: int = 1, on_arrival: Dictionary = {}) -> void:
    if not movement_task.is_empty():
        return
    var path: Array[Vector2i] = shortest_tile_path(units[unit_idx]["pos"], destination, int(units[unit_idx]["id"]))
    if destination != units[unit_idx]["pos"] and path.is_empty():
        status_message = "No safe traversable path to that square."
        return
    if int(units[unit_idx]["ap"]) < ap_cost:
        return
    units[unit_idx]["ap"] = int(units[unit_idx]["ap"]) - ap_cost
    if ap_cost > 0 and not path.is_empty():
        unit_action_counters[unit_idx]["moves"] = int(unit_action_counters[unit_idx]["moves"]) + 1
    movement_task = {"unit_idx": unit_idx, "path": path, "cursor": 0, "after": on_arrival}
    movement_tick = 0.03
    if path.is_empty():
        complete_movement_task()

func move_unit(unit_idx: int, destination: Vector2i, _steps: int) -> void:
    start_unit_movement(unit_idx, destination)

func complete_movement_task() -> void:
    if movement_task.is_empty():
        return
    var task: Dictionary = movement_task.duplicate(true)
    movement_task.clear()
    var unit_idx: int = int(task["unit_idx"])
    if game_over or int(units[unit_idx]["hp"]) <= 0:
        return
    var next_action: Dictionary = task.get("after", {})
    if str(next_action.get("kind", "")) == "area_shred":
        resolve_area_shred(unit_idx, next_action["aim"])
    elif next_action.get("kind", "") == "scythe_charge":
        var target_idx: int = find_unit_by_id(int(next_action["target"]))
        if target_idx >= 0 and int(units[target_idx]["hp"]) > 0 and grid_distance(units[unit_idx]["pos"], units[target_idx]["pos"]) == 1:
            var strike: Dictionary = melee_impact(unit_idx, target_idx, SCYTHE_CHARGE_DAMAGE)
            resolve_attack(unit_idx, target_idx, strike, SCYTHE_CHARGE_NAME, 0, false, false)
        else:
            status_message = "Charge ended without reaching its target."
    elif str(task.get("kind", "")) == "sentinel_breach":
        status_message = "Breach complete. Cover and collision resolved along the travelled path."
    queue_redraw()

func advance_movement_task() -> void:
    if movement_task.is_empty():
        return
    var moving_idx: int = int(movement_task["unit_idx"])
    if game_over or int(units[moving_idx]["hp"]) <= 0:
        movement_task.clear()
        return
    var steps: Array = movement_task["path"]
    var at: int = int(movement_task["cursor"])
    if at >= steps.size():
        complete_movement_task()
        return
    var next_tile: Vector2i = steps[at]
    if str(movement_task.get("kind", "")) == "sentinel_breach":
        var previous_tile: Vector2i = units[moving_idx]["pos"]
        var face: String = direction_to_face(previous_tile, next_tile)
        var edge: String = edge_key(previous_tile, face)
        if destructible_edges.has(edge):
            damage_cover_edge(edge, 5, moving_idx, BREACH_ACTION_NAME)
        # A Breach may hit one enemy at the selected landing tile only.
        var enemy_idx: int = find_unit_at(next_tile)
        if enemy_idx >= 0:
            if units[enemy_idx]["team"] == "player" or int(units[enemy_idx].get("weight", 2)) >= int(units[moving_idx].get("weight", 3)):
                add_log(BREACH_ACTION_NAME + " stopped by an unmovable occupant.")
                movement_task.clear()
                return
            battle_stats[moving_idx]["attacks"] = int(battle_stats[moving_idx]["attacks"]) + 1
            environment_hit_unit(moving_idx, enemy_idx, SENTINEL_BREACH_DAMAGE, BREACH_ACTION_NAME)
            if int(units[enemy_idx]["hp"]) > 0:
                var displacement: Vector2i = breach_push_destination(enemy_idx, next_tile - previous_tile)
                if displacement.x < 0:
                    add_log(BREACH_ACTION_NAME + " collision could not displace the target.")
                    movement_task.clear()
                    assess_winner()
                    return
                units[enemy_idx]["pos"] = displacement
                battle_stats[enemy_idx]["tiles"] = int(battle_stats[enemy_idx]["tiles"]) + 1
                add_log("%s knocked to %s." % [str(units[enemy_idx]["name"]), str(displacement)])
                apply_hazard_entry(enemy_idx)
        if not tile_is_open(next_tile, int(units[moving_idx]["id"])):
            add_log(BREACH_ACTION_NAME + " was interrupted before entering its next tile.")
            movement_task.clear()
            assess_winner()
            return
    elif not tile_is_open(next_tile, int(units[moving_idx]["id"])):
        add_log("%s interrupted by occupied path." % str(units[moving_idx]["name"]))
        movement_task.clear()
        return
    units[moving_idx]["pos"] = next_tile
    battle_stats[moving_idx]["tiles"] = int(battle_stats[moving_idx]["tiles"]) + 1
    movement_task["cursor"] = at + 1
    apply_hazard_entry(moving_idx)
    assess_winner()
    if int(units[moving_idx]["hp"]) > 0 and not game_over and not room_cleared:
        var overwatch_fired: bool = trigger_reactions_to_step(moving_idx)
        if overwatch_fired and movement_task["after"].get("kind", "") == "scythe_charge":
            movement_task.clear()
            status_message = "Overwatch interrupted Scythe's Charge before the strike."
            add_log(status_message)
            return
    if int(units[moving_idx]["hp"]) <= 0 or game_over:
        movement_task.clear()
        return
    if test_mission_id == "assassination" and bool(units[moving_idx].get("mission_target", false)) and units[moving_idx]["pos"] == ESCAPE_EXIT:
        movement_task.clear()
        officer_escapes(moving_idx)
        return
    if int(movement_task["cursor"]) >= steps.size():
        complete_movement_task()

func clear_reactions_for_team(team: String) -> void:
    # Reserve lasts only through the opposing faction phase. Unused AP expires.
    for idx in range(units.size()):
        if units[idx]["team"] == team:
            units[idx]["reaction_available"] = false
            units[idx]["reaction_type"] = ""

func reserve_reaction(idx: int, reaction_kind: String) -> bool:
    if reaction_kind != "overwatch":
        return false
    if int(units[idx]["magazine_capacity"]) == 0:
        status_message = "Overwatch requires a firearm."
        return false
    if int(units[idx]["hp"]) <= 0 or int(units[idx]["ap"]) < REACTION_AP_COST:
        status_message = "Need 1 available AP to reserve a reaction."
        return false
    if not has_attack_ammo(idx):
        status_message = EMPTY_MAGAZINE
        return false
    if bool(units[idx].get("reaction_available", false)):
        status_message = "Already has a reaction reserved this phase."
        return false
    units[idx]["ap"] = int(units[idx]["ap"]) - REACTION_AP_COST
    units[idx]["reaction_type"] = reaction_kind
    units[idx]["reaction_available"] = true
    unit_action_counters[idx]["overwatch_set"] = int(unit_action_counters[idx]["overwatch_set"]) + 1
    var name: String = str(units[idx]["name"])
    status_message = "%s reserves 1 AP for %s (expires after opposing phase)." % [name, reaction_kind]
    add_log(status_message)
    return true

func trigger_reactions_to_step(mover_idx: int) -> bool:
    # No chains: reactions trigger ONLY on traversed movement cells, never
    # on another reaction or on a non-movement attack.
    var fired: bool = false
    for defender_idx in range(units.size()):
        if game_over or int(units[mover_idx]["hp"]) <= 0:
            return fired
        if units[defender_idx]["team"] == units[mover_idx]["team"] or int(units[defender_idx]["hp"]) <= 0:
            continue
        if not bool(units[defender_idx].get("reaction_available", false)):
            continue
        var kind: String = str(units[defender_idx].get("reaction_type", ""))
        if kind == "overwatch":
            if not bool(attack_preview(defender_idx, mover_idx)["valid"]):
                continue
            units[defender_idx]["reaction_available"] = false
            units[defender_idx]["reaction_type"] = ""
            battle_stats[defender_idx]["reactions"] = int(battle_stats[defender_idx]["reactions"]) + 1
            add_log("Overwatch triggers: %s!" % str(units[defender_idx]["name"]))
            perform_attack(defender_idx, mover_idx, "Overwatch", 0, 0, 0)
            fired = true
    return fired


func record_damage_feedback(attacker_idx: int, target_idx: int, ability_name: String, arm: int, hp: int, cover: int = 0) -> void:
    # One source of truth for visible hit effects and the audit overlay.
    # Actual damage, not raw weapon impact: excludes overkill and reductions.
    var team: String = str(units[attacker_idx]["team"])
    var running: int = 0
    for event in damage_history:
        if str(event["team"]) == team:
            running += int(event["arm"]) + int(event["hp"])
    running += arm + hp
    damage_history.append({
        "number": damage_history.size() + 1,
        "round": turn_number,
        "team": team,
        "attacker": str(units[attacker_idx]["name"]),
        "defender": str(units[target_idx]["name"]),
        "ability": ability_name,
        "arm": arm,
        "hp": hp,
        "cover": cover,
        "running": running
    })
    # Keep only short-lived visual effects; the permanent damage ledger is never truncated.
    damage_floaters.append({"pos": units[target_idx]["pos"], "arm": arm, "hp": hp, "ttl": DAMAGE_FLOAT_SECONDS})
    queue_redraw()

func summed_ledger_damage(team: String) -> int:
    var total: int = 0
    for event in damage_history:
        if str(event["team"]) == team:
            total += int(event["arm"]) + int(event["hp"])
    return total

func ledger_audit_text() -> String:
    var rebels: int = summed_ledger_damage("player")
    var enemies: int = summed_ledger_damage("enemy")
    # Independent checks: damage by source, damage by victim, ability totals,
    # and the permanent event ledger must all agree.
    var hit_rebels: int = 0
    var hit_enemies: int = 0
    for idx in range(battle_stats.size()):
        if units[idx]["team"] == "player":
            hit_rebels += stat_damage(idx, "taken")
        else:
            hit_enemies += stat_damage(idx, "taken")
    var neutral: int = summed_ledger_damage("environment")
    var abilities_rebels: int = 0
    var abilities_enemies: int = 0
    for k in ability_damage_totals.keys():
        if str(k).begins_with("REBEL |"):
            abilities_rebels += int(ability_damage_totals[k])
        else:
            abilities_enemies += int(ability_damage_totals[k])
    var matches: bool = rebels == total_team_damage("player") and enemies == total_team_damage("enemy") and (rebels + enemies + neutral) == (hit_rebels + hit_enemies) and rebels == abilities_rebels and enemies == abilities_enemies
    return "RECONCILED" if matches else "MISMATCH — PLEASE REPORT BUG"

func draw_damage_floaters() -> void:
    for event in damage_floaters:
        var ttl: float = float(event["ttl"])
        var alpha: float = clampf(ttl / DAMAGE_FLOAT_SECONDS * 1.4, 0.0, 1.0)
        var lift: float = (DAMAGE_FLOAT_SECONDS - ttl) * 19.0
        var tile: Vector2i = event["pos"]
        var centre: Vector2 = ORIGIN + Vector2((float(tile.x) + 0.5) * TILE, (float(tile.y) + 0.5) * TILE - 19.0 - lift)
        var armour: int = int(event["arm"])
        var health: int = int(event["hp"])
        var title: String = "HP -%d" % health if armour == 0 else ("ARM -%d" % armour if health == 0 else "ARM -%d  HP -%d" % [armour, health])
        var color: Color = Color(1.0, 0.54, 0.50, alpha) if health > 0 else Color(0.48, 0.81, 1.0, alpha)
        var text_size: int = 11
        var width: float = ThemeDB.fallback_font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, text_size).x + 10.0
        draw_rect(Rect2(centre.x - width / 2.0, centre.y - 12.0, width, 17), Color(0.04, 0.09, 0.14, alpha * 0.89))
        draw_label(title, Vector2(centre.x - width / 2.0 + 5.0, centre.y + 1.0), text_size, color)

func draw_hit_ledger() -> void:
    draw_rect(Rect2(90, 102, 1270, 668), Color(0.055, 0.105, 0.15, 0.98), true)
    draw_rect(Rect2(90, 102, 1270, 668), Color("#87a9c2"), false, 2.0)
    draw_label("HIT-BY-HIT DAMAGE LEDGER", Vector2(116, 144), 25, Color("#f5e5b4"))
    draw_label("[L] Close    [UP/DOWN] Scroll    [R] Restart", Vector2(900, 142), 14, Color("#bbd5e7"))
    var totals: String = "Rebels: %d damage    KGB: %d damage    |    Audit: %s" % [summed_ledger_damage("player"), summed_ledger_damage("enemy"), ledger_audit_text()]
    draw_label(totals, Vector2(116, 173), 15, Color("#a5e3c1") if ledger_audit_text() == "RECONCILED" else Color("#ff9999"))
    draw_label("Unit damage totals exclude damage to objective devices (shown as OBJECTIVE hits). Buffs/healing are not damage.", Vector2(116, 196), 12, Color("#b8cad9"))
    draw_line(Vector2(114, 212), Vector2(1335, 212), Color("#587082"), 1.0)
    draw_label("#    ROUND   FACTION   ATTACKER", Vector2(115, 239), 12, Color("#b8cad9"))
    draw_label("ATTACK / ABILITY", Vector2(495, 239), 12, Color("#b8cad9"))
    draw_label("TARGET", Vector2(815, 239), 12, Color("#b8cad9"))
    draw_label("ARM", Vector2(1075, 239), 12, Color("#b8cad9"))
    draw_label("HP", Vector2(1134, 239), 12, Color("#b8cad9"))
    draw_label("RUNNING", Vector2(1200, 239), 12, Color("#b8cad9"))
    var max_scroll: int = maxi(0, damage_history.size() - LEDGER_VISIBLE_ROWS)
    ledger_scroll = mini(ledger_scroll, max_scroll)
    for r in range(mini(LEDGER_VISIBLE_ROWS, damage_history.size() - ledger_scroll)):
        var idx: int = damage_history.size() - 1 - ledger_scroll - r
        var e: Dictionary = damage_history[idx]
        var y: float = 264.0 + float(r) * 26.0
        if r % 2 == 0:
            draw_rect(Rect2(107, y - 18, 1232, 25), Color("#24384c"))
        var color: Color = Color("#f5d58f") if str(e["team"]) == "objective" else (Color("#8ccfff") if str(e["team"]) == "player" else Color("#ffafaa"))
        var faction: String = "OBJECTIVE" if str(e["team"]) == "objective" else ("ENVIRONMENT" if str(e["team"]) == "environment" else ("REBELS" if str(e["team"]) == "player" else "KGB"))
        draw_label("%02d   %02d     %s" % [int(e["number"]), int(e["round"]), faction], Vector2(115, y), 12, color)
        draw_label(str(e["attacker"]).substr(0, 24), Vector2(275, y), 12, color)
        var attack_note: String = str(e["ability"])
        if int(e["cover"]) > 0:
            attack_note += " [cover -%d]" % int(e["cover"])
        draw_label(attack_note.substr(0, 31), Vector2(495, y), 12, Color("#e5eaf3"))
        draw_label(str(e["defender"]).substr(0, 25), Vector2(815, y), 12, Color("#d1dfea"))
        draw_label("-%d" % int(e["arm"]), Vector2(1083, y), 12, Color("#88d2ff"))
        draw_label("-%d" % int(e["hp"]), Vector2(1140, y), 12, Color("#ffac9f"))
        draw_label(str(e["running"]), Vector2(1218, y), 12, color)
    draw_line(Vector2(114, 720), Vector2(1335, 720), Color("#587082"), 1.0)
    draw_label("%d hit events  |  Viewing newest first  |  Events %d–%d of %d" % [damage_history.size(), maxi(0, damage_history.size() - ledger_scroll), maxi(0, damage_history.size() - ledger_scroll - LEDGER_VISIBLE_ROWS + 1), damage_history.size()], Vector2(116, 748), 12, Color("#c1d2df"))

func recoverable_hp(unit: Dictionary) -> int:
    var maximum: int = int(unit["max_hp"])
    return ceili(maximum * 0.5) if int(unit.get("downs", 0)) > 0 else maximum

func apply_healing(healer_idx: int, patient_idx: int, amount: int, ability_name: String) -> bool:
    if int(units[patient_idx]["hp"]) <= 0:
        return false
    var actual: int = mini(amount, recoverable_hp(units[patient_idx]) - int(units[patient_idx]["hp"]))
    if actual <= 0:
        return false
    units[patient_idx]["hp"] = int(units[patient_idx]["hp"]) + actual
    battle_stats[healer_idx]["healing"] = int(battle_stats[healer_idx]["healing"]) + actual
    record_ability_use(healer_idx, ability_name)
    status_message = "%s heals %s for %d HP." % [str(units[healer_idx]["name"]), str(units[patient_idx]["name"]), actual]
    add_log(status_message)
    return true

func perform_attack(attacker_idx: int, target_idx: int, named_ability: String = "", bonus_damage: int = 0, pierce: int = 0, cost: int = 1) -> void:
    var attack: Dictionary = attack_preview(attacker_idx, target_idx, bonus_damage, pierce)
    if not bool(attack["valid"]) or int(units[attacker_idx]["ap"]) < cost:
        return
    if not spend_shot(attacker_idx):
        return
    var weapon_name: String = str(units[attacker_idx]["basic_attack"])
    resolve_attack(attacker_idx, target_idx, attack, named_ability if named_ability != "" else weapon_name, cost, named_ability in ["", weapon_name])

func resolve_attack(attacker_idx: int, target_idx: int, attack: Dictionary, ability: String, cost: int, basic: bool, record_use: bool = true) -> void:
    units[attacker_idx]["ap"] = int(units[attacker_idx]["ap"]) - cost
    var armour_damage: int = int(attack["armour_damage"])
    var hp_damage: int = int(attack["hp_damage"])
    units[target_idx]["armour"] = maxi(0, int(units[target_idx]["armour"]) - armour_damage)
    units[target_idx]["hp"] = maxi(0, int(units[target_idx]["hp"]) - hp_damage)
    var attacker_name: String = str(units[attacker_idx]["name"])
    var defender_name: String = str(units[target_idx]["name"])
    if basic:
        unit_action_counters[attacker_idx]["basic_attacks"] = int(unit_action_counters[attacker_idx]["basic_attacks"]) + 1
    # Count real harm only (HP + armour actually removed, not overkill).
    battle_stats[attacker_idx]["dealt_hp"] = int(battle_stats[attacker_idx]["dealt_hp"]) + hp_damage
    battle_stats[attacker_idx]["dealt_arm"] = int(battle_stats[attacker_idx]["dealt_arm"]) + armour_damage
    battle_stats[attacker_idx]["attacks"] = int(battle_stats[attacker_idx]["attacks"]) + 1
    battle_stats[target_idx]["taken_hp"] = int(battle_stats[target_idx]["taken_hp"]) + hp_damage
    battle_stats[target_idx]["taken_arm"] = int(battle_stats[target_idx]["taken_arm"]) + armour_damage
    var key: String = ("REBEL | " if units[attacker_idx]["team"] == "player" else "ENEMY | ") + ability
    ability_damage_totals[key] = int(ability_damage_totals.get(key, 0)) + hp_damage + armour_damage
    if record_use:
        record_ability_use(attacker_idx, ability)
    record_damage_feedback(attacker_idx, target_idx, ability, armour_damage, hp_damage, int(attack["cover"]))
    units[attacker_idx]["stim_bonus"] = 0 # one attack consumes any serum buff
    add_log("%s [%s] -> %s: %d ARM, %d HP." % [attacker_name, ability, defender_name, armour_damage, hp_damage])
    status_message = "%s [%s]: -%d ARM / -%d HP." % [attacker_name, ability, armour_damage, hp_damage]
    var armour_loss: int = int(attack.get("armour_cap_loss", 0))
    if armour_loss > 0:
        units[target_idx]["max_armour"] = int(units[target_idx]["max_armour"]) - armour_loss
        add_log("%s loses %d maximum armour." % [defender_name, armour_loss])
    if int(units[target_idx]["hp"]) <= 0:
        battle_stats[attacker_idx]["kills"] = int(battle_stats[attacker_idx]["kills"]) + 1
        if units[target_idx]["team"] == "player":
            register_player_down(target_idx)
        else:
            add_log("%s eliminated." % defender_name)
        if int(units[target_idx]["id"]) == selected_id:
            selected_id = -1
    assess_winner()

func can_use_loadout_action(idx: int, action: String) -> bool:
    if idx < 0 or int(units[idx]["hp"]) <= 0:
        return false
    var unit: Dictionary = units[idx]
    if action == "melee":
        return int(unit["melee_damage"]) > 0 and int(unit["ap"]) >= StarterLoadouts.MELEE_AP
    if action == "blink":
        return unit.get("scythe_origin", "") == "Blink" and int(unit["blink_used_turn"]) != turn_number and int(unit["ap"]) >= SHORT_BLINK_AP
    return int(unit["medkit_charges"]) > 0 and int(unit["ap"]) >= StarterLoadouts.MEDKIT_AP

func toggle_loadout_action(action: String) -> void:
    var idx: int = find_unit_by_id(selected_id)
    if not can_use_loadout_action(idx, action):
        status_message = "Melee needs an equipped weapon and 1 AP." if action == "melee" else "Medkit needs an unused charge and 1 AP."
        if action == "blink":
            status_message = "Short Blink requires the Blink origin and 1 AP. Once per turn."
        queue_redraw()
        return
    loadout_action = "" if loadout_action == action else action
    special_mode = false
    breach_target_mode = false
    shred_landing_tile = Vector2i(-1, -1)
    status_message = "Targeting cancelled."
    if loadout_action == "melee":
        status_message = "Click an adjacent enemy for a melee attack (1 AP)."
    elif loadout_action == "medkit":
        status_message = "Click yourself or an adjacent ally to use the medkit (1 AP)."
    elif loadout_action == "blink":
        status_message = "Click a visible landing tile within four tiles. Overwatch can fire on landing."
    queue_redraw()

func use_loadout_action(actor_idx: int, target_idx: int) -> bool:
    if not can_use_loadout_action(actor_idx, loadout_action):
        return false
    var actor: Dictionary = units[actor_idx]
    if loadout_action == "medkit":
        if target_idx < 0 or units[target_idx]["team"] != "player" or grid_distance(actor["pos"], units[target_idx]["pos"]) > 1:
            status_message = "Select yourself or an adjacent living ally for the medkit."
            return false
        if not apply_healing(actor_idx, target_idx, StarterLoadouts.MEDKIT_HP, StarterLoadouts.MEDKIT_NAME):
            status_message = "This operative is already at their healing limit."
            return false
        actor["ap"] = int(actor["ap"]) - StarterLoadouts.MEDKIT_AP
        actor["medkit_charges"] = int(actor["medkit_charges"]) - 1
        if hq_deployment:
            headquarters.campaign.spend_medkit(hq_operative_id(actor_idx))
        return true
    if target_idx < 0 or units[target_idx]["team"] == "player" or grid_distance(actor["pos"], units[target_idx]["pos"]) != 1:
        status_message = "Select an adjacent enemy for a melee attack."
        return false
    var impact: Dictionary = melee_impact(actor_idx, target_idx, int(actor["melee_damage"]))
    if armour_enabled and actor["melee_weapon"] == WOLVERINE_CLAWS:
        impact["armour_cap_loss"] = mini(1, int(units[target_idx]["max_armour"]))
    resolve_attack(actor_idx, target_idx, impact, str(actor["melee_weapon"]), StarterLoadouts.MELEE_AP, true)
    return true

func can_land_short_blink(idx: int, tile: Vector2i) -> bool:
    var origin: Vector2i = units[idx]["pos"]
    return tile != origin and grid_distance(origin, tile) <= SHORT_BLINK_RANGE and tile_is_open(tile) and has_line_of_sight(origin, tile)

func use_short_blink(idx: int, tile: Vector2i) -> bool:
    if not can_use_loadout_action(idx, "blink"):
        return false
    if not can_land_short_blink(idx, tile):
        status_message = "Short Blink needs an open tile within four tiles and in line of sight."
        return false
    var operative: Dictionary = units[idx]
    operative["ap"] = int(operative["ap"]) - SHORT_BLINK_AP
    operative["blink_used_turn"] = turn_number
    operative["pos"] = tile
    unit_action_counters[idx]["moves"] = int(unit_action_counters[idx]["moves"]) + 1
    record_ability_use(idx, SHORT_BLINK)
    status_message = "%s uses Short Blink." % str(operative["name"])
    add_log(status_message)
    apply_hazard_entry(idx)
    assess_winner()
    if int(operative["hp"]) > 0 and not game_over and not room_cleared:
        trigger_reactions_to_step(idx)
    return true

func melee_impact(actor_idx: int, target_idx: int, base_damage: int) -> Dictionary:
    var target: Dictionary = units[target_idx]
    var damage: int = base_damage + int(units[actor_idx].get("stim_bonus", 0))
    var armour_hit: int = mini(int(target["armour"]), damage)
    return {"armour_damage": armour_hit, "hp_damage": mini(int(target["hp"]), damage - armour_hit), "cover": 0}

func scythe_charge_distance() -> int:
    return SCYTHE_CHARGE_DISTANCE + (SPIDER_AGILITY_BONUS if units[0].get("scythe_origin", "") == "Arachnid" else 0)

func scythe_charge_plan(target_idx: int) -> Dictionary:
    if target_idx < 0 or units[target_idx]["team"] != "enemy" or int(units[target_idx]["hp"]) <= 0:
        return {}
    var origin: Vector2i = units[0]["pos"]
    var enemy_tile: Vector2i = units[target_idx]["pos"]
    var charge_distance: int = scythe_charge_distance()
    var options: Dictionary = reachable(origin, charge_distance, 0)
    var shortest: int = charge_distance + 1
    var landing: Vector2i = Vector2i(-1, -1)
    for offset in DIRECTIONS:
        var candidate: Vector2i = enemy_tile + offset
        if options.has(candidate) and int(options[candidate]) < shortest:
            landing = candidate
            shortest = int(options[candidate])
    if landing.x < 0:
        return {}
    return {"landing": landing, "path": shortest_tile_path(origin, landing, 0), "impact": melee_impact(0, target_idx, SCYTHE_CHARGE_DAMAGE)}

func start_scythe_charge(target_idx: int) -> bool:
    var plan: Dictionary = scythe_charge_plan(target_idx)
    if plan.is_empty():
        status_message = "Choose an enemy with a walkable landing tile within %d steps." % scythe_charge_distance()
        return false
    units[0]["special_used_turn"] = turn_number
    record_ability_use(0, SCYTHE_CHARGE_NAME)
    status_message = "Scythe charges at %s." % str(units[target_idx]["name"])
    add_log(status_message)
    start_unit_movement(0, plan["landing"], special_cost(0), {"kind": "scythe_charge", "target": int(units[target_idx]["id"])})
    return true

func special_cost(idx: int) -> int:
    # Build 10 temporary test balance: every player signature costs 1 AP.
    return 1 if idx >= 0 and idx < 5 else 99

func special_cooldown_remaining(idx: int) -> int:
    if operative_kit(idx) not in [3, 4]:
        return 0
    return maxi(0, int(units[idx].get("special_ready_turn", -99)) - turn_number)

func special_available(idx: int) -> bool:
    if int(units[idx]["special_used_turn"]) == turn_number:
        return false
    if special_cooldown_remaining(idx) > 0:
        return false
    if operative_kit(idx) in [2, 3] and not has_attack_ammo(idx):
        return false
    return int(units[idx]["ap"]) >= special_cost(idx)

func special_unavailable_message(idx: int) -> String:
    if int(units[idx]["special_used_turn"]) == turn_number:
        return "Ability already used this turn."
    var remaining: int = special_cooldown_remaining(idx)
    if remaining > 0:
        return "Ability cooling down: %d player turn(s) until ready." % remaining
    if operative_kit(idx) in [2, 3] and not has_attack_ammo(idx):
        return EMPTY_MAGAZINE
    return "Insufficient AP: ability requires %d AP." % special_cost(idx)

func special_readiness_label(idx: int) -> String:
    if int(units[idx]["special_used_turn"]) == turn_number:
        return "USED"
    var remaining: int = special_cooldown_remaining(idx)
    if remaining > 0:
        return "CD: %d TURN" % remaining
    if operative_kit(idx) in [2, 3] and not has_attack_ammo(idx):
        return "RELOAD"
    if int(units[idx]["ap"]) < special_cost(idx):
        return "NEED %d AP" % special_cost(idx)
    return "READY"

func shred_arc(razor_pos: Vector2i, aim_tile: Vector2i) -> Array[Vector2i]:
    var result: Array[Vector2i] = []
    var offset: Vector2i = aim_tile - razor_pos
    var centre: int = SHRED_RING.find(offset)
    if centre < 0:
        return result
    for n in [-1, 0, 1]:
        var tile: Vector2i = razor_pos + SHRED_RING[(centre + n + 8) % 8]
        if is_in_bounds(tile) and not walls.has(tile):
            result.append(tile)
    return result

func area_shred(actor_idx: int, landing: Vector2i, aim_tile: Vector2i) -> bool:
    # The entire charge + sweep costs 1 AP, and a reaction during movement
    # can stop Scythe before the sweep. Movement is animated one cell at a time.
    var options: Dictionary = reachable(units[actor_idx]["pos"], SHRED_CHARGE_DISTANCE, int(units[actor_idx]["id"]))
    if not options.has(landing) or not tile_is_open(landing, int(units[actor_idx]["id"])):
        status_message = "Area Shred landing is blocked or farther than 3 steps."
        return false
    var arc: Array[Vector2i] = shred_arc(landing, aim_tile)
    if arc.is_empty():
        status_message = "Choose an adjacent aiming tile for Area Shred."
        return false
    var target_count: int = 0
    for tile in arc:
        var opponent: int = find_unit_at(tile)
        if opponent >= 0 and units[opponent]["team"] == "enemy" and int(units[opponent]["hp"]) > 0:
            target_count += 1
    if target_count == 0 and not (radio_is_active() and arc.has(RADIO_POS)) and not arc_has_breakable_cover(arc) and not arc_has_barrel(arc):
        status_message = "That arc has no enemies or active objective. Pick another direction."
        return false
    if int(units[actor_idx]["ap"]) < special_cost(actor_idx):
        status_message = "Area Shred requires 1 AP."
        return false
    var steps: int = int(options[landing])
    units[actor_idx]["ap"] = int(units[actor_idx]["ap"]) - special_cost(actor_idx)
    record_ability_use(actor_idx, "Area Shred")
    add_log("Scythe charges up to %d tiles; 3-cell arc follows." % steps)
    start_unit_movement(actor_idx, landing, 0, {"kind": "area_shred", "aim": aim_tile})
    status_message = "Scythe charging: reserved reaction fire may interrupt the sweep."
    return true

func resolve_area_shred(actor_idx: int, aim_tile: Vector2i) -> void:
    if int(units[actor_idx]["hp"]) <= 0:
        return
    var arc: Array[Vector2i] = shred_arc(units[actor_idx]["pos"], aim_tile)
    var total: int = 0
    var hits: int = 0
    for tile in arc:
        var idx: int = find_unit_at(tile)
        if idx < 0 or units[idx]["team"] != "enemy" or int(units[idx]["hp"]) <= 0:
            continue
        hits += 1
        var arm: int = mini(int(units[idx]["armour"]), SHRED_DAMAGE)
        var hp: int = mini(int(units[idx]["hp"]), SHRED_DAMAGE - arm)
        units[idx]["armour"] = int(units[idx]["armour"]) - arm
        units[idx]["hp"] = int(units[idx]["hp"]) - hp
        battle_stats[actor_idx]["dealt_arm"] = int(battle_stats[actor_idx]["dealt_arm"]) + arm
        battle_stats[actor_idx]["dealt_hp"] = int(battle_stats[actor_idx]["dealt_hp"]) + hp
        battle_stats[actor_idx]["attacks"] = int(battle_stats[actor_idx]["attacks"]) + 1
        battle_stats[idx]["taken_arm"] = int(battle_stats[idx]["taken_arm"]) + arm
        battle_stats[idx]["taken_hp"] = int(battle_stats[idx]["taken_hp"]) + hp
        total += arm + hp
        record_damage_feedback(actor_idx, idx, "Area Shred", arm, hp, 0)
        add_log("Scythe [Area Shred] -> %s: %d ARM / %d HP." % [str(units[idx]["name"]), arm, hp])
        if int(units[idx]["hp"]) <= 0:
            battle_stats[actor_idx]["kills"] = int(battle_stats[actor_idx]["kills"]) + 1
            add_log(str(units[idx]["name"]) + " eliminated.")
    ability_damage_totals["REBEL | Area Shred"] = int(ability_damage_totals.get("REBEL | Area Shred", 0)) + total
    # Structural force affects physical cover edges, unlike ordinary shots.
    damage_cover_in_tiles(arc, 2, actor_idx, "Area Shred", true)
    for tile in arc:
        if barrel_is_active(tile):
            hit_barrel(tile, SHRED_DAMAGE, actor_idx, "Area Shred")
    # Area Shred may also smash the radio if its tile is inside the chosen arc.
    if radio_is_active() and arc.has(RADIO_POS):
        hit_radio(actor_idx, SHRED_DAMAGE, "Area Shred", 0)
    else:
        status_message = "Area Shred hit %d targets, dealing %d actual damage." % [hits, total]
    assess_winner()

func try_special_action(actor_idx: int, target_idx: int, target_tile: Vector2i) -> bool:
    var kit: int = operative_kit(actor_idx)
    if kit == 0:
        if not special_available(actor_idx):
            status_message = special_unavailable_message(actor_idx)
            return false
        if test_mission_id == "scythe":
            return start_scythe_charge(target_idx)
        if shred_landing_tile.x < 0:
            var options: Dictionary = reachable(units[actor_idx]["pos"], SHRED_CHARGE_DISTANCE, int(units[actor_idx]["id"]))
            if not options.has(target_tile):
                status_message = "First select a blue landing tile within 3 walkable steps (Scythe's tile = stay)."
                return false
            shred_landing_tile = target_tile
            status_message = "Landing selected. Now click any neighbouring square to orient the 3-tile Shred arc."
            return false
        if target_tile == shred_landing_tile:
            shred_landing_tile = Vector2i(-1, -1)
            status_message = "Landing cleared. Choose another blue tile."
            return false
        if not area_shred(actor_idx, shred_landing_tile, target_tile):
            return false
        units[actor_idx]["special_used_turn"] = turn_number
        shred_landing_tile = Vector2i(-1, -1)
        return true
    if target_idx < 0:
        status_message = "Select a unit as the ability target. Q cancels."
        return false
    var actor: Dictionary = units[actor_idx]
    if not special_available(actor_idx):
        status_message = special_unavailable_message(actor_idx)
        return false
    var ability: String = str(actor["special"])
    if kit in [2, 3] and units[target_idx]["team"] != "enemy":
        status_message = "%s needs an enemy target." % ability
        return false
    if kit in [1, 4] and units[target_idx]["team"] != "player":
        status_message = "%s needs a friendly target." % ability
        return false
    if kit == 1:
        if not armour_enabled:
            status_message = "Fortify requires armour mode ON."
            return false
        if target_idx == actor_idx:
            status_message = "Fortify requires another friendly operative; Anvil is protected automatically."
            return false
        if grid_distance(actor["pos"], units[target_idx]["pos"]) > 2:
            status_message = "Fortify requires another ally within 2 tiles."
            return false
        units[actor_idx]["ap"] = int(units[actor_idx]["ap"]) - special_cost(actor_idx)
        units[target_idx]["armour"] = int(units[target_idx]["armour"]) + 2
        units[actor_idx]["armour"] = int(units[actor_idx]["armour"]) + 2
        # The after-action support counter measures recipients, not button presses.
        battle_stats[actor_idx]["buffs"] = int(battle_stats[actor_idx]["buffs"]) + 2
        record_ability_use(actor_idx, ability)
        status_message = "Anvil Fortify: +2 temporary ARM to %s and Anvil." % str(units[target_idx]["name"])
        add_log(status_message)
    elif kit == 2:
        if not bool(attack_preview(actor_idx, target_idx, 2, 1)["valid"]):
            status_message = str(attack_preview(actor_idx, target_idx)["reason"])
            return false
        perform_attack(actor_idx, target_idx, ability, 2, 1, special_cost(actor_idx))
    elif kit == 3:
        if not bool(attack_preview(actor_idx, target_idx, 1, 0)["valid"]):
            status_message = str(attack_preview(actor_idx, target_idx)["reason"])
            return false
        perform_attack(actor_idx, target_idx, ability, 1, 0, special_cost(actor_idx))
        if int(units[target_idx]["hp"]) > 0:
            units[target_idx]["jammed_actions"] = mini(2, int(units[target_idx]["jammed_actions"]) + 1)
            add_log(str(units[target_idx]["name"]) + " loses 1 AP next enemy phase.")
    elif kit == 4:
        if grid_distance(actor["pos"], units[target_idx]["pos"]) > 3:
            status_message = "Field Treatment requires an ally within 3 tiles."
            return false
        if not apply_healing(actor_idx, target_idx, 3, ability):
            status_message = "The target is already at their healing limit."
            return false
        units[actor_idx]["ap"] = int(units[actor_idx]["ap"]) - special_cost(actor_idx)
    units[actor_idx]["special_used_turn"] = turn_number
    if kit in [3, 4]:
        # One *full next player turn* must pass before reuse.
        # If used in round 1: unusable round 2, ready round 3.
        units[actor_idx]["special_ready_turn"] = turn_number + 2
    return true

func register_player_down(idx: int) -> void:
    var unit: Dictionary = units[idx]
    unit["downs"] = int(unit.get("downs", 0)) + 1
    unit["ap"] = 0
    unit["statuses"].clear()
    unit["stim_bonus"] = 0
    unit["jammed_actions"] = 0
    unit["reaction_type"] = ""
    unit["reaction_available"] = false
    if int(unit["downs"]) >= 2:
        unit["recovery_round"] = 0
        unit["permanently_dead"] = true
        add_log("%s has gone down a second time: PERMANENTLY LOST." % str(unit["name"]))
    else:
        # The next two player turns are missed in full, even if the down
        # happens during the enemy phase immediately before the first one.
        unit["recovery_round"] = turn_number + FIRST_DOWN_MISSED_TURNS + 1
        add_log("%s DOWNED. Stands in round %d or on room clear." % [str(unit["name"]), int(unit["recovery_round"])])

func recover_downed_operatives() -> void:
    for idx in range(5):
        var unit: Dictionary = units[idx]
        var ready_round: int = int(unit["recovery_round"])
        if ready_round <= 0 or ready_round > turn_number:
            continue
        unit["hp"] = recoverable_hp(unit)
        unit["recovery_round"] = 0
        add_log("%s stands at %d HP. A second down is permanent." % [str(unit["name"]), int(unit["hp"])])

func complete_test_mission(success: bool) -> void:
    if game_over:
        return
    save_room_result()
    game_over = true
    mission_victory = success
    winner = "MISSION COMPLETE" if success else "MISSION FAILED"
    status_message = ("Mission objective achieved!" if success else "Primary objective failed.") + " [P] room activity | [M] missions | [R] retry"
    if hq_deployment:
        headquarters.campaign.credit_reward(test_mission_id + "_complete", success)
        headquarters.campaign.finish("Mission complete" if success else "Mission failed", units)
        status_message = winner + "  [P] room activity  |  [F9] headquarters"
        print("HQ operation %s: %s in room %d, round %d." % [test_mission_id, winner, mission_stage + 1, turn_number])
    show_report = true
    add_log(winner + " — " + get_objective_progress_line())
    queue_redraw()

func assess_winner() -> void:
    if game_over or room_cleared:
        return
    var alive_players: int = alive_count("player")
    var alive_enemies: int = alive_count("enemy")
    if test_mission_id == "defence" and bool(mission_flags.get("safehouse_destroyed", false)):
        complete_test_mission(false)
        return
    if alive_players == 0:
        complete_test_mission(false)
        return
    if test_mission_id == "defence":
        # Wave missions never conclude just because all CURRENT enemies are dead.
        return
    if alive_enemies > 0:
        return
    if test_mission_id in ["sabotage", "rescue"] and not all_required_objectives_met():
        status_message = "All guards defeated. Finish objective: " + get_objective_progress_line()
        queue_redraw()
        return
    if test_mission_id == "assassination" and mission_stage == 2:
        complete_test_mission(all_required_objectives_met())
        return
    if test_mission_id == "chain" and mission_stage == 1 and not bool(radio_state.get("destroyed_in_time", false)):
        queue_radio_alert("Room 2 cleared without disabling the transmitter before the deadline")
    if mission_stage == mission_room_total() - 1:
        complete_test_mission(true)
        return
    save_room_result(true)
    room_cleared = true
    status_message = "ROOM %d CLEARED. Review squad activity; ENTER to proceed." % (mission_stage + 1)
    if hq_deployment:
        status_message += " [E] extract to HQ."
        print("HQ operation %s: cleared room %d in round %d." % [test_mission_id, mission_stage + 1, turn_number])
    add_log(status_message)
    queue_redraw()

func tile_at_screen(screen_pos: Vector2) -> Vector2i:
    if not Rect2(ORIGIN, Vector2(board_w * TILE, board_h * TILE)).has_point(screen_pos):
        return Vector2i(-1, -1)
    return Vector2i(
        floori((screen_pos.x - ORIGIN.x) / float(TILE)),
        floori((screen_pos.y - ORIGIN.y) / float(TILE))
    )

func _unhandled_input(event: InputEvent) -> void:
    if headquarters.visible:
        if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_M:
            headquarters.hide()
            hq_deployment = false
            test_mission_id = "chain"
            restart_game()
            mission_picker_open = true
            queue_redraw()
        return
    if event is InputEventMouseMotion:
        var next_tile: Vector2i = tile_at_screen(event.position)
        if next_tile != hovered_tile:
            hovered_tile = next_tile
            queue_redraw()
        return
    if not movement_task.is_empty():
        return
    if loadout_open:
        handle_loadout_input(event)
        return
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_F9 and (mission_picker_open or (hq_deployment and game_over)):
            headquarters.open()
            return
        if hq_deployment:
            if event.keycode == KEY_E and room_cleared:
                extract_hq_operation()
                return
            if event.keycode == KEY_G and side_to_play == "player" and not game_over and not room_cleared:
                emergency_reload()
                return
            if event.keycode in [KEY_M, KEY_R, KEY_A, KEY_I, KEY_F6, KEY_F7, KEY_F8]:
                return
        if event.keycode == KEY_M:
            mission_picker_open = not mission_picker_open
            queue_redraw()
            return
        if mission_picker_open:
            if event.keycode >= KEY_1 and event.keycode < KEY_1 + TEST_MISSION_IDS.size():
                begin_loadout(TEST_MISSION_IDS[event.keycode - KEY_1])
            return
        if event.keycode == KEY_L:
            show_hit_ledger = not show_hit_ledger
            ledger_scroll = 0
            queue_redraw()
            return
        if show_hit_ledger and event.keycode in [KEY_UP, KEY_DOWN, KEY_ESCAPE]:
            if event.keycode == KEY_UP:
                ledger_scroll = mini(maxi(0, damage_history.size() - LEDGER_VISIBLE_ROWS), ledger_scroll + 1)
            elif event.keycode == KEY_DOWN:
                ledger_scroll = maxi(0, ledger_scroll - 1)
            else:
                show_hit_ledger = false
            queue_redraw()
            return
        if show_hit_ledger and event.keycode != KEY_R:
            return
        if game_over and event.keycode == KEY_P:
            show_room_activity = not show_room_activity
            activity_room_page = maxi(0, room_history.size() - 1)
            queue_redraw()
            return
        if game_over and show_room_activity and event.keycode in [KEY_LEFT, KEY_RIGHT]:
            if event.keycode == KEY_LEFT:
                activity_room_page = maxi(0, activity_room_page - 1)
            else:
                activity_room_page = mini(room_history.size() - 1, activity_room_page + 1)
            queue_redraw()
            return
        if event.keycode in [KEY_F6, KEY_F7, KEY_F8]:
            dev_jump_to_room(event.keycode - KEY_F6)
            return
        if room_cleared:
            if event.keycode in [KEY_ENTER, KEY_KP_ENTER, KEY_C]:
                next_mission_room()
            elif event.keycode == KEY_R:
                restart_game()
            return
        if event.keycode == KEY_R:
            restart_game()
        elif event.keycode == KEY_SPACE and side_to_play == "player" and not game_over:
            end_player_turn()
        elif event.keycode == KEY_X and side_to_play == "player" and not game_over:
            reload_selected_weapon()
        elif event.keycode in [KEY_J, KEY_K] and side_to_play == "player" and not game_over:
            toggle_loadout_action("melee" if event.keycode == KEY_J else "medkit")
        elif event.keycode == KEY_Z and side_to_play == "player" and not game_over:
            toggle_loadout_action("blink")
        elif event.keycode in [KEY_T, KEY_C]:
            status_message = "This is one continuous mission. Clear the room to advance; R restarts from room 1."
            queue_redraw()
        elif event.keycode == KEY_H:
            show_enemy_threat = not show_enemy_threat
            status_message = "Threat preview %s: hover an enemy to see its move + attack reach." % ("ON" if show_enemy_threat else "OFF")
            queue_redraw()
        elif event.keycode == KEY_O and side_to_play == "player" and not game_over:
            var who: int = find_unit_by_id(selected_id)
            if who >= 0 and reserve_reaction(who, "overwatch"):
                loadout_action = ""
                special_mode = false
                shred_landing_tile = Vector2i(-1, -1)
            queue_redraw()
        elif event.keycode == KEY_A:
            armour_enabled = not armour_enabled
            restart_game()
        elif event.keycode == KEY_I:
            smart_ai_enabled = not smart_ai_enabled
            restart_game()
        elif event.keycode == KEY_F:
            show_firing_range = not show_firing_range
            status_message = "Green base-attack links %s [F]." % ("ON" if show_firing_range else "OFF")
            queue_redraw()
        elif event.keycode == KEY_V and game_over:
            show_report = not show_report
            queue_redraw()
        elif event.keycode == KEY_ESCAPE:
            loadout_action = ""
            breach_target_mode = false
            special_mode = false
            shred_landing_tile = Vector2i(-1, -1)
            queue_redraw()
        elif event.keycode == KEY_B and side_to_play == "player" and not game_over:
            if operative_kit(selected_id) == 1 and int(units[selected_id]["hp"]) > 0:
                loadout_action = ""
                breach_target_mode = not breach_target_mode
                special_mode = false
                status_message = "BREACH: select a blue straight-line destination (1-4 tiles). Orange = destroyed; green = push; red X = blocked." if breach_target_mode else "Breach targeting cancelled."
            else:
                status_message = "Breach test is only available to Anvil."
            queue_redraw()
        elif event.keycode == KEY_Q and side_to_play == "player" and not game_over:
            var cur: int = find_unit_by_id(selected_id)
            if cur >= 0 and int(units[cur]["hp"]) > 0:
                if not special_available(cur):
                    status_message = special_unavailable_message(cur)
                else:
                    loadout_action = ""
                    special_mode = not special_mode
                    breach_target_mode = false
                    shred_landing_tile = Vector2i(-1, -1)
                    status_message = "Ability targeting cancelled."
                    if special_mode:
                        status_message = "SELECT TARGET for " + str(units[cur]["special"])
                        if operative_kit(cur) == 0 and test_mission_id != "scythe":
                            status_message = "Scythe Area Shred: choose landing tile within 3 steps."
            queue_redraw()
        elif event.keycode == KEY_D:
            ai_debug_enabled = not ai_debug_enabled
            status_message = "AI debug %s. Toggle with D." % ["ON" if ai_debug_enabled else "OFF"]
            queue_redraw()
        elif event.keycode in [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5] and side_to_play == "player" and not game_over:
            var next_id: int = event.keycode - KEY_1
            if next_id < 5 and int(units[next_id]["hp"]) > 0:
                selected_id = next_id
                loadout_action = ""
                breach_target_mode = false
                special_mode = false
                shred_landing_tile = Vector2i(-1, -1)
                status_message = "Selected %s." % str(units[next_id]["name"])
                queue_redraw()
        elif event.keycode == KEY_TAB and side_to_play == "player" and not game_over:
            for offset in range(1, 6):
                var next_id: int = (maxi(-1, selected_id) + offset) % 5
                if int(units[next_id]["hp"]) > 0 and int(units[next_id]["ap"]) > 0:
                    selected_id = next_id
                    loadout_action = ""
                    breach_target_mode = false
                    special_mode = false
                    shred_landing_tile = Vector2i(-1, -1)
                    status_message = "Selected %s." % str(units[next_id]["name"])
                    queue_redraw()
                    break
        return
    if show_hit_ledger and not mission_picker_open:
        return
    if not (event is InputEventMouseButton):
        return
    if not event.pressed or event.button_index != MOUSE_BUTTON_LEFT:
        return
    var clicked: Vector2 = event.position
    if mission_picker_open:
        if HQ_BUTTON.has_point(clicked):
            headquarters.open()
            return
        for i in range(TEST_MISSION_IDS.size()):
            if mission_picker_rect(i).has_point(clicked):
                begin_loadout(TEST_MISSION_IDS[i])
                return
        return
    if not hq_deployment and Rect2(884, 51, 140, 25).has_point(clicked):
        mission_picker_open = true
        queue_redraw()
        return
    for room_idx in range(ROOM_COUNT):
        if not hq_deployment and dev_button_rect(room_idx).has_point(clicked):
            dev_jump_to_room(room_idx)
            return
    if room_cleared:
        if NEXT_ROOM_BUTTON.has_point(clicked):
            next_mission_room()
        return
    if game_over and show_report:
        if REPORT_RESET.has_point(clicked):
            if hq_deployment:
                headquarters.open()
            else:
                restart_game()
        return
    if not hq_deployment and RESET_BUTTON.has_point(clicked):
        restart_game()
        return
    if END_BUTTON.has_point(clicked):
        if side_to_play == "player" and not game_over:
            end_player_turn()
        return
    if game_over or side_to_play != "player":
        return
    var weapon_owner: int = find_unit_by_id(selected_id)
    if weapon_owner >= 0 and int(units[weapon_owner]["hp"]) > 0:
        if units[weapon_owner].get("scythe_origin", "") == "Blink" and SHORT_BLINK_BUTTON.has_point(clicked):
            toggle_loadout_action("blink")
            return
        if MELEE_BUTTON.has_point(clicked) or MEDKIT_BUTTON.has_point(clicked):
            toggle_loadout_action("melee" if MELEE_BUTTON.has_point(clicked) else "medkit")
            return
        var loaded: bool = has_attack_ammo(weapon_owner)
        if (RELOAD_BUTTON if loaded else EMPTY_RELOAD_BUTTON).has_point(clicked):
            reload_selected_weapon()
            return
        if loaded and SHOOT_BUTTON.has_point(clicked):
            loadout_action = ""
            special_mode = false
            breach_target_mode = false
            shred_landing_tile = Vector2i(-1, -1)
            status_message = "Click a target to shoot for 1 AP." if int(units[weapon_owner]["ap"]) > 0 else "Shooting needs 1 AP."
            queue_redraw()
            return
    # Compact squad tabs on the inspector, in addition to keys 1-5 and Tab.
    for row in range(5):
        if squad_tab_rect(row).has_point(clicked):
            if int(units[row]["hp"]) > 0:
                selected_id = row
                loadout_action = ""
                breach_target_mode = false
                special_mode = false
                shred_landing_tile = Vector2i(-1, -1)
                status_message = "Selected %s." % str(units[row]["name"])
                queue_redraw()
            return
    var tile: Vector2i = tile_at_screen(clicked)
    if not is_in_bounds(tile):
        return
    var clicked_unit_idx: int = find_unit_at(tile)
    if loadout_action != "":
        var actor: int = find_unit_by_id(selected_id)
        var acted: bool = use_short_blink(actor, tile) if loadout_action == "blink" else use_loadout_action(actor, clicked_unit_idx)
        if acted:
            loadout_action = ""
        queue_redraw()
        return
    if breach_target_mode:
        var worked: bool = sentinel_breach(tile)
        if worked:
            breach_target_mode = false
        queue_redraw()
        return
    if special_mode:
        var acting_idx: int = find_unit_by_id(selected_id)
        if acting_idx >= 0 and try_special_action(acting_idx, clicked_unit_idx, tile):
            special_mode = false
            shred_landing_tile = Vector2i(-1, -1)
        queue_redraw()
        return
    if clicked_unit_idx >= 0 and units[clicked_unit_idx]["team"] == "player":
        selected_id = int(units[clicked_unit_idx]["id"])
        breach_target_mode = false
        special_mode = false
        shred_landing_tile = Vector2i(-1, -1)
        status_message = "Selected %s. Movement: 1 AP, up to %d tiles. Attack: 1 AP." % [str(units[clicked_unit_idx]["name"]), int(units[clicked_unit_idx]["move"])]
        queue_redraw()
        return
    var selected_idx: int = find_unit_by_id(selected_id)
    if selected_idx < 0 or int(units[selected_idx]["hp"]) <= 0:
        status_message = "Select one of your living blue operatives first."
        queue_redraw()
        return
    if int(units[selected_idx]["ap"]) <= 0:
        status_message = "This unit has no AP left; select another operative or End Turn."
        queue_redraw()
        return
    if mission_object_at(tile):
        objective_action(selected_idx, tile)
        queue_redraw()
        return
    if barrel_is_active(tile):
        attack_barrel(selected_idx, tile)
        queue_redraw()
        return
    if radio_is_present() and tile == RADIO_POS:
        if not radio_is_active():
            status_message = "Radio Transmitter already destroyed."
        else:
            attack_radio(selected_idx)
        queue_redraw()
        return
    if clicked_unit_idx >= 0:
        if can_attack(selected_idx, clicked_unit_idx):
            perform_attack(selected_idx, clicked_unit_idx)
        else:
            status_message = str(attack_preview(selected_idx, clicked_unit_idx)["reason"]) + "."
        queue_redraw()
        return
    var valid_tiles: Dictionary = reachable(units[selected_idx]["pos"], int(units[selected_idx]["move"]), selected_id)
    if valid_tiles.has(tile) and tile != units[selected_idx]["pos"]:
        move_unit(selected_idx, tile, int(valid_tiles[tile]))
        status_message = "%s moves. %d AP remaining." % [str(units[selected_idx]["name"]), int(units[selected_idx]["ap"])]
        add_log(str(units[selected_idx]["name"]) + " moves.")
    elif walls.has(tile):
        status_message = "Solid wall: blocks movement and line of sight."
    else:
        status_message = "Out of reach. Green squares show movement up to 4 tiles for 1 AP."
    queue_redraw()

func end_player_turn() -> void:
    if game_over or room_cleared or side_to_play != "player":
        return
    # The third full player turn ends here; if radio still broadcasts, the
    # consequence is permanent even if the player destroys it later.
    if test_mission_id == "chain" and mission_stage == 1 and turn_number >= RADIO_DEADLINE_ROUND and not bool(radio_state.get("destroyed_in_time", false)):
        queue_radio_alert("three player turns elapsed")
    run_mission_events("player_end")
    loadout_action = ""
    special_mode = false
    shred_landing_tile = Vector2i(-1, -1)
    side_to_play = "enemy"
    clear_reactions_for_team("enemy")
    refill_armour_for_team("enemy")
    process_environment_phase("enemy")
    if game_over or room_cleared:
        return
    run_mission_events("enemy_start")
    ai_focus_id = choose_enemy_focus() if smart_ai_enabled else -1
    add_log("Enemy phase begins (%s)." % ["TACTICAL" if smart_ai_enabled else "LEGACY"])
    if smart_ai_enabled and ai_debug_enabled and ai_focus_id >= 0:
        add_log("AI coordinated focus: " + str(units[ai_focus_id]["name"]))
    enemy_action_order.clear()
    # A support specialist acts before its horde so its serum can meaningfully
    # influence the charge; all units still receive only their own AP.
    var phase_order: Array[int] = []
    for kind in ["support", "boss", "horde", "ranged"]:
        for idx in range(5, units.size()):
            if str(units[idx].get("kind", "ranged")) == kind:
                phase_order.append(idx)
    var alive_enemies: int = 0
    for enemy_idx in phase_order:
        if units[enemy_idx]["team"] != "enemy" or int(units[enemy_idx]["hp"]) <= 0:
            continue
        alive_enemies += 1
        # Iskra's disruption reduces the actual AP available this phase.
        units[enemy_idx]["ap"] = maxi(0, int(units[enemy_idx]["max_ap"]) - int(units[enemy_idx]["jammed_actions"]))
        units[enemy_idx]["jammed_actions"] = 0
        # Two slots per enemy; skipped automatically if jammed or no AP.
        for _step in range(int(units[enemy_idx]["max_ap"])):
            enemy_action_order.append(enemy_idx)
    enemy_action_cursor = 0
    enemy_action_count = 0
    last_acting_enemy = -1
    enemy_action_timer = 0.18
    status_message = "Enemy phase: %d opponents, including move-triggered player reactions." % alive_enemies
    queue_redraw()

func _process(delta: float) -> void:
    if headquarters.visible or mission_picker_open or loadout_open:
        return
    if not damage_floaters.is_empty():
        for i in range(damage_floaters.size() - 1, -1, -1):
            var popup: Dictionary = damage_floaters[i]
            popup["ttl"] = float(popup["ttl"]) - delta
            damage_floaters[i] = popup
            if float(popup["ttl"]) <= 0.0:
                damage_floaters.remove_at(i)
        queue_redraw()
    if not movement_task.is_empty():
        movement_tick -= delta
        if movement_tick <= 0.0:
            movement_tick = MOVEMENT_STEP_SECONDS
            advance_movement_task()
            queue_redraw()
        return
    if game_over or room_cleared or side_to_play != "enemy":
        return
    enemy_action_timer -= delta
    if enemy_action_timer > 0.0:
        return
    if enemy_action_cursor >= enemy_action_order.size():
        finish_enemy_phase()
        return
    var enemy_idx: int = enemy_action_order[enemy_action_cursor]
    enemy_action_cursor += 1
    last_acting_enemy = enemy_idx
    if int(units[enemy_idx]["hp"]) > 0 and int(units[enemy_idx]["ap"]) > 0:
        var fleeing: bool = bool(units[enemy_idx].get("mission_target", false)) and bool(mission_flags.get("escape_active", false))
        if not fleeing and not has_attack_ammo(enemy_idx):
            reload_weapon(enemy_idx)
        elif test_mission_id == "defence":
            defence_enemy_step(enemy_idx)
        elif bool(units[enemy_idx].get("mission_target", false)) and test_mission_id == "assassination":
            fleeing_officer_step(enemy_idx)
        elif str(units[enemy_idx].get("kind", "ranged")) == "horde":
            horde_enemy_step(enemy_idx)
        elif str(units[enemy_idx].get("kind", "ranged")) == "support":
            support_enemy_step(enemy_idx)
        elif str(units[enemy_idx].get("kind", "ranged")) == "boss":
            boss_enemy_step(enemy_idx)
        elif smart_ai_enabled:
            smart_enemy_step(enemy_idx)
        else:
            var target_idx: int = nearest_attackable_player(enemy_idx)
            if target_idx >= 0:
                perform_attack(enemy_idx, target_idx)
                ai_shot_count += 1
            elif enemy_move(enemy_idx):
                ai_move_count += 1
        enemy_action_count += 1
    enemy_action_timer = 0.13 if str(units[enemy_idx].get("kind", "")) == "horde" else 0.23
    queue_redraw()

func finish_enemy_phase() -> void:
    if game_over:
        return
    if test_mission_id == "assassination" and mission_stage == 2 and bool(mission_flags.get("escape_active", false)):
        for i in range(units.size()):
            if bool(units[i].get("mission_target", false)) and int(units[i]["hp"]) > 0 and units[i]["pos"] == ESCAPE_EXIT:
                officer_escapes(i)
                if game_over:
                    return
    if test_mission_id == "defence" and turn_number >= DEFENCE_LAST_ROUND:
        complete_test_mission(int(mission_objects[DEFENCE_HQ_POS]["hp"]) > 0)
        return
    turn_number += 1
    side_to_play = "player"
    recover_downed_operatives()
    clear_reactions_for_team("player")
    refill_armour_for_team("player")
    for idx in range(units.size()):
        if units[idx]["team"] == "player" and int(units[idx]["hp"]) > 0:
            units[idx]["ap"] = int(units[idx]["max_ap"])
    age_hazards()
    run_mission_events("player_start")
    process_environment_phase("player")
    if game_over or room_cleared:
        return
    last_acting_enemy = -1
    status_message = "Your turn %d. Choose among your five squad roles." % turn_number
    add_log("Player turn %d." % turn_number)
    queue_redraw()

func nearest_attackable_player(enemy_idx: int) -> int:
    var best_idx: int = -1
    var best_health: int = 99999
    for idx in range(units.size()):
        if units[idx]["team"] != "player" or int(units[idx]["hp"]) <= 0:
            continue
        if can_attack(enemy_idx, idx) and int(units[idx]["hp"]) < best_health:
            best_health = int(units[idx]["hp"])
            best_idx = idx
    return best_idx

func enemy_move(enemy_idx: int) -> bool:
    var unit: Dictionary = units[enemy_idx]
    var possible: Dictionary = reachable(unit["pos"], MOVE_DISTANCE, int(unit["id"]))
    var best_tile: Vector2i = unit["pos"]
    var best_score: float = 100000.0
    for candidate in possible.keys():
        var candidate_tile: Vector2i = candidate
        var nearest_distance: int = 9999
        for opponent in units:
            if opponent["team"] == "player" and int(opponent["hp"]) > 0:
                nearest_distance = mini(nearest_distance, grid_distance(candidate_tile, opponent["pos"]))
        # Minor preference for positions that offer clear shots.
        var score: float = float(nearest_distance)
        for opponent in units:
            if opponent["team"] == "player" and int(opponent["hp"]) > 0:
                if has_line_of_sight(candidate_tile, opponent["pos"]) and grid_distance(candidate_tile, opponent["pos"]) <= int(unit["range"]):
                    score -= 0.8
                    break
        # Modest preference for cover against the nearest visible threat.
        for opponent in units:
            if opponent["team"] == "player" and int(opponent["hp"]) > 0:
                if grid_distance(candidate_tile, opponent["pos"]) == nearest_distance:
                    score -= 0.65 * float(cover_level_at(candidate_tile, opponent["pos"]))
                    break
        if score < best_score:
            best_score = score
            best_tile = candidate_tile
    if best_tile == unit["pos"]:
        return false
    move_unit(enemy_idx, best_tile, int(possible[best_tile]))
    add_log(str(unit["name"]) + " advances.")
    return true


# -----------------------------------------------------------------------------
# BUILD 05: TACTICAL ENEMY AI. Each enemy gets the SAME 2 AP / 4 tiles / attacks
# and the same LOS, armour, cover and movement legality checks as the player.
# Scores plans of up to TWO actions; no damage/AP/stat cheats and no fog-of-war
# knowledge beyond the fully revealed board in this proof of concept.
# -----------------------------------------------------------------------------
func choose_enemy_focus() -> int:
    # Lightweight fire coordination: a wounded/dangerous player is an attractive
    # shared target, not a mandatory target, and unreachable targets are ignored
    # by each local attack planner. Does not grant enemies any special knowledge.
    var winner_idx: int = -1
    var winner_score: float = -100000.0
    for idx in range(units.size()):
        if units[idx]["team"] != "player" or int(units[idx]["hp"]) <= 0:
            continue
        var reachable_by_someone: bool = false
        for enemy_idx in range(5, units.size()):
            if int(units[enemy_idx]["hp"]) <= 0:
                continue
            if bool(attack_preview(enemy_idx, idx)["valid"]):
                reachable_by_someone = true
                break
        if not reachable_by_someone:
            continue
        var e_hp: int = int(units[idx]["hp"])
        var e_armour: int = int(units[idx]["armour"])
        var e_damage: int = int(units[idx]["damage"])
        var score: float = 20.0 - float(e_hp) - float(e_armour) * 0.6 + float(e_damage) * 0.7
        if score > winner_score:
            winner_score = score
            winner_idx = idx
    return winner_idx

func ai_profile_params(enemy_idx: int) -> Dictionary:
    # Trait weights are separated from the planning engine, so a future boss,
    # healer or guardian can use the same core with additional action choices.
    var profile: String = str(units[enemy_idx].get("ai_profile", "balanced"))
    var weights: Dictionary = {"survival": 1.0, "pursuit": 1.0, "damage": 1.0}
    match profile:
        "aggressive":
            weights = {"survival": 0.65, "pursuit": 1.5, "damage": 1.12}
        "defensive":
            weights = {"survival": 1.55, "pursuit": 0.70, "damage": 0.96}
        "self_preserving":
            weights = {"survival": 1.85, "pursuit": 0.75, "damage": 0.96}
    var traits: Dictionary = units[enemy_idx].get("ai_traits", {})
    weights["survival"] = float(weights["survival"]) * float(traits.get("self_preservation", 1.0))
    return weights

func ai_incoming_threat(enemy_idx: int, destination: Vector2i) -> float:
    # Approximate predictable damage from the TWO most dangerous known player
    # shooters, evaluating shared-edge cover from each player's direction.
    var biggest: float = 0.0
    var second: float = 0.0
    for opponent in units:
        if opponent["team"] != "player" or int(opponent["hp"]) <= 0:
            continue
        if grid_distance(destination, opponent["pos"]) > int(opponent["range"]):
            continue
        if not has_line_of_sight(opponent["pos"], destination):
            continue
        var cover: int = cover_level_at(destination, opponent["pos"])
        var hit: float = float(maxi(1, int(opponent["damage"]) - cover))
        if hit > biggest:
            second = biggest
            biggest = hit
        elif hit > second:
            second = hit
    return biggest + second * 0.6

func ai_position_score(enemy_idx: int, destination: Vector2i) -> float:
    var parameters: Dictionary = ai_profile_params(enemy_idx)
    var nearest: int = 1000
    var nearest_idx: int = -1
    for idx in range(5):
        if int(units[idx]["hp"]) <= 0:
            continue
        var distance: int = grid_distance(destination, units[idx]["pos"])
        if distance < nearest:
            nearest = distance
            nearest_idx = idx
    if nearest_idx < 0:
        return 0.0
    var threat: float = ai_incoming_threat(enemy_idx, destination)
    var health_ratio: float = float(units[enemy_idx]["hp"]) / float(maxi(1, int(units[enemy_idx]["max_hp"])))
    # Wounded units care more about not exposing themselves; the officer
    # explicitly has a higher self-preservation trait.
    var wounded_factor: float = 1.0 + (1.0 - health_ratio) * 0.8
    var survival: float = float(parameters["survival"])
    var pursuit: float = float(parameters["pursuit"])
    var weapon_range: int = int(units[enemy_idx]["range"])
    var range_gap: int = maxi(0, nearest - weapon_range)
    var distance_value: float = -0.95 * float(range_gap) - 0.08 * float(absi(nearest - mini(weapon_range, 4)))
    var adjacent_cover: int = cover_level_at(destination, units[nearest_idx]["pos"])
    var cover_bonus: float = float(adjacent_cover) * 0.55 * survival
    return pursuit * distance_value - threat * survival * wounded_factor * 0.88 + cover_bonus - (12.0 if hazards.has(destination) else 0.0)

func ai_shot_value(enemy_idx: int, target_idx: int, shot_damage: int, target_hp: int, target_armour: int) -> float:
    if target_hp <= 0:
        return -10000.0
    var effective_armour: int = mini(target_armour, shot_damage)
    var effective_hp: int = mini(target_hp, maxi(0, shot_damage - effective_armour))
    var target_max_hp: int = int(units[target_idx]["max_hp"])
    var value: float = float(effective_hp) * 5.0 + float(effective_armour) * 1.45
    if effective_hp >= target_hp and effective_hp > 0:
        value += 8.0  # Finish a player unit, rather than letting it act again.
    if target_idx == ai_focus_id:
        value += 1.6
    # Small preference for already-wounded threats, and dangerous shooters.
    value += 0.9 * (1.0 - float(target_hp) / float(maxi(1, target_max_hp)))
    value += float(units[target_idx]["damage"]) * 0.30
    var parameters: Dictionary = ai_profile_params(enemy_idx)
    return value * float(parameters["damage"])

func ai_best_fire_plan(enemy_idx: int, origin_tile: Vector2i, shots: int) -> Dictionary:
    # Evaluate every first target and every possible second target. Armour and
    # HP are simulated after the first hit so we don't double-count a kill or
    # waste a shot on a model already incapacitated.
    var best: Dictionary = {"score": 0.0, "first": -1, "second": -1}
    if int(units[enemy_idx]["magazine_capacity"]) > 0:
        shots = mini(shots, int(units[enemy_idx]["rounds"]))
    if shots <= 0:
        return best
    for first_idx in range(5):
        if int(units[first_idx]["hp"]) <= 0:
            continue
        var first_preview: Dictionary = attack_preview_from(enemy_idx, first_idx, origin_tile)
        if not bool(first_preview["valid"]):
            continue
        var first_damage: int = int(first_preview["damage"])
        var first_hp: int = int(units[first_idx]["hp"])
        var first_arm: int = int(units[first_idx]["armour"])
        var first_arm_hit: int = mini(first_arm, first_damage)
        var first_hp_hit: int = mini(first_hp, maxi(0, first_damage - first_arm_hit))
        var first_score: float = ai_shot_value(enemy_idx, first_idx, first_damage, first_hp, first_arm)
        if first_score > float(best["score"]):
            best = {"score": first_score, "first": first_idx, "second": -1}
        if shots < 2:
            continue
        for second_idx in range(5):
            if int(units[second_idx]["hp"]) <= 0:
                continue
            var second_hp: int = int(units[second_idx]["hp"])
            var second_arm: int = int(units[second_idx]["armour"])
            if second_idx == first_idx:
                second_hp = first_hp - first_hp_hit
                second_arm = first_arm - first_arm_hit
            if second_hp <= 0:
                continue
            var second_preview: Dictionary = attack_preview_from(enemy_idx, second_idx, origin_tile)
            if not bool(second_preview["valid"]):
                continue
            var second_score: float = ai_shot_value(enemy_idx, second_idx, int(second_preview["damage"]), second_hp, second_arm)
            var combined: float = first_score + second_score
            if combined > float(best["score"]):
                best = {"score": combined, "first": first_idx, "second": second_idx}
    return best

func smart_choose_action(enemy_idx: int) -> Dictionary:
    var source: Vector2i = units[enemy_idx]["pos"]
    var ap: int = int(units[enemy_idx]["ap"])
    var origin_position_score: float = ai_position_score(enemy_idx, source)
    var base_fire: Dictionary = ai_best_fire_plan(enemy_idx, source, ap)
    var origin_shot_idx: int = int(base_fire["first"])
    var best_action: Dictionary = {"kind": "hold", "tile": source, "target": -1, "score": origin_position_score, "reason": "holds position"}
    if origin_shot_idx >= 0:
        best_action = {"kind": "shoot", "tile": source, "target": origin_shot_idx, "score": float(base_fire["score"]) + origin_position_score, "reason": "fires from current cover"}
    var options: Dictionary = reachable(source, MOVE_DISTANCE, int(units[enemy_idx]["id"]))
    for candidate in options.keys():
        var tile: Vector2i = candidate
        if tile == source:
            continue
        var position_score: float = ai_position_score(enemy_idx, tile)
        # The cost of movement itself is small; the lost attack is accounted
        # for by allocating fewer shots in the rest-of-turn plan.
        var move_score: float = position_score - 0.45
        # With one AP, new cover/closer range may be worth giving up a shot.
        # This can also help stuck enemies get into range over successive turns.
        if ap == 1:
            var later: Dictionary = ai_best_fire_plan(enemy_idx, tile, 1)
            move_score += 0.15 * float(later["score"])
        # With two AP, evaluate moving then firing: 1 move + 1 shot.
        if ap >= 2:
            var move_fire: Dictionary = ai_best_fire_plan(enemy_idx, tile, 1)
            move_score += float(move_fire["score"])
            if origin_shot_idx >= 0:
                # Also compare firing first and then moving, while replanning
                # after the first real shot. No premature movement is required.
                var shoot_move: float = float(ai_best_fire_plan(enemy_idx, source, 1)["score"]) + position_score - 0.45
                if shoot_move > float(best_action["score"]):
                    best_action = {"kind": "shoot", "tile": source, "target": origin_shot_idx, "score": shoot_move, "reason": "shoots before repositioning"}
        if move_score > float(best_action["score"]) + 0.15:
            var reason: String = "seeks a firing angle"
            if ai_incoming_threat(enemy_idx, tile) + 0.5 < ai_incoming_threat(enemy_idx, source):
                reason = "seeks safer cover"
            elif int(ai_best_fire_plan(enemy_idx, tile, 1)["first"]) >= 0:
                reason = "repositions for a stronger shot"
            best_action = {"kind": "move", "tile": tile, "target": -1, "score": move_score, "reason": reason}
    return best_action

func smart_enemy_step(enemy_idx: int) -> void:
    if not has_attack_ammo(enemy_idx):
        reload_weapon(enemy_idx)
        return
    var action: Dictionary = smart_choose_action(enemy_idx)
    var name: String = str(units[enemy_idx]["name"])
    var profile: String = str(units[enemy_idx].get("ai_profile", "balanced"))
    var kind: String = str(action["kind"])
    var reason: String = str(action["reason"])
    ai_last_decision = "%s (%s): %s" % [name, profile, reason]
    if kind == "shoot":
        var target_idx: int = int(action["target"])
        if target_idx >= 0 and bool(attack_preview(enemy_idx, target_idx)["valid"]):
            if cover_level_at(units[target_idx]["pos"], units[enemy_idx]["pos"]) == 0:
                ai_flank_count += 1
            perform_attack(enemy_idx, target_idx)
            ai_shot_count += 1
        else:
            units[enemy_idx]["ap"] = maxi(0, int(units[enemy_idx]["ap"]) - 1)
            reason = "lost its firing opportunity"
    elif kind == "move":
        var dest: Vector2i = action["tile"]
        if tile_is_open(dest, int(units[enemy_idx]["id"])) and reachable(units[enemy_idx]["pos"], MOVE_DISTANCE, int(units[enemy_idx]["id"])).has(dest):
            var steps: int = int(reachable(units[enemy_idx]["pos"], MOVE_DISTANCE, int(units[enemy_idx]["id"]))[dest])
            move_unit(enemy_idx, dest, steps)
            ai_move_count += 1
            add_log("%s %s." % [name, reason])
            status_message = "%s %s." % [name, reason]
        else:
            units[enemy_idx]["ap"] = maxi(0, int(units[enemy_idx]["ap"]) - 1)
            reason = "could not move"
    else:
        # Ranged enemies threaten an approach rather than silently wasting AP.
        if not bool(units[enemy_idx].get("reaction_available", false)) and reserve_reaction(enemy_idx, "overwatch"):
            reason = "reserves overwatch"
        else:
            units[enemy_idx]["ap"] = 0
            reason = "holds a defensible position"
            add_log("%s holds position." % name)
    ai_last_decision = "%s (%s): %s" % [name, profile, reason]
    if ai_debug_enabled:
        add_log("AI %s [%.1f]" % [ai_last_decision, float(action["score"])])

func horde_enemy_step(idx: int) -> void:
    # Intentionally stupid but threatening: no evaluation of own survival,
    # player firepower, cover or retaliation. Runs toward nearest live target.
    var best_target: int = -1
    var best_value: float = 100000.0
    for player_idx in range(5):
        if int(units[player_idx]["hp"]) <= 0:
            continue
        var dist: int = grid_distance(units[idx]["pos"], units[player_idx]["pos"])
        var value: float = float(dist) + 0.08 * float(units[player_idx]["hp"])
        if value < best_value:
            best_value = value
            best_target = player_idx
    if best_target < 0:
        units[idx]["ap"] = 0
        return
    # Bite directly if adjacent; this ignores directional ranged cover.
    if bool(attack_preview(idx, best_target)["valid"]):
        perform_attack(idx, best_target)
        ai_shot_count += 1
        ai_last_decision = str(units[idx]["name"]) + ": bites the nearest prey"
        return
    var options: Dictionary = reachable(units[idx]["pos"], HORDE_MOVE_DISTANCE, int(units[idx]["id"]))
    var best_tile: Vector2i = units[idx]["pos"]
    var nearest: int = grid_distance(best_tile, units[best_target]["pos"])
    var best_steps: int = -1
    for candidate in options.keys():
        var tile: Vector2i = candidate
        var dist: int = grid_distance(tile, units[best_target]["pos"])
        var steps: int = int(options[tile])
        if dist < nearest or (dist == nearest and steps > best_steps):
            best_tile = tile
            nearest = dist
            best_steps = steps
    if best_tile != units[idx]["pos"]:
        move_unit(idx, best_tile, int(options[best_tile]))
        ai_move_count += 1
        ai_last_decision = str(units[idx]["name"]) + ": charges straight toward prey"
        add_log(str(units[idx]["name"]) + " charges (%d tiles)." % int(options[best_tile]))
    else:
        units[idx]["ap"] = 0
        ai_last_decision = str(units[idx]["name"]) + ": blocked by crowd"

func support_cover_value(idx: int, tile: Vector2i) -> float:
    # Measure actual cover from ALL living players, not just tile decoration.
    # A physical barrier must face an attacker to count as useful protection.
    var total: float = 0.0
    for player_idx in range(5):
        if int(units[player_idx]["hp"]) <= 0:
            continue
        var dist: int = grid_distance(tile, units[player_idx]["pos"])
        var value: int = cover_level_at(tile, units[player_idx]["pos"])
        if value > 0:
            total += float(value) * (3.0 if dist <= int(units[player_idx]["range"]) else 0.9)
    return total

func support_best_cover(idx: int) -> Dictionary:
    var origin: Vector2i = units[idx]["pos"]
    var paths: Dictionary = reachable(origin, MOVE_DISTANCE, int(units[idx]["id"]))
    var best: Vector2i = origin
    var best_score: float = -100000.0
    var origin_score: float = support_cover_value(idx, origin)
    # Prefer actual *effective* cover (relative to player firing lanes) to
    # any uncovered square. Evaluate survival and ally distance after that.
    var covered_tiles_exist: bool = false
    for option in paths.keys():
        if support_cover_value(idx, option) > 0.1:
            covered_tiles_exist = true
            break
    for option in paths.keys():
        var tile: Vector2i = option
        var protection: float = support_cover_value(idx, tile)
        var incoming: float = ai_incoming_threat(idx, tile)
        var closest_friend: int = 99
        for ally in range(5, units.size()):
            if ally != idx and int(units[ally]["hp"]) > 0:
                closest_friend = mini(closest_friend, grid_distance(tile, units[ally]["pos"]))
        # A support unit must remain within working distance of the frontline.
        # Cover is a bonus, never a reason to abandon every ally.
        var front_distance: int = 99
        for friend_idx in range(5, units.size()):
            if friend_idx == idx or int(units[friend_idx]["hp"]) <= 0:
                continue
            var friend_nearest_player: int = 99
            for player_idx in range(5):
                if int(units[player_idx]["hp"]) > 0:
                    friend_nearest_player = mini(friend_nearest_player, grid_distance(units[friend_idx]["pos"], units[player_idx]["pos"]))
            if friend_nearest_player <= 7:
                front_distance = mini(front_distance, grid_distance(tile, units[friend_idx]["pos"]))
        var value: float = 0.85 * protection - 0.50 * incoming - 2.4 * float(maxi(0, closest_friend - 3))
        if front_distance < 99:
            value -= 3.0 * float(maxi(0, front_distance - SUPPORT_RANGE))
        else:
            value -= 0.8 * float(maxi(0, closest_friend - SUPPORT_RANGE))
        if hazards.has(tile):
            value -= 15.0
        if tile != origin:
            value -= 1.0  # avoid dithering between comparably safe tiles
        if value > best_score:
            best_score = value
            best = tile
    return {"tile": best, "cover_score": support_cover_value(idx, best), "origin_score": origin_score}

func support_has_valid_target(idx: int) -> bool:
    if int(units[idx]["ap"]) < SUPPORT_COST:
        return false
    for ally_idx in range(5, units.size()):
        if ally_idx == idx or int(units[ally_idx]["hp"]) <= 0:
            continue
        if grid_distance(units[idx]["pos"], units[ally_idx]["pos"]) <= SUPPORT_RANGE:
            if int(units[ally_idx]["hp"]) < int(units[ally_idx]["max_hp"]) or int(units[ally_idx].get("stim_bonus", 0)) == 0:
                return true
    return false

func support_enemy_step(idx: int) -> void:
    var ap: int = int(units[idx]["ap"])
    var current: Vector2i = units[idx]["pos"]
    var cover_plan: Dictionary = support_best_cover(idx)
    var cover_here: float = float(cover_plan["origin_score"])
    var cover_there: float = float(cover_plan["cover_score"])
    var safe_tile: Vector2i = cover_plan["tile"]
    # Stay near allies rather than camping irrelevant far-away cover.
    # Reposition only when there is no immediate meaningful 1 AP support action.
    if safe_tile != current and not support_has_valid_target(idx) and (cover_there > cover_here + 0.2 or (cover_here < 0.1 and cover_there > 0.1)):
        var path: Dictionary = reachable(current, MOVE_DISTANCE, int(units[idx]["id"]))
        if path.has(safe_tile):
            move_unit(idx, safe_tile, int(path[safe_tile]))
            ai_move_count += 1
            ai_last_decision = "Biotechnician: seeks cover before supporting"
            status_message = str(units[idx]["name"]) + " moves into cover."
            add_log(status_message)
            return
    # Each support action now costs 1 AP, leaving another AP for a follow-up.
    if ap >= SUPPORT_COST:
        var heal_idx: int = -1
        var heal_score: float = 0.0
        for ally_idx in range(5, units.size()):
            if ally_idx == idx or int(units[ally_idx]["hp"]) <= 0:
                continue
            if grid_distance(current, units[ally_idx]["pos"]) > SUPPORT_RANGE:
                continue
            var missing: int = int(units[ally_idx]["max_hp"]) - int(units[ally_idx]["hp"])
            if missing <= 0:
                continue
            var score: float = float(mini(3, missing)) + (1.0 if str(units[ally_idx].get("kind", "")) == "ranged" else 0.0)
            if score > heal_score:
                heal_idx = ally_idx
                heal_score = score
        if heal_idx >= 0 and apply_healing(idx, heal_idx, 3, "Field Regenerator"):
            units[idx]["ap"] = ap - SUPPORT_COST
            ai_last_decision = "Biotechnician: heals ally (range 4, 1 AP)"
            return
        var buff_idx: int = -1
        var buff_score: float = -9999.0
        for ally_idx in range(5, units.size()):
            if ally_idx == idx or int(units[ally_idx]["hp"]) <= 0:
                continue
            if grid_distance(current, units[ally_idx]["pos"]) > SUPPORT_RANGE:
                continue
            if int(units[ally_idx]["stim_bonus"]) > 0:
                continue
            var nearest_player: int = 99
            for player_idx in range(5):
                if int(units[player_idx]["hp"]) > 0:
                    nearest_player = mini(nearest_player, grid_distance(units[ally_idx]["pos"], units[player_idx]["pos"]))
            var score: float = 9.0 - float(nearest_player) + (1.0 if str(units[ally_idx].get("kind", "")) == "horde" else 0.0)
            if score > buff_score:
                buff_score = score
                buff_idx = ally_idx
        if buff_idx >= 0:
            units[idx]["ap"] = ap - SUPPORT_COST
            units[buff_idx]["stim_bonus"] = 1
            battle_stats[idx]["buffs"] = int(battle_stats[idx]["buffs"]) + 1
            record_ability_use(idx, "Aggression Serum")
            ai_last_decision = "Biotechnician: buffs one ally's next attack (range 4, 1 AP)"
            status_message = "Biotechnician buffs %s's next attack: +1 damage." % str(units[buff_idx]["name"])
            add_log(status_message)
            return
    # When support is unavailable or AP is insufficient, use a WEAKER ranged
    # attack where sensible, while maintaining the safest position available.
    var target: int = nearest_attackable_player(idx)
    if target >= 0:
        perform_attack(idx, target)  # support pistol: 1 damage, 5 range, 1 AP
        ai_shot_count += 1
        ai_last_decision = "Biotechnician: fires weaker support pistol"
        return
    # If no support target and no shot, move closer to allies while preserving
    # cover where possible; remaining AP can be used next step for a pistol shot.
    if safe_tile != current:
        var path_after: Dictionary = reachable(current, MOVE_DISTANCE, int(units[idx]["id"]))
        if path_after.has(safe_tile):
            move_unit(idx, safe_tile, int(path_after[safe_tile]))
            ai_move_count += 1
            ai_last_decision = "Biotechnician: moves to better cover"
            return
    if not bool(units[idx].get("reaction_available", false)) and reserve_reaction(idx, "overwatch"):
        ai_last_decision = "Biotechnician: reserves overwatch from cover"
    else:
        units[idx]["ap"] = 0
        ai_last_decision = "Biotechnician: holds cover"

func boss_enemy_step(idx: int) -> void:
    # A one-time tactical retreat/shield command once the commander is wounded.
    # Unique behavior differentiates the boss beyond raw HP and damage.
    if not bool(units[idx].get("boss_emergency_used", false)) and int(units[idx]["hp"]) <= 9 and int(units[idx]["ap"]) >= 1:
        units[idx]["ap"] = int(units[idx]["ap"]) - 1
        units[idx]["boss_emergency_used"] = true
        if armour_enabled:
            units[idx]["armour"] = int(units[idx]["armour"]) + 2
        var protected_idx: int = -1
        var nearest: int = 999
        for ally_idx in range(5, units.size()):
            if ally_idx == idx or int(units[ally_idx]["hp"]) <= 0 or str(units[ally_idx].get("kind", "")) != "ranged":
                continue
            var distance: int = grid_distance(units[idx]["pos"], units[ally_idx]["pos"])
            if distance <= 4 and distance < nearest:
                nearest = distance
                protected_idx = ally_idx
        if protected_idx >= 0:
            units[protected_idx]["stim_bonus"] = 1
            battle_stats[idx]["buffs"] = int(battle_stats[idx]["buffs"]) + 1
        record_ability_use(idx, "Emergency Directive")
        status_message = "Voronov activates Emergency Directive: +2 self ARM, +1 ally next attack."
        add_log(status_message)
        ai_last_decision = "Commander: emergency shield and ally damage order"
        return
    if smart_ai_enabled:
        smart_enemy_step(idx)
    else:
        var target: int = nearest_attackable_player(idx)
        if target >= 0:
            perform_attack(idx, target)
        elif not bool(units[idx].get("reaction_available", false)):
            reserve_reaction(idx, "overwatch")
        else:
            units[idx]["ap"] = 0


func ability_description(idx: int) -> Array[String]:
    if idx == 0 and test_mission_id == "scythe":
        return ["CHARGE | 1 AP | once/turn", "Move up to %d tiles and strike one enemy for 2 damage." % scythe_charge_distance(), "Hostile Overwatch can stop Charge before the strike."]
    match operative_kit(idx):
        0: return ["AREA SHRED | 1 AP | once/turn", "Charge 0-3 steps, then sweep 3 adjacent tiles for 2 damage each.", "Charge can trigger enemy reactions; sweep ignores cover."]
        1: return ["FORTIFY | 1 AP | once/turn", "+2 temporary ARM to one ally (range 2) and Anvil.", "Bonuses expire at next player armour reset."]
        2: return ["PRECISION SHOT | 1 AP | once/turn", "Attack: base weapon damage +2; ignores 1 cover level.", "Uses normal weapon range and line of sight."]
        3: return ["ARC DISRUPTOR | 1 AP | CD: 1 turn", "Weapon damage +1; enemy loses 1 AP next phase.", "Cooldown next turn; normal weapon range and LOS."]
        4: return ["FIELD TREATMENT | 1 AP | CD: 1 turn", "Heal up to 3 HP, ally within 3 tiles.", "Cooldown next turn; cannot revive incapacitated allies."]
    return ["", "", ""]

func stat_damage(idx: int, field_prefix: String) -> int:
    return int(battle_stats[idx][field_prefix + "_hp"]) + int(battle_stats[idx][field_prefix + "_arm"])

func sorted_unit_indices(team: String) -> Array[int]:
    var result: Array[int] = []
    for i in range(units.size()):
        if units[i]["team"] == team:
            result.append(i)
    # Small fixed roster; straightforward sort avoids a custom-lambda dependency.
    for a in range(result.size()):
        for b in range(a + 1, result.size()):
            if stat_damage(result[b], "dealt") > stat_damage(result[a], "dealt"):
                var tmp: int = result[a]
                result[a] = result[b]
                result[b] = tmp
    return result

func total_team_damage(team: String) -> int:
    var total: int = 0
    for idx in range(units.size()):
        if units[idx]["team"] == team:
            total += stat_damage(idx, "dealt")
    return total

func leading_unit(team: String, category: String) -> int:
    var result: int = -1
    var high: int = -1
    for idx in range(units.size()):
        if units[idx]["team"] != team:
            continue
        var value: int = stat_damage(idx, category) if category in ["dealt", "taken"] else int(battle_stats[idx][category])
        if value > high:
            result = idx
            high = value
    return result

func team_reactions(team: String) -> int:
    var total: int = 0
    for idx in range(units.size()):
        if units[idx]["team"] == team:
            total += int(battle_stats[idx].get("reactions", 0))
    return total


func chain_sum(stat_name: String) -> int:
    var accumulated: int = 0
    for entry in room_history:
        accumulated += int(entry.get(stat_name, 0))
    return accumulated

func room_ability_summary(abilities: Dictionary) -> String:
    if abilities.is_empty():
        return "No signature ability used"
    var pieces: PackedStringArray = PackedStringArray()
    for key in abilities.keys():
        pieces.append("%s x%d" % [str(key), int(abilities[key])])
    return ", ".join(pieces)

func draw_room_activity(record: Dictionary, final_report: bool = false) -> void:
    # Every resolved player action is counted once. Damage/Hits are distinct:
    # Area Shred is one ability activation but may produce several hit events.
    draw_rect(Rect2(0, 0, 1460, 900), Color("#111d2b"))
    draw_rect(Rect2(98, 78, 1260, 760), Color("#203448"), true)
    draw_rect(Rect2(98, 78, 1260, 760), Color("#80bbad"), false, 2.0)
    var current_page: int = activity_room_page + 1 if final_report else mission_stage + 1
    var heading: String = "ROOM %d / %d — SQUAD ACTIVITY" % [current_page, mission_room_total()]
    draw_label(heading, Vector2(135, 127), 28, Color("#b6e8d1"))
    draw_label(str(record["name"]), Vector2(137, 163), 18, Color("#f6dfa8"))
    draw_label("Rounds %d   |   Squad damage %d   |   Enemy damage %d   |   Enemies defeated %d/%d" % [int(record["turns"]), int(record["player_damage"]), int(record["enemy_damage"]), int(record["enemies_defeated"]), int(record["enemy_count"])], Vector2(137, 198), 15, Color("#dae9f3"))
    draw_label("OPERATIVE / HEALTH", Vector2(141, 249), 13, Color("#91cbef"))
    draw_label("ACTIONS PERFORMED IN THIS ROOM", Vector2(356, 249), 13, Color("#91cbef"))
    draw_label("COMBAT CONTRIBUTION", Vector2(1041, 249), 13, Color("#91cbef"))
    var squad: Array = record["activity"]
    for idx in range(mini(5, squad.size())):
        var u: Dictionary = squad[idx]
        var yy: float = 267.0 + idx * 70.0
        draw_rect(Rect2(128, yy, 1202, 66), Color("#29455c") if idx % 2 == 0 else Color("#273d52"), true)
        draw_label(str(u["name"]), Vector2(142, yy + 22), 17, Color("#a7e4ff"))
        var hp_text: String = "HP %d/%d" % [int(u["hp"]), int(u["hp_cap"])]
        if bool(record["advances"]):
            hp_text += " -> %d" % int(u["next_hp"])
        if bool(u["dead"]):
            hp_text += "  LOST"
        elif int(u["hp"]) <= 0:
            hp_text += "  DOWNED"
        draw_label(hp_text, Vector2(142, yy + 45), 12, Color("#ffb7a3") if int(u["hp"]) <= 0 else Color("#b5e7cf"))
        draw_label("Basic attacks: %d  |  Moves: %d (%d tiles)  |  Overwatch: %d set / %d fired" % [int(u["basic_attacks"]), int(u["moves"]), int(u["tiles"]), int(u["overwatch_set"]), int(u["overwatch_triggered"])], Vector2(356, yy + 20), 12, Color("#e4edf5"))
        var extras: String = "Ability: %s   |   Heal %d  |  Buff %d" % [room_ability_summary(u["abilities"]), int(u["healing"]), int(u["buffs"])]
        if int(u["objective_damage"]) > 0:
            extras += "  |  OBJECTIVE dmg %d" % int(u["objective_damage"])
        if int(u.get("env_triggers", 0)) > 0 or int(u.get("cover_broken", 0)) > 0:
            extras += "  |  ENV %d / cover %d" % [int(u.get("env_triggers", 0)), int(u.get("cover_broken", 0))]
        draw_wrapped_label(extras, Vector2(356, yy + 42), 667.0, 11, Color("#c4dce9"), 13.0, 2)
        draw_label("Dealt %d  /  Taken %d" % [int(u["dealt_hp"]) + int(u["dealt_arm"]), int(u["taken_hp"]) + int(u["taken_arm"])], Vector2(1041, yy + 24), 12, Color("#dff2fd"))
        draw_label("Kills %d   |   HP hit %d" % [int(u["kills"]), int(u["dealt_hp"])], Vector2(1041, yy + 45), 12, Color("#ccdae8"))
    var footer: String = "Room 2 objective: " + str(record["radio"]) if test_mission_id == "chain" and current_page == 2 else "Mission: " + test_mission_id.to_upper() + " | Movement tiles include charged movement."
    var footer_warn: bool = test_mission_id == "chain" and current_page == 2 and bool(record["radio_bonus"])
    draw_label(footer, Vector2(142, 659), 15, Color("#ffb6a0") if footer_warn else Color("#bce5c8"))
    if not final_report:
        draw_label("Pending recoveries stand at half HP. Armour, AP and cooldowns reset. Magazines refill.", Vector2(142, 691), 14, Color("#d3e0ec"))
        draw_rect(NEXT_ROOM_BUTTON, Color("#2b806f"), true)
        draw_rect(NEXT_ROOM_BUTTON, Color("#9ce4d0"), false, 2.0)
        draw_label("CONTINUE TO ROOM %d  [ENTER]" % (mission_stage + 2), Vector2(570, 774), 19, Color.WHITE)
        var transition_navigation: String = "[E] Extract to HQ with secured rewards" if hq_deployment else "[R] Restart mission"
        draw_label("[L] This room's hit ledger   |   " + transition_navigation, Vector2(142, 816), 13, Color("#aac2d3"))
    else:
        draw_label("[LEFT/RIGHT] Review completed rooms    [P] Return to battle report", Vector2(142, 714), 14, Color("#d3e0ec"))
        draw_rect(REPORT_RESET, Color("#6a4e5b"), true)
        draw_label("HQ [F9]" if hq_deployment else "RESTART [R]", Vector2(1209, 836), 18, Color.WHITE)
        var activity_navigation: String = "[F9] Return to HQ" if hq_deployment else "[R] Restart selected mission   |   [M] Mission menu"
        draw_label("[L] Hit ledger: final room only   |   " + activity_navigation, Vector2(142, 815), 13, Color("#aac2d3"))

func draw_room_transition() -> void:
    if room_history.is_empty():
        return
    draw_room_activity(room_history.back())
    if show_hit_ledger:
        draw_hit_ledger()

func draw_battle_report() -> void:
    draw_rect(Rect2(22, 66, 1416, 807), Color("#19283b"), true)
    draw_rect(Rect2(22, 66, 1416, 807), Color("#8da5b7"), false, 2.0)
    draw_label("AFTER-ACTION REPORT  /  %s" % test_mission_id.to_upper(), Vector2(46, 108), 26, Color("#f5e5b4"))
    var outcome_heading: String = "MISSION OBJECTIVE ACHIEVED" if mission_victory else "MISSION OBJECTIVE FAILED"
    draw_label("%s  |  %d rounds in this room  |  %s AI" % [outcome_heading, turn_number, "TACTICAL" if smart_ai_enabled else "LEGACY"], Vector2(47, 145), 16, Color("#c8d6e2"))
    draw_label("Rebel damage: %d   Enemy damage: %d   Surviving rebels: %d/5   Defeated enemies: %d/%d" % [total_team_damage("player"), total_team_damage("enemy"), alive_count("player"), defeated_enemy_count(), units.size() - 5], Vector2(47, 173), 15, Color("#dce7ef"))
    var radio_consequence: String = "RADIO: ALERT SENT (+3 HOUNDS)" if radio_reinforcements_queued else "RADIO: NO ALERT"
    draw_label("ROOMS: %d/%d  |  %s" % [room_history.size(), mission_room_total(), get_objective_progress_line()], Vector2(47, 194), 12, Color("#a8d4bc"))
    # Three columns: player ranked by damage, enemy ranked by damage, abilities grouped across both teams.
    draw_rect(Rect2(42, 214, 405, 558), Color("#20354b"))
    draw_rect(Rect2(457, 214, 487, 558), Color("#20354b"))
    draw_rect(Rect2(954, 214, 462, 558), Color("#20354b"))
    draw_label("REBEL PERFORMANCE", Vector2(57, 241), 18, Color("#85d2ff"))
    draw_label("Rank / Operative     Dmg     Taken    Tiles    Kills", Vector2(57, 266), 12, Color("#a6bfd2"))
    var players: Array[int] = sorted_unit_indices("player")
    for n in range(players.size()):
        var idx: int = players[n]
        var s: Dictionary = battle_stats[idx]
        var y: float = 293.0 + n * 43.0
        draw_label("%d  %s%s" % [n+1, str(units[idx]["name"]), " (DOWN)" if int(units[idx]["hp"]) <= 0 else ""], Vector2(57, y), 13, Color("#87d0fc"))
        draw_label("%d       %d       %d       %d" % [stat_damage(idx,"dealt"), stat_damage(idx,"taken"), int(s["tiles"]), int(s["kills"])], Vector2(265, y), 12, Color("#dfe8f2"))
        draw_label("HP %d + ARM %d dealt  |  Heal %d  |  Buff %d" % [int(s["dealt_hp"]), int(s["dealt_arm"]), int(s["healing"]), int(s["buffs"])], Vector2(72, y+17), 11, Color("#aebfcf"))
    draw_line(Vector2(57, 528), Vector2(430, 528), Color("#4c6378"), 1.0)
    draw_label("BATTLE LEADERS", Vector2(57, 551), 17, Color("#f0d8a8"))
    var rebel_tank: int = leading_unit("player", "taken")
    var rebel_runner: int = leading_unit("player", "tiles")
    var enemy_attacker: int = leading_unit("enemy", "dealt")
    draw_label("Most damage taken (rebel): %s (%d)" % [str(units[rebel_tank]["name"]), stat_damage(rebel_tank,"taken")], Vector2(57, 580), 12, Color("#cad8e4"))
    draw_label("Longest march (rebel): %s (%d tiles)" % [str(units[rebel_runner]["name"]), int(battle_stats[rebel_runner]["tiles"])], Vector2(57, 604), 12, Color("#cad8e4"))
    draw_label("Top enemy attacker: %s (%d)" % [str(units[enemy_attacker]["name"]), stat_damage(enemy_attacker,"dealt")], Vector2(57, 628), 12, Color("#cad8e4"))
    draw_label("Movement counts actual traversed tiles. Reactions:", Vector2(57, 664), 12, Color("#a7bace"))
    draw_label("Rebels %d   |   Enemies %d" % [team_reactions("player"), team_reactions("enemy")], Vector2(57, 679), 11, Color("#a7bace"))
    var movement_note: String = "Hounds: 4 HP, move 5/AP. Others: 4/AP."
    if test_mission_id == "scythe" and scythe_origin == "Arachnid":
        movement_note = "Hounds and Arachnid: move 5/AP. Others: 4/AP."
    draw_label(movement_note, Vector2(57, 701), 12, Color("#a7bace"))
    draw_label("Hit ledger [L] — %s" % ledger_audit_text(), Vector2(57, 727), 12, Color("#9de4b2") if ledger_audit_text() == "RECONCILED" else Color("#ff9999"))
    draw_label("TOTAL: %d rooms | %d rebel dmg | %d enemy dmg" % [room_history.size(), chain_sum("player_damage"), chain_sum("enemy_damage")], Vector2(57, 752), 11, Color("#f0dbad"))
    draw_label("ENEMY PERFORMANCE", Vector2(473, 241), 18, Color("#ffab9e"))
    draw_label("Rank / Enemy                    Dmg   Taken   Tiles   Kills", Vector2(473, 266), 12, Color("#a6bfd2"))
    var enemies: Array[int] = sorted_unit_indices("enemy")
    for n in range(mini(enemies.size(), 14)):
        var idx: int = enemies[n]
        var st: Dictionary = battle_stats[idx]
        var y: float = 289.0 + n * 31.0
        var label: String = str(units[idx]["name"])
        draw_label("%2d  %s" % [n+1, label], Vector2(473, y), 12, Color("#efa69d") if int(units[idx]["hp"]) > 0 else Color("#8a98a6"))
        draw_label("%d    %d    %d    %d" % [stat_damage(idx, "dealt"), stat_damage(idx, "taken"), int(st["tiles"]), int(st["kills"])], Vector2(780, y), 12, Color("#d9e4ed"))
    draw_label("ABILITY DAMAGE RANKING", Vector2(970, 241), 18, Color("#edce9d"))
    draw_label("Actual HP + armour damage by ability; both sides", Vector2(970, 263), 12, Color("#a6bfd2"))
    var ability_keys: Array = ability_damage_totals.keys()
    for a in range(ability_keys.size()):
        for b in range(a + 1, ability_keys.size()):
            if int(ability_damage_totals[ability_keys[b]]) > int(ability_damage_totals[ability_keys[a]]):
                var tmp: Variant = ability_keys[a]
                ability_keys[a] = ability_keys[b]
                ability_keys[b] = tmp
    for n in range(mini(ability_keys.size(), 18)):
        var key: String = str(ability_keys[n])
        var total: int = int(ability_damage_totals[key])
        var used: int = int(ability_use_totals.get(key, 0))
        var y: float = 291.0 + n * 23.0
        draw_label("%2d  %s" % [n+1, key.substr(0, 35)], Vector2(970, y), 12, Color("#88d1ff") if key.begins_with("REBEL") else Color("#ffae9f"))
        draw_label("%d dmg / %d" % [total, used], Vector2(1312, y), 11, Color("#e9e2c8"))
    draw_label("Heal and buffs are counted for units, not as damage.", Vector2(970, 740), 11, Color("#a6bfd2"))
    draw_rect(REPORT_RESET, Color("#6a4e5b"))
    draw_label("HQ [F9]" if hq_deployment else "RESTART [R]", Vector2(1209, 836), 19, Color("#fffaf2"))
    var report_navigation: String = "  |  [F9] Return to HQ" if hq_deployment else "  |  [R] Restart"
    draw_label("[P] Squad activity by room  |  [V] Battlefield / Report  |  [L] Hit ledger" + report_navigation, Vector2(47, 832), 13, Color("#dbe7f0"))

func draw_label(text: String, position: Vector2, font_size: int = 16, color: Color = Color.WHITE) -> void:
    draw_string(ThemeDB.fallback_font, position, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)


func draw_wrapped_label(value: String, position: Vector2, max_width: float, font_size: int, color: Color, line_height: float = 16.0, max_lines: int = 4) -> int:
    # Wrap actual rendered text so long values never overlap the neighbouring panel.
    # Returns number of lines drawn; used by the selected-unit card.
    var words: PackedStringArray = value.split(" ", false)
    var line: String = ""
    var drawn: int = 0
    for word in words:
        var proposed: String = word if line.is_empty() else line + " " + word
        if not line.is_empty() and ThemeDB.fallback_font.get_string_size(proposed, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > max_width:
            draw_label(line, position + Vector2(0, float(drawn) * line_height), font_size, color)
            drawn += 1
            if drawn >= max_lines:
                return drawn
            line = word
        else:
            line = proposed
    if not line.is_empty() and drawn < max_lines:
        draw_label(line, position + Vector2(0, float(drawn) * line_height), font_size, color)
        drawn += 1
    return drawn

func selected_status_text(idx: int) -> String:
    # Only show active gameplay effects, not unused internal bookkeeping fields.
    var parts: PackedStringArray = PackedStringArray()
    var unit: Dictionary = units[idx]
    var hp_limit: int = recoverable_hp(unit)
    if hp_limit < int(unit["max_hp"]):
        parts.append("Wounded: %d HP cap" % hp_limit)
    if int(unit.get("stim_bonus", 0)) > 0:
        parts.append("Serum: +%d next attack" % int(unit["stim_bonus"]))
    if int(unit.get("jammed_actions", 0)) > 0:
        parts.append("Disrupted: -%d next phase AP" % int(unit["jammed_actions"]))
    if armour_enabled and int(unit["armour"]) > int(unit["max_armour"]):
        parts.append("Fortified: %d bonus ARM until refresh" % (int(unit["armour"]) - int(unit["max_armour"])))
    if bool(unit.get("reaction_available", false)):
        parts.append("RESERVED: " + str(unit.get("reaction_type", "")).to_upper())
    var active_effects: Dictionary = unit.get("statuses", {})
    for effect in active_effects.keys():
        if int(active_effects[effect]) > 0:
            parts.append("%s (%d)" % [str(effect).capitalize(), int(active_effects[effect])])
    if int(unit["hp"]) <= 0:
        parts.append("INCAPACITATED")
    if parts.is_empty():
        return "None"
    return "; ".join(parts)

func draw_selected_unit_card(idx: int) -> void:
    # Uses the space under the 22x16 battlefield rather than crowding the roster.
    var card: Rect2 = Rect2(445, 680, 370, 203)
    draw_rect(card, Color("#203144"), true)
    draw_rect(card, Color("#456174"), false, 1.0)
    draw_label("SELECTED OPERATIVE", Vector2(458, 701), 14, Color("#9db9cc"))
    if idx < 0 or idx >= units.size():
        draw_label("Select a rebel (1–5) to inspect.", Vector2(458, 731), 12, Color("#d4e4f1"))
        return
    var unit: Dictionary = units[idx]
    draw_label(str(unit["name"]).to_upper(), Vector2(458, 724), 18, Color("#8cd0ff"))
    draw_label("HP %d/%d   ARM %d/%d   AP %d/%d   WT %d" % [int(unit["hp"]), int(unit["max_hp"]), int(unit["armour"]) if armour_enabled else 0, int(unit["max_armour"]) if armour_enabled else 0, int(unit["ap"]), int(unit["max_ap"]), int(unit.get("weight", 2))], Vector2(458, 745), 12, Color("#e5eff8"))
    draw_label("Move: %d tiles/1 AP   |   Attack: %d DMG / %d tiles" % [int(unit["move"]), int(unit["damage"]), int(unit["range"])], Vector2(458, 762), 11, Color("#c4d7e5"))
    var effects: String = "Effects: " + selected_status_text(idx)
    draw_wrapped_label(effects, Vector2(458, 779), 340.0, 11, Color("#f1d9a1"), 13.0, 2)
    draw_line(Vector2(458, 796), Vector2(799, 796), Color("#547087"), 1.0)
    var info: Array[String] = ability_description(idx)
    var readystate: String = "AIMING" if special_mode else special_readiness_label(idx)
    var heading_lines: int = draw_wrapped_label("[Q] " + info[0] + "  [" + readystate + "]", Vector2(458, 812), 340.0, 11, Color("#f2d28c"), 13.0, 2)
    var line_y: float = 812.0 + float(heading_lines) * 13.0 + 3.0
    for entry in [info[1], info[2]]:
        var count: int = draw_wrapped_label(str(entry), Vector2(458, line_y), 339.0, 10, Color("#d8e3ed"), 12.0, 2)
        line_y += float(count) * 12.0
    draw_label("[O] Overwatch 1 AP  |  [B] Breach 1 AP / 4-tile line", Vector2(458, 872), 10, Color("#a5d9be"))

func draw_base_attack_links(idx: int) -> void:
    # The standard weapon preview is the sole source of truth for range / LOS.
    # Draw links behind tokens; only enemies actually within range get rings.
    if idx < 0 or idx >= units.size() or int(units[idx]["hp"]) <= 0:
        return
    var origin: Vector2i = units[idx]["pos"]
    var from_center: Vector2 = ORIGIN + Vector2((float(origin.x) + 0.5) * TILE, (float(origin.y) + 0.5) * TILE)
    for enemy_idx in range(5, units.size()):
        if int(units[enemy_idx]["hp"]) <= 0:
            continue
        if str(units[enemy_idx]["team"]) != "enemy":
            continue
        if not bool(attack_preview(idx, enemy_idx)["valid"]):
            continue
        var target: Vector2i = units[enemy_idx]["pos"]
        var to_center: Vector2 = ORIGIN + Vector2((float(target.x) + 0.5) * TILE, (float(target.y) + 0.5) * TILE)
        draw_line(from_center, to_center, Color(0.12, 0.23, 0.19, 0.95), 6.0)
        draw_line(from_center, to_center, Color("#70f0a6"), 3.5, true)
        draw_circle(to_center, 19.5, Color("#70f0a6"), false, 3.2, true)

func target_range_state(attacker_idx: int, target_idx: int) -> String:
    # A target can be geometrically in range but have no clear line of sight.
    if attacker_idx < 0 or target_idx < 0:
        return "NONE"
    if not has_attack_ammo(attacker_idx):
        return "MAGAZINE EMPTY"
    var start: Vector2i = units[attacker_idx]["pos"]
    var target: Vector2i = units[target_idx]["pos"]
    if grid_distance(start, target) > int(units[attacker_idx]["range"]):
        return "OUT OF RANGE"
    if not has_line_of_sight(start, target):
        return "LOS BLOCKED"
    return "IN RANGE + CLEAR LOS"

func future_enemy_threat_tiles(idx: int) -> Dictionary:
    # Threat preview is a deliberately conservative reachable-set estimate,
    # not a promise of where a tactical AI planner will decide to fire.
    var projected: Dictionary = {}
    if idx < 5 or idx >= units.size() or int(units[idx]["hp"]) <= 0:
        return projected
    var origins: Dictionary = {units[idx]["pos"]: 0}
    var next_ap: int = maxi(0, int(units[idx]["max_ap"]) - int(units[idx].get("jammed_actions", 0)))
    if not has_attack_ammo(idx):
        next_ap -= RELOAD_AP_COST
    if next_ap >= 2:
        origins = reachable(units[idx]["pos"], int(units[idx]["move"]), int(units[idx]["id"]))
    if next_ap <= 0:
        return projected
    for y in range(board_h):
        for x in range(board_w):
            var target: Vector2i = Vector2i(x, y)
            if walls.has(target):
                continue
            for possible in origins.keys():
                var origin: Vector2i = possible
                if grid_distance(origin, target) <= int(units[idx]["range"]) and has_line_of_sight(origin, target):
                    projected[target] = true
                    break
    return projected

func draw_hover_enemy_threat() -> void:
    if not show_enemy_threat or game_over:
        return
    var idx: int = find_unit_at(hovered_tile)
    if idx < 5 or idx < 0 or idx >= units.size() or units[idx]["team"] != "enemy":
        return
    var threat: Dictionary = future_enemy_threat_tiles(idx)
    for threatened in threat.keys():
        var tile: Vector2i = threatened
        var rect: Rect2 = Rect2(ORIGIN + Vector2(float(tile.x * TILE + 2), float(tile.y * TILE + 2)), Vector2(TILE - 4, TILE - 4))
        draw_rect(rect, Color(0.85, 0.30, 0.31, 0.20), true)
    var center: Vector2 = ORIGIN + Vector2(float(hovered_tile.x * TILE + TILE / 2), float(hovered_tile.y * TILE + TILE / 2))
    draw_circle(center, 23.0, Color("#ffbd96"), false, 3.0)


func draw_cover_edges(tile_rect: Rect2, edges: Dictionary) -> void:
    # Lines sit on exact tile boundaries to show a barrier shared by both tiles.
    # The edge is drawn only at its authored location; defense lookup is symmetric.
    var left: float = tile_rect.position.x + 3.0
    var top: float = tile_rect.position.y
    var right: float = tile_rect.position.x + float(TILE) - 3.0
    var bottom: float = tile_rect.position.y + float(TILE)
    for face in edges.keys():
        var level: int = int(edges[face])
        # Light: turquoise 4px; reinforced: tan 7px; impervious: slate 7px.
        var cover_color: Color = Color("#a9bdd5") if level == 3 else (Color("#e0d6a7") if level == 2 else Color("#73bcb6"))
        var thickness: float = 4.0 if level == 1 else 7.0
        var a: Vector2 = Vector2.ZERO
        var b: Vector2 = Vector2.ZERO
        match str(face):
            "N":
                a = Vector2(left, top)
                b = Vector2(right, top)
            "S":
                a = Vector2(left, bottom)
                b = Vector2(right, bottom)
            "W":
                a = Vector2(tile_rect.position.x, top + 3.0)
                b = Vector2(tile_rect.position.x, bottom - 3.0)
            "E":
                a = Vector2(tile_rect.position.x + float(TILE), top + 3.0)
                b = Vector2(tile_rect.position.x + float(TILE), bottom - 3.0)
        draw_line(a, b, cover_color, thickness)
        var along: Vector2 = (b - a).normalized()
        var across: Vector2 = Vector2(-along.y, along.x)
        draw_line(a + across * 2.0, b + across * 2.0, cover_color.darkened(0.58), 2.0)
        if level >= 2:
            draw_line(a - across * 2.0, b - across * 2.0, cover_color.lightened(0.32), 1.0)
        var bolt_color: Color = cover_color.lightened(0.4) if level == 1 else cover_color.darkened(0.6)
        for anchor in [a + along * 3.0, (a + b) * 0.5, b - along * 3.0]:
            draw_rect(Rect2(Vector2(anchor) - Vector2.ONE, Vector2(2, 2)), bolt_color)

func draw_wall_tile(rect: Rect2) -> void:
    var top_left: Vector2 = rect.position
    draw_rect(rect.grow(-2), Color("#293946"))
    draw_rect(Rect2(top_left + Vector2(3, 3), Vector2(28, 27)), Color("#667984"))
    draw_rect(Rect2(top_left + Vector2(3, 3), Vector2(28, 2)), Color("#aebdc1"))
    draw_rect(Rect2(top_left + Vector2(29, 5), Vector2(2, 25)), Color("#3d4d59"))
    draw_rect(Rect2(top_left + Vector2(8, 8), Vector2(18, 17)), Color("#485b66"))
    draw_rect(Rect2(top_left + Vector2(8, 8), Vector2(18, 2)), Color("#82959d"))
    draw_rect(Rect2(top_left + Vector2(9, 23), Vector2(17, 2)), Color("#354651"))
    for offset in [Vector2(5, 6), Vector2(27, 6), Vector2(5, 27), Vector2(27, 27)]:
        draw_rect(Rect2(top_left + offset, Vector2(2, 2)), Color("#c2cdd0"))

func draw_hazard_tile(rect: Rect2, kind: String) -> void:
    var tint: Color = Color("#ef6a31") if kind == "fire" else (Color("#a2db4f") if kind == "radiation" else Color("#60c8ef"))
    var patch: Rect2 = rect.grow(-3)
    draw_rect(patch, Color(tint, 0.36))
    draw_rect(patch, Color(tint, 0.82), false, 1.0)
    for x in [5, 12, 19, 26]:
        var offset: Vector2 = rect.position + Vector2(x, 26 if x in [5, 19] else 24)
        draw_rect(Rect2(offset, Vector2(3, 3)), Color(tint.lightened(0.38), 0.66))
    draw_rect(Rect2(rect.position + Vector2(4, 4), Vector2(11, 12)), tint.darkened(0.68))
    draw_label(kind.substr(0, 1).to_upper(), rect.position + Vector2(6, 14), 10, tint.lightened(0.5))

func defeated_enemy_count() -> int:
    var defeated: int = 0
    var officer_escaped: bool = bool(mission_flags.get("officer_escaped", false))
    for unit in units:
        if unit["team"] != "enemy" or int(unit["hp"]) > 0:
            continue
        # Escape sets Orlov's HP to zero to remove him from combat.
        if officer_escaped and bool(unit.get("mission_target", false)):
            continue
        defeated += 1
    return defeated

func alive_count(team: String) -> int:
    var count: int = 0
    for unit in units:
        if unit["team"] == team and int(unit["hp"]) > 0:
            count += 1
    return count

func draw_action_button(rect: Rect2, label: String, enabled: bool) -> void:
    draw_rect(rect, Color("#31576b") if enabled else Color("#293846"))
    draw_rect(rect, Color("#85b9c6") if enabled else Color("#506472"), false, 1.0)
    draw_label(label, rect.position + Vector2(10, 18), 12, Color("#f1ecd3") if enabled else Color("#a7b2ba"))

func draw_scythe_charge_preview(plan: Dictionary) -> void:
    if plan.is_empty():
        return
    var from: Vector2 = ORIGIN + (Vector2(units[0]["pos"]) + Vector2(0.5, 0.5)) * TILE
    for step in plan["path"]:
        var centre: Vector2 = ORIGIN + (Vector2(step) + Vector2(0.5, 0.5)) * TILE
        draw_line(from, centre, Color("#ffda8b"), 2.0)
        draw_circle(centre, 4.0, Color("#ffda8b"))
        from = centre
    var landing: Vector2 = ORIGIN + Vector2(plan["landing"]) * TILE
    draw_rect(Rect2(landing + Vector2(2, 2), Vector2(TILE - 4, TILE - 4)), Color("#ffda8b"), false, 2.0)

func _draw() -> void:
    draw_rect(Rect2(0, 0, 1460, 900), Color("#131c29"))
    draw_label("HAMMER & ASH  /  COMBAT PROTOTYPE", Vector2(32, 43), 24, Color("#ebf0f9"))
    draw_label("BUILD 10  |  MODULAR MISSION TESTS", Vector2(900, 44), 15, Color("#8da1b5"))
    if mission_picker_open:
        draw_mission_picker()
        return
    if loadout_open:
        draw_loadout()
        return
    if hq_deployment:
        draw_label("RESISTANCE OPERATIONS", Vector2(897, 68), 13, Color("#f6ecd6"))
    else:
        draw_rect(Rect2(884, 51, 140, 25), Color("#31576b"), true)
        draw_rect(Rect2(884, 51, 140, 25), Color("#7abec7"), false, 1.0)
        draw_label("MISSIONS [M]", Vector2(897, 68), 13, Color("#f6ecd6"))
        draw_developer_room_buttons()
    if room_cleared:
        draw_room_transition()
        return
    if game_over and show_report:
        if show_room_activity and not room_history.is_empty():
            draw_room_activity(room_history[clampi(activity_room_page, 0, room_history.size() - 1)], true)
        else:
            draw_battle_report()
        if show_hit_ledger:
            draw_hit_ledger()
        return

    var current_idx: int = find_unit_by_id(selected_id)
    var current_kit: int = operative_kit(current_idx)
    var aiming_charge: bool = test_mission_id == "scythe" and current_kit == 0 and special_mode
    var aiming_blink: bool = loadout_action == "blink" and can_use_loadout_action(current_idx, "blink")
    var charge_preview: Dictionary = scythe_charge_plan(find_unit_at(hovered_tile)) if aiming_charge else {}
    var movement_options: Dictionary = {}
    if not game_over and side_to_play == "player" and current_idx >= 0 and int(units[current_idx]["hp"]) > 0 and int(units[current_idx]["ap"]) > 0:
        if special_mode and current_kit == 0 and not aiming_charge and shred_landing_tile.x < 0:
            movement_options = reachable(units[current_idx]["pos"], SHRED_CHARGE_DISTANCE, selected_id)
        elif not special_mode and loadout_action == "":
            movement_options = reachable(units[current_idx]["pos"], int(units[current_idx]["move"]), selected_id)

    draw_rect(Rect2(ORIGIN - Vector2(5, 5), Vector2(board_w * TILE + 10, board_h * TILE + 10)), Color("#182536"))
    for y in range(board_h):
        for x in range(board_w):
            var tile := Vector2i(x, y)
            var r := Rect2(ORIGIN.x + x * TILE, ORIGIN.y + y * TILE, TILE - 1, TILE - 1)
            var square_color: Color = Color("#26374a") if (x + y) % 2 == 0 else Color("#2a3e50")
            if walls.has(tile):
                square_color = Color("#75858b")
            elif movement_options.has(tile) and (current_idx < 0 or tile != units[current_idx]["pos"]):
                square_color = Color("#325d78") if special_mode else Color("#236a55")
            elif tile_has_adjacent_cover(tile):
                square_color = Color("#374a57")
            draw_rect(r, square_color)
            if hazards.has(tile):
                draw_hazard_tile(r, str(hazards[tile]["kind"]))
            if walls.has(tile):
                draw_wall_tile(r)
            if aiming_blink and can_land_short_blink(current_idx, tile):
                draw_rect(r.grow(-3), Color(0.62, 0.47, 0.90, 0.2))
                draw_rect(r.grow(-3), Color("#c3a9f5"), false, 1.0)
            if tile == hovered_tile:
                draw_rect(r.grow(-2), Color("#ffe7a0"), false, 2.0)
    draw_hover_enemy_threat()
    if aiming_charge:
        draw_scythe_charge_preview(charge_preview)
    elif special_mode and current_kit == 0:
        if shred_landing_tile.x < 0:
            var origin_pos: Vector2i = units[current_idx]["pos"]
            # Scythe's own tile is a legal zero-move landing choice.
            var centre: Vector2 = ORIGIN + Vector2(float(origin_pos.x * TILE + TILE / 2), float(origin_pos.y * TILE + TILE / 2))
            draw_circle(centre, 20.0, Color("#97e5f7"), false, 2.0)
        else:
            var land_pos: Vector2 = ORIGIN + Vector2(float(shred_landing_tile.x * TILE), float(shred_landing_tile.y * TILE))
            var land_rect: Rect2 = Rect2(land_pos + Vector2(2,2), Vector2(TILE - 4, TILE - 4))
            draw_rect(land_rect, Color("#91e4ff"), false, 3.0)
            var razor_pos: Vector2i = units[current_idx]["pos"]
            var start_center: Vector2 = ORIGIN + Vector2(float(razor_pos.x * TILE + TILE / 2), float(razor_pos.y * TILE + TILE / 2))
            var land_center: Vector2 = land_pos + Vector2(float(TILE) / 2.0, float(TILE) / 2.0)
            if razor_pos != shred_landing_tile:
                draw_line(start_center, land_center, Color("#89d7ed"), 2.0)
            var preview_arc: Array[Vector2i] = shred_arc(shred_landing_tile, hovered_tile)
            for tile in preview_arc:
                var top_left: Vector2 = ORIGIN + Vector2(float(tile.x * TILE), float(tile.y * TILE))
                var tile_rect: Rect2 = Rect2(top_left + Vector2(2, 2), Vector2(TILE - 4, TILE - 4))
                draw_rect(tile_rect, Color(0.97, 0.57, 0.21, 0.28), true)
                draw_rect(tile_rect, Color("#ffbb75"), false, 2.0)
    for authored_tile in cover_edges.keys():
        var cover_tile: Vector2i = authored_tile
        var cover_rect := Rect2(ORIGIN.x + cover_tile.x * TILE, ORIGIN.y + cover_tile.y * TILE, TILE - 1, TILE - 1)
        draw_cover_edges(cover_rect, cover_edges[cover_tile])
    draw_rect(Rect2(ORIGIN, Vector2(board_w * TILE, board_h * TILE)), Color("#9aa8b8"), false, 2.0)

    if radio_is_present():
        var radio_center: Vector2 = ORIGIN + Vector2((float(RADIO_POS.x) + 0.5) * TILE, (float(RADIO_POS.y) + 0.5) * TILE)
        var radio_working: bool = radio_is_active()
        var fill: Color = Color("#eebc59") if radio_working else Color("#556474")
        draw_rect(Rect2(radio_center - Vector2(15, 15), Vector2(30, 30)), Color("#152335"))
        draw_rect(Rect2(radio_center - Vector2(12, 12), Vector2(24, 24)), fill.darkened(0.42))
        draw_rect(Rect2(radio_center - Vector2(15, 15), Vector2(30, 30)), Color("#fff0b6") if radio_working else Color("#8495a3"), false, 2.0)
        draw_rect(Rect2(radio_center + Vector2(-9, -10), Vector2(18, 5)), fill.darkened(0.65))
        draw_rect(Rect2(radio_center + Vector2(-7, -8), Vector2(10, 2)), fill.lightened(0.6))
        draw_rect(Rect2(radio_center + Vector2(-9, -2), Vector2(18, 12)), fill)
        draw_label("TX", radio_center + Vector2(-7, 8), 10, Color("#172b3d"))
        for pip in range(RADIO_HP):
            var pip_color: Color = Color("#b7f5b8") if pip < int(radio_state["hp"]) else Color("#4f505b")
            draw_rect(Rect2(radio_center.x - 12 + pip * 14, radio_center.y + 17, 11, 4), pip_color)

    draw_barrels()
    draw_mission_objects()
    # The next defence entry lane is marked one player round before a wave.
    if test_mission_id == "defence" and next_defence_wave_round() == turn_number + 1:
        var lane: Rect2 = Rect2(ORIGIN.x + 17 * TILE, ORIGIN.y, (board_w - 17) * TILE, board_h * TILE)
        draw_rect(lane, Color(1.0, 0.62, 0.25, 0.11), true)
        draw_rect(lane.grow(-2), Color("#eab671"), false, 2.0)
        draw_label("WAVE NEXT TURN", lane.position + Vector2(8, 23), 12, Color("#f5d18f"))
    if show_firing_range and current_idx >= 0 and side_to_play == "player" and not special_mode and not breach_target_mode and not aiming_blink:
        draw_base_attack_links(current_idx)
    for idx in range(units.size()):
        var unit: Dictionary = units[idx]
        var cell: Vector2i = unit["pos"]
        var center: Vector2 = ORIGIN + Vector2(float(cell.x * TILE + TILE / 2), float(cell.y * TILE + TILE / 2))
        if int(unit["hp"]) <= 0:
            var ready_round: int = int(unit.get("recovery_round", 0))
            if ready_round > 0:
                draw_circle(center, 12.0, Color("#283747"))
                draw_circle(center, 12.0, Color("#edbb80"), false, 2.0)
                draw_label("R%d" % ready_round, center + Vector2(-7, 4), 10, Color("#ffdfa5"))
            continue
        var kind: String = str(unit.get("kind", ""))
        # Exhausted allies change from blue to grey until their AP refreshes.
        var unit_color: Color = (Color("#7c8791") if int(unit["ap"]) <= 0 else Color("#46a9e9")) if unit["team"] == "player" else (Color("#c56f92") if kind == "horde" else (Color("#e8c26b") if kind == "support" else Color("#e66c61")))
        if int(unit["id"]) == selected_id and side_to_play == "player":
            draw_circle(center, 19.0, Color("#f1f3f6"))
        if last_acting_enemy == idx and side_to_play == "enemy":
            draw_circle(center, 21.0, Color("#f1d794"))
        draw_circle(center, 14.0, unit_color)
        var sprite: Texture2D = unit_sprites.get(UnitSprites.role_for(unit))
        if sprite != null:
            var tint: Color = Color("#aab2bc") if unit["team"] == "player" and int(unit["ap"]) <= 0 else Color.WHITE
            draw_texture(sprite, center.round() - sprite.get_size() / 2.0, tint)
        else:
            draw_label(str(unit["letter"]), center + Vector2(-5.5, 5), 17, Color("#0f1c24"))
        if bool(unit.get("reaction_available", false)):
            var indicator: String = "O" if str(unit.get("reaction_type", "")) == "overwatch" else "G"
            draw_rect(Rect2(center.x + 10, center.y - 23, 15, 15), Color("#e5c58b"))
            draw_label(indicator, center + Vector2(12, -11), 12, Color("#18283a"))
        draw_rect(Rect2(center.x - 15, center.y + 16, 30, 3), Color("#3f2830"))
        draw_rect(Rect2(center.x - 15, center.y + 16, 30.0 * float(unit["hp"]) / float(unit["max_hp"]), 3), Color("#8cdd8d"))
        if int(unit["max_armour"]) > 0 and armour_enabled:
            draw_rect(Rect2(center.x - 15, center.y + 21, 30, 3), Color("#263c51"))
            draw_rect(Rect2(center.x - 15, center.y + 21, 30.0 * float(unit["armour"]) / float(unit["max_armour"]), 3), Color("#75c7ff"))

    # Draw Breach atop units so too-heavy targets show an unambiguous red X.
    if breach_target_mode and current_kit == 1:
        draw_sentinel_breach_preview()
    draw_damage_floaters()

    # Compact tactical inspector: selected operative is always visible, while
    # hovering an enemy reveals only THAT enemy's stats and status effects.
    var hovered_idx: int = find_unit_at(hovered_tile, true)
    draw_rect(Rect2(858, 79, 568, 656), Color("#1d2a3b"))
    draw_label("ROOM %d/%d  |  ROUND %d  |  %s TURN" % [mission_stage + 1, mission_room_total(), turn_number, side_to_play.to_upper()], Vector2(874, 108), 19, Color("#eff4fb"))
    draw_label("%s  |  REBELS %d  ·  ENEMIES %d" % [active_arena_name(), alive_count("player"), alive_count("enemy")], Vector2(875, 136), 13, Color("#d2c9a0"))
    draw_label("ARMOUR %s [A]   ·   AI %s [I]   ·   DEBUG %s [D]" % ["ON" if armour_enabled else "OFF", "TACTICAL" if smart_ai_enabled else "LEGACY", "ON" if ai_debug_enabled else "OFF"], Vector2(875, 159), 12, Color("#94c9eb"))

    draw_label("SELECT SQUAD  [1-5 / TAB / CLICK]", Vector2(875, 190), 13, Color("#a3bed1"))
    for squad_idx in range(5):
        var ally: Dictionary = units[squad_idx]
        var tab: Rect2 = squad_tab_rect(squad_idx)
        var is_active: bool = int(ally["id"]) == selected_id
        var is_alive: bool = int(ally["hp"]) > 0
        var tab_exhausted: bool = is_alive and int(ally["ap"]) <= 0
        draw_rect(tab, Color("#53616e") if tab_exhausted else (Color("#355f80") if is_active else (Color("#2b4052") if is_alive else Color("#303440"))), true)
        draw_rect(tab, Color("#9aa4ae") if tab_exhausted else (Color("#74bfe5") if is_active else Color("#415970")), false, 1.0)
        draw_label("%d %s" % [squad_idx + 1, str(ally["name"]).to_upper()], tab.position + Vector2(8, 21 if is_alive else 13), 11, Color("#f2f7fb") if is_alive else Color("#8494a2"))
        if not is_alive:
            var ready_round: int = int(ally["recovery_round"])
            var down_state: String = "DOWN · ROUND %d" % ready_round if ready_round > 0 else "LOST"
            draw_label(down_state, tab.position + Vector2(8, 26), 10, Color("#efbd85"))

    # Selected operative panel. Status line uses the same source of truth as
    # the old selected-unit card; no independently maintained sidebar state.
    draw_rect(Rect2(870, 245, 543, 199), Color("#213347"), true)
    draw_rect(Rect2(870, 245, 543, 199), Color("#45677e"), false, 1.0)
    draw_label("SELECTED OPERATIVE", Vector2(884, 265), 13, Color("#a4c2d6"))
    if current_idx >= 0:
        var active: Dictionary = units[current_idx]
        var display_name: String = str(active["name"])
        if active.has("scythe_origin"):
            display_name += " · " + str(active["scythe_origin"])
        draw_label(display_name.to_upper(), Vector2(884, 290), 19, Color("#88d2ff"))
        var melee_name: String = str(active["melee_weapon"]) if int(active["melee_damage"]) > 0 else "Melee slot empty"
        draw_label("%s  ·  %s  ·  %s" % [str(active["basic_attack"]), melee_name, str(active["armour_name"])], Vector2(885, 304), 11, Color("#b8d2e1"))
        var current_armour: int = int(active["armour"]) if armour_enabled else 0
        var maximum_armour: int = int(active["max_armour"]) if armour_enabled else 0
        draw_label("HP  %d/%d" % [int(active["hp"]), int(active["max_hp"])], Vector2(885, 319), 15, Color("#e5f4e4"))
        draw_label("ARM  %d/%d" % [current_armour, maximum_armour], Vector2(1026, 319), 15, Color("#c6e7ff"))
        draw_label("AP  %d/%d" % [int(active["ap"]), int(active["max_ap"])], Vector2(1180, 319), 15, Color("#f3e9ca"))
        draw_label("WT %d" % int(active.get("weight", 2)), Vector2(1330, 319), 14, Color("#e3deee"))
        draw_label("MOVE %d tiles/AP    ATTACK %d dmg    RANGE %d    AMMO %d/%d" % [int(active["move"]), int(active["damage"]), int(active["range"]), int(active["rounds"]), int(active["magazine_capacity"])], Vector2(885, 341), 13, Color("#c8d8e8"))
        if int(active["hp"]) > 0 and side_to_play == "player" and not game_over:
            draw_action_button(MELEE_BUTTON, "MELEE [J]", can_use_loadout_action(current_idx, "melee"))
            draw_action_button(MEDKIT_BUTTON, "MEDKIT [K] %d" % int(active["medkit_charges"]), can_use_loadout_action(current_idx, "medkit"))
            var loaded: bool = has_attack_ammo(current_idx)
            if loaded:
                draw_action_button(SHOOT_BUTTON, "SHOOT", int(active["ap"]) > 0)
            var reload_ready: bool = int(active["ap"]) >= RELOAD_AP_COST and int(active["rounds"]) < int(active["magazine_capacity"])
            draw_action_button(RELOAD_BUTTON if loaded else EMPTY_RELOAD_BUTTON, "RELOAD [X]", reload_ready)
        draw_wrapped_label("STATUS: " + selected_status_text(current_idx), Vector2(885, 363), 515.0, 12, Color("#eed7a0"), 15.0, 2)
        var description: Array[String] = ability_description(current_idx)
        var ready: String = special_readiness_label(current_idx)
        draw_label("[Q] %s   [%s]" % [description[0], ready], Vector2(885, 402), 12, Color("#f2d28c"))
        draw_wrapped_label(description[1], Vector2(885, 420), 515.0, 11, Color("#dae7f1"), 13.0, 1)
        if current_kit == 1:
            draw_label("[B] BREACH: 1 AP · 4-tile charge / cover break / 5 dmg", Vector2(885, 438), 11, Color("#96dbb9"))
        elif active.get("scythe_origin", "") == "Blink" and side_to_play == "player" and not game_over:
            var blink_label: String = "SHORT BLINK [Z] · 1 AP"
            if int(active["blink_used_turn"]) == turn_number:
                blink_label = "SHORT BLINK [Z] · USED"
            draw_action_button(SHORT_BLINK_BUTTON, blink_label, can_use_loadout_action(current_idx, "blink"))
        elif active.get("scythe_origin", "") == "Arachnid":
            draw_label("SPIDER AGILITY  +1 tile to movement and Charge", Vector2(885, 438), 11, Color("#e1a1b6"))
    else:
        draw_label("No living operative selected.", Vector2(884, 295), 14, Color("#dbe9f2"))

    # Enemy inspection is intentionally not a list: hover any living enemy
    # on the battlefield for HP, armour, AP, weight, effects and attack preview.
    draw_rect(Rect2(870, 451, 543, 164), Color("#25303e"), true)
    draw_rect(Rect2(870, 451, 543, 164), Color("#58677d"), false, 1.0)
    draw_label("HOVERED TARGET", Vector2(884, 471), 13, Color("#a9bdcf"))
    if hovered_idx >= 0 and str(units[hovered_idx]["team"]) == "enemy":
        var foe: Dictionary = units[hovered_idx]
        draw_label(str(foe["name"]).to_upper(), Vector2(884, 494), 18, Color("#f7ad9c"))
        draw_label("HP  %d/%d" % [int(foe["hp"]), int(foe["max_hp"])], Vector2(885, 520), 14, Color("#f4ddda"))
        draw_label("ARM  %d/%d" % [int(foe["armour"]) if armour_enabled else 0, int(foe["max_armour"]) if armour_enabled else 0], Vector2(1027, 520), 14, Color("#c6ddec"))
        draw_label("AP  %d/%d" % [int(foe["ap"]), int(foe["max_ap"])], Vector2(1180, 520), 14, Color("#f3e9ca"))
        draw_label("WT %d" % int(foe.get("weight", 2)), Vector2(1330, 520), 14, Color("#dfd9e8"))
        draw_wrapped_label("STATUS: " + selected_status_text(hovered_idx), Vector2(885, 543), 515.0, 12, Color("#f3d8a1"), 15.0, 1)
        var foe_ammo: String = "   AMMO %d/%d" % [int(foe["rounds"]), int(foe["magazine_capacity"])] if int(foe["magazine_capacity"]) > 0 else ""
        draw_label("ATTACK %d dmg   RANGE %d   MOVE %d   ·   %s%s" % [int(foe["damage"]), int(foe["range"]), int(foe["move"]), str(foe.get("ai_role", foe.get("kind", "enemy"))).to_upper(), foe_ammo], Vector2(885, 565), 12, Color("#d3dfeb"))
        if current_idx >= 0:
            var base_range: String = target_range_state(current_idx, hovered_idx)
            draw_label("BASE WEAPON: " + base_range, Vector2(885, 586), 12, Color("#8fe0b0") if base_range == "IN RANGE + CLEAR LOS" else Color("#f2af9e"))
            var shot: Dictionary = attack_preview(current_idx, hovered_idx)
            var line_text: String = "SHOT: %d impact · %d ARM + %d HP" % [int(shot["damage"]), int(shot["armour_damage"]), int(shot["hp_damage"])] if bool(shot["valid"]) else "SHOT UNAVAILABLE: " + str(shot["reason"])
            draw_wrapped_label(line_text, Vector2(885, 605), 515.0, 11, Color("#8fe0b0") if bool(shot["valid"]) else Color("#f2af9e"), 14.0, 1)
    elif hovered_idx >= 0 and int(units[hovered_idx].get("recovery_round", 0)) > 0:
        var downed: Dictionary = units[hovered_idx]
        draw_label(str(downed["name"]).to_upper() + " — DOWNED", Vector2(884, 497), 18, Color("#efbd85"))
        draw_label("Stands at %d HP in player round %d or on room clear." % [recoverable_hp(downed), int(downed["recovery_round"])], Vector2(884, 525), 13, Color("#deebeb"))
    elif barrel_is_active(hovered_tile):
        var barrel_data: Dictionary = barrel_preview(current_idx, hovered_tile) if current_idx >= 0 else {"reason": "Select a living operative"}
        draw_label(str(barrels[hovered_tile]["kind"]).to_upper() + " BARREL", Vector2(884, 497), 18, Color("#e8bf74"))
        draw_label("Directly targetable · Explodes · Affects both sides", Vector2(884, 524), 12, Color("#dae1e8"))
        draw_wrapped_label(str(barrel_data["reason"]), Vector2(884, 549), 515.0, 12, Color("#f0d6aa"), 15.0, 2)
    elif mission_object_at(hovered_tile):
        var hovered_object: Dictionary = mission_objects[hovered_tile]
        draw_label(str(hovered_object.get("label", "OBJECTIVE")), Vector2(884, 497), 18, Color("#e8d8a8"))
        var obj_detail: String = "HP %d/%d" % [int(hovered_object.get("hp", 0)), int(hovered_object.get("max_hp", 1))] if str(hovered_object.get("kind", "")) in ["machine", "protect"] else "Adjacent interaction (1 AP)"
        draw_label(obj_detail, Vector2(884, 525), 13, Color("#deebeb"))
        draw_wrapped_label(get_objective_progress_line(), Vector2(884, 558), 510.0, 12, Color("#d7cea8"), 17.0, 2)
    elif radio_is_active() and hovered_tile == RADIO_POS:
        draw_label("RADIO TRANSMITTER", Vector2(884, 497), 18, Color("#f6d28a"))
        draw_label("HP %d/%d  ·  Destroy by end of player turn 3" % [int(radio_state["hp"]), RADIO_HP], Vector2(884, 523), 13, Color("#e4e5d4"))
    else:
        draw_label("Hover an enemy to inspect its combat profile.", Vector2(884, 506), 13, Color("#bccbd9"))
        draw_label("Hover barrels or the transmitter to inspect objects.", Vector2(884, 532), 12, Color("#9fb5c6"))

    draw_rect(Rect2(870, 625, 543, 97), Color("#202f3d"), true)
    draw_rect(Rect2(870, 625, 543, 97), Color("#42586c"), false, 1.0)
    draw_label("OBJECTIVE — %s" % ("ELIMINATE ALL ENEMIES" if test_mission_id == "chain" else test_mission_id.to_upper()), Vector2(884, 647), 13, Color("#f2ddad"))
    if test_mission_id == "scythe":
        draw_label(get_objective_progress_line(), Vector2(884, 674), 13, Color("#f2d7a2"))
        draw_label("The sentry starts with Overwatch reserved.", Vector2(884, 695), 11, Color("#a9c0d5"))
    elif test_mission_id != "chain":
        draw_wrapped_label(get_objective_progress_line(), Vector2(884, 674), 509.0, 13, Color("#f2d7a2"), 17.0, 2)
        var next_wave: int = next_defence_wave_round()
        var detail: String = "Clear guards and complete objectives." if hq_deployment else "Clear guards + objectives; [M] switch tests."
        if test_mission_id == "defence":
            detail = "NEXT WAVE: ROUND %d (east entry lane)." % next_wave if next_wave > 0 else "Final wave deployed — survive through enemy round 8."
        draw_label(detail, Vector2(884, 714), 11, Color("#a9c0d5"))
    elif mission_stage == 1:
        var radio_color: Color = Color("#9be1bb") if bool(radio_state.get("destroyed_in_time", false)) else (Color("#f7aaa0") if radio_reinforcements_queued else Color("#edd18e"))
        var radio_line: String = "TX DISABLED — no reinforcement" if bool(radio_state.get("destroyed_in_time", false)) else ("TX ALERT SENT — 3 extra hounds in Room 3" if radio_reinforcements_queued else "OPTIONAL: Destroy radio TX by turn 3")
        draw_label(radio_line, Vector2(884, 672), 13, radio_color)
        if radio_is_active():
            draw_label("Radio HP %d/%d   ·   Player round %d" % [int(radio_state["hp"]), RADIO_HP, turn_number], Vector2(884, 696), 12, Color("#c4d5e3"))
    elif mission_stage == 2 and radio_reinforcements_queued:
        draw_label("ALERT CONSEQUENCE: 3 additional hounds deployed", Vector2(884, 674), 12, Color("#f1ada2"))
    else:
        draw_label("Survive this room; squad HP carries into the next.", Vector2(884, 674), 12, Color("#b4c9da"))
    draw_label("[F] ATTACK LINKS: %s   ·   [H] ENEMY THREAT: %s" % ["ON" if show_firing_range else "OFF", "ON" if show_enemy_threat else "OFF"], Vector2(884, 714), 11, Color("#9cbee0"))

    draw_rect(END_BUTTON, Color("#345e7e") if side_to_play == "player" and not game_over else Color("#304251"))
    draw_label("END TURN", Vector2(919, 790), 19, Color("#ffffff"))
    if not hq_deployment:
        draw_rect(RESET_BUTTON, Color("#6a4e5b"))
        draw_label("RESTART", Vector2(1146, 790), 19, Color("#ffffff"))
    draw_label("SPACE: END TURN   |   1-5: SELECT   |   TAB: NEXT   |   X: RELOAD", Vector2(872, 838), 13, Color("#a6bccc"))
    draw_label("H: THREAT | O: OVERWATCH | Q: ABILITY | L: LEDGER", Vector2(872, 858), 12, Color("#a6bccc"))
    var battle_navigation: String = "B: BREACH | M: MISSIONS | F6/F7/F8: ORIGINAL ROOM JUMP"
    if hq_deployment:
        battle_navigation = "B: BREACH"
        if headquarters.campaign.mission.get("emergency_reload", false):
            battle_navigation += " | G: EMERGENCY RELOAD (%d INTEL)" % Headquarters.State.RELOAD_COST
    draw_label(battle_navigation, Vector2(872, 876), 11, Color("#a6bccc"))


    draw_rect(Rect2(20, 680, 410, 203), Color("#192738"), true)
    draw_rect(Rect2(20, 680, 410, 203), Color("#456174"), false, 1.0)
    draw_label("ATTACK / AREA PREVIEW", Vector2(32, 701), 14, Color("#9db9cf"))
    var preview_text: String = "Hover an enemy for range and damage details."
    if current_kit == 1 and breach_target_mode:
        var breach_data: Dictionary = breach_plan(hovered_tile)
        if bool(breach_data["valid"]):
            var structural: int = breach_data["edges"].size()
            var target: int = int(breach_data["enemy"])
            preview_text = "BREACH 1 AP: %d steps / %d barriers. %s" % [breach_data["path"].size(), structural, "5 DMG + displacement" if target >= 0 else "Clear landing"]
        else:
            preview_text = "BREACH INVALID: " + str(breach_data["reason"])
    elif current_idx >= 0 and barrel_is_active(hovered_tile):
        var barrel_info: Dictionary = barrel_preview(current_idx, hovered_tile)
        preview_text = "%s BARREL: %s. Blast + knockback up to 2 tiles; 3-round hazard." % [str(barrels[hovered_tile]["kind"]).to_upper(), str(barrel_info["reason"])]
    elif aiming_charge:
        preview_text = "Charge: choose an enemy with a landing tile within %d walkable steps." % scythe_charge_distance()
        if not charge_preview.is_empty():
            var impact: Dictionary = charge_preview["impact"]
            preview_text = "Charge (1 AP): %d steps · %d ARM / %d HP before Overwatch." % [charge_preview["path"].size(), int(impact["armour_damage"]), int(impact["hp_damage"])]
    elif current_idx >= 0 and special_mode and current_kit == 0:
        if shred_landing_tile.x < 0:
            var options: Dictionary = reachable(units[current_idx]["pos"], SHRED_CHARGE_DISTANCE, selected_id)
            preview_text = "Area Shred: select landing (%d/3 steps), then choose an attack direction." % int(options[hovered_tile]) if options.has(hovered_tile) else "Area Shred: click a blue landing tile (0–3 steps)."
        else:
            var arc_tiles: Array[Vector2i] = shred_arc(shred_landing_tile, hovered_tile)
            var hits: int = 0
            for tile in arc_tiles:
                var idx: int = find_unit_at(tile)
                if idx >= 0 and units[idx]["team"] == "enemy" and int(units[idx]["hp"]) > 0:
                    hits += 1
            preview_text = "Area Shred: %d enemies at %d DMG each, 1 AP total." % [hits, SHRED_DAMAGE] if not arc_tiles.is_empty() else "Aim at a tile adjacent to the blue landing square."
    elif current_idx >= 0 and mission_object_at(hovered_tile):
        var objective_hint: String = "Click from adjacency (1 AP)"
        if str(mission_objects[hovered_tile]["kind"]) == "machine":
            objective_hint = "Shoot or strike machine (1 AP)" if has_attack_ammo(current_idx) else "Magazine empty. Move adjacent to strike or reload [X]."
        preview_text = "%s — %s" % [str(mission_objects[hovered_tile]["label"]), objective_hint]
    elif current_idx >= 0 and radio_is_active() and hovered_tile == RADIO_POS:
        var objective_preview: Dictionary = radio_attack_preview(current_idx)
        preview_text = "RADIO: %s | %d HP damage. Must destroy by end of turn 3." % [str(objective_preview["reason"]), int(objective_preview["damage"])]
    elif current_idx >= 0 and hovered_idx >= 0 and units[hovered_idx]["team"] == "enemy":
        var bonus: int = 2 if special_mode and current_kit == 2 else (1 if special_mode and current_kit == 3 else 0)
        var pierce: int = 1 if special_mode and current_kit == 2 else 0
        var preview: Dictionary = attack_preview(current_idx, hovered_idx, bonus, pierce)
        if bool(preview["valid"]):
            preview_text = "%s: %d base - %d cover = %d impact (%d ARM / %d HP)." % [str(units[hovered_idx]["name"]), int(preview["base"]), int(preview["cover"]), int(preview["damage"]), int(preview["armour_damage"]), int(preview["hp_damage"])]
        else:
            preview_text = "%s: %s." % [str(units[hovered_idx]["name"]), str(preview["reason"])]
    elif hazards.has(hovered_tile):
        var hh: Dictionary = hazards[hovered_tile]
        preview_text = "%s HAZARD: 1 damage on entry/phase; applies status. Expires in %d rounds." % [str(hh["kind"]).to_upper(), maxi(0, int(hh["expires_round"]) - turn_number)]
    elif current_idx >= 0 and movement_options.has(hovered_tile) and hovered_tile != units[current_idx]["pos"]:
        preview_text = "Move 1 AP / %d tiles. H previews hovered enemy's next-turn move + attack threat." % int(units[current_idx]["move"])
    if loadout_action == "melee" and current_idx >= 0:
        preview_text = "%s: %d damage to an adjacent enemy (1 AP)." % [str(units[current_idx]["melee_weapon"]), int(units[current_idx]["melee_damage"])]
        if units[current_idx]["melee_weapon"] == WOLVERINE_CLAWS:
            preview_text += " Removes 1 maximum armour."
    elif loadout_action == "medkit":
        preview_text = "Medkit: heal up to %d HP on yourself or an adjacent ally (1 AP)." % StarterLoadouts.MEDKIT_HP
    elif aiming_blink:
        preview_text = "Short Blink: choose a highlighted tile. Overwatch can fire on landing."
        if can_land_short_blink(current_idx, hovered_tile) and hazards.has(hovered_tile):
            preview_text = "Short Blink: %s hazard and eligible Overwatch apply on landing." % str(hazards[hovered_tile]["kind"]).capitalize()
    draw_wrapped_label(preview_text, Vector2(32, 723), 384.0, 12, Color("#e7d7ab"), 14.0, 2)
    draw_wrapped_label("STATUS: " + status_message, Vector2(32, 752), 384.0, 12, Color("#ecf1f7"), 14.0, 2)
    var debug_line: String = "AI: " + ai_last_decision if ai_debug_enabled and not ai_last_decision.is_empty() else "RECENT ACTIONS"
    draw_wrapped_label(debug_line, Vector2(32, 784), 384.0, 11, Color("#9db9cf"), 13.0, 2)
    for i in range(mini(action_log.size(), 3)):
        draw_wrapped_label(action_log[i], Vector2(32, 808 + i * 22), 384.0, 11, Color("#c7d4e2"), 13.0, 1)
    draw_selected_unit_card(current_idx)
    if game_over:
        draw_rect(Rect2(182, 269, 468, 134), Color("#0d1c29"), true)
        draw_rect(Rect2(182, 269, 468, 134), Color("#edce93"), false, 2.0)
        var heading: String = "MISSION COMPLETE" if mission_victory else "MISSION FAILED"
        var subheading: String = ("ALL %d ROOMS CLEARED" % mission_room_total()) if mission_victory else ("ROOM %d OF %d" % [mission_stage + 1, mission_room_total()])
        var heading_width: float = ThemeDB.fallback_font.get_string_size(heading, HORIZONTAL_ALIGNMENT_LEFT, -1, 25).x
        var subheading_width: float = ThemeDB.fallback_font.get_string_size(subheading, HORIZONTAL_ALIGNMENT_LEFT, -1, 19).x
        draw_label(heading, Vector2(416.0 - heading_width * 0.5, 316), 25, Color("#f6dba1"))
        draw_label(subheading, Vector2(416.0 - subheading_width * 0.5, 344), 19, Color("#e9f1f5"))
        draw_label("[V] Report    [L] Ledger    [R] Restart", Vector2(255, 376), 13, Color("#e0e8ed"))
    if show_hit_ledger:
        draw_hit_ledger()
