extends Node2D
## Hammer & Ash — Build 10: regional campaign battles and the original regression chain.
## Compare legacy vs tactical AI using I. D toggles debug decisions.
## New tactical AI scores short plans of movement + attack (2 enemy AP),
## with role-configurable self-preservation, aggression and target priorities.
## Cover is a *physical shared edge*, not owned exclusively by a tile.
## Artwork is drawn in 2D with embedded pixel sprites; no external assets required.

const UnitSprites = preload("res://scripts/unit_sprites.gd")
const OriginAvatars = preload("res://scripts/origin_avatars.gd")
const StarterLoadouts = preload("res://scripts/starter_loadouts.gd")
const PlayerClasses = preload("res://scripts/player_classes.gd")
const CampaignState = preload("res://scripts/hq_trial_state.gd")
const CampaignOperations = preload("res://scripts/campaign_operations.gd")
const Headquarters = preload("res://scripts/hq_trial_screen.gd")
const ClassCombat = preload("res://scripts/class_combat.gd")
const SabotageVisuals = preload("res://scripts/sabotage_visuals.gd")
const BattlefieldView = preload("res://scripts/battlefield_view.gd")
const UnitPlayback = preload("res://scripts/unit_playback.gd")
const COMBAT_BACKGROUND := Color("#121b24")
const HUD_SURFACE := Color("#1b2833")
const HUD_LINE := Color("#354957")
const HUD_TEXT := Color("#edf2f2")
const HUD_MUTED := Color("#acbec7")
const HUD_ACCENT := Color("#9fdfc3")
const HUD_OBJECTIVE := Color("#efd3a2")
const HUD_RAIL := Rect2(1138, 64, 306, 668)
const DEVELOPER_BUTTON := Rect2(1310, 15, 134, 34)
const EXTRACT_BUTTON := Rect2(907, 733, 213, 64)
const CAMERA_PAN_SPEED := 570.0
const CAMERA_KEYS := [KEY_W, KEY_A, KEY_S, KEY_D]
const ACTION_COLUMNS := 17
const ACTION_YELLOW := Color("#ffe16a")
const FIRST_ACTION_RECT := Rect2(164, 679, 44, 42)
const ACTION_SPACING := Vector2(56, 50)
const HQ_BUTTON: Rect2 = Rect2(950, 751, 235, 46)

var headquarters: Headquarters = Headquarters.new()
var hq_deployment: bool = false
var class_combat: ClassCombat = ClassCombat.new(self)
var resolving_class_action: bool = false

@onready var unit_sprites: Dictionary[String, Texture2D] = UnitSprites.create_textures()

var board_w: int = 22
var board_h: int = 16
const TILE: int = 36
const ORIGIN: Vector2 = Vector2(32, 88)
var battlefield := BattlefieldView.new()
var pan_keys: Dictionary = {}
var hud_cursor := Vector2(-1, -1)
var developer_menu_open := false
var show_combat_log := false
var sabotage_visuals := SabotageVisuals.new()
var unit_playback := UnitPlayback.new()
var atmosphere_time := 0.0
var show_facing_arrows := false
var sprite_foot_anchors: Dictionary = {}
var pending_defeats: Dictionary[int, bool] = {}
const DIRECTIONS: Array[Vector2i] = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
const MOVE_DIRECTIONS: Array[Vector2i] = [
	Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
	Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1),
]
const MOVE_DISTANCE: int = 4
const DEFAULT_MAGAZINE_CAPACITY: int = 3
const RELOAD_AP_COST: int = 1
const EMPTY_MAGAZINE: String = "Magazine empty: reload [X]."
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
const END_BUTTON := Rect2(1158, 678, 266, 40)

var walls: Array[Vector2i] = []
var high_ground_tiles: Array[Vector2i] = []
var cover_edges: Dictionary = {}
var armour_enabled: bool = true
const ARENA_NAMES: Array[String] = ["LARGE 22x16", "COMPACT 18x14"]
# Scenario selection is internal to the authored mission; C/T no longer skip rooms.
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
var mission_failure_reason: String = ""
# Room 2 secondary objective. An unanswered radio call adds three hounds to Room 3.
var radio_state: Dictionary = {}
var radio_reinforcements_queued: bool = false
const RADIO_POS: Vector2i = Vector2i(15, 8)
const RADIO_DEADLINE_ROUND: int = 3
const RADIO_HP: int = 2
const RADIO_EXTRA_HOUNDS: int = 3
# Prototype timing: hazards last 3 rounds and ongoing damage ticks twice.
# Shocked affects the next AP refresh. Blinded expires at faction phase end.
const HAZARD_ROUNDS: int = 3
const STATUS_TURNS: int = 2
const BLINDED_DAMAGE_PENALTY: int = 2
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
const OVERWATCH_SHOT_AP: int = 1
const OVERWATCH_END_WIDTH: int = 4
const OVERWATCH_APPROACH_MOVES: int = 2
const OVERWATCH_HOLD_MESSAGE: String = "This unit is holding position on Overwatch."

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
const EnemyRoster = preload("res://scripts/enemy_roster.gd")
const TEST_MISSION_IDS: Array[String] = ["chain"]
const TEST_MISSION_TITLES: Array[String] = ["Original three-room chain"]
var test_mission_id: String = "chain"
var campaign_operation: Dictionary = {}
var mission_picker_open: bool = true
var show_enemy_tier_mix := false
var loadout_open: bool = false
var pending_mission_id: String = ""
var loadout_operative: int = 0
var mission_loadouts: Array[int] = StarterLoadouts.defaults()
var draft_loadouts: Array[int] = []
var loadout_action: String = ""
const DEPLOY_BUTTON: Rect2 = Rect2(1015, 743, 216, 54)
const LOADOUT_BACK_BUTTON: Rect2 = Rect2(229, 743, 157, 54)
var mission_objects: Dictionary = {}       # Vector2i -> objective object data
var mission_objectives: Array[Dictionary] = [] # reusable {id,type,label,required,complete}

func mission_room_total() -> int:
	if not campaign_operation.is_empty():
		return CampaignOperations.room_count(test_mission_id)
	return ROOM_COUNT

func mission_room_label(stage: int) -> String:
	if not campaign_operation.is_empty():
		return "%02d / %s" % [stage + 1, CampaignOperations.layout(test_mission_id, stage)["label"].to_upper()]
	return ROOM_NAMES[stage]


func mission_picker_rect(idx: int) -> Rect2:
	return Rect2(100 + (idx % 2) * 640, 175 + floori(idx / 2.0) * 108, 620, 88)

func draw_mission_picker() -> void:
	draw_rect(Rect2(0, 0, 1460, 900), Color("#111b2b"), true)
	draw_label("HAMMER & ASH  /  COMBAT REGRESSION", Vector2(100, 95), 29, Color("#edf2f8"))
	draw_label("Campaign operations are available from the USSR map at headquarters.", Vector2(100, 136), 16, Color("#acc6d8"))
	var descriptions: Array[String] = [
		"Three linked rooms with squad carry-over and a timed radio consequence.",
	]
	for i in range(TEST_MISSION_IDS.size()):
		var r: Rect2 = mission_picker_rect(i)
		var selected: bool = TEST_MISSION_IDS[i] == test_mission_id
		draw_rect(r, Color("#29495c") if selected else Color("#233347"), true)
		draw_rect(r, Color("#87d4bc") if selected else Color("#667f91"), false, 2.0)
		draw_label("%d  /  %s" % [(i + 1) % 10, TEST_MISSION_TITLES[i]], r.position + Vector2(20, 32), 21, Color("#e9f1f5"))
		draw_label(descriptions[i], r.position + Vector2(22, 61), 14, Color("#a9c1d1"))
	draw_label("Click the scenario or press 1 to prepare the squad's loadout.", Vector2(265, 770), 14, Color("#e8d19a"))
	draw_label("Developer shortcuts: M menu  |  F6/F7/F8 original-room jump  |  L hit ledger", Vector2(265, 802), 13, Color("#9fb5c6"))
	draw_action_button(HQ_BUTTON, "HEADQUARTERS [F9]", true)

func begin_loadout(id: String) -> void:
	if not TEST_MISSION_IDS.has(id):
		return
	pending_mission_id = id
	draft_loadouts = mission_loadouts.duplicate(true)
	loadout_operative = 0
	mission_picker_open = false
	loadout_open = true
	queue_redraw()

func deploy_loadout() -> void:
	if not loadout_open:
		return
	mission_loadouts = draft_loadouts.duplicate(true)
	loadout_open = false
	choose_test_mission(pending_mission_id)

func loadout_member_rect(idx: int) -> Rect2:
	return Rect2(229 + idx * 203, 179, 190, 54)

func consumable_rect(option: int) -> Rect2:
	return Rect2(423 + option * 405, 372, 391, 76)

func handle_loadout_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode in [KEY_ESCAPE, KEY_M]:
			loadout_open = false
			mission_picker_open = true
		elif event.keycode in [KEY_ENTER, KEY_KP_ENTER]:
			deploy_loadout()
		elif event.keycode in [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5]:
			loadout_operative = event.keycode - KEY_1
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
			for option in range(StarterLoadouts.CONSUMABLES.size()):
				if consumable_rect(option).has_point(event.position):
					draft_loadouts[loadout_operative] = option
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
		draw_texture(unit_sprites[role], tab.position + Vector2(13, 15))
		draw_label("%d  %s" % [idx + 1, str(units[idx]["name"])], tab.position + Vector2(48, 34), 16, Color("#edf2f8"))
	var suit_card := Rect2(423, 267, 391, 76)
	draw_rect(suit_card, Color("#284b51"))
	draw_rect(suit_card, Color("#8edac4"), false, 1.0)
	draw_label(StarterLoadouts.SUPERSUIT, suit_card.position + Vector2(17, 29), 18, Color("#edf2f8"))
	draw_label(StarterLoadouts.SUPERSUIT_DETAIL, suit_card.position + Vector2(17, 52), 13, Color("#b5cdda"))
	draw_label("CONSUMABLE", Vector2(230, 406), 15, Color("#bbd4e1"))
	for option in range(StarterLoadouts.CONSUMABLES.size()):
		var card: Rect2 = consumable_rect(option)
		var equipped: bool = draft_loadouts[loadout_operative] == option
		draw_rect(card, Color("#284b51") if equipped else Color("#223449"))
		draw_rect(card, Color("#8edac4") if equipped else Color("#435b72"), false, 1.0)
		draw_label(StarterLoadouts.CONSUMABLES[option], card.position + Vector2(17, 29), 18, Color("#edf2f8"))
		if option == 0:
			draw_label(StarterLoadouts.MEDKIT_DETAIL, card.position + Vector2(17, 52), 13, Color("#b5cdda"))
		if equipped:
			draw_label("EQUIPPED", card.position + Vector2(card.size.x - 81, 29), 11, Color("#ace6cc"))
	draw_rect(LOADOUT_BACK_BUTTON, Color("#293b50"))
	draw_label("BACK [ESC]", LOADOUT_BACK_BUTTON.position + Vector2(25, 34), 16, Color("#edf2f8"))
	draw_rect(DEPLOY_BUTTON, Color("#377760"))
	draw_label("DEPLOY [ENTER]", DEPLOY_BUTTON.position + Vector2(26, 34), 17, Color("#f3fff9"))

func choose_test_mission(id: String) -> void:
	if not TEST_MISSION_IDS.has(id):
		return
	test_mission_id = id
	restart_game()
	mission_picker_open = false
	queue_redraw()

func add_objective(id: String, kind: String, label: String, required: bool = true) -> void:
	mission_objectives.append({"id": id, "type": kind, "label": label, "required": required, "completed": false, "failed": false})

func mission_object_at(tile: Vector2i) -> bool:
	if not mission_objects.has(tile):
		return false
	var obj: Dictionary = mission_objects[tile]
	if str(obj.get("kind", "")) == "prisoner":
		return not bool(obj.get("released", false))
	return int(obj.get("hp", 0)) > 0

func mission_object_named(id: String) -> Vector2i:
	for pos in mission_objects.keys():
		if str(mission_objects[pos].get("id", "")) == id:
			return pos
	return Vector2i(-1, -1)

func setup_room_objectives() -> void:
	mission_objects.clear()
	mission_objectives.clear()
	if not campaign_operation.is_empty():
		var layout := CampaignOperations.layout(test_mission_id, mission_stage)
		if layout.has("generator"):
			var generator: Vector2i = campaign_tile(layout["generator"])
			mission_objects[generator] = {"id": "generator", "kind": "machine", "label": "POWER GENERATOR", "hp": 6, "max_hp": 6}
			add_objective("generator", "destroy", "Destroy power generator")
		elif layout.has("prisoners"):
			for index in range(layout["prisoners"].size()):
				var suffix: String = ["A", "B"][index]
				var id: String = "prisoner_" + suffix.to_lower()
				var tile: Vector2i = campaign_tile(layout["prisoners"][index])
				mission_objects[tile] = {"id": id, "kind": "prisoner", "label": "PRISONER " + suffix, "hp": 1, "released": false}
				add_objective(id, "free", "Free prisoner " + suffix)
	for p in mission_objects.keys():
		assert(not walls.has(p), "Mission object spawned in wall")
		assert(find_unit_at(p) < 0, "Mission object overlaps unit")
		assert(not barrel_is_active(p), "Mission object overlaps barrel")

func objective_complete(id: String) -> bool:
	var pos := mission_object_named(id)
	if pos.x < 0:
		return false
	var object: Dictionary = mission_objects[pos]
	return object["released"] if object["kind"] == "prisoner" else int(object["hp"]) <= 0

func all_required_objectives_met() -> bool:
	for objective in mission_objectives:
		if bool(objective["required"]) and not objective_complete(str(objective["id"])):
			return false
	return true

func get_objective_progress_line() -> String:
	if not campaign_operation.is_empty():
		match campaign_operation["kind"]:
			"relay": return "Power generator destroyed." if objective_complete("generator") else "Destroy the power generator."
			"rescue": return "Cells freed %d/2. Interact with each prisoner from an adjacent tile (1 AP)." % (int(objective_complete("prisoner_a")) + int(objective_complete("prisoner_b")))
		return "Clear the enemy formation."
	if test_mission_id == "chain":
		if mission_stage == 1:
			return "OPTIONAL: Destroy radio TX by end of turn 3"
		if mission_stage == 2 and radio_reinforcements_queued:
			return "RADIO ALERT: +3 hounds in final room"
		return "Eliminate all enemies to clear room."
	return "Eliminate all enemies to clear room."


func objective_action(actor_idx: int, tile: Vector2i) -> bool:
	if actor_idx < 0 or not mission_object_at(tile) or int(units[actor_idx]["ap"]) < 1:
		return false
	var obj: Dictionary = mission_objects[tile]
	var kind: String = str(obj["kind"])
	var adjacent: bool = grid_distance(units[actor_idx]["pos"], tile) == 1
	if kind == "prisoner":
		if not adjacent:
			status_message = "Move adjacent to interact with this objective (1 AP)."
			return false
		units[actor_idx]["ap"] = int(units[actor_idx]["ap"]) - 1
		record_ability_use(actor_idx, "Objective Interaction")
		obj["released"] = true
		mission_objects[tile] = obj
		status_message = "%s FREE! Once guards are defeated the prisoner evacuates safely." % str(obj["label"])
		add_log(status_message)
		assess_winner()
		queue_redraw()
		return true
	if kind != "machine":
		status_message = "Your squad cannot attack this protected objective."
		return false
	var actor: Dictionary = units[actor_idx]
	var legacy_strike: bool = adjacent and not actor.has("class_build")
	if not legacy_strike:
		var preview: Dictionary = object_attack_preview(actor_idx, tile)
		if preview.get("blocked_by_cover", false):
			return fire_into_full_cover(actor_idx, tile, str(units[actor_idx]["basic_attack"]), 1, true)
		if not preview["valid"]:
			status_message = preview["reason"]
			return false
		spend_shot(actor_idx)
	play_unit_action(actor_idx, board_center(tile), legacy_strike or basic_is_melee(actor), Color.TRANSPARENT, str(actor["basic_attack"]))
	units[actor_idx]["ap"] = int(units[actor_idx]["ap"]) - 1
	unit_action_counters[actor_idx]["basic_attacks"] = int(unit_action_counters[actor_idx]["basic_attacks"]) + 1
	battle_stats[actor_idx]["attacks"] = int(battle_stats[actor_idx]["attacks"]) + 1
	var damage: int = maxi(0, (2 if legacy_strike else int(actor["damage"])) - blinded_damage_penalty(actor_idx))
	var dealt: int = mini(damage, int(obj["hp"]))
	obj["hp"] = maxi(0, int(obj["hp"]) - damage)
	mission_objects[tile] = obj
	unit_action_counters[actor_idx]["objective_damage"] = int(unit_action_counters[actor_idx]["objective_damage"]) + dealt
	damage_history.append({"number": damage_history.size() + 1, "round": turn_number, "team": "objective", "attacker": str(units[actor_idx]["name"]), "defender": str(obj["label"]), "ability": "Objective Strike", "arm": 0, "hp": dealt, "cover": 0, "running": dealt})
	show_damage_at(tile, 0, dealt)
	if int(obj["hp"]) <= 0:
		queue_burst(board_center(tile), 24.0, Color("#f6aa72"))
	status_message = "%s takes %d damage (%d HP left)." % [str(obj["label"]), dealt, int(obj["hp"])]
	add_log(status_message)
	assess_winner()
	queue_redraw()
	return true

func append_enemy_to_battle(enemy: Dictionary) -> void:
	enemy["id"] = units.size()
	fill_magazine(enemy)
	enemy["statuses"] = {}
	enemy["class_effects"] = {}
	enemy["reaction_type"] = ""
	enemy["reaction_available"] = false
	enemy["special_used_turn"] = -99
	enemy["special_ready_turn"] = -99
	enemy["stim_bonus"] = 0
	enemy["jammed_actions"] = 0
	enemy["weight"] = 1 if enemy.get("kind", "") == "horde" else 2
	units.append(enemy)
	battle_stats.append({"dealt_hp": 0, "dealt_arm": 0, "taken_hp": 0, "taken_arm": 0, "tiles": 0, "kills": 0, "attacks": 0, "healing": 0, "buffs": 0, "ability_uses": 0, "reactions": 0})
	unit_action_counters.append({"moves": 0, "basic_attacks": 0, "overwatch_set": 0, "objective_damage": 0, "env_triggers": 0, "cover_broken": 0, "named_abilities": {}})

func draw_mission_object(pos: Vector2i) -> void:
	var obj: Dictionary = mission_objects[pos]
	var kind: String = str(obj["kind"])
	var active: bool = mission_object_at(pos)
	var floor_pos: Vector2 = battlefield.project(board_center(pos))
	var center: Vector2 = floor_pos + Vector2(0, -13)
	var col := Color("#e8bd67") if kind == "machine" else Color("#93ddac")
	if not active: col = Color("#697681")
	var base: Color = col.darkened(0.46)
	var light: Color = col.lightened(0.24)
	var corner: Vector2 = center - Vector2(14, 14)
	sabotage_visuals.draw_shadow(self, floor_pos + Vector2(2, 2), 40.0)
	draw_colored_polygon(PackedVector2Array([corner, corner + Vector2(7, -5), corner + Vector2(34, -5),
		corner + Vector2(28, 0)]), base.lightened(0.13))
	draw_colored_polygon(PackedVector2Array([corner + Vector2(28, 0), corner + Vector2(34, -5),
		corner + Vector2(34, 22), corner + Vector2(28, 28)]), base.darkened(0.45))
	draw_rect(Rect2(corner, Vector2(28, 28)), base)
	draw_rect(Rect2(corner + Vector2(1, 1), Vector2(26, 2)), light)
	draw_rect(Rect2(corner + Vector2(2, 24), Vector2(24, 2)), col.darkened(0.66))
	if kind == "prisoner":
		draw_rect(Rect2(corner + Vector2(3, 5), Vector2(22, 17)), Color("#182a2b"))
		for x in [5, 11, 17, 23]:
			draw_rect(Rect2(corner + Vector2(x, 5), Vector2(2, 16)), light)
	else:
		draw_rect(Rect2(corner + Vector2(4, 5), Vector2(20, 8)), base.darkened(0.65))
		for x in [6, 12, 18]:
			draw_rect(Rect2(corner + Vector2(x, 7), Vector2(4, 3)), light if active else base)
		for x in [3, 9, 15, 21]:
			draw_line(corner + Vector2(x, 25), corner + Vector2(x + 3, 22), base.darkened(0.54), 2.0)
	draw_rect(Rect2(corner + Vector2(8, 13), Vector2(12, 10)), col)
	var glyph: String = "G" if kind == "machine" else ("1" if obj["id"] == "prisoner_a" else "2")
	draw_label(glyph, center + Vector2(-4, 9), 11, Color("#10232e"))
	if kind == "machine" and active:
		draw_label("%d" % int(obj["hp"]), center + Vector2(8, -15), 11, Color("#ffffff"))


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
	high_ground_tiles.clear()
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

	register_destructible_cover()
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

func register_destructible_cover() -> void:
	destructible_edges.clear()
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

func squad_tab_rect(idx: int) -> Rect2:
	return Rect2(34, 172 + idx * 65, 126, 46)

func dev_jump_to_room(stage: int) -> void:
	# Developer-only testing shortcut: resets squad to full HP, removes history.
	# Does NOT simulate clearing prior rooms. Never available in retail missions.
	room_history.clear()
	radio_reinforcements_queued = false
	radio_state.clear()
	load_mission_room(clampi(stage, 0, ROOM_COUNT - 1), [])
	status_message = "DEV JUMP to ROOM %d: fresh squad, no radio-alert consequence. [F6/F7/F8]" % (stage + 1)
	add_log(status_message)
	queue_redraw()

func barrel_is_active(tile: Vector2i) -> bool:
	return barrels.has(tile) and int(barrels[tile].get("hp", 0)) > 0

func barrel_preview(attacker_idx: int, tile: Vector2i) -> Dictionary:
	if not barrel_is_active(tile) or attacker_idx < 0 or attacker_idx >= units.size():
		return {"valid": false, "reason": "Barrel unavailable", "distance": 0}
	var result: Dictionary = object_attack_preview(attacker_idx, tile)
	if result["valid"]:
		result["reason"] += " · Detonation damages both sides"
	return result

func object_attack_preview(attacker_idx: int, tile: Vector2i) -> Dictionary:
	var attacker: Dictionary = units[attacker_idx]
	var distance: int = grid_distance(attacker["pos"], tile)
	var result: Dictionary = {"valid": false, "distance": distance}
	var cover_block := "" if basic_is_melee(attacker) else ranged_cover_block_reason(attacker["pos"], tile)
	if not has_attack_ammo(attacker_idx):
		result["reason"] = empty_attack_resource(attacker_idx)
	elif distance > int(attacker["range"]):
		result["reason"] = "Out of basic-attack range"
	elif not has_line_of_sight(attacker["pos"], tile):
		result["reason"] = "Wall blocks line of sight"
	elif attacker.has("class_build") and not basic_is_melee(attacker) and not class_combat.shot_through_smoke(attacker_idx, attacker["pos"], tile):
		result["reason"] = "Smoke obscures line of sight"
	elif not cover_block.is_empty():
		result["blocked_by_cover"] = cover_block == FULL_COVER_BLOCK
		result["reason"] = cover_block + " · 0 damage · spends AP and ammo" if result["blocked_by_cover"] else cover_block
	else:
		result["valid"] = true
		result["reason"] = "Click to attack (1 AP)"
	return result

func fire_into_full_cover(actor_idx: int, tile: Vector2i, ability: String, cost: int, basic: bool) -> bool:
	if int(units[actor_idx]["ap"]) < cost or not spend_shot(actor_idx):
		return false
	var source: Vector2i = units[actor_idx]["pos"]
	var edge: Vector2 = board_center(tile)
	var face: String = attacked_side(source, tile)
	if face != "":
		edge += Vector2(tile_offset_for_face(face)) * TILE * 0.5
	play_unit_action(actor_idx, edge, false, Color.TRANSPARENT, str(units[actor_idx]["basic_attack"]))
	units[actor_idx]["ap"] -= cost
	if basic:
		unit_action_counters[actor_idx]["basic_attacks"] += 1
	battle_stats[actor_idx]["attacks"] += 1
	record_ability_use(actor_idx, ability)
	units[actor_idx]["stim_bonus"] = 0
	if class_combat.enabled:
		class_combat.spend_basic_attack_effects(actor_idx)
	report_full_cover_block(actor_idx)
	queue_redraw()
	return true

func attack_barrel(actor_idx: int, tile: Vector2i) -> bool:
	var preview: Dictionary = barrel_preview(actor_idx, tile)
	if preview.get("blocked_by_cover", false):
		return fire_into_full_cover(actor_idx, tile, str(units[actor_idx]["basic_attack"]), 1, true)
	if not bool(preview["valid"]):
		status_message = str(preview["reason"])
		return false
	if int(units[actor_idx]["ap"]) < 1:
		status_message = "Attacking the barrel costs 1 AP."
		return false
	if not spend_shot(actor_idx):
		return false
	play_unit_action(actor_idx, board_center(tile), basic_is_melee(units[actor_idx]), Color.TRANSPARENT,
		str(units[actor_idx]["basic_attack"]))
	units[actor_idx]["ap"] = int(units[actor_idx]["ap"]) - 1
	unit_action_counters[actor_idx]["basic_attacks"] = int(unit_action_counters[actor_idx]["basic_attacks"]) + 1
	battle_stats[actor_idx]["attacks"] = int(battle_stats[actor_idx]["attacks"]) + 1
	record_ability_use(actor_idx, str(units[actor_idx]["basic_attack"]))
	var damage: int = maxi(0, int(units[actor_idx]["damage"]) - blinded_damage_penalty(actor_idx))
	hit_barrel(tile, damage, actor_idx, str(units[actor_idx]["basic_attack"]))
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
	if campaign_operation.get("kind", "") == "relay":
		queue_burst(board_center(tile), radius * TILE, Color("#ffad65") if kind == "fuel" else Color("#c0d98b"), &"blast")
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

func environment_hit_unit(creator: int, idx: int, raw_damage: int, label: String, direct_hp: bool = false) -> void:
	if idx < 0 or idx >= units.size() or int(units[idx]["hp"]) <= 0 or raw_damage <= 0:
		return
	var taken_arm: int = 0 if direct_hp else mini(int(units[idx]["armour"]), raw_damage)
	var taken_hp: int = mini(int(units[idx]["hp"]), maxi(0, raw_damage - taken_arm))
	var armour_before: int = int(units[idx]["armour"])
	if class_combat.enabled:
		if class_combat.effects(idx).get("electrical_weak", false) and ("Shock" in label or "Electrical" in label):
			raw_damage += 1
		var impact: Dictionary = class_combat.impact(creator, idx, raw_damage, 0,
			{"area": true, "hazard": true, "bypass": armour_before if direct_hp else 0, "bypass_barriers": direct_hp})
		class_combat.consume_hit(-1, idx, impact)
		taken_arm = impact["armour_damage"]
		taken_hp = impact["hp_damage"]
	units[idx]["armour"] = int(units[idx]["armour"]) - taken_arm
	units[idx]["hp"] = int(units[idx]["hp"]) - taken_hp
	if class_combat.enabled:
		class_combat.on_damage(idx, 0, taken_hp)
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
		show_damage_at(units[idx]["pos"], taken_arm, taken_hp, idx)
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
	if distance > 0 and class_combat.enabled:
		if class_combat.resists_displacement(idx):
			return
		distance = class_combat.displacement_distance(idx, distance)
	var delta: Vector2i = units[idx]["pos"] - epicentre
	var dir: Vector2i = Vector2i.ZERO
	if absi(delta.x) >= absi(delta.y):
		dir.x = 1 if delta.x >= 0 else -1
	else:
		dir.y = 1 if delta.y >= 0 else -1
	for _step in range(distance):
		var dest: Vector2i = units[idx]["pos"] + dir
		if not footprint_is_open(units[idx], dest):
			environment_hit_unit(creator, idx, 1, "Knockback Collision")
			break
		apply_unit_position(idx, dest, &"displace")
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

func apply_status(idx: int, kind: String, duration: int = 1) -> void:
	if class_combat.enabled and class_combat.quarantine_protects(idx, kind):
		return
	if int(units[idx]["hp"]) <= 0:
		return
	var effects: Dictionary = units[idx].get("statuses", {})
	match kind:
		"shocked": effects[kind] = SHOCK_TURNS
		"blinded": effects[kind] = maxi(duration, int(effects.get(kind, 0)))
		_: effects[kind] = STATUS_TURNS
	units[idx]["statuses"] = effects

func blinded_damage_penalty(idx: int) -> int:
	return BLINDED_DAMAGE_PENALTY if int(units[idx]["statuses"].get("blinded", 0)) > 0 else 0

func expire_blinded_for_team(team: String) -> void:
	for unit in units:
		if unit["team"] != team:
			continue
		var statuses: Dictionary = unit["statuses"]
		if int(statuses.get("blinded", 0)) > 1:
			statuses["blinded"] -= 1
		else:
			statuses.erase("blinded")

func apply_hazard_entry(idx: int) -> void:
	var footprint: Rect2i = unit_footprint(units[idx], units[idx]["pos"])
	for y in range(footprint.position.y, footprint.end.y):
		for x in range(footprint.position.x, footprint.end.x):
			if int(units[idx]["hp"]) <= 0:
				return
			var tile := Vector2i(x, y)
			if hazards.has(tile):
				apply_hazard_at(idx, tile)

func apply_hazard_at(idx: int, tile: Vector2i) -> void:
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
			if effect == "blinded":
				continue  # Expires after the affected side has acted.
			match str(effect):
				"burning": environment_hit_unit(-1, idx, 1, "Burning Status")
				"irradiated": environment_hit_unit(-1, idx, 1, "Irradiated Status", true)
				"bleeding": environment_hit_unit(-1, idx, 1, "Bleeding Status", true)
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
		if campaign_operation.get("kind", "") == "relay":
			var edge_center: Vector2 = board_center(tile) + Vector2(tile_offset_for_face(face)) * TILE * 0.5
			queue_burst(edge_center, 18.0, Color("#dbc29b"))
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
			if class_combat.enabled:
				class_combat.recalibrate(actor_idx)
		add_log("COVER SHATTERED (%s): %s / %s" % [cause, str(tile), face])
	else:
		destructible_edges[key] = edge
		add_log("%s cover damaged by %s." % ["Light" if int(edge["level"]) == 1 else "Reinforced", cause])

func breach_push_destination(victim_idx: int, direction: Vector2i, landing: Vector2i) -> Vector2i:
	# Deterministic displacement: straight forward, then clockwise, then counterclockwise.
	# Not a physics force: one tile only. Existing explosion knockback still has a 2-tile cap.
	var side: Vector2i = Vector2i(-direction.y, direction.x)
	var candidates: Array[Vector2i] = [direction, side, -side]
	for offset in candidates:
		var destination: Vector2i = units[victim_idx]["pos"] + offset
		if not unit_footprint(units[victim_idx], destination).has_point(landing) and footprint_is_open(units[victim_idx], destination):
			return destination
	return Vector2i(-1, -1)

func breach_plan(target_tile: Vector2i) -> Dictionary:
	# Single authoritative preflight used for both preview and execution.
	# The charge cannot turn, jump walls, target allies or shove equally heavy enemies.
	var plan: Dictionary = {"valid": false, "reason": "Select a destination", "path": [], "edges": [], "enemy": -1, "push": Vector2i(-1, -1), "lethal": false}
	if operative_kit(selected_id) != 1 or int(units[selected_id]["hp"]) <= 0:
		plan["reason"] = "Anvil is unavailable"
		return plan
	if overwatch_locks_movement(selected_id):
		plan["reason"] = "Holding position on Overwatch"
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
				var push: Vector2i = breach_push_destination(occupant, direction, current)
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
		draw_set_transform_matrix(battlefield.camera)
		draw_label("5 DMG", battlefield.project(enemy_screen) + Vector2(-15, -34), 12, Color("#ffe49c"))
		draw_set_transform_matrix(battlefield.ground)
		if not bool(hovered["lethal"]):
			var pushed: Vector2i = hovered["push"]
			var pushed_screen: Vector2 = ORIGIN + Vector2((float(pushed.x) + 0.5) * TILE, (float(pushed.y) + 0.5) * TILE)
			draw_rect(Rect2(ORIGIN + Vector2(pushed.x * TILE + 3, pushed.y * TILE + 3), Vector2(TILE - 6, TILE - 6)), Color("#6feeaa"), false, 3.0)
			draw_line(enemy_screen, pushed_screen, Color("#6feeaa"), 3.0)
			draw_circle(pushed_screen, 4.0, Color("#6feeaa"))

func draw_barrel(tile: Vector2i) -> void:
	var barrel: Dictionary = barrels[tile]
	var c: Vector2 = battlefield.project(board_center(tile)) + Vector2(0, -8)
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
	restart_game()
	mission_picker_open = false
	var playable_classes: Array[String] = []
	for idx in range(5):
		var kit: String = units[idx]["name"]
		playable_classes.append(kit)
		headquarters.kit_profiles[kit] = units[idx].duplicate(true)
		headquarters.kit_profiles[kit].merge(PlayerClasses.LEVEL_ONE_STATS, true)
	playable_classes.append("Glaz")
	headquarters.kit_profiles["Glaz"] = make_glaz_profile()
	add_child(headquarters)
	headquarters.campaign.seed(playable_classes)
	headquarters.deployed.connect(deploy_hq_operation)
	headquarters.open()

func deploy_hq_operation(operation: String) -> void:
	if not CampaignOperations.has_operation(operation) or headquarters.campaign.mission.get("operation") != operation:
		return
	hq_deployment = true
	test_mission_id = operation
	mission_picker_open = false
	restart_game()

func hq_operative_id(idx: int) -> int:
	return int(headquarters.campaign.mission["squad"][idx])

func operative_kit(idx: int) -> int:
	return int(units[idx].get("kit_index", idx)) if idx >= 0 and idx < 5 else -1

func operative_avatar(unit: Dictionary) -> Texture2D:
	var key: String = OriginAvatars.variant(unit["kit_name"], unit["class_build"], unit["class_state"]["form"])
	return OriginAvatars.texture(key)

func make_glaz_profile() -> Dictionary:
	var profile: Dictionary = PlayerClasses.LEVEL_ONE_STATS.duplicate()
	profile.merge({"id": 5, "team": "player", "name": "Glaz", "letter": "G",
		"ap": 3, "max_ap": 3, "basic_attack": "Glaz Sidearm", "special": ""})
	return profile

func extract_hq_operation() -> void:
	if not hq_deployment or not room_cleared or headquarters.campaign.mission.is_empty():
		return
	headquarters.campaign.finish("%s · Extracted after Room %d" % [campaign_operation["label"], mission_stage + 1], units,
		chain_sum("kill_xp"), chain_sum("objective_xp"))
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
	load_mission_room(0, [])

func load_mission_room(stage: int, carry: Array[Dictionary]) -> void:
	sabotage_visuals.reset()
	hovered_tile = Vector2i(-1, -1)
	texture_filter = TEXTURE_FILTER_NEAREST
	mission_stage = stage
	campaign_operation = CampaignOperations.operation(test_mission_id) if hq_deployment else {}
	class_combat.begin_room(hq_deployment)
	resolving_class_action = false
	breach_target_mode = false
	loadout_action = ""
	room_cleared = false
	mission_victory = false
	mission_failure_reason = ""
	if test_mission_id == "chain" and stage == 1:
		radio_state = {"pos": RADIO_POS, "hp": RADIO_HP, "max_hp": RADIO_HP, "damage": 0, "destroyed_in_time": false, "destroyed_round": -1}
		radio_reinforcements_queued = false
	else:
		radio_state.clear()
	# Three distinct maps: open kennels, fortified bunker, compact final arena.
	if hq_deployment:
		setup_campaign_arena(CampaignOperations.layout(test_mission_id, stage))
	else:
		setup_legacy_arena(stage)
	battlefield.frame(Vector2i(board_w, board_h), ORIGIN, TILE)
	pan_keys.clear()
	developer_menu_open = false
	var authored: Array[Dictionary] = []
	for idx in range(5):
		if not hq_deployment:
			authored.append(units[idx].duplicate(true))
			continue
		var id: int = hq_operative_id(idx)
		var kit: String = headquarters.campaign.roster[id]["kit"]
		var kit_index: int = headquarters.campaign.classes.find(kit)
		var operative: Dictionary = make_glaz_profile() if kit == "Glaz" else units[kit_index].duplicate(true)
		operative.merge(PlayerClasses.LEVEL_ONE_STATS, true)
		operative["kit_index"] = kit_index
		operative["kit_name"] = kit
		operative["name"] = headquarters.campaign.operative_name(id)
		operative["pos"] = units[idx]["pos"]
		authored.append(operative)
	if hq_deployment:
		var layout := CampaignOperations.layout(test_mission_id, stage)
		var formation: Array = campaign_operation["formation"]
		if campaign_operation["kind"] == "sweep":
			formation = formation[stage]
		for i in range(formation.size()):
			authored.append(EnemyRoster.create(formation[i], campaign_tile(layout["posts"][i])))
	elif stage == 0:
		# Seven fast experiments and a supporting KGB biotechnician.
		for idx in range(5, 12):
			authored.append(units[idx].duplicate(true))
		var medic: Dictionary = units[12].duplicate(true)
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
		elite["tier"] = EnemyRoster.Tier.MINI_BOSS
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
		units[idx]["class_effects"] = {}
		if idx < 5:
			if hq_deployment:
				var id: int = hq_operative_id(idx)
				StarterLoadouts.equip(units[idx], headquarters.campaign.mission["gear"][id])
			else:
				StarterLoadouts.equip(units[idx], mission_loadouts[idx])
				# Fixtures retain their authored attacks and the original secondary strike.
				units[idx]["fixture_melee_damage"] = 0 if idx == 2 else 2
				units[idx]["fixture_melee_name"] = "Melee Strike"
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
			if class_combat.enabled:
				var id: int = hq_operative_id(idx)
				class_combat.setup_unit(idx, headquarters.campaign.mission["class_builds"][id],
					carry[idx] if carry.size() == 5 else {})
			if int(units[idx]["hp"]) <= 0:
				units[idx]["ap"] = 0
		units[idx]["armour"] = int(units[idx]["max_armour"]) if armour_enabled and int(units[idx]["hp"]) > 0 else 0
	for idx in range(units.size()):
		var class_weight: int = 1 if str(units[idx].get("kind", "")) == "horde" else 2
		if (operative_kit(idx) == 1 and not class_combat.enabled) or str(units[idx].get("name", "")) == "KGB Elite Enforcer":
			class_weight = 3
		units[idx]["weight"] = 5 if units[idx].get("trait") == "ballast" else class_weight
		units[idx]["statuses"] = {}
		units[idx]["breach_used_turn"] = -99
	if not hq_deployment:
		setup_environment_for_room(stage)
	reset_room_state()
	setup_room_objectives()
	for unit in units:
		assert(int(unit["hp"]) <= 0 or footprint_is_open(unit, unit["pos"]), "Room unit footprint starts in blocked space")
	if class_combat.enabled:
		for idx in range(5):
			class_combat.prime_high_perch(idx)
		class_combat.deploy_devices()
	selected_id = -1
	for idx in range(5):
		if int(units[idx]["hp"]) > 0:
			selected_id = idx
			break
	status_message = ""
	if test_mission_id == "chain" and stage == 1:
		add_log("SECONDARY: Destroy Radio Transmitter in 3 player turns (optional for clearance).")
	elif test_mission_id == "chain" and stage == 2 and radio_reinforcements_queued:
		add_log("ALERT CONSEQUENCE: three additional hounds in the final room.")
	add_log("%s — room %d/%d begins." % [campaign_operation.get("label", "Original chain"), mission_stage + 1, mission_room_total()])
	if hq_deployment:
		print("HQ operation %s: entered room %d/%d." % [test_mission_id, mission_stage + 1, mission_room_total()])
	queue_redraw()

func make_chain_rifle(label: String, at: Vector2i, stronger: bool, profile: String) -> Dictionary:
	var max_health: int = 8 if stronger else 6
	var max_protection: int = 2 if stronger else 1
	return {"id": -1, "team": "enemy", "kind": "ranged", "name": label, "letter": label.substr(label.length() - 1), "pos": at, "hp": max_health, "max_hp": max_health, "ap": 2, "max_ap": 2, "damage": 3 if stronger else 2, "range": 6, "move": MOVE_DISTANCE, "armour": max_protection, "max_armour": max_protection, "basic_attack": "KGB Service Rifle", "ai_profile": profile, "ai_role": "combatant", "ai_traits": {"self_preservation": 1.15}}

func campaign_tile(tile: Vector2i) -> Vector2i:
	return CampaignOperations.battle_tile(test_mission_id, tile, board_h)

func setup_campaign_arena(layout: Dictionary) -> void:
	var size: Vector2i = layout["size"]
	board_w = size.x
	board_h = size.y
	walls.clear()
	cover_edges.clear()
	barrels.clear()
	hazards.clear()
	high_ground_tiles.clear()
	for area: Rect2i in layout["walls"]:
		for y in range(area.position.y, area.end.y):
			for x in range(area.position.x, area.end.x):
				walls.append(campaign_tile(Vector2i(x, y)))
	for platform: Rect2i in layout.get("high_ground", []):
		for y in range(platform.position.y, platform.end.y):
			for x in range(platform.position.x, platform.end.x):
				high_ground_tiles.append(campaign_tile(Vector2i(x, y)))
	for cover: Vector3i in layout["cover"]:
		cover_edges[campaign_tile(Vector2i(cover.x, cover.y))] = {"E": cover.z}
	var region: Dictionary = CampaignOperations.REGIONS[test_mission_id.get_slice("/", 0)]
	var local_cover := campaign_tile(region["cover"])
	if not walls.has(local_cover) and not walls.has(local_cover + Vector2i.LEFT):
		cover_edges.get_or_add(local_cover, {})["W"] = 2
	for kind: String in layout.get("barrels", {}):
		barrels[campaign_tile(layout["barrels"][kind])] = {"kind": kind, "hp": 1, "max_hp": 1}
	register_destructible_cover()
	var allies: Array[Vector2i] = []
	for y: int in layout["entry"]:
		allies.append(campaign_tile(Vector2i(1, y)))
	make_operative_roster(allies)

func reset_room_state() -> void:
	unit_playback.reset()
	pending_defeats.clear()
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
	special_mode = false
	shred_landing_tile = Vector2i(-1, -1)
	show_report = false
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

func save_room_result(advances: bool = false) -> void:
	# Snapshot the room once at its result boundary. Every damage source uses
	# the same defeated-unit test, and repeating debrief cannot award it again.
	var kill_xp := 0
	for unit in units:
		if enemy_defeated(unit):
			kill_xp += EnemyRoster.kill_xp(unit)
	var objective_xp := 0
	for objective in mission_objectives:
		if objective_complete(objective["id"]):
			objective_xp += CampaignState.OBJECTIVE_XP
	if radio_state.get("destroyed_in_time", false):
		objective_xp += CampaignState.OBJECTIVE_XP
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
			"overwatch_triggered": int(stats.get("overwatch_shots", 0)),
			"abilities": counters["named_abilities"].duplicate(true),
			"dealt_hp": int(stats["dealt_hp"]), "dealt_arm": int(stats["dealt_arm"]),
			"taken_hp": int(stats["taken_hp"]), "taken_arm": int(stats["taken_arm"]),
			"kills": int(stats["kills"]), "healing": int(stats["healing"]),
			"buffs": int(stats["buffs"]), "objective_damage": int(counters["objective_damage"]), "env_triggers": int(counters["env_triggers"]), "cover_broken": int(counters["cover_broken"])
		})
	room_history.append({"name": mission_room_label(mission_stage), "turns": turn_number, "player_damage": total_team_damage("player"), "enemy_damage": total_team_damage("enemy"), "hp": after_hp, "enemy_count": units.size() - 5, "enemies_defeated": defeated_enemy_count(), "radio": radio_result, "radio_bonus": radio_reinforcements_queued, "activity": activity, "advances": advances,
		"kill_xp": kill_xp, "objective_xp": objective_xp})
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
		var entry: Dictionary = {"hp": health, "downs": downs, "permanently_dead": dead, "medkit_charges": int(unit["medkit_charges"])}
		if class_combat.enabled:
			class_combat.save_carry(idx, entry)
		result.append(entry)
	return result

func next_mission_room() -> void:
	if not room_cleared or mission_stage >= mission_room_total() - 1 or not movement_task.is_empty():
		return
	var carry: Array[Dictionary] = carry_squad_to_next_room()
	load_mission_room(mission_stage + 1, carry)

func setup_legacy_arena(stage: int) -> void:
	# The three layouts used by the original regression chain.
	if stage == 1:
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
		make_operative_roster(ally_tiles)
	elif stage == 0:
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
		# Seven fast-moving experiments and their supporting technician.
		var foe_tiles: Array[Vector2i] = [
			Vector2i(15, 1), Vector2i(17, 2), Vector2i(16, 4),
			Vector2i(18, 5), Vector2i(16, 7), Vector2i(18, 8),
			Vector2i(16, 10), Vector2i(14, 8)
		]
		make_regression_roster(ally_tiles, foe_tiles)
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
			Vector2i(13, 10), Vector2i(13, 8)
		]
		make_regression_roster(ally_tiles, foe_tiles)

func make_operative_roster(allies: Array[Vector2i]) -> void:
	# One signature ability per player for initial class interaction testing.
	# Stats are intentionally provisional; 2D tokens remain placeholders.
	units = [
		{"id": 0, "team": "player", "name": "Scythe", "letter": "S", "pos": allies[0], "hp": 9, "max_hp": 9, "ap": 3, "max_ap": 3, "damage": 3, "range": 4, "armour": 2, "max_armour": 2, "basic_attack": "Scythe Carbine", "special": "Area Shred"},
		{"id": 1, "team": "player", "name": "Anvil", "letter": "A", "pos": allies[1], "hp": 11, "max_hp": 11, "ap": 3, "max_ap": 3, "damage": 2, "range": 5, "armour": 3, "max_armour": 3, "basic_attack": "Anvil SMG", "special": "Fortify"},
		{"id": 2, "team": "player", "name": "Needle", "letter": "N", "pos": allies[2], "hp": 8, "max_hp": 8, "ap": 3, "max_ap": 3, "damage": 3, "range": 8, "armour": 1, "max_armour": 1, "basic_attack": "Needle Rifle", "special": "Precision Shot"},
		{"id": 3, "team": "player", "name": "Iskra", "letter": "I", "pos": allies[3], "hp": 8, "max_hp": 8, "ap": 3, "max_ap": 3, "damage": 2, "range": 6, "armour": 1, "max_armour": 1, "basic_attack": "Iskra Carbine", "special": "Arc Disruptor"},
		{"id": 4, "team": "player", "name": "Alkhimik", "letter": "K", "pos": allies[4], "hp": 9, "max_hp": 9, "ap": 3, "max_ap": 3, "damage": 2, "range": 5, "armour": 2, "max_armour": 2, "basic_attack": "Alkhimik Sidearm", "special": "Field Treatment"}
	]

func make_regression_roster(allies: Array[Vector2i], enemies: Array[Vector2i]) -> void:
	make_operative_roster(allies)
	for n in range(7):
		units.append({"id": 5 + n, "team": "enemy", "kind": "horde", "name": "Experiment %02d" % (n + 1), "letter": "H", "pos": enemies[n], "hp": 4, "max_hp": 4, "ap": 2, "max_ap": 2, "damage": 2, "range": 1, "move": HORDE_MOVE_DISTANCE, "armour": 0, "max_armour": 0, "basic_attack": "Ravenous Bite", "ai_profile": "horde", "ai_role": "melee", "ai_traits": {"self_preservation": 0.0}})
	units.append({"id": 12, "team": "enemy", "kind": "support", "name": "KGB Biotechnician", "letter": "+", "pos": enemies[7], "hp": 7, "max_hp": 7, "ap": 2, "max_ap": 2, "damage": 1, "range": 5, "move": MOVE_DISTANCE, "armour": 1, "max_armour": 1, "basic_attack": "Support Pistol", "ai_profile": "self_preserving", "ai_role": "medic", "ai_traits": {"self_preservation": 1.5}})



func add_log(message: String) -> void:
	action_log.push_front(message)
	while action_log.size() > 7:
		action_log.pop_back()

func is_in_bounds(tile: Vector2i) -> bool:
	return tile.x >= 0 and tile.x < board_w and tile.y >= 0 and tile.y < board_h

func unit_footprint(unit: Dictionary, anchor: Vector2i) -> Rect2i:
	# Position is the top-left cell of the square footprint.
	var size: int = int(unit.get("footprint_size", 1))
	return Rect2i(anchor, Vector2i(size, size))

func find_unit_at(tile: Vector2i, include_downed: bool = false) -> int:
	for idx in range(units.size()):
		var unit: Dictionary = units[idx]
		if int(unit["hp"]) <= 0 and not (include_downed and int(unit.get("recovery_round", 0)) > 0):
			continue
		if unit_footprint(unit, unit["pos"]).has_point(tile):
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
	if class_combat.enabled and class_combat.drone_at(tile):
		return false
	var occupant := find_unit_at(tile, true)
	return occupant < 0 or int(units[occupant]["id"]) == ignore_id

func footprint_is_open(unit: Dictionary, anchor: Vector2i) -> bool:
	var footprint: Rect2i = unit_footprint(unit, anchor)
	var ignore_id: int = int(unit.get("id", -1))
	for y in range(footprint.position.y, footprint.end.y):
		for x in range(footprint.position.x, footprint.end.x):
			if not tile_is_open(Vector2i(x, y), ignore_id):
				return false
	return true

func footprint_has_hazard(unit: Dictionary, anchor: Vector2i) -> bool:
	var footprint: Rect2i = unit_footprint(unit, anchor)
	for tile in hazards:
		if footprint.has_point(tile):
			return true
	return false

func can_take_move_step(unit: Dictionary, from: Vector2i, to: Vector2i) -> bool:
	var delta: Vector2i = (to - from).abs()
	if maxi(delta.x, delta.y) != 1:
		return false
	if not footprint_is_open(unit, to):
		return false
	if from.x == to.x or from.y == to.y:
		return true
	# Both orthogonal offsets must fit, including the entire footprint of a large unit.
	return footprint_is_open(unit, Vector2i(to.x, from.y)) and footprint_is_open(unit, Vector2i(from.x, to.y))

func reachable(start: Vector2i, limit: int, unit_id: int, parents: Dictionary = {}, destination: Vector2i = Vector2i(-1, -1)) -> Dictionary:
	var mover_idx: int = find_unit_by_id(unit_id)
	var mover: Dictionary = units[mover_idx] if mover_idx >= 0 else {}
	if class_combat.enabled and mover_idx >= 0:
		limit = class_combat.movement_budget(mover_idx, limit)
	var distances: Dictionary = {start: 0}
	var frontier: Array[Vector2i] = [start]
	var head: int = 0
	while head < frontier.size():
		var cell: Vector2i = frontier[head]
		head += 1
		var current_steps: int = int(distances[cell])
		if current_steps >= limit:
			continue
		for delta in MOVE_DIRECTIONS:
			var next_tile: Vector2i = cell + delta
			if class_combat.enabled and mover_idx >= 0 and not class_combat.voluntary_step(mover_idx, cell, next_tile):
				continue
			if not distances.has(next_tile) and can_take_move_step(mover, cell, next_tile):
				distances[next_tile] = current_steps + 1
				if destination.x >= 0:
					parents[next_tile] = cell
				if next_tile == destination:
					return distances
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

const FULL_COVER_BLOCK := "Full cover blocks this shot."

func report_full_cover_block(attacker_idx: int) -> void:
	status_message = "%s fires into full cover." % units[attacker_idx]["name"]
	add_log(status_message)

func ranged_cover_block_reason(attacker_tile: Vector2i, defender_tile: Vector2i, cover_pierce: int = 0, ignored_drone: int = -1) -> String:
	if attacker_tile == defender_tile:
		return ""
	if cover_level_at(defender_tile, attacker_tile) - cover_pierce >= 2:
		return FULL_COVER_BLOCK
	if class_combat.enabled and class_combat.barricade_at(defender_tile, attacked_side(attacker_tile, defender_tile), ignored_drone):
		return "Shield Run blocks this shot."
	return ""

func radio_is_present() -> bool:
	return test_mission_id == "chain" and mission_stage == 1 and not radio_state.is_empty()

func radio_is_active() -> bool:
	return radio_is_present() and int(radio_state.get("hp", 0)) > 0

func fill_magazine(unit: Dictionary) -> void:
	var default_capacity: int = 0 if unit.get("kind", "") == "horde" else DEFAULT_MAGAZINE_CAPACITY
	unit["magazine_capacity"] = int(unit.get("magazine_capacity", default_capacity))
	unit["rounds"] = int(unit["magazine_capacity"])

func basic_is_melee(unit: Dictionary) -> bool:
	return unit.get("basic_melee", false) or unit.get("kind", "") == "horde"

func empty_attack_resource(idx: int) -> String:
	return "No ranged charges: recharge [X]." if units[idx].has("class_build") else EMPTY_MAGAZINE

func has_attack_ammo(idx: int) -> bool:
	var unit: Dictionary = units[idx]
	return basic_is_melee(unit) or int(unit["magazine_capacity"]) == 0 or int(unit["rounds"]) > 0

func spend_shot(idx: int) -> bool:
	if not has_attack_ammo(idx):
		return false
	if not basic_is_melee(units[idx]) and int(units[idx]["magazine_capacity"]) > 0:
		units[idx]["rounds"] = int(units[idx]["rounds"]) - 1
	return true

func reload_weapon(idx: int) -> bool:
	var unit: Dictionary = units[idx]
	if basic_is_melee(unit) or int(unit["hp"]) <= 0 or int(unit["ap"]) < RELOAD_AP_COST or int(unit["rounds"]) >= int(unit["magazine_capacity"]):
		return false
	unit["ap"] = int(unit["ap"]) - RELOAD_AP_COST
	fill_magazine(unit)
	var action: String = "recharges" if unit.has("class_build") else "reloads"
	play_unit_action(idx, unit_board_center(idx), false, Color.TRANSPARENT,
		"Recharge" if unit.has("class_build") else "Reload")
	status_message = "%s %s %s (%d/%d)." % [unit["name"], action, unit["basic_attack"], unit["rounds"], unit["magazine_capacity"]]
	add_log(status_message)
	queue_redraw()
	return true

func reload_selected_weapon() -> void:
	var idx: int = find_unit_by_id(selected_id)
	if idx < 0 or int(units[idx]["hp"]) <= 0:
		return
	if basic_is_melee(units[idx]):
		status_message = "The current basic attack is melee."
	elif reload_weapon(idx):
		loadout_action = ""
		special_mode = false
		breach_target_mode = false
		shred_landing_tile = Vector2i(-1, -1)
	elif int(units[idx]["rounds"]) == int(units[idx]["magazine_capacity"]):
		status_message = "Ranged charges already full." if units[idx].has("class_build") else "Magazine already full."
	else:
		status_message = "Replenishing ranged attacks costs %d AP." % RELOAD_AP_COST
	queue_redraw()

func emergency_reload() -> void:
	var idx: int = find_unit_by_id(selected_id)
	if idx < 0 or int(units[idx]["hp"]) <= 0:
		status_message = "Select a living operative."
	elif not headquarters.campaign.mission.get("emergency_reload", false):
		status_message = "Emergency Reload is unprepared or already spent."
	elif basic_is_melee(units[idx]):
		status_message = "Select an operative with a ranged basic attack."
	elif int(units[idx]["rounds"]) >= int(units[idx]["magazine_capacity"]):
		status_message = "Ranged charges already full."
	elif not headquarters.campaign.use_emergency_reload():
		status_message = "Emergency Reload requires %d Intel." % Headquarters.State.RELOAD_COST
	else:
		fill_magazine(units[idx])
		status_message = "Emergency Reload refilled %s's ranged charges." % str(units[idx]["name"])
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
		result["damage"] = clampi(2 + int(unit.get("stim_bonus", 0)) - blinded_damage_penalty(attacker_idx), 0, int(radio_state["hp"]))
		result["reason"] = "Adjacent melee strike (1 AP)"
	elif dist <= int(unit["range"]) and has_line_of_sight(unit["pos"], RADIO_POS):
		if not has_attack_ammo(attacker_idx):
			result["reason"] = EMPTY_MAGAZINE
			return result
		var cover_block := ranged_cover_block_reason(unit["pos"], RADIO_POS)
		if not cover_block.is_empty():
			result["blocked_by_cover"] = cover_block == FULL_COVER_BLOCK
			result["reason"] = cover_block + " · 0 damage · spends AP and ammo" if result["blocked_by_cover"] else cover_block
			return result
		result["valid"] = true
		result["damage"] = clampi(int(unit["damage"]) + int(unit.get("stim_bonus", 0)) - blinded_damage_penalty(attacker_idx), 0, int(radio_state["hp"]))
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

func hit_radio(attacker_idx: int, raw_damage: int, attack_name: String, cost: int, basic: bool = false) -> bool:
	if not radio_is_active() or attacker_idx < 0 or int(units[attacker_idx]["ap"]) < cost:
		return false
	var actual: int = mini(int(radio_state["hp"]), maxi(0, raw_damage))
	if actual <= 0 and not basic:
		return false
	if cost > 0:
		play_unit_action(attacker_idx, board_center(RADIO_POS), attack_name == "Relay Melee", Color.TRANSPARENT, attack_name)
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
	show_damage_at(RADIO_POS, 0, actual)
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
	if preview.get("blocked_by_cover", false):
		fire_into_full_cover(attacker_idx, RADIO_POS, str(units[attacker_idx]["basic_attack"]), 1, true)
		return
	if not bool(preview["valid"]):
		status_message = str(preview["reason"])
		return
	if int(units[attacker_idx]["ap"]) < 1:
		status_message = "Attacking the transmitter costs 1 AP."
		return
	var attack_name: String = "Relay Melee" if bool(preview["melee"]) else str(units[attacker_idx]["basic_attack"])
	if not bool(preview["melee"]) and not spend_shot(attacker_idx):
		return
	if hit_radio(attacker_idx, int(preview["damage"]), attack_name, 1, true):
		units[attacker_idx]["stim_bonus"] = 0

func attack_preview(attacker_index: int, target_index: int, bonus_damage: int = 0, pierce: int = 0, uses_base_attack: bool = true, overwatch_tile: Vector2i = Vector2i(-1, -1)) -> Dictionary:
	if attacker_index < 0 or attacker_index >= units.size():
		return {"valid": false, "reason": "Invalid attacker", "damage": 0, "armour_damage": 0, "hp_damage": 0, "cover": 0, "base": 0, "side": ""}
	return attack_preview_from(attacker_index, target_index, units[attacker_index]["pos"], bonus_damage, pierce, uses_base_attack, 0, overwatch_tile)

func attack_preview_from(attacker_index: int, target_index: int, from_tile: Vector2i, bonus_damage: int = 0, pierce: int = 0, uses_base_attack: bool = true, approach_steps: int = 0, overwatch_tile: Vector2i = Vector2i(-1, -1), respect_target_priority: bool = true) -> Dictionary:
	# Shared deterministic calculation used for actual and hypothetical attacks.
	var result: Dictionary = {"valid": false, "reason": "Invalid target", "damage": 0, "armour_damage": 0, "hp_damage": 0, "cover": 0, "base": 0, "side": ""}
	if attacker_index < 0 or target_index < 0 or attacker_index == target_index:
		return result
	var attacker: Dictionary = units[attacker_index]
	var target: Dictionary = units[target_index]
	if int(attacker["hp"]) <= 0 or int(target["hp"]) <= 0 or attacker["team"] == target["team"]:
		return result
	var follow_up: bool = class_combat.enabled and uses_base_attack and not is_in_bounds(overwatch_tile) \
		and class_combat.breach_follow_up_ready(attacker_index, target_index)
	if not has_attack_ammo(attacker_index) and not follow_up:
		result["reason"] = empty_attack_resource(attacker_index)
		return result
	if class_combat.enabled and class_combat.effects(attacker_index).get("mind_lock_shot", false):
		result["reason"] = "Mind Lock has limited this enemy to one attack."
		return result
	if class_combat.enabled:
		if attacker.get("basic_attack") == "Synaptic Prick" and not class_combat.organic(target_index):
			result["reason"] = "Synaptic Prick requires an organic target."
			return result
		if respect_target_priority:
			var taunter: int = class_combat.effects(attacker_index).get("taunted_by", -1)
			var forced: bool = class_combat.living(taunter) and attack_preview_from(attacker_index, taunter, from_tile, 0, 0, true, 0, Vector2i(-1, -1), false)["valid"]
			if forced and taunter != target_index:
				result["reason"] = "Must attack the Anvil that taunted this unit."
				return result
			if not forced and int(class_combat.effects(attacker_index).get("phantom_target", -1)) == target_index:
				for alternate in range(5):
					if alternate != target_index and class_combat.living(alternate) \
							and attack_preview_from(attacker_index, alternate, from_tile, 0, 0, true, 0, Vector2i(-1, -1), false)["valid"]:
						result["reason"] = "Phantom Threat diverts this attack to another target."
						return result
	var overwatch: bool = is_in_bounds(overwatch_tile)
	var target_tile: Vector2i = overwatch_tile if overwatch else target["pos"]
	result["base"] = int(attacker["damage"]) + bonus_damage + int(attacker.get("stim_bonus", 0))
	var penalty: int = blinded_damage_penalty(attacker_index) if uses_base_attack else 0
	result["base"] -= penalty
	if uses_base_attack and attacker["team"] == "enemy" and (attacker.has("trait") or hq_deployment):
		result["base"] += formation_damage_bonus(attacker_index, from_tile, target_tile)
	var melee: bool = basic_is_melee(attacker)
	if not overwatch and attacker.get("trait") == "combo" and grid_distance(from_tile, target_tile) == 1:
		melee = true
	if melee and attacker.has("class_build"):
		var footprint: Rect2i = unit_footprint(target, target_tile)
		target_tile = from_tile.clamp(footprint.position, footprint.end - Vector2i.ONE)
	result["side"] = attacked_side(from_tile, target_tile)
	var extra_range: int = class_combat.range_bonus(attacker_index, target_index) if class_combat.enabled and not melee else 0
	var reach_distance: int = class_combat.distance(from_tile, target_tile) if attacker.has("class_build") else grid_distance(from_tile, target_tile)
	if not overwatch and reach_distance > int(attacker["range"]) + extra_range:
		result["reason"] = "Out of range"
		return result
	if not has_line_of_sight(from_tile, target_tile):
		result["reason"] = "Solid wall blocks line of sight"
		return result
	result["melee"] = melee
	if class_combat.enabled and not melee and not class_combat.shot_through_smoke(attacker_index, from_tile, target_tile):
		result["reason"] = "Smoke obscures line of sight"
		return result
	var cover: int = 0 if melee else maxi(0, cover_level_at(target_tile, from_tile) - pierce)
	if not melee:
		var cover_block := ranged_cover_block_reason(from_tile, target_tile, pierce)
		if not cover_block.is_empty():
			result["reason"] = cover_block
			result["cover"] = 2
			if cover_block == FULL_COVER_BLOCK:
				if has_attack_ammo(attacker_index):
					result["blocked_by_cover"] = true
				else:
					result["reason"] = empty_attack_resource(attacker_index)
			return result
	result["valid"] = true
	result["cover"] = cover
	result["damage"] = 0 if penalty > 0 and int(result["base"]) <= 0 else maxi(1, int(result["base"]) - cover)
	# Cover reduces impact first; armour absorbs remaining impact, then HP.
	# This preview is shared by real attacks and hypothetical movement previews.
	var remaining_armour: int = int(target["armour"])
	result["armour_damage"] = mini(remaining_armour, int(result["damage"]))
	result["hp_damage"] = mini(int(target["hp"]), maxi(0, int(result["damage"]) - int(result["armour_damage"])))
	if class_combat.enabled:
		var context: Dictionary = {"melee": melee, "ranged": not melee, "approach_steps": approach_steps, "review_basic": uses_base_attack, "source": from_tile,
			"overwatch": overwatch, "obstruction": class_combat.intervening_cover(attacker_index, from_tile, target_tile) if not melee else 0}
		result.merge(class_combat.impact(attacker_index, target_index, result["base"], cover, context), true)
		result["raw_damage"] = result["base"]
		result["raw_cover"] = cover
		result["damage"] = int(result["armour_damage"]) + int(result["hp_damage"])
	cover = int(result["cover"])
	result["reason"] = "Melee ignores cover" if melee else ("Flanking / unprotected" if cover == 0 else ("Half cover" if cover == 1 else "Full cover"))
	return result

func formation_damage_bonus(idx: int, origin: Vector2i, target: Vector2i) -> int:
	var signature: String = units[idx].get("trait", "")
	var distance := grid_distance(origin, target)
	var bonus := 0
	if signature in ["close", "combo"] and distance == 1:
		bonus = 2
	elif signature == "sniper" and distance <= 3:
		bonus = -2
	var accompanied := false
	var commanded := false
	for ally in units:
		if ally["id"] == idx or ally["team"] != "enemy" or ally["hp"] <= 0:
			continue
		if grid_distance(origin, ally["pos"]) <= 3:
			accompanied = true
			if ally.get("trait") == "command":
				commanded = true
	if signature == "alone" and not accompanied:
		bonus += 2
	if signature == "formation" and accompanied:
		bonus += 1
	return bonus + int(commanded)

func can_attack(attacker_index: int, target_index: int) -> bool:
	return bool(attack_preview(attacker_index, target_index)["valid"])

func record_ability_use(actor_idx: int, ability_name: String, class_action: bool = false) -> void:
	# Only named signature abilities go in the player's ability-usage summary.
	# Ordinary weapon attacks already have their own action counter.
	if actor_idx < 5 and (class_action or ability_name in [
			str(units[actor_idx].get("special", "")), BREACH_ACTION_NAME, StarterLoadouts.MEDKIT_NAME]):
		var counts: Dictionary = unit_action_counters[actor_idx]["named_abilities"]
		counts[ability_name] = int(counts.get(ability_name, 0)) + 1
	battle_stats[actor_idx]["ability_uses"] = int(battle_stats[actor_idx]["ability_uses"]) + 1
	var key: String = ("REBEL | " if units[actor_idx]["team"] == "player" else "ENEMY | ") + ability_name
	ability_use_totals[key] = int(ability_use_totals.get(key, 0)) + 1

func shortest_tile_path(start: Vector2i, destination: Vector2i, unit_id: int) -> Array[Vector2i]:
	# Reconstruct a true shortest traversable path, not a teleport to the end.
	var result: Array[Vector2i] = []
	if start == destination:
		return result
	var parents: Dictionary = {}
	reachable(start, board_w * board_h, unit_id, parents, destination)
	if not parents.has(destination):
		return result
	var cursor: Vector2i = destination
	while cursor != start:
		result.push_front(cursor)
		cursor = parents[cursor]
	return result

func movement_path(unit_idx: int, destination: Vector2i, ap_cost: int = 1) -> Array[Vector2i]:
	var path: Array[Vector2i] = shortest_tile_path(units[unit_idx]["pos"], destination, int(units[unit_idx]["id"]))
	if class_combat.enabled and ap_cost > 0 and not path.is_empty():
		var shortened: int = int(class_combat.effects(unit_idx).get("first_move_short", 0))
		path.resize(maxi(1, path.size() - shortened))
	return path

func start_unit_movement(unit_idx: int, destination: Vector2i, ap_cost: int = 1, on_arrival: Dictionary = {}) -> void:
	if not movement_task.is_empty():
		return
	if destination != units[unit_idx]["pos"] and voluntary_movement_locked(unit_idx):
		status_message = movement_lock_reason(unit_idx)
		return
	var path: Array[Vector2i] = movement_path(unit_idx, destination, ap_cost)
	if destination != units[unit_idx]["pos"] and path.is_empty():
		status_message = "No safe traversable path to that square."
		return
	if int(units[unit_idx]["ap"]) < ap_cost:
		return
	if class_combat.enabled and ap_cost > 0 and not path.is_empty():
		class_combat.effects(unit_idx).erase("first_move_short")
	units[unit_idx]["ap"] = int(units[unit_idx]["ap"]) - ap_cost
	if ap_cost > 0 and not path.is_empty():
		unit_action_counters[unit_idx]["moves"] = int(unit_action_counters[unit_idx]["moves"]) + 1
	movement_task = {"unit_idx": unit_idx, "path": path, "cursor": 0, "after": on_arrival,
		"standard": ap_cost > 0 and on_arrival.is_empty() and not path.is_empty()}
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
	if class_combat.enabled and task.get("standard", false):
		class_combat.finished_standard_move(unit_idx, int(task["cursor"]))
	var next_action: Dictionary = task.get("after", {})
	if str(next_action.get("kind", "")) == "area_shred":
		resolve_area_shred(unit_idx, next_action["aim"])
	elif next_action.get("kind", "") == "basic_melee" and not room_cleared:
		var target_idx: int = find_unit_by_id(int(next_action["target"]))
		if not resolve_basic_melee(unit_idx, target_idx, next_action["fixture"], 0):
			status_message = "The approach ended without a legal melee strike."
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
			play_unit_action(moving_idx, unit_board_center(enemy_idx), true)
			environment_hit_unit(moving_idx, enemy_idx, SENTINEL_BREACH_DAMAGE, BREACH_ACTION_NAME)
			if int(units[enemy_idx]["hp"]) > 0:
				var displacement: Vector2i = breach_push_destination(enemy_idx, next_tile - previous_tile, next_tile)
				if displacement.x < 0:
					add_log(BREACH_ACTION_NAME + " collision could not displace the target.")
					movement_task.clear()
					assess_winner()
					return
				apply_unit_position(enemy_idx, displacement, &"displace")
				battle_stats[enemy_idx]["tiles"] = int(battle_stats[enemy_idx]["tiles"]) + 1
				add_log("%s knocked to %s." % [str(units[enemy_idx]["name"]), str(displacement)])
				apply_hazard_entry(enemy_idx)
		if not footprint_is_open(units[moving_idx], next_tile):
			add_log(BREACH_ACTION_NAME + " was interrupted before entering its next tile.")
			movement_task.clear()
			assess_winner()
			return
	elif not can_take_move_step(units[moving_idx], units[moving_idx]["pos"], next_tile):
		add_log("%s interrupted by occupied path." % str(units[moving_idx]["name"]))
		movement_task.clear()
		return
	class_combat.opportunity(moving_idx, units[moving_idx]["pos"], next_tile)
	if int(units[moving_idx]["hp"]) <= 0 or game_over or room_cleared or (class_combat.enabled and class_combat.effects(moving_idx).erase("intercept_stopped")):
		movement_task.clear()
		return
	var prior_cell: Vector2i = units[moving_idx]["pos"]
	apply_unit_position(moving_idx, next_tile)
	movement_task["cursor"] = at + 1
	apply_hazard_entry(moving_idx)
	if class_combat.enabled:
		class_combat.moved(moving_idx, 1)
	else:
		battle_stats[moving_idx]["tiles"] = int(battle_stats[moving_idx]["tiles"]) + 1
	assess_winner()
	if int(units[moving_idx]["hp"]) > 0 and not game_over and not room_cleared:
		trigger_reactions_to_step(moving_idx, prior_cell)
	if int(units[moving_idx]["hp"]) <= 0 or game_over:
		movement_task.clear()
		return
	if units[moving_idx]["pos"] != next_tile:
		movement_task.clear()
		add_log("%s's movement ends after displacement." % str(units[moving_idx]["name"]))
		return
	if int(movement_task["cursor"]) >= steps.size():
		complete_movement_task()

func clear_reactions_for_team(team: String) -> void:
	for idx in range(units.size()):
		if units[idx]["team"] == team:
			clear_overwatch(idx)
			units[idx].erase("overwatch_locked")

func clear_overwatch(idx: int) -> void:
	units[idx]["reaction_available"] = false
	units[idx]["reaction_type"] = ""
	units[idx].erase("overwatch_tiles")

func overwatch_locks_movement(idx: int) -> bool:
	return units[idx].get("overwatch_locked", false) and units[idx]["team"] == side_to_play

func voluntary_movement_locked(idx: int) -> bool:
	return overwatch_locks_movement(idx) or (class_combat.enabled and class_combat.effects(idx).get("anchored", false))

func movement_lock_reason(idx: int) -> String:
	return "The suit is anchored until its next turn." if class_combat.enabled and class_combat.effects(idx).get("anchored", false) else OVERWATCH_HOLD_MESSAGE

func overwatch_shots(idx: int) -> int:
	var unit: Dictionary = units[idx]
	return mini(int(unit["ap"]), int(unit["rounds"]))

func overwatch_unavailable(idx: int) -> String:
	if class_combat.enabled and class_combat.reaction_disabled(idx):
		return "Reactions are disrupted."
	var unit: Dictionary = units[idx]
	if basic_is_melee(unit) or int(unit["magazine_capacity"]) <= 0:
		return "Overwatch requires a ranged weapon that uses ammo or charges."
	if int(unit["hp"]) <= 0 or int(unit["ap"]) < OVERWATCH_SHOT_AP:
		return "Overwatch needs at least 1 AP for a reaction shot."
	if int(unit["rounds"]) <= 0:
		return empty_attack_resource(idx)
	if unit.get("overwatch_locked", false):
		return "This unit has already set Overwatch this turn."
	return ""

func overwatch_cone(idx: int, aim: Vector2i) -> Dictionary:
	var unit: Dictionary = units[idx]
	var origin: Vector2i = unit["pos"]
	var footprint: Rect2i = unit_footprint(unit, origin)
	if footprint.has_point(aim):
		return {}
	var cone := grid_cone(origin, aim, int(unit["range"]), OVERWATCH_END_WIDTH)
	for tile: Vector2i in cone.keys():
		if footprint.has_point(tile):
			cone.erase(tile)
	return cone

func grid_cone(origin: Vector2i, aim: Vector2i, reach: int, end_width: int) -> Dictionary:
	var delta := aim - origin
	if delta == Vector2i.ZERO:
		return {}
	# Slice along the dominant grid axis, widening each row within reach.
	var horizontal: bool = absi(delta.x) >= absi(delta.y)
	var forward: int = delta.x if horizontal else delta.y
	var lateral: int = delta.y if horizontal else delta.x
	var cone: Dictionary = {}
	for depth in range(1, reach + 1):
		var width: int = ceili(float(end_width * depth) / reach)
		var ideal_start: float = float(lateral * depth) / absi(forward) - (width - 1) * 0.5
		var start: int = clampi(roundi(ideal_start), -reach, reach - width + 1)
		for offset in range(start, start + width):
			var step := Vector2i(signi(forward) * depth, offset)
			var tile: Vector2i = origin + (step if horizontal else Vector2i(step.y, step.x))
			if is_in_bounds(tile):
				cone[tile] = true
	return cone

func set_overwatch(idx: int, aim: Vector2i) -> bool:
	var unavailable: String = overwatch_unavailable(idx)
	if not unavailable.is_empty():
		status_message = unavailable
		return false
	var cone: Dictionary = overwatch_cone(idx, aim)
	if units[idx]["team"] == "enemy":
		var origin: Vector2i = units[idx]["pos"]
		for tile: Vector2i in cone.keys():
			if walls.has(tile) or not has_line_of_sight(origin, tile):
				cone.erase(tile)
	if cone.is_empty():
		status_message = "Choose a direction with tiles outside the unit's footprint."
		return false
	units[idx]["overwatch_tiles"] = cone
	units[idx]["overwatch_locked"] = true
	units[idx]["reaction_type"] = "overwatch"
	units[idx]["reaction_available"] = true
	unit_action_counters[idx]["overwatch_set"] = int(unit_action_counters[idx]["overwatch_set"]) + 1
	status_message = "%s sets Overwatch with up to %d shots and holds position." % [units[idx]["name"], overwatch_shots(idx)]
	add_log(status_message)
	return true

func set_enemy_overwatch(idx: int) -> bool:
	if not overwatch_unavailable(idx).is_empty():
		return false
	var aim: Vector2i = enemy_overwatch_aim(idx)
	return is_in_bounds(aim) and set_overwatch(idx, aim)

func enemy_overwatch_aim(idx: int) -> Vector2i:
	var origin: Vector2i = units[idx]["pos"]
	var reach: int = int(units[idx]["range"])
	var approaches: Dictionary = {}
	for target in range(5):
		var operative: Dictionary = units[target]
		if int(operative["hp"]) <= 0:
			continue
		var routes: Dictionary = reachable(operative["pos"], int(operative["move"]) * OVERWATCH_APPROACH_MOVES, int(operative["id"]))
		for anchor: Vector2i in routes:
			var steps: int = int(routes[anchor])
			if steps == 0:
				continue
			var footprint: Rect2i = unit_footprint(operative, anchor)
			for y in range(footprint.position.y, footprint.end.y):
				for x in range(footprint.position.x, footprint.end.x):
					var tile := Vector2i(x, y)
					var delta: Vector2i = (tile - origin).abs()
					if maxi(delta.x, delta.y) > reach or steps >= int(approaches.get(tile, 999)):
						continue
					if attack_preview(idx, target, 0, 0, true, tile)["valid"]:
						approaches[tile] = steps

	var aim := Vector2i(-1, -1)
	var best_score := 0.0
	for candidate: Vector2i in approaches:
		var cone: Dictionary = overwatch_cone(idx, candidate)
		if not cone.has(candidate):
			continue
		var score := 0.0
		for tile: Vector2i in cone:
			if approaches.has(tile):
				score += 1.0 / float(approaches[tile])
		if score > best_score or (is_equal_approx(score, best_score) and int(approaches[candidate]) < int(approaches[aim])):
			aim = candidate
			best_score = score
	return aim

func overwatch_budget(defender_idx: int, mover_idx: int) -> int:
	return overwatch_budget_for_team(defender_idx, units[mover_idx]["team"])

func overwatch_budget_for_team(defender_idx: int, mover_team: String) -> int:
	var defender: Dictionary = units[defender_idx]
	if defender["team"] == mover_team or defender["team"] == side_to_play or int(defender["hp"]) <= 0:
		return 0
	if not defender["reaction_available"] or defender["reaction_type"] != "overwatch":
		return 0
	if class_combat.enabled and class_combat.reaction_disabled(defender_idx):
		return 0
	return overwatch_shots(defender_idx)

func overwatch_target_tile(defender_idx: int, mover_idx: int, anchor: Vector2i) -> Vector2i:
	var footprint: Rect2i = unit_footprint(units[mover_idx], anchor)
	var cone: Dictionary = units[defender_idx].get("overwatch_tiles", {})
	for tile: Vector2i in cone:
		if not footprint.has_point(tile):
			continue
		var preview: Dictionary = attack_preview(defender_idx, mover_idx, 0, 0, true, tile)
		if preview["valid"] or preview.get("blocked_by_cover", false):
			return tile
	return Vector2i(-1, -1)

func expected_overwatch_shots(mover_idx: int, path: Array[Vector2i], stops_on_hit: bool = false) -> int:
	var budgets: Dictionary = {}
	for defender_idx in range(units.size()):
		var available: int = overwatch_budget(defender_idx, mover_idx)
		if available > 0:
			budgets[defender_idx] = available
	if budgets.is_empty():
		return 0
	var shots := 0
	var saved_passages: Dictionary = {}
	var previous: Vector2i = units[mover_idx]["pos"]
	for step: Vector2i in path:
		for defender_idx: int in budgets:
			if int(budgets[defender_idx]) <= 0 or not is_in_bounds(overwatch_target_tile(defender_idx, mover_idx, step)):
				continue
			if class_combat.enabled:
				var controller: int = class_combat.safe_passage_source(defender_idx, mover_idx, previous, step)
				if controller >= 0 and not saved_passages.has(controller):
					saved_passages[controller] = true
					continue
			budgets[defender_idx] -= 1
			shots += 1
		if stops_on_hit and shots > 0:
			break
		previous = step
	return shots

func trigger_reactions_to_step(mover_idx: int, previous_tile: Vector2i = Vector2i(-1, -1)) -> bool:
	# No chains: reactions trigger ONLY on traversed movement cells, never
	# on another reaction or on a non-movement attack.
	var fired: bool = false
	for defender_idx in range(units.size()):
		if game_over or int(units[mover_idx]["hp"]) <= 0:
			return fired
		if overwatch_budget(defender_idx, mover_idx) <= 0:
			continue
		var target_tile: Vector2i = overwatch_target_tile(defender_idx, mover_idx, units[mover_idx]["pos"])
		if not is_in_bounds(target_tile):
			continue
		if class_combat.enabled and class_combat.safe_passage(defender_idx, mover_idx, previous_tile):
			add_log("Safe Passage prevents %s's Overwatch on this step." % units[defender_idx]["name"])
			continue
		if perform_attack(defender_idx, mover_idx, "Overwatch", 0, 0, OVERWATCH_SHOT_AP, target_tile):
			battle_stats[defender_idx]["reactions"] = int(battle_stats[defender_idx]["reactions"]) + 1
			battle_stats[defender_idx]["overwatch_shots"] = int(battle_stats[defender_idx].get("overwatch_shots", 0)) + 1
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
	show_damage_at(units[target_idx]["pos"], arm, hp, target_idx)
	queue_redraw()

func show_damage_at(tile: Vector2i, arm: int, hp: int, target_idx: int = -1) -> void:
	var defeats_target: bool = target_idx >= 0 and int(units[target_idx]["hp"]) <= 0
	if defeats_target and unit_playback.busy():
		pending_defeats[target_idx] = true
	unit_playback.after_queued_actions(func() -> void:
		damage_floaters.append({"pos": tile, "arm": arm, "hp": hp, "ttl": DAMAGE_FLOAT_SECONDS,
			"target": target_idx})
		if defeats_target:
			pending_defeats.erase(target_idx)
	)

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
		var centre: Vector2 = battlefield.project(board_center(tile)) + Vector2(0, -27.0 - lift)
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

func apply_healing(healer_idx: int, patient_idx: int, amount: int, ability_name: String, record_use: bool = true) -> bool:
	if class_combat.enabled and class_combat.effects(healer_idx).get("aphasia", false):
		return false
	if int(units[patient_idx]["hp"]) <= 0:
		return false
	var actual: int = mini(amount, recoverable_hp(units[patient_idx]) - int(units[patient_idx]["hp"]))
	if actual <= 0:
		return false
	units[patient_idx]["hp"] = int(units[patient_idx]["hp"]) + actual
	battle_stats[healer_idx]["healing"] = int(battle_stats[healer_idx]["healing"]) + actual
	if record_use:
		play_support_action(healer_idx, patient_idx)
		record_ability_use(healer_idx, ability_name)
	status_message = "%s heals %s for %d HP." % [str(units[healer_idx]["name"]), str(units[patient_idx]["name"]), actual]
	add_log(status_message)
	return true

func perform_attack(attacker_idx: int, target_idx: int, named_ability: String = "", bonus_damage: int = 0, pierce: int = 0, cost: int = 1, overwatch_tile: Vector2i = Vector2i(-1, -1)) -> bool:
	var weapon_name: String = str(units[attacker_idx]["basic_attack"])
	var basic: bool = named_ability in ["", weapon_name]
	var overwatch: bool = named_ability == "Overwatch"
	var attack: Dictionary = attack_preview(attacker_idx, target_idx, bonus_damage, pierce, basic or overwatch, overwatch_tile)
	if int(units[attacker_idx]["ap"]) < cost:
		return false
	if attack.get("blocked_by_cover", false):
		var cover_target: Vector2i = overwatch_tile if overwatch else units[target_idx]["pos"]
		return fire_into_full_cover(attacker_idx, cover_target, named_ability if named_ability != "" else weapon_name, cost, basic)
	if not bool(attack["valid"]):
		return false
	if basic and class_combat.enabled and class_combat.breach_follow_up_ready(attacker_idx, target_idx):
		class_combat.effects(attacker_idx).erase("breach_follow_up")
	elif not spend_shot(attacker_idx):
		return false
	if units[attacker_idx].get("trait") == "combo" and attack.get("melee", false):
		weapon_name = "Hammer finish"
	resolve_attack(attacker_idx, target_idx, attack, named_ability if named_ability != "" else weapon_name, cost, basic)
	return true

func resolve_attack(attacker_idx: int, target_idx: int, attack: Dictionary, ability: String, cost: int, basic: bool, record_use: bool = true) -> void:
	units[attacker_idx]["ap"] = int(units[attacker_idx]["ap"]) - cost
	var aim: Vector2 = unit_board_center(target_idx)
	if class_combat.enabled:
		var interception: Dictionary = class_combat.intercept(attacker_idx, target_idx, attack)
		if interception.get("blocked", false):
			play_attack_impact(attacker_idx, target_idx, attack, aim, ability)
			battle_stats[attacker_idx]["attacks"] += 1
			if basic:
				unit_action_counters[attacker_idx]["basic_attacks"] += 1
			units[attacker_idx]["stim_bonus"] = 0
			class_combat.spend_basic_attack_effects(attacker_idx)
			return
		if interception.has("target"):
			var visual_source: Variant = attack.get("visual_source")
			var visual_queued: bool = attack.get("visual_queued", false)
			target_idx = interception["target"]
			attack = class_combat.impact(attacker_idx, target_idx, int(attack["raw_damage"]), 0, {"ranged": true})
			if visual_source != null:
				attack["visual_source"] = visual_source
			attack["visual_queued"] = visual_queued
		class_combat.consume_hit(attacker_idx, target_idx, attack)
	play_attack_impact(attacker_idx, target_idx, attack, aim, ability)
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
	if class_combat.enabled:
		class_combat.on_damage(target_idx, armour_loss, hp_damage)
	elif armour_loss > 0:
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
	if class_combat.enabled:
		class_combat.after_hit(attacker_idx, target_idx, attack)
	if basic and units[attacker_idx].has("trait"):
		resolve_enemy_trait(attacker_idx, target_idx, hp_damage)
	assess_winner()

func resolve_enemy_trait(idx: int, victim: int, hp_damage: int) -> void:
	var actor: Dictionary = units[idx]
	var pos: Vector2i = units[victim]["pos"]
	match actor["trait"]:
		"blast":
			queue_burst(board_center(pos), 29.0, Color("#edab69"))
			for other in range(units.size()):
				if other != victim and (other != idx or actor["kind"] != "horde") and unit_footprint(units[other], units[other]["pos"]).grow(1).has_point(pos):
					environment_hit_unit(idx, other, 1, actor["basic_attack"] + " splash")
		"push", "combo":
			if units[victim]["hp"] > 0 and grid_distance(actor["pos"], pos) == 1:
				push_from_explosion(victim, actor["pos"], 4, idx)
		"leech":
			if hp_damage > 0:
				apply_healing(idx, idx, 2, "Blood dividend")
		"burning", "bleeding", "shocked":
			apply_status(victim, actor["trait"])

func can_use_loadout_action(idx: int, action: String) -> bool:
	if idx < 0 or int(units[idx]["hp"]) <= 0:
		return false
	var unit: Dictionary = units[idx]
	if action == "melee":
		var melee: bool = basic_is_melee(unit) if unit.has("class_build") else int(unit.get("fixture_melee_damage", 0)) > 0
		return melee and int(unit["ap"]) >= StarterLoadouts.MELEE_AP
	return int(unit["medkit_charges"]) > 0 and int(unit["ap"]) >= StarterLoadouts.MEDKIT_AP

func toggle_loadout_action(action: String) -> void:
	var idx: int = find_unit_by_id(selected_id)
	if not can_use_loadout_action(idx, action):
		status_message = "Melee needs an available strike and 1 AP." if action == "melee" else "Medkit needs an unused charge and 1 AP."
		queue_redraw()
		return
	loadout_action = "" if loadout_action == action else action
	special_mode = false
	breach_target_mode = false
	shred_landing_tile = Vector2i(-1, -1)
	status_message = "Targeting cancelled."
	if loadout_action == "melee":
		status_message = "Click an enemy to move into reach and strike (1 AP total)."
	elif loadout_action == "medkit":
		status_message = "Click yourself or an adjacent ally to use the medkit (1 AP)."
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
	return try_basic_melee(actor_idx, target_idx, not actor.has("class_build"))

func basic_melee_preview_from(actor_idx: int, target_idx: int, from: Vector2i, fixture: bool, steps: int = 0) -> Dictionary:
	if target_idx < 0 or int(units[target_idx]["hp"]) <= 0 or units[target_idx]["team"] == units[actor_idx]["team"]:
		return {"valid": false, "reason": "Choose a living enemy"}
	if not fixture:
		return attack_preview_from(actor_idx, target_idx, from, 0, 0, true, steps)
	var footprint: Rect2i = unit_footprint(units[target_idx], units[target_idx]["pos"])
	if grid_distance(from, from.clamp(footprint.position, footprint.end - Vector2i.ONE)) != 1:
		return {"valid": false, "reason": "Out of range"}
	var impact: Dictionary = melee_impact(actor_idx, target_idx, fixture_melee_base_damage(actor_idx), false)
	impact["valid"] = true
	return impact

func basic_melee_plan(actor_idx: int, target_idx: int, fixture: bool) -> Dictionary:
	var actor: Dictionary = units[actor_idx]
	if fixture and int(actor.get("fixture_melee_damage", 0)) <= 0:
		return {"valid": false, "reason": "Melee strike unavailable"}
	if int(units[actor_idx]["ap"]) < StarterLoadouts.MELEE_AP:
		return {"valid": false, "reason": "Melee requires 1 AP"}
	var origin: Vector2i = actor["pos"]
	var preview: Dictionary = basic_melee_preview_from(actor_idx, target_idx, origin, fixture)
	if preview["valid"]:
		preview["steps"] = 0
		return preview
	if preview["reason"] != "Out of range":
		return preview
	if overwatch_locks_movement(actor_idx):
		return {"valid": false, "reason": "This unit is holding position on Overwatch"}
	var options: Dictionary = reachable(origin, int(actor["move"]), int(actor["id"]))
	# Reachable inserts tiles in breadth-first order, with the nearest landings first.
	for landing: Vector2i in options:
		var steps: int = int(options[landing])
		if steps == 0:
			continue
		preview = basic_melee_preview_from(actor_idx, target_idx, landing, fixture, steps)
		if preview["valid"]:
			preview["landing"] = landing
			preview["steps"] = steps
			return preview
	return {"valid": false, "reason": "No melee landing tile within one move"}

func try_basic_melee(actor_idx: int, target_idx: int, fixture: bool = false) -> bool:
	var preview: Dictionary = basic_melee_plan(actor_idx, target_idx, fixture)
	if not preview["valid"]:
		status_message = preview["reason"] + "."
		return false
	if int(preview["steps"]) == 0:
		return resolve_basic_melee(actor_idx, target_idx, fixture, StarterLoadouts.MELEE_AP)
	start_unit_movement(actor_idx, preview["landing"], StarterLoadouts.MELEE_AP,
		{"kind": "basic_melee", "target": units[target_idx]["id"], "fixture": fixture})
	status_message = "%s moves to strike." % str(units[actor_idx]["name"])
	return true

func resolve_basic_melee(actor_idx: int, target_idx: int, fixture: bool, cost: int) -> bool:
	var preview: Dictionary = basic_melee_preview_from(actor_idx, target_idx, units[actor_idx]["pos"], fixture)
	if not preview["valid"]:
		return false
	var attack_key: String = "fixture_melee_name" if fixture else "basic_attack"
	resolve_attack(actor_idx, target_idx, preview, str(units[actor_idx][attack_key]), cost, true)
	return true

func fixture_melee_base_damage(idx: int) -> int:
	return maxi(0, int(units[idx]["fixture_melee_damage"]) + int(units[idx].get("stim_bonus", 0)) - blinded_damage_penalty(idx))

func melee_impact(actor_idx: int, target_idx: int, base_damage: int, include_stim: bool = true) -> Dictionary:
	var target: Dictionary = units[target_idx]
	var damage: int = base_damage + (int(units[actor_idx].get("stim_bonus", 0)) if include_stim else 0)
	var armour_hit: int = mini(int(target["armour"]), damage)
	return {"armour_damage": armour_hit, "hp_damage": mini(int(target["hp"]), damage - armour_hit), "cover": 0, "melee": true}

func special_cost(idx: int) -> int:
	# Build 10 temporary test balance: every player signature costs 1 AP.
	return 1 if idx >= 0 and idx < 5 else 99

func special_cooldown_remaining(idx: int) -> int:
	if operative_kit(idx) not in [3, 4]:
		return 0
	return maxi(0, int(units[idx].get("special_ready_turn", -99)) - turn_number)

func special_available(idx: int) -> bool:
	if operative_kit(idx) == 0 and overwatch_locks_movement(idx):
		return false
	if int(units[idx]["special_used_turn"]) == turn_number:
		return false
	if special_cooldown_remaining(idx) > 0:
		return false
	if operative_kit(idx) in [2, 3] and not has_attack_ammo(idx):
		return false
	return int(units[idx]["ap"]) >= special_cost(idx)

func special_unavailable_message(idx: int) -> String:
	if operative_kit(idx) == 0 and overwatch_locks_movement(idx):
		return OVERWATCH_HOLD_MESSAGE
	if int(units[idx]["special_used_turn"]) == turn_number:
		return "Ability already used this turn."
	var remaining: int = special_cooldown_remaining(idx)
	if remaining > 0:
		return "Ability cooling down: %d player turn(s) until ready." % remaining
	if operative_kit(idx) in [2, 3] and not has_attack_ammo(idx):
		return EMPTY_MAGAZINE
	return "Insufficient AP: ability requires %d AP." % special_cost(idx)

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
	if not options.has(landing) or not footprint_is_open(units[actor_idx], landing):
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
	play_unit_action(actor_idx, board_center(aim_tile), true)
	var total: int = 0
	var hits: int = 0
	var hit_targets: Dictionary = {}
	for tile in arc:
		var idx: int = find_unit_at(tile)
		if idx < 0 or units[idx]["team"] != "enemy" or hit_targets.has(idx):
			continue
		hit_targets[idx] = true
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
		play_support_action(actor_idx, target_idx)
		units[target_idx]["armour"] = int(units[target_idx]["armour"]) + 2
		units[actor_idx]["armour"] = int(units[actor_idx]["armour"]) + 2
		# The after-action support counter measures recipients, not button presses.
		battle_stats[actor_idx]["buffs"] = int(battle_stats[actor_idx]["buffs"]) + 2
		record_ability_use(actor_idx, ability)
		status_message = "Anvil Fortify: +2 temporary ARM to %s and Anvil." % str(units[target_idx]["name"])
		add_log(status_message)
	elif kit == 2:
		if not bool(attack_preview(actor_idx, target_idx, 2, 1, false)["valid"]):
			status_message = str(attack_preview(actor_idx, target_idx)["reason"])
			return false
		perform_attack(actor_idx, target_idx, ability, 2, 1, special_cost(actor_idx))
	elif kit == 3:
		var preview: Dictionary = attack_preview(actor_idx, target_idx, 1, 0, false)
		if not preview["valid"] and not preview.get("blocked_by_cover", false):
			status_message = preview["reason"]
			return false
		if not perform_attack(actor_idx, target_idx, ability, 1, 0, special_cost(actor_idx)):
			return false
		if not preview.get("blocked_by_cover", false) and int(units[target_idx]["hp"]) > 0:
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
	unit["class_effects"].clear()
	unit["stim_bonus"] = 0
	unit["jammed_actions"] = 0
	clear_overwatch(idx)
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

func complete_test_mission(success: bool, failure_reason: String = "Primary objective failed") -> void:
	if game_over:
		return
	save_room_result()
	game_over = true
	mission_victory = success
	mission_failure_reason = "" if success else failure_reason
	winner = "MISSION COMPLETE" if success else "MISSION FAILED"
	var outcome: String = "Mission complete" if success else "Mission failed · " + failure_reason
	status_message = outcome + "  [P] room activity  |  [M] missions  |  [R] retry"
	if hq_deployment:
		headquarters.campaign.credit_reward(str(campaign_operation["kind"]) + "_complete", success)
		headquarters.campaign.finish("%s · %s" % [campaign_operation["label"], outcome], units,
			chain_sum("kill_xp") if success else 0,
			chain_sum("objective_xp") if success else 0)
		status_message = outcome + "  [P] room activity  |  [F9] headquarters"
		print("HQ operation %s: %s in room %d, round %d." % [test_mission_id, winner, mission_stage + 1, turn_number])
	show_report = true
	add_log(outcome + " · " + get_objective_progress_line())
	queue_redraw()

func assess_winner() -> void:
	if game_over or room_cleared or resolving_class_action:
		return
	for shell in units.duplicate():
		if shell.get("trait") == "nest" and not shell.get("opened", false) and (shell["hp"] <= 0 or (armour_enabled and shell["armour"] == 0)):
			var child := EnemyRoster.create("Collectivist Drone", shell["pos"])
			for offset in [Vector2i.ZERO, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP, Vector2i.ONE, -Vector2i.ONE, Vector2i(1,-1), Vector2i(-1,1)]:
				var tile: Vector2i = shell["pos"] + offset
				if footprint_is_open(child, tile):
					shell["opened"] = true
					child["pos"] = tile
					child["ap"] = 0
					child["summoned"] = true
					append_enemy_to_battle(child)
					add_log("Matryoshka opens. A Collectivist Drone emerges.")
					break
	var alive_players: int = alive_count("player")
	var alive_enemies: int = alive_count("enemy")
	if alive_players == 0:
		complete_test_mission(false, "Squad wiped")
		return
	if alive_enemies > 0:
		return
	if not all_required_objectives_met():
		status_message = "All guards defeated. Finish objective: " + get_objective_progress_line()
		queue_redraw()
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

func board_center(tile: Vector2i) -> Vector2:
	return ORIGIN + (Vector2(tile) + Vector2(0.5, 0.5)) * TILE

func unit_board_center(idx: int) -> Vector2:
	var pos: Vector2i = units[idx]["pos"]
	return ORIGIN + (Vector2(pos) + Vector2(unit_footprint(units[idx], pos).size) * 0.5) * TILE

func apply_unit_position(idx: int, destination: Vector2i, kind: StringName = &"walk") -> void:
	var from: Vector2 = unit_board_center(idx)
	var previous: Vector2i = units[idx]["pos"]
	if destination != previous and units[idx].has("overwatch_tiles"):
		clear_overwatch(idx)
	units[idx]["pos"] = destination
	var to: Vector2 = unit_board_center(idx)
	var direction := Vector2i.ZERO
	var duration: float = UnitPlayback.DISPLACE_SECONDS
	match kind:
		&"walk":
			duration = UnitPlayback.WALK_SECONDS
		&"leap":
			duration = UnitPlayback.LEAP_SECONDS
		&"blink":
			duration = 0.24
	if kind != &"displace":
		direction = UnitPlayback.nearest_facing(to - from, MOVE_DIRECTIONS)
	unit_playback.motion(idx, from, to, direction, kind, duration)
	if class_combat.enabled:
		class_combat.position_changed(idx, previous)
	queue_redraw()

func play_unit_action(idx: int, target: Vector2, melee: bool = false,
		burst_color: Color = Color.TRANSPARENT, ability: String = "") -> void:
	var from: Vector2 = unit_board_center(idx)
	var direction: Vector2i = UnitPlayback.nearest_facing(target - from, MOVE_DIRECTIONS)
	var style: StringName = SabotageVisuals.attack_style(ability, melee, burst_color)
	unit_playback.action(idx, direction, style, SabotageVisuals.action_seconds(style),
		sabotage_visuals.strike.bind(from, target, style, burst_color))
	queue_redraw()

func play_support_action(idx: int, target_idx: int) -> void:
	play_unit_action(idx, unit_board_center(target_idx), false, Color("#9de2ba"))

func queue_burst(target: Vector2, radius: float, color: Color, style: StringName = &"burst") -> void:
	unit_playback.after_queued_actions(sabotage_visuals.burst.bind(target, radius, color, style))
	queue_redraw()

func play_attack_impact(attacker_idx: int, target_idx: int, impact: Dictionary, aim: Vector2, ability: String) -> void:
	var target: Vector2 = unit_board_center(target_idx)
	var weapon: String = str(units[attacker_idx]["basic_attack"]) if ability == "Overwatch" else ability
	var style: StringName = SabotageVisuals.attack_style(weapon, bool(impact.get("melee", false)), Color.TRANSPARENT)
	if impact.get("dodge", false):
		queue_burst(target, 13.0, Color("#b5c5d4"))
	elif impact.get("area", false) or impact.get("visual_queued", false):
		queue_burst(target, 16.0, Color("#ffca8a"))
	elif impact.has("visual_source"):
		unit_playback.after_queued_actions(sabotage_visuals.strike.bind(board_center(impact["visual_source"]), target, style))
	else:
		var from: Vector2 = unit_board_center(attacker_idx)
		var direction: Vector2i = UnitPlayback.nearest_facing(aim - from, MOVE_DIRECTIONS)
		unit_playback.action(attacker_idx, direction, style, SabotageVisuals.action_seconds(style),
			sabotage_visuals.strike.bind(from, target, style))

func tile_at_screen(screen_pos: Vector2) -> Vector2i:
	if combat_hud_covers(screen_pos):
		return Vector2i(-1, -1)
	return battlefield.tile_at(screen_pos)

func combat_hud_covers(screen_pos: Vector2) -> bool:
	for slot in range(5):
		if squad_tab_rect(slot).has_point(screen_pos):
			return true
	return not operative_action_at(screen_pos).is_empty()

func battlefield_camera_available() -> bool:
	return not (headquarters.visible or mission_picker_open or loadout_open or room_cleared
		or show_hit_ledger or developer_menu_open or (game_over and show_report))

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		pan_keys.clear()
		battlefield.dragging = false

func process_camera(delta: float) -> void:
	if battlefield.advance_pivot(delta):
		hovered_tile = tile_at_screen(hud_cursor)
		queue_redraw()
	if not battlefield_camera_available():
		pan_keys.clear()
		battlefield.dragging = false
		return
	var direction := Vector2(
		float(pan_keys.has(KEY_A)) - float(pan_keys.has(KEY_D)),
		float(pan_keys.has(KEY_W)) - float(pan_keys.has(KEY_S)))
	if direction != Vector2.ZERO:
		battlefield.pan(direction.normalized() * CAMERA_PAN_SPEED * minf(delta, 0.05))
		hovered_tile = tile_at_screen(hud_cursor)
		queue_redraw()

func handle_battlefield_camera(event: InputEvent) -> bool:
	if not battlefield_camera_available():
		return false
	if event is InputEventKey:
		var code: Key = event.physical_keycode if event.physical_keycode != KEY_NONE else event.keycode
		if code in CAMERA_KEYS:
			if event.pressed:
				pan_keys[code] = true
			else:
				pan_keys.erase(code)
			return true
		if not event.pressed or event.echo:
			return false
		match code:
			KEY_Q: battlefield.pivot(-1)
			KEY_E: battlefield.pivot(1)
			KEY_HOME: battlefield.reset_camera()
			_: return false
	elif event is InputEventMouseMotion and battlefield.dragging:
		battlefield.pan(event.relative)
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			battlefield.dragging = event.pressed and BattlefieldView.AREA.has_point(event.position) and not combat_hud_covers(event.position)
			return battlefield.dragging or not event.pressed
		if not event.pressed or not BattlefieldView.AREA.has_point(event.position) or combat_hud_covers(event.position):
			return false
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP: battlefield.zoom_at(event.position, 1.25)
			MOUSE_BUTTON_WHEEL_DOWN: battlefield.zoom_at(event.position, 0.8)
			_: return false
	else:
		return false
	hovered_tile = tile_at_screen(hud_cursor)
	queue_redraw()
	return true

func ability_aiming() -> bool:
	return class_combat.actor >= 0 or special_mode or breach_target_mode or not loadout_action.is_empty()

func cancel_or_back() -> void:
	if developer_menu_open:
		developer_menu_open = false
	elif loadout_open:
		loadout_open = false
		mission_picker_open = true
	elif mission_picker_open:
		mission_picker_open = false
		headquarters.open()
	elif show_hit_ledger:
		show_hit_ledger = false
	elif ability_aiming():
		class_combat.cancel()
		loadout_action = ""
		breach_target_mode = false
		special_mode = false
		shred_landing_tile = Vector2i(-1, -1)
		status_message = "Ability targeting cancelled."
	elif game_over and show_report:
		if show_room_activity:
			show_room_activity = false
		else:
			show_report = false
	elif game_over and hq_deployment and not unit_playback.busy():
		headquarters.open()
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if headquarters.visible:
		if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_M:
			headquarters.hide()
			hq_deployment = false
			test_mission_id = "chain"
			restart_game()
			mission_picker_open = true
			queue_redraw()
		elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
			headquarters.go_back()
		return
	if event is InputEventMouse:
		hud_cursor = event.position
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		cancel_or_back()
		return
	if handle_battlefield_camera(event):
		return
	if event is InputEventMouseMotion:
		var next_tile: Vector2i = tile_at_screen(event.position)
		if next_tile != hovered_tile or next_tile.x < 0:
			hovered_tile = next_tile
			queue_redraw()
		return
	if not movement_task.is_empty() or unit_playback.busy():
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not mission_picker_open and not loadout_open and handle_developer_click(event.position):
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
			if event.keycode in [KEY_M, KEY_R, KEY_I, KEY_F6, KEY_F7, KEY_F8]:
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
			use_developer_option({"id": "ledger"})
			return
		if show_hit_ledger and event.keycode in [KEY_UP, KEY_DOWN]:
			if event.keycode == KEY_UP:
				ledger_scroll = mini(maxi(0, damage_history.size() - LEDGER_VISIBLE_ROWS), ledger_scroll + 1)
			else:
				ledger_scroll = maxi(0, ledger_scroll - 1)
			queue_redraw()
			return
		if show_hit_ledger and event.keycode != KEY_R:
			return
		if game_over and event.keycode == KEY_P:
			use_developer_option({"id": "activity"})
			return
		if game_over and show_room_activity and event.keycode in [KEY_LEFT, KEY_RIGHT]:
			if event.keycode == KEY_LEFT:
				activity_room_page = maxi(0, activity_room_page - 1)
			else:
				activity_room_page = mini(room_history.size() - 1, activity_room_page + 1)
			queue_redraw()
			return
		if event.keycode in [KEY_F6, KEY_F7, KEY_F8]:
			use_developer_option({"id": "room", "stage": event.keycode - KEY_F6})
			return
		if room_cleared:
			if event.keycode in [KEY_ENTER, KEY_KP_ENTER, KEY_C]:
				next_mission_room()
			elif event.keycode == KEY_R:
				restart_game()
			return
		if class_combat.enabled and class_combat.actor >= 0 and event.keycode in [
				KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_TAB, KEY_X, KEY_J, KEY_K, KEY_O]:
			class_combat.cancel()
		if event.keycode == KEY_R:
			restart_game()
		elif event.keycode == KEY_SPACE and side_to_play == "player" and not game_over:
			end_player_turn()
		elif event.keycode == KEY_X and side_to_play == "player" and not game_over:
			reload_selected_weapon()
		elif event.keycode in [KEY_J, KEY_K] and side_to_play == "player" and not game_over:
			toggle_loadout_action("melee" if event.keycode == KEY_J else "medkit")
		elif event.keycode in [KEY_T, KEY_C]:
			status_message = "This is one continuous mission. Clear the room to advance; R restarts from room 1."
			queue_redraw()
		elif event.keycode == KEY_H:
			use_developer_option({"id": "threat"})
		elif event.keycode == KEY_O and side_to_play == "player" and not game_over:
			use_operative_action("overwatch")
		elif event.keycode == KEY_I:
			use_developer_option({"id": "ai"})
		elif event.keycode == KEY_F:
			use_developer_option({"id": "links"})
		elif event.keycode == KEY_V and game_over:
			use_developer_option({"id": "report"})
		elif event.keycode == KEY_B and side_to_play == "player" and not game_over and not class_combat.enabled:
			use_operative_action("breach")
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
	if room_cleared:
		if NEXT_ROOM_BUTTON.has_point(clicked):
			next_mission_room()
		elif hq_deployment and EXTRACT_BUTTON.has_point(clicked):
			extract_hq_operation()
		return
	if game_over and show_report:
		if REPORT_RESET.has_point(clicked):
			if hq_deployment:
				headquarters.open()
			else:
				restart_game()
		return
	if END_BUTTON.has_point(clicked):
		if side_to_play == "player" and not game_over:
			end_player_turn()
		return
	if game_over or side_to_play != "player":
		return
	if handle_operative_action_click(clicked):
		return
	for row in range(5):
		if squad_tab_rect(row).has_point(clicked):
			if int(units[row]["hp"]) > 0:
				class_combat.cancel()
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
	if loadout_action == "overwatch":
		if set_overwatch(find_unit_by_id(selected_id), tile):
			loadout_action = ""
		queue_redraw()
		return
	if class_combat.enabled and class_combat.actor >= 0:
		class_combat.submit(tile)
		queue_redraw()
		return
	var clicked_unit_idx: int = find_unit_at(tile)
	if loadout_action != "" and loadout_action != "shoot":
		var actor: int = find_unit_by_id(selected_id)
		if not can_use_loadout_action(actor, loadout_action):
			return
		var acted: bool
		if loadout_action == "melee" and units[actor].has("class_build") and barrel_is_active(tile):
			acted = attack_barrel(actor, tile)
		elif loadout_action == "melee" and units[actor].has("class_build") and mission_object_at(tile) and mission_objects[tile]["kind"] == "machine":
			acted = objective_action(actor, tile)
		else:
			acted = use_loadout_action(actor, clicked_unit_idx)
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
		var clicked_id: int = int(units[clicked_unit_idx]["id"])
		if clicked_id == selected_id and tile != units[clicked_unit_idx]["pos"]:
			# A large operative may shift its anchor into its own footprint.
			clicked_unit_idx = -1
	if clicked_unit_idx >= 0 and units[clicked_unit_idx]["team"] == "player":
		selected_id = int(units[clicked_unit_idx]["id"])
		loadout_action = ""
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
		if basic_is_melee(units[selected_idx]):
			try_basic_melee(selected_idx, clicked_unit_idx)
		elif not perform_attack(selected_idx, clicked_unit_idx):
			status_message = str(attack_preview(selected_idx, clicked_unit_idx)["reason"]).trim_suffix(".") + "."
		queue_redraw()
		return
	if loadout_action == "shoot":
		status_message = "Choose an attack target or press Esc to cancel."
		queue_redraw()
		return
	if voluntary_movement_locked(selected_idx):
		status_message = movement_lock_reason(selected_idx)
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
		status_message = "Out of reach. Green squares show movement up to %d steps for 1 AP." % int(units[selected_idx]["move"])
	queue_redraw()

func end_player_turn() -> void:
	if game_over or room_cleared or side_to_play != "player":
		return
	# The third full player turn ends here; if radio still broadcasts, the
	# consequence is permanent even if the player destroys it later.
	if test_mission_id == "chain" and mission_stage == 1 and turn_number >= RADIO_DEADLINE_ROUND and not bool(radio_state.get("destroyed_in_time", false)):
		queue_radio_alert("three player turns elapsed")
	class_combat.cancel()
	loadout_action = ""
	special_mode = false
	shred_landing_tile = Vector2i(-1, -1)
	expire_blinded_for_team("player")
	side_to_play = "enemy"
	clear_reactions_for_team("enemy")
	refill_armour_for_team("enemy")
	if class_combat.enabled:
		resolving_class_action = true
		class_combat.start_enemy_phase()
		resolving_class_action = false
		assess_winner()
		if game_over or room_cleared:
			return
	process_environment_phase("enemy")
	if game_over or room_cleared:
		return
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
		var class_penalty: int = int(class_combat.effects(enemy_idx).get("review_ap_loss", 0)) if class_combat.enabled else 0
		units[enemy_idx]["ap"] = maxi(0, int(units[enemy_idx]["max_ap"]) - int(units[enemy_idx]["jammed_actions"]) - class_penalty)
		if class_combat.enabled:
			if class_penalty > 0:
				units[enemy_idx]["ap"] = maxi(1, int(units[enemy_idx]["ap"]))
			if class_combat.effects(enemy_idx).get("stunned", false):
				units[enemy_idx]["ap"] = 0
			class_combat.effects(enemy_idx).erase("review_ap_loss")
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
	process_camera(delta)
	if headquarters.visible or mission_picker_open or loadout_open:
		return
	var previous_beat: int = int(atmosphere_time * 15.0)
	atmosphere_time += delta
	if not game_over and previous_beat != int(atmosphere_time * 15.0) \
			and (not hazards.is_empty() or not class_combat.drones.is_empty()):
		queue_redraw()
	if sabotage_visuals.advance(delta):
		queue_redraw()
	if unit_playback.advance(delta):
		queue_redraw()
	if not damage_floaters.is_empty():
		for i in range(damage_floaters.size() - 1, -1, -1):
			var popup: Dictionary = damage_floaters[i]
			popup["ttl"] = float(popup["ttl"]) - delta
			damage_floaters[i] = popup
			if float(popup["ttl"]) <= 0.0:
				damage_floaters.remove_at(i)
		queue_redraw()
	if unit_playback.busy():
		return
	if not movement_task.is_empty():
		movement_tick -= delta
		if movement_tick <= 0.0:
			movement_tick = 0.0
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
	if int(units[enemy_idx]["hp"]) > 0 and int(units[enemy_idx]["ap"]) > 0 and not overwatch_locks_movement(enemy_idx):
		if not has_attack_ammo(enemy_idx):
			reload_weapon(enemy_idx)
		elif class_combat.enabled and class_combat.try_enemy_drone_attack(enemy_idx):
			ai_shot_count += 1
		elif str(units[enemy_idx].get("kind", "ranged")) == "horde":
			horde_enemy_step(enemy_idx)
		elif str(units[enemy_idx].get("kind", "ranged")) == "support" and not (
				class_combat.enabled and (class_combat.effects(enemy_idx).get("mind_lock", false) or class_combat.effects(enemy_idx).get("aphasia", false))):
			support_enemy_step(enemy_idx)
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
	expire_blinded_for_team("enemy")
	if class_combat.enabled:
		class_combat.finish_enemy_phase()
	turn_number += 1
	side_to_play = "player"
	recover_downed_operatives()
	clear_reactions_for_team("player")
	refill_armour_for_team("player")
	for idx in range(units.size()):
		if units[idx]["team"] == "player" and int(units[idx]["hp"]) > 0:
			units[idx]["ap"] = int(units[idx]["max_ap"])
	if class_combat.enabled:
		class_combat.start_player_phase()
		assess_winner()
		if game_over or room_cleared:
			return
	age_hazards()
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
	var possible: Dictionary = reachable(unit["pos"], int(unit["move"]), int(unit["id"]))
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
		var melee := basic_is_melee(opponent)
		if not melee and not ranged_cover_block_reason(opponent["pos"], destination).is_empty():
			continue
		var cover: int = 0 if melee else cover_level_at(destination, opponent["pos"])
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
	return pursuit * distance_value - threat * survival * wounded_factor * 0.88 + cover_bonus - (12.0 if footprint_has_hazard(units[enemy_idx], destination) else 0.0)

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
	var options: Dictionary = reachable(source, int(units[enemy_idx]["move"]), int(units[enemy_idx]["id"]))
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
		var options: Dictionary = reachable(units[enemy_idx]["pos"], int(units[enemy_idx]["move"]), int(units[enemy_idx]["id"]))
		if options.has(dest):
			move_unit(enemy_idx, dest, int(options[dest]))
			ai_move_count += 1
			add_log("%s %s." % [name, reason])
			status_message = "%s %s." % [name, reason]
		else:
			units[enemy_idx]["ap"] = maxi(0, int(units[enemy_idx]["ap"]) - 1)
			reason = "could not move"
	else:
		# Ranged enemies threaten an approach rather than silently wasting AP.
		if set_enemy_overwatch(enemy_idx):
			reason = "sets an Overwatch cone"
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
	var options: Dictionary = reachable(units[idx]["pos"], int(units[idx]["move"]), int(units[idx]["id"]))
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
		if footprint_has_hazard(units[idx], tile):
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
			var can_heal: bool = units[idx].get("trait") != "broadcast" and units[ally_idx]["hp"] < units[ally_idx]["max_hp"]
			var can_buff: bool = units[idx].get("trait") != "choir" and units[ally_idx].get("stim_bonus", 0) == 0
			if can_heal or can_buff:
				return true
	return false

func support_enemy_step(idx: int) -> void:
	var ap: int = int(units[idx]["ap"])
	var current: Vector2i = units[idx]["pos"]
	var speaker: String = units[idx]["name"]
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
			ai_last_decision = speaker + ": seeks cover before supporting"
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
		if units[idx].get("trait") != "broadcast" and heal_idx >= 0 and apply_healing(idx, heal_idx, 3, "Choir of Flesh" if units[idx].get("trait") == "choir" else "Field Regenerator"):
			units[idx]["ap"] = ap - SUPPORT_COST
			ai_last_decision = speaker + ": heals ally (range 4, 1 AP)"
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
		if units[idx].get("trait") != "choir" and buff_idx >= 0:
			play_support_action(idx, buff_idx)
			units[idx]["ap"] = ap - SUPPORT_COST
			units[buff_idx]["stim_bonus"] = 1
			battle_stats[idx]["buffs"] = int(battle_stats[idx]["buffs"]) + 1
			record_ability_use(idx, "Party Broadcast" if units[idx].get("trait") == "broadcast" else "Aggression Serum")
			ai_last_decision = speaker + ": buffs one ally's next attack (range 4, 1 AP)"
			status_message = speaker + " buffs %s's next attack: +1 damage." % str(units[buff_idx]["name"])
			add_log(status_message)
			return
	# When support is unavailable or AP is insufficient, use a WEAKER ranged
	# attack where sensible, while maintaining the safest position available.
	var target: int = nearest_attackable_player(idx)
	if target >= 0:
		perform_attack(idx, target)  # support pistol: 1 damage, 5 range, 1 AP
		ai_shot_count += 1
		ai_last_decision = speaker + ": fires weaker support pistol"
		return
	# If no support target and no shot, move closer to allies while preserving
	# cover where possible; remaining AP can be used next step for a pistol shot.
	if safe_tile != current:
		var path_after: Dictionary = reachable(current, MOVE_DISTANCE, int(units[idx]["id"]))
		if path_after.has(safe_tile):
			move_unit(idx, safe_tile, int(path_after[safe_tile]))
			ai_move_count += 1
			ai_last_decision = speaker + ": moves to better cover"
			return
	if set_enemy_overwatch(idx):
		ai_last_decision = speaker + ": sets an Overwatch cone from cover"
	else:
		units[idx]["ap"] = 0
		ai_last_decision = speaker + ": holds cover"

func ability_description(idx: int) -> Array[String]:
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
	draw_label("Room XP value   %d enemy + %d objective" % [record.get("kill_xp", 0),
		record.get("objective_xp", 0)], Vector2(137, 224), 14, Color("#b6e8d1"))
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
		draw_label("Pending recoveries stand at half HP. Protection, AP, ranged charges and cooldowns reset.",
			Vector2(142, 691), 14, Color("#d3e0ec"))
		draw_rect(NEXT_ROOM_BUTTON, Color("#2b806f"), true)
		draw_rect(NEXT_ROOM_BUTTON, Color("#9ce4d0"), false, 2.0)
		draw_label("CONTINUE TO ROOM %d  [ENTER]" % (mission_stage + 2), Vector2(570, 774), 19, Color.WHITE)
		if hq_deployment:
			var extract_label := "EXTRACT TO HQ [E]"
			draw_action_button(EXTRACT_BUTTON, extract_label, true)
		var transition_navigation: String = "[R] Restart mission"
		if hq_deployment:
			transition_navigation = "[E] Extract with secured rewards"
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
	var title: String = campaign_operation.get("label", test_mission_id)
	draw_label("AFTER-ACTION REPORT  /  %s" % title.to_upper(), Vector2(46, 108), 26, Color("#f5e5b4"))
	var outcome_heading: String = "MISSION COMPLETE" if mission_victory else "MISSION FAILED · " + mission_failure_reason.to_upper()
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
	var movement_note := "Movement uses each unit’s current movement range."
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
	# Return the number of drawn lines for HUD sections that stack text.
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
		parts.append("OVERWATCH: %d SHOTS" % overwatch_shots(idx))
	if class_combat.enabled:
		var fx: Dictionary = class_combat.effects(idx)
		var shield: int = int(fx.get("barrier", 0)) + int(fx.get("force_shell", 0)) + int(fx.get("feather_barrier", 0))
		if shield > 0:
			parts.append("Barrier %d" % shield)
		if unit.get("armour_broken", false):
			parts.append("Armour broken")
		for entry in ClassCombat.STATUS_LABELS:
			if fx.has(entry):
				parts.append(ClassCombat.STATUS_LABELS[entry])
	var active_effects: Dictionary = unit.get("statuses", {})
	for effect in active_effects.keys():
		if int(active_effects[effect]) > 0:
			parts.append("%s (%d)" % [str(effect).capitalize(), int(active_effects[effect])])
	if int(unit["hp"]) <= 0:
		parts.append("INCAPACITATED")
	if parts.is_empty():
		return "None"
	return "; ".join(parts)

func draw_squad_hud(idx: int) -> void:
	for slot in range(5):
		var ally: Dictionary = units[slot]
		var rect: Rect2 = squad_tab_rect(slot)
		var active: bool = int(ally["id"]) == selected_id
		var living: bool = int(ally["hp"]) > 0
		var ready: bool = living and int(ally["ap"]) > 0
		var ink: Color = HUD_TEXT if ready or active else HUD_MUTED
		draw_rect(rect, Color("#2b4946") if active else (Color("#293c49") if rect.has_point(hud_cursor) else Color("#22313d")))
		draw_rect(rect, HUD_ACCENT if active else HUD_LINE, false)
		var name_pos: Vector2 = rect.position + Vector2(10, 19)
		draw_label("%d  %s" % [slot + 1, ally["name"]], name_pos, 13, ink)
		var recovery_round: int = int(ally["recovery_round"])
		var detail: String = "%d AP" % int(ally["ap"]) if living else ("Down · R%d" % recovery_round if recovery_round > 0 else "Lost")
		draw_label(detail, name_pos + Vector2(0, 17), 12, HUD_ACCENT if ready else HUD_MUTED)

	if idx < 0:
		draw_label("Select an operative", Vector2(30, 786), 18, HUD_MUTED)
		return
	var unit: Dictionary = units[idx]
	var avatar: Texture2D = operative_avatar(unit) if unit.has("class_build") else unit_sprites.get(UnitSprites.role_for(unit))
	if avatar != null:
		draw_texture_rect(avatar, Rect2(30, 771, 54, 54), false)
	var identity: String = str(unit["name"])
	draw_label(identity, Vector2(94, 784), 20, HUD_TEXT)
	if class_combat.enabled:
		draw_label(class_combat.summary(idx), Vector2(255, 784), 12, HUD_OBJECTIVE)
	var stats: String = unit_vitals(unit)
	if not basic_is_melee(unit):
		stats += "    %s %d/%d" % ["Charges" if unit.has("class_build") else "Ammo", unit["rounds"], unit["magazine_capacity"]]
	draw_label(stats, Vector2(94, 805), 13, HUD_ACCENT)
	draw_label("%s · %d dmg · Range %d · Move %d · Weight %d" % [unit["basic_attack"], unit["damage"], unit["range"], unit["move"], unit.get("weight", 2)], Vector2(94, 824), 12, HUD_MUTED)
	var effects: String = selected_status_text(idx)
	if effects != "None":
		draw_wrapped_label(effects, Vector2(94, 843), 442, 11, HUD_OBJECTIVE, 12, 3)

func unit_vitals(unit: Dictionary) -> String:
	return "HP %d/%d    ARM %d/%d    AP %d/%d" % [unit["hp"], unit["max_hp"],
		int(unit["armour"]) if armour_enabled else 0, int(unit["max_armour"]) if armour_enabled else 0,
		unit["ap"], unit["max_ap"]]

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
		draw_line(from_center, to_center, Color(0.12, 0.23, 0.19, 0.82), 4.0)
		draw_line(from_center, to_center, Color(0.44, 0.94, 0.65, 0.65), 2.0, true)
		draw_circle(to_center, 19.5, Color(0.44, 0.94, 0.65, 0.9), false, 2.2, true)

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

func draw_overwatch_cone(cone: Dictionary, color: Color, preview: bool = false) -> void:
	for tile: Vector2i in cone:
		var cell: Rect2 = battlefield.tile_rect(tile)
		draw_rect(cell, Color(color, 0.32 if preview else 0.23))
		if not cone.has(tile + Vector2i.UP):
			draw_line(cell.position, Vector2(cell.end.x, cell.position.y), color, 1.5)
		if not cone.has(tile + Vector2i.DOWN):
			draw_line(Vector2(cell.position.x, cell.end.y), cell.end, color, 1.5)
		if not cone.has(tile + Vector2i.LEFT):
			draw_line(cell.position, Vector2(cell.position.x, cell.end.y), color, 1.5)
		if not cone.has(tile + Vector2i.RIGHT):
			draw_line(Vector2(cell.end.x, cell.position.y), cell.end, color, 1.5)

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


func draw_cover_edges(tile_rect: Rect2, tile: Vector2i, edges: Dictionary) -> void:
	# Lines sit on exact tile boundaries to show a barrier shared by both tiles.
	# The edge is drawn only at its authored location; defense lookup is symmetric.
	var left: float = tile_rect.position.x + 3.0
	var top: float = tile_rect.position.y
	var right: float = tile_rect.position.x + float(TILE) - 3.0
	var bottom: float = tile_rect.position.y + float(TILE)
	for face in edges.keys():
		var level: int = int(edges[face])
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
		var neighbour: Vector2i = tile + tile_offset_for_face(str(face))
		var other_edges: Dictionary = cover_edges.get(neighbour, {})
		var other_level: int = int(other_edges.get(opposing_face(str(face)), 0))
		if other_level > level or (other_level == level and face in ["E", "S"]):
			continue
		var structure: Dictionary = destructible_edges.get(edge_key(tile, str(face)), {})
		sabotage_visuals.draw_cover(self, battlefield, a, b, level,
			int(structure.get("hp", 0)) < int(structure.get("max_hp", 0)))

func draw_battle_depth(sabotage: bool) -> void:
	var entries: Array[Dictionary] = []
	for tile in walls:
		entries.append(battle_depth_entry("wall", tile))
	for tile in barrels:
		entries.append(battle_depth_entry("barrel", tile))
	for tile in mission_objects:
		entries.append(battle_depth_entry("objective", tile))
	if radio_is_present():
		entries.append(battle_depth_entry("radio", RADIO_POS))
	for idx in range(units.size()):
		if int(units[idx]["hp"]) <= 0 and int(units[idx].get("recovery_round", 0)) <= 0 \
				and not pending_defeats.has(idx) and not unit_playback.ground_positions.has(idx) and battle_hit_age(idx) >= 0.23:
			continue
		var cell: Vector2i = units[idx]["pos"]
		var ground: Vector2 = unit_board_center(idx)
		var entry: Dictionary = battle_depth_entry("unit", cell, unit_footprint(units[idx], cell).size,
			unit_playback.ground_positions.get(idx, ground) - ground)
		entry["idx"] = idx
		entries.append(entry)
	if class_combat.enabled:
		for owner in class_combat.drones:
			var track: int = -int(owner) - 2
			if class_combat.drone_live(owner) or unit_playback.ground_positions.has(track):
				var cell: Vector2i = class_combat.drones[owner]["pos"]
				var ground: Vector2 = board_center(cell)
				var drone: Dictionary = battle_depth_entry("drone", cell, Vector2i.ONE,
					unit_playback.ground_positions.get(track, ground) - ground)
				drone["idx"] = owner
				entries.append(drone)
	entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var a_pos: Vector2 = a["center"]
		var b_pos: Vector2 = b["center"]
		if a_pos.y != b_pos.y:
			return a_pos.y < b_pos.y
		if a_pos.x != b_pos.x:
			return a_pos.x < b_pos.x
		return a["kind"] < b["kind"])

	var obscured: Array[Dictionary] = []
	var visible_targets: Array[Dictionary] = []
	for entry in entries:
		var tile: Vector2i = entry["tile"]
		var kind: String = entry["kind"]
		var art: Rect2 = entry["art"]
		if kind == "wall":
			var fade: bool = art.has_point(battlefield.project(board_center(hovered_tile))) if is_in_bounds(hovered_tile) else false
			for target in visible_targets:
				if art.intersects(target["art"]):
					fade = true
					break
			var wall_color := Color("#87908a") if sabotage else Color("#748991")
			wall_color.a = 0.25 if fade else 1.0
			var joined: Array[bool] = []
			for side in BattlefieldView.SIDES:
				joined.append(walls.has(tile + side))
			battlefield.draw_wall(self, battlefield.tile_rect(tile), wall_color, joined)
			continue
		for target in visible_targets:
			if art.intersects(target["art"]) and target not in obscured:
				obscured.append(target)
		match kind:
			"barrel": draw_barrel(tile)
			"objective": draw_mission_object(tile)
			"radio": draw_battle_radio()
			"unit": draw_battle_unit(entry["idx"], entry["center"], entry["size"])
			"drone": class_combat.draw_drone(entry["idx"], entry["center"])
		visible_targets.append(entry)

	draw_set_transform_matrix(battlefield.ground)
	for target in obscured:
		var marker_color := Color("#f2d48d")
		if target["kind"] == "unit":
			marker_color = Color("#86cbf6") if units[target["idx"]]["team"] == "player" else Color("#f19688")
		draw_rect(Rect2(target["footprint"]).grow(-2), marker_color, false, 1.5)
	for entry in entries:
		if entry["kind"] != "unit":
			continue
		var unit: Dictionary = units[entry["idx"]]
		var selected: bool = int(unit["id"]) == selected_id and side_to_play == "player"
		var acting: bool = last_acting_enemy == entry["idx"] and side_to_play == "enemy"
		if selected or acting or int(entry["size"].x) > 1:
			var outline := Color("#eff4f2") if selected else (Color("#f1d794") if acting else Color("#bc9692"))
			draw_rect(Rect2(entry["footprint"]).grow(-2), outline, false, 2.5)
	if is_in_bounds(hovered_tile):
		var hover: Rect2 = battlefield.tile_rect(hovered_tile).grow(-2)
		draw_rect(hover, Color("#22252b"), false, 4.0)
		draw_rect(hover, Color("#ffe7a0"), false, 2.0)

func battle_depth_entry(kind: String, tile: Vector2i, size: Vector2i = Vector2i.ONE,
		motion: Vector2 = Vector2.ZERO) -> Dictionary:
	var footprint: Rect2 = battlefield.tile_rect(tile, size)
	footprint.position += motion
	var center: Vector2 = battlefield.project(footprint.get_center())
	var half_width: float = 18.0 if size.x == 1 else 34.0
	var height: float = 41.0 if size.x == 1 else 58.0
	var art := Rect2(center - Vector2(half_width, height), Vector2(half_width * 2, height + 4))
	if kind == "wall":
		art = battlefield.wall_bounds(footprint)
	return {"kind": kind, "tile": tile, "center": center, "art": art, "footprint": footprint, "size": size}

func draw_battle_radio() -> void:
	var radio_center: Vector2 = battlefield.project(board_center(RADIO_POS)) + Vector2(0, -10)
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


func battle_hit_age(idx: int) -> float:
	for i in range(damage_floaters.size() - 1, -1, -1):
		var event: Dictionary = damage_floaters[i]
		if event["target"] == idx and int(event["arm"]) + int(event["hp"]) > 0:
			return DAMAGE_FLOAT_SECONDS - float(event["ttl"])
	return INF

func draw_battle_unit(idx: int, center: Vector2, size_in_tiles: Vector2i) -> void:
	var unit: Dictionary = units[idx]
	var large: bool = size_in_tiles.x > 1
	var hit_age: float = battle_hit_age(idx)
	var defeated: bool = int(unit["hp"]) <= 0 and not pending_defeats.has(idx) and not unit_playback.ground_positions.has(idx)
	if defeated and hit_age >= 0.23:
		var ready_round: int = int(unit.get("recovery_round", 0))
		if ready_round > 0:
			draw_circle(center, 12.0, Color("#283747"))
			draw_circle(center, 12.0, Color("#edbb80"), false, 2.0)
			draw_label("R%d" % ready_round, center + Vector2(-7, 4), 10, Color("#ffdfa5"))
		return
	var kind: String = str(unit.get("kind", ""))
	# Exhausted allies change from blue to grey until their AP refreshes.
	var unit_color: Color = (Color("#7c8791") if int(unit["ap"]) <= 0 else Color("#46a9e9")) if unit["team"] == "player" else (Color("#c56f92") if kind == "horde" else (Color("#e8c26b") if kind == "support" else Color("#e66c61")))
	if unit.has("family"):
		unit_color = EnemyRoster.COLORS[unit["family"]]
	var shadow_width: float = 27.0 if not large else 54.0
	var bunker_avatar: bool = unit.has("class_build")
	var sprite: Texture2D = operative_avatar(unit) if bunker_avatar else unit_sprites.get(UnitSprites.role_for(unit))
	var facing: Vector2i = unit_playback.facing.get(idx, UnitPlayback.INITIAL_FACING)
	var pose: StringName = &"fall" if defeated else unit_playback.pose(idx)
	var progress: float = hit_age / 0.23 if defeated else unit_playback.progress()
	var feet: Vector2 = center
	if pose == &"leap":
		feet.y -= unit_playback.lift
		if progress > 0.74:
			sabotage_visuals.draw_ring(self, center, 7.0 + (progress - 0.74) * 53.0,
				Color(0.77, 0.68, 0.52, (1.0 - progress) * 2.5), 1.5)
	if pose == &"blink":
		var track: Dictionary = unit_playback.current
		var start: Vector2 = battlefield.project(track["from"])
		var finish: Vector2 = battlefield.project(track["to"])
		var shimmer := Color(0.71, 0.58, 1.0, sin(progress * PI))
		sabotage_visuals.draw_aura(self, start, shimmer, progress, &"pulse")
		sabotage_visuals.draw_aura(self, finish, shimmer, progress, &"pulse")
	sabotage_visuals.draw_shadow(self, center, shadow_width, 1.0 - unit_playback.lift / 60.0 if pose == &"leap" else 1.0)
	draw_line(center - Vector2(shadow_width * 0.36, -2), center + Vector2(shadow_width * 0.36, 2), unit_color, 1.5)
	if sprite != null:
		var tint: Color = Color("#aab2bc") if unit["team"] == "player" and int(unit["ap"]) <= 0 else Color.WHITE
		if unit.has("family"):
			tint = Color.WHITE.lerp(unit_color, 0.38)
		var scale: float = 1.28 if bunker_avatar else (1.10 if large else 1.48)
		draw_unit_pose(sprite, feet, scale, tint, pose, facing, progress, maxf(0.0, 1.0 - hit_age / 0.18))
	else:
		draw_label(str(unit["letter"]), feet + Vector2(-5.5, -3), 17, Color("#0f1c24"))
	if bool(unit.get("reaction_available", false)) and overwatch_shots(idx) > 0:
		var indicator: String = "O" if str(unit.get("reaction_type", "")) == "overwatch" else "G"
		draw_rect(Rect2(center.x + 10, center.y - 23, 15, 15), Color("#e5c58b"))
		draw_label(indicator, center + Vector2(12, -11), 12, Color("#18283a"))
	var bar_width: float = 48.0 if large else 24.0
	var bar_pos := center + Vector2(-bar_width * 0.5, 5)
	draw_rect(Rect2(bar_pos, Vector2(bar_width, 3)), Color("#3f2830"))
	draw_rect(Rect2(bar_pos, Vector2(bar_width * float(unit["hp"]) / float(unit["max_hp"]), 3)), Color("#8cdd8d"))
	if int(unit["max_armour"]) > 0 and armour_enabled:
		var armour_pos: Vector2 = bar_pos + Vector2(0, 5)
		draw_rect(Rect2(armour_pos, Vector2(bar_width, 3)), Color("#263c51"))
		draw_rect(Rect2(armour_pos, Vector2(bar_width * float(unit["armour"]) / float(unit["max_armour"]), 3)), Color("#75c7ff"))
	if show_facing_arrows:
		draw_facing_arrow(center, facing, large, unit_color.lightened(0.56))

func draw_unit_pose(sprite: Texture2D, feet: Vector2, scale: float, tint: Color,
		pose: StringName, facing: Vector2i, progress: float, hit: float) -> void:
	if not sprite_foot_anchors.has(sprite):
		var used: Rect2i = sprite.get_image().get_used_rect()
		sprite_foot_anchors[sprite] = Vector2(sprite.get_width() * 0.5, used.end.y)
	var anchor: Vector2 = sprite_foot_anchors[sprite]
	var direction: Vector2 = battlefield.projection.basis_xform(Vector2(facing)).normalized()
	var swing: float = sin(PI * progress)
	var impact: float = 0.0
	if progress >= UnitPlayback.IMPACT_FRACTION:
		impact = 1.0 - smoothstep(UnitPlayback.IMPACT_FRACTION, 1.0, progress)
	var root: Vector2 = feet
	var lean: float = 0.0
	var stretch := Vector2.ONE
	match pose:
		&"walk":
			var step: float = 1.0 if unit_playback.stride % 2 == 0 else -1.0
			root += Vector2(step, -2.8) * swing
			lean = step * swing * 0.09
			stretch.y = 1.0 + swing * 0.06
		&"leap":
			lean = direction.x * 0.30 * swing
			stretch = Vector2(1.0 - swing * 0.13, 1.0 + swing * 0.14)
		&"blink":
			tint.a *= 1.0 - swing * 0.93
			stretch = Vector2(1.0 - swing * 0.64, 1.0 + swing * 0.15)
		&"displace":
			lean = -direction.x * swing * 0.24
			stretch.y = 1.0 - swing * 0.12
		&"fall":
			lean = -signf(direction.x) * progress * 1.18
			stretch.y = 1.0 - progress * 0.54
			tint.a *= 1.0 - smoothstep(0.38, 1.0, progress)
		&"slash", &"slam":
			root += direction * (impact * 12.0 - (swing * 4.0 if impact == 0.0 else 0.0))
			lean = direction.x * (impact * 0.41 - (swing * 0.13 if impact == 0.0 else 0.0))
			stretch.y = 1.0 + impact * 0.08
		&"shot", &"beam", &"arc", &"shell":
			root += direction * (swing * 3.0 - impact * (10.0 if pose == &"shell" else 6.0))
			lean = direction.x * (swing * 0.13 - impact * 0.27)
			stretch.y = 1.0 - impact * 0.10
		&"heal", &"shield", &"pulse", &"service":
			root.y -= swing * 4.0
			stretch = Vector2(1.0 + swing * 0.06, 1.0 - swing * 0.07)
	if hit > 0.0:
		lean -= direction.x * hit * 0.22
		root += Vector2(sin(hit * 19.0) * hit * 3.0, -hit * 2.0)
		tint = tint.lerp(Color("#ffba97"), hit * 0.72)
	var mirror: float = -1.0 if direction.x < -0.001 else 1.0
	var model := Transform2D(lean, stretch * Vector2(mirror, 1) * scale, 0.0, root.round())
	draw_set_transform_matrix(battlefield.camera * model)
	if pose == &"walk":
		var size: Vector2 = sprite.get_size()
		var waist: float = floorf(anchor.y * 0.70)
		var stride: float = swing * size.y * 0.075
		var split: float = floorf(anchor.x)
		var upper := Rect2(0, 0, size.x, waist)
		draw_texture_rect_region(sprite, Rect2(-anchor, upper.size), upper, tint)
		for side in [0, 1]:
			var leg := Rect2(side * split, waist, split if side == 0 else size.x - split, size.y - waist)
			var step: float = stride * (1.0 if (side + unit_playback.stride) % 2 == 0 else -0.65)
			var stride_rect := Rect2(leg.position - anchor + Vector2(step * 0.35, -maxf(0.0, step) * 0.24),
				leg.size + Vector2(0, step * 0.45))
			draw_texture_rect_region(sprite, stride_rect, leg, tint)
	else:
		draw_texture(sprite, -anchor, tint)
	draw_set_transform_matrix(battlefield.camera)

func draw_facing_arrow(center: Vector2, facing: Vector2i, large: bool, color: Color) -> void:
	var direction: Vector2 = battlefield.projection.basis_xform(Vector2(facing)).normalized()
	var tip: Vector2 = center + direction * (25.0 if large else 15.0)
	var base: Vector2 = tip - direction * 7.0
	var side := Vector2(-direction.y, direction.x)
	var arrow := PackedVector2Array([tip, base + side * 3.5, base - side * 3.5])
	draw_colored_polygon(arrow, color)
	arrow.append(tip)
	draw_polyline(arrow, Color("#111b27"), 1.25, true)

func draw_hazard_tile(rect: Rect2, kind: String) -> void:
	var tint: Color = Color("#ef6a31") if kind == "fire" else (Color("#a2db4f") if kind == "radiation" else Color("#60c8ef"))
	var patch: Rect2 = rect.grow(-3)
	draw_rect(patch, Color(tint, 0.36))
	draw_rect(patch, Color(tint, 0.82), false, 1.0)
	for x in [5, 12, 19, 26]:
		var offset: Vector2 = rect.position + Vector2(x, 26 if x in [5, 19] else 24)
		draw_rect(Rect2(offset, Vector2(3, 3)), Color(tint.lightened(0.38), 0.66))
	draw_rect(Rect2(rect.position + Vector2(4, 4), Vector2(11, 12)), tint.darkened(0.68))
	draw_set_transform_matrix(battlefield.camera)
	var marker: Vector2 = battlefield.project(rect.position + Vector2(9, 10))
	draw_label(kind.left(1).to_upper(), marker + Vector2(-3, 3), 10, tint.lightened(0.5))
	var center: Vector2 = battlefield.project(rect.get_center())
	for i in range(5):
		var age: float = fposmod(atmosphere_time * (0.63 + 0.10 * i) + i * 0.197, 1.0)
		var mote: Vector2 = (center + Vector2(-13 + 6 * i + sin(age * TAU + i) * 4, 3 - age * 21)).round()
		var glow: Color = Color(tint.lightened(0.42), (1.0 - age) * 0.7)
		draw_rect(Rect2(mote, Vector2(2, 3) if kind == "fire" else Vector2(2, 2)), glow)
	draw_set_transform_matrix(battlefield.ground)

func enemy_defeated(unit: Dictionary) -> bool:
	return unit["team"] == "enemy" and unit["hp"] <= 0


func defeated_enemy_count() -> int:
	var defeated := 0
	for unit in units:
		if enemy_defeated(unit):
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

func action_button_rect(index: int) -> Rect2:
	var offset := Vector2(index % ACTION_COLUMNS, -floori(float(index) / ACTION_COLUMNS)) * ACTION_SPACING
	return Rect2(FIRST_ACTION_RECT.position + offset, FIRST_ACTION_RECT.size)

func operative_action_at(point: Vector2) -> Dictionary:
	var column: int = floori((point.x - FIRST_ACTION_RECT.position.x) / ACTION_SPACING.x)
	var row: int = floori((FIRST_ACTION_RECT.end.y - point.y) / ACTION_SPACING.y)
	if column < 0 or column >= ACTION_COLUMNS or row < 0 or not BattlefieldView.AREA.has_point(point):
		return {}
	var index: int = row * ACTION_COLUMNS + column
	if not action_button_rect(index).has_point(point):
		return {}
	var actions: Array[Dictionary] = operative_actions(find_unit_by_id(selected_id))
	return actions[index] if index < actions.size() else {}

func operative_actions(idx: int) -> Array[Dictionary]:
	var actions: Array[Dictionary] = []
	if idx < 0 or int(units[idx]["hp"]) <= 0:
		return actions
	var unit: Dictionary = units[idx]
	var melee: bool = basic_is_melee(unit)
	var ready: bool = side_to_play == "player" and not game_over and movement_task.is_empty() and not unit_playback.busy()
	var has_ap: bool = int(unit["ap"]) > 0
	var loaded: bool = has_attack_ammo(idx) or (class_combat.enabled and not class_combat.effects(idx).get("breach_follow_up", []).is_empty())
	var refilling: bool = int(unit["rounds"]) < int(unit["magazine_capacity"])
	var reload_name: String = "Recharge" if class_combat.enabled else "Reload"
	if not melee:
		actions.append({"id": "shoot", "label": "%s · 1 AP" % unit["basic_attack"], "enabled": ready and has_ap and loaded})
	if melee or not class_combat.enabled:
		actions.append({"id": "melee", "label": "Melee · 1 AP [J]", "enabled": ready and can_use_loadout_action(idx, "melee")})
	if not melee:
		actions.append({"id": "reload", "label": "%s · %d AP [X]" % [reload_name, RELOAD_AP_COST],
			"enabled": ready and has_ap and refilling})
		var overwatch_reason := overwatch_unavailable(idx)
		actions.append({"id": "overwatch", "label": "Overwatch · %d AP per shot [O]" % OVERWATCH_SHOT_AP,
			"enabled": ready and overwatch_reason.is_empty(), "reason": overwatch_reason})
	actions.append({"id": "medkit", "label": "Medkit · %d left · 1 AP [K]" % unit["medkit_charges"],
		"enabled": ready and can_use_loadout_action(idx, "medkit")})
	if class_combat.enabled:
		for entry in class_combat.actions(idx):
			var skill: String = entry["skill"]
			var mode: String = entry["mode"]
			var caption: String = skill if mode.is_empty() else "%s / %s" % [skill, mode]
			var blocked: String = class_combat.unavailable(idx, skill, mode)
			actions.append({"id": "class", "label": "%s · %d AP" % [caption, entry["ap"]],
				"enabled": ready and blocked.is_empty(), "skill": skill, "mode": mode,
				"reason": blocked, "symbol": action_initials(mode if not mode.is_empty() else skill)})
		if headquarters.campaign.mission.get("emergency_reload", false) and not melee:
			actions.append({"id": "emergency", "label": "Emergency Reload · %d Intel [G]" % Headquarters.State.RELOAD_COST,
				"enabled": ready and refilling and headquarters.campaign.intel >= Headquarters.State.RELOAD_COST})
	else:
		actions.append({"id": "signature", "label": "%s · %d AP" % [unit["special"], special_cost(idx)],
			"enabled": ready and special_available(idx), "reason": "" if special_available(idx) else special_unavailable_message(idx),
			"symbol": action_initials(unit["special"])})
		if operative_kit(idx) == 1:
			actions.append({"id": "breach", "label": "Breach · 1 AP [B]", "enabled": ready and has_ap})
	return actions

func action_initials(label: String) -> String:
	var words := label.split(" ", false)
	return (words[0].left(1) + words[1].left(1)).to_upper() if words.size() > 1 else label.left(2).to_upper()

func action_is_selected(action: Dictionary, idx: int) -> bool:
	match action["id"]:
		"signature": return special_mode
		"breach": return breach_target_mode
		"class": return class_combat.actor == idx and class_combat.ability == action["skill"] and class_combat.mode == action["mode"]
		_: return loadout_action == action["id"]

func draw_operative_actions(idx: int) -> Dictionary:
	var actions: Array[Dictionary] = operative_actions(idx)
	var inspected: Dictionary = {}
	var armed: Dictionary = {}
	for index in range(actions.size()):
		var action: Dictionary = actions[index]
		var rect: Rect2 = action_button_rect(index)
		var selected: bool = action_is_selected(action, idx)
		var hover: bool = rect.has_point(hud_cursor)
		var holding_overwatch: bool = action["id"] == "overwatch" and units[idx]["reaction_available"]
		var ink: Color = ACTION_YELLOW if action["enabled"] or selected or holding_overwatch else Color("#9b8953")
		draw_rect(rect, ACTION_YELLOW if selected else (Color("#45402b") if hover else Color("#252720")))
		draw_rect(rect, ink if hover or selected or holding_overwatch else ink.darkened(0.36), false)
		draw_action_symbol(action, rect.get_center(), Color("#282516") if selected else ink)
		if holding_overwatch:
			draw_circle(rect.end - Vector2(7, 7), 2, HUD_ACCENT)
		if hover:
			inspected = action
		if selected:
			armed = action
	return armed if inspected.is_empty() else inspected

func operative_action_detail(action: Dictionary, idx: int) -> String:
	var unit: Dictionary = units[idx]
	match action["id"]:
		"shoot":
			return "%d base damage · %d tile range · %d/%d %s" % [unit["damage"], unit["range"],
				unit["rounds"], unit["magazine_capacity"], "charges" if unit.has("class_build") else "rounds"]
		"melee":
			if unit.has("class_build"):
				return "Strike for %d base damage. An approach to a reachable enemy is included in the action." % unit["damage"]
			return "Strike an adjacent enemy with the fixture melee attack."
		"reload":
			return "Refill the ranged weapon to %d. Current supply %d/%d." % [unit["magazine_capacity"], unit["rounds"], unit["magazine_capacity"]]
		"overwatch":
			return "Aim a reaction cone. The operative holds position and spends one round or charge per shot."
		"medkit":
			return "Heal up to %d HP on yourself or an adjacent ally, up to their current healing cap." % StarterLoadouts.MEDKIT_HP
		"emergency":
			return "Use the prepared stratagem to refill this operative's ranged supply."
		"breach":
			return "Rush up to four tiles in a straight line, breaking cover and knocking back enemies in the path."
		"class":
			return class_combat.action_detail(idx, action["skill"])
		"signature":
			var info: Array[String] = ability_description(idx)
			return info[1] + " " + info[2]
	return ""

func draw_action_symbol(action: Dictionary, c: Vector2, ink: Color) -> void:
	match action["id"]:
		"shoot":
			draw_circle(c, 7, ink, false, 1.5, true)
			for direction in [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]:
				draw_line(c + direction * 5, c + direction * 10, ink, 1.6, true)
			draw_circle(c, 1.7, ink)
		"overwatch":
			draw_polyline(PackedVector2Array([c + Vector2(-10, 0), c + Vector2(-5, -4),
				c + Vector2(0, -6), c + Vector2(5, -4), c + Vector2(10, 0), c + Vector2(5, 4),
				c + Vector2(0, 6), c + Vector2(-5, 4), c + Vector2(-10, 0)]), ink, 1.5, true)
			draw_circle(c, 2.8, ink)
		"reload", "emergency":
			draw_arc(c, 7, 0.05, TAU * 0.80, 18, ink, 1.8, true)
			draw_colored_polygon(PackedVector2Array([c + Vector2(3, -10), c + Vector2(5, -3), c + Vector2(-2, -5)]), ink)
			if action["id"] == "emergency":
				draw_circle(c, 2, ink)
		"melee":
			draw_line(c + Vector2(-7, 7), c + Vector2(8, -8), ink, 3, true)
			draw_line(c + Vector2(-7, 0), c + Vector2(0, 7), ink, 2, true)
		"medkit":
			draw_rect(Rect2(c - Vector2(8, 6), Vector2(16, 13)), ink, false, 1.5)
			draw_line(c - Vector2(4, 0), c + Vector2(4, 0), ink, 2)
			draw_line(c - Vector2(0, 4), c + Vector2(0, 4), ink, 2)
		"breach":
			draw_line(c + Vector2(-9, 0), c + Vector2(9, 0), ink, 2, true)
			draw_polyline(PackedVector2Array([c + Vector2(3, -6), c + Vector2(9, 0), c + Vector2(3, 6)]), ink, 2, true)
		_:
			var symbol: String = action["symbol"]
			var width: float = ThemeDB.fallback_font.get_string_size(symbol, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x
			draw_label(symbol, c + Vector2(-width * 0.5, 4), 12, ink)

func handle_operative_action_click(point: Vector2) -> bool:
	var action: Dictionary = operative_action_at(point)
	if action.is_empty():
		return false
	if action["enabled"]:
		use_operative_action(action["id"], action)
	return true

func use_operative_action(action: String, entry: Dictionary = {}) -> void:
	var idx: int = find_unit_by_id(selected_id)
	if idx < 0 or units[idx]["hp"] <= 0:
		return
	if action != "class":
		class_combat.cancel()
	match action:
		"melee", "medkit":
			toggle_loadout_action(action)
		"reload":
			reload_selected_weapon()
		"emergency":
			emergency_reload()
		"overwatch":
			var unavailable: String = overwatch_unavailable(idx)
			if unavailable.is_empty():
				loadout_action = "" if loadout_action == "overwatch" else "overwatch"
				special_mode = false
				breach_target_mode = false
				shred_landing_tile = Vector2i(-1, -1)
				status_message = "Aim and click to set Overwatch. Esc cancels." if loadout_action == "overwatch" else "Overwatch targeting cancelled."
			else:
				status_message = unavailable
		"shoot":
			loadout_action = "" if loadout_action == "shoot" else "shoot"
			special_mode = false
			breach_target_mode = false
			shred_landing_tile = Vector2i(-1, -1)
			status_message = "Click a target for a ranged attack (1 AP)." if loadout_action == "shoot" else "Ranged targeting cancelled."
		"breach":
			if operative_kit(idx) == 1:
				loadout_action = ""
				breach_target_mode = not breach_target_mode
				special_mode = false
				shred_landing_tile = Vector2i(-1, -1)
				status_message = "Breach: choose a straight-line destination" if breach_target_mode else "Breach targeting cancelled."
		"signature":
			if special_available(idx):
				loadout_action = ""
				special_mode = not special_mode
				breach_target_mode = false
				shred_landing_tile = Vector2i(-1, -1)
				status_message = "Select a target for %s." % units[idx]["special"] if special_mode else "Ability targeting cancelled."
				if special_mode and operative_kit(idx) == 0:
					status_message = "Area Shred: choose a landing tile within 3 steps."
		"class":
			loadout_action = ""
			class_combat.arm_action(idx, entry["skill"], entry["mode"])
	queue_redraw()

func developer_options() -> Array[Dictionary]:
	var options: Array[Dictionary] = [
		{"id": "ledger", "label": "Hit ledger [L]", "checked": show_hit_ledger},
		{"id": "links", "label": "Attack links [F]", "checked": show_firing_range},
		{"id": "facing", "label": "Unit facing arrows", "checked": show_facing_arrows},
		{"id": "threat", "label": "Enemy threat [H]", "checked": show_enemy_threat},
		{"id": "debug", "label": "AI debug decisions", "checked": ai_debug_enabled}]
	if not hq_deployment:
		options.push_front({"id": "restart", "label": "Restart fixture [R]"})
		options.push_front({"id": "missions", "label": "Test missions [M]"})
		options.append({"id": "armour", "label": "Armour · restarts mission", "checked": armour_enabled})
		options.append({"id": "ai", "label": "Tactical AI · restarts mission", "checked": smart_ai_enabled})
		for stage in range(ROOM_COUNT):
			options.append({"id": "room", "label": "Jump to room %d [F%d]" % [stage + 1, stage + 6], "stage": stage})
	if game_over:
		options.append({"id": "report", "label": "Mission report [V]", "checked": show_report})
		options.append({"id": "activity", "label": "Room activity [P]", "checked": show_room_activity and show_report})
	options.append({"id": "tier_mix", "label": "Enemy tier mix", "checked": show_enemy_tier_mix})
	options.append({"id": "combat_log", "label": "Combat log", "checked": show_combat_log})
	return options

func developer_option_rect(index: int) -> Rect2:
	return Rect2(HUD_RAIL.position.x, DEVELOPER_BUTTON.end.y + 5 + index * 28, HUD_RAIL.size.x, 28)

func draw_developer_menu() -> void:
	if not developer_menu_open:
		return
	var options: Array[Dictionary] = developer_options()
	for index in range(options.size()):
		var rect: Rect2 = developer_option_rect(index)
		var option: Dictionary = options[index]
		draw_rect(rect, Color("#345362") if rect.has_point(hud_cursor) else Color("#203447"))
		draw_rect(rect, Color("#48687d"), false, 1)
		if option.has("checked"):
			var box := Rect2(rect.position + Vector2(9, 8), Vector2(11, 11))
			draw_rect(box, Color("#aac5cf"), false, 1)
			if option["checked"]:
				draw_rect(box.grow(-2), Color("#9ed8b2"))
		draw_label(option["label"], rect.position + Vector2(28, 18), 13, Color("#e2edf3"))

func handle_developer_click(point: Vector2) -> bool:
	if DEVELOPER_BUTTON.has_point(point):
		developer_menu_open = not developer_menu_open
		pan_keys.clear()
		queue_redraw()
		return true
	if not developer_menu_open:
		return false
	developer_menu_open = false
	var options: Array[Dictionary] = developer_options()
	for index in range(options.size()):
		if developer_option_rect(index).has_point(point):
			use_developer_option(options[index])
			break
	queue_redraw()
	return true

func use_developer_option(option: Dictionary) -> void:
	match option["id"]:
		"missions":
			mission_picker_open = true
		"restart":
			restart_game()
		"tier_mix":
			show_enemy_tier_mix = not show_enemy_tier_mix
		"combat_log":
			show_combat_log = not show_combat_log
		"ledger":
			class_combat.cancel()
			show_hit_ledger = not show_hit_ledger
			ledger_scroll = 0
		"links":
			show_firing_range = not show_firing_range
		"facing":
			show_facing_arrows = not show_facing_arrows
		"threat":
			show_enemy_threat = not show_enemy_threat
		"debug":
			ai_debug_enabled = not ai_debug_enabled
		"armour":
			armour_enabled = not armour_enabled
			restart_game()
		"ai":
			smart_ai_enabled = not smart_ai_enabled
			restart_game()
		"room":
			dev_jump_to_room(option["stage"])
		"report":
			show_report = not show_report
		"activity":
			show_room_activity = not (show_room_activity and show_report)
			show_report = true
			activity_room_page = maxi(0, room_history.size() - 1)
	queue_redraw()

func draw_combat_header(show_navigation: bool, in_battle: bool = false) -> void:
	var title := "HAMMER & ASH"
	if in_battle:
		var room_name := mission_room_label(mission_stage).get_slice(" / ", 1)
		title = campaign_operation.get("label", room_name)
		if not campaign_operation.is_empty() and mission_room_total() > 1:
			draw_label(room_name.capitalize(), Vector2(25, 52), 12, HUD_MUTED)
		var phase: String = "Squad turn" if side_to_play == "player" else "Enemy turn"
		var room: String = "   ·   Room %d/%d" % [mission_stage + 1, mission_room_total()] if mission_room_total() > 1 else ""
		var phase_line: String = "%s   ·   Round %d%s" % [phase, turn_number, room]
		var width: float = ThemeDB.fallback_font.get_string_size(phase_line, HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x
		draw_label(phase_line, Vector2(572 - width * 0.5, 38), 16, HUD_ACCENT if side_to_play == "player" else Color("#efac9e"))
	var title_y := 34 if in_battle and not campaign_operation.is_empty() and mission_room_total() > 1 else 40
	draw_label(title, Vector2(24, title_y), 24, HUD_TEXT)
	if show_navigation:
		draw_rect(DEVELOPER_BUTTON, Color("#293c49") if DEVELOPER_BUTTON.has_point(hud_cursor) or developer_menu_open else HUD_SURFACE)
		draw_rect(DEVELOPER_BUTTON, HUD_LINE, false)
		draw_label("Development  ▾", DEVELOPER_BUTTON.position + Vector2(12, 22), 13, HUD_MUTED)

func draw_mission_objectives() -> void:
	draw_label("OBJECTIVES", Vector2(1158, 93), 12, HUD_MUTED)
	var primary: String = "Eliminate the enemy squad"
	match campaign_operation.get("kind", ""):
		"relay": primary = "Destroy the power generator"
		"rescue": primary = "Free both prisoners"
	draw_label(primary, Vector2(1158, 119), 16, HUD_TEXT)

	var progress: String = "%d enemies remaining" % alive_count("enemy")
	var detail := ""
	match test_mission_id:
		"chain":
			if mission_stage == 1:
				if radio_state.get("destroyed_in_time", false):
					detail = "Radio disabled · reinforcements prevented"
				elif radio_reinforcements_queued:
					detail = "Radio alert sent · 3 more hounds in Room 3"
				elif radio_is_active():
					detail = "Optional · Destroy radio by end of round 3 (%d/%d HP)" % [radio_state["hp"], RADIO_HP]
			elif mission_stage == 2 and radio_reinforcements_queued:
				detail = "Radio alert · 3 extra hounds deployed"
	if campaign_operation.get("kind", "") == "rescue":
		detail = get_objective_progress_line()
	elif campaign_operation.get("kind", "") == "relay" and objective_complete("generator"):
		detail = "Power generator destroyed."
	var lines: int = draw_wrapped_label(progress, Vector2(1158, 145), 266, 13, HUD_MUTED, 17, 2)
	var y: float = 151 + lines * 17
	for paragraph in detail.split("\n", false):
		y += draw_wrapped_label(paragraph, Vector2(1158, y), 266, 13, HUD_OBJECTIVE, 17, 3) * 17
	if show_enemy_tier_mix:
		var totals := [0, 0, 0, 0, 0]
		for unit in units:
			if unit["team"] == "enemy":
				totals[EnemyRoster.tier(unit)] += 1
		draw_label("Tier mix (spawned)", Vector2(1158, 570), 13, HUD_ACCENT)
		draw_label("Low %d   Mid %d   High %d   Mini %d   Boss %d" % totals,
			Vector2(1158, 590), 12, HUD_TEXT)
	draw_line(Vector2(1158, 223), Vector2(1424, 223), HUD_LINE)

func draw_hover_profile(idx: int, y: float) -> float:
	if idx >= 0:
		var unit: Dictionary = units[idx]
		if int(unit.get("recovery_round", 0)) > 0:
			draw_label("%s · Downed" % unit["name"], Vector2(1158, y), 17, HUD_OBJECTIVE)
			var recovery: String = "Returns at %d HP in round %d or on room clear." % [recoverable_hp(unit), unit["recovery_round"]]
			return y + 22 + draw_wrapped_label(recovery, Vector2(1158, y + 22), 266, 13, HUD_MUTED, 17, 2) * 17
		if unit["team"] == "enemy":
			var title_lines: int = draw_wrapped_label(unit["name"], Vector2(1158, y), 266, 17, Color("#efb0a2"), 20, 2)
			y += title_lines * 20
			draw_label("%s tier  /  %d XP" % [EnemyRoster.TIER_NAMES[EnemyRoster.tier(unit)],
				EnemyRoster.kill_xp(unit)], Vector2(1158, y), 13, HUD_ACCENT)
			y += 19
			draw_label(unit_vitals(unit), Vector2(1158, y), 13, HUD_TEXT)
			y += 19
			var profile: String = "%d dmg · Range %d · Move %d · Weight %d" % [unit["damage"], unit["range"], unit["move"], unit.get("weight", 2)]
			draw_label(profile, Vector2(1158, y), 12, HUD_MUTED)
			y += 18
			if int(unit["magazine_capacity"]) > 0:
				draw_label("Ammo %d/%d" % [unit["rounds"], unit["magazine_capacity"]], Vector2(1158, y), 12, HUD_MUTED)
				y += 18
			if unit.has("hint"):
				y += draw_wrapped_label("%s / %s. %s" % [unit["family"], unit["basic_attack"], unit["hint"]], Vector2(1158, y), 266, 12, EnemyRoster.COLORS[unit["family"]], 16, 4) * 16
			var effects: String = selected_status_text(idx)
			if effects != "None":
				y += draw_wrapped_label(effects, Vector2(1158, y), 266, 12, HUD_OBJECTIVE, 16, 3) * 16
			return y + 4
	if mission_object_at(hovered_tile):
		var obj: Dictionary = mission_objects[hovered_tile]
		if obj["kind"] in ["machine", "protect"]:
			draw_label("%d/%d HP" % [obj["hp"], obj["max_hp"]], Vector2(1158, y), 14, HUD_TEXT)
			return y + 21
	elif radio_is_active() and hovered_tile == RADIO_POS:
		draw_label("Radio transmitter · %d/%d HP" % [radio_state["hp"], RADIO_HP], Vector2(1158, y), 15, HUD_OBJECTIVE)
		return y + 21
	elif walls.has(hovered_tile):
		draw_label("Wall", Vector2(1158, y), 16, HUD_TEXT)
		draw_label("Blocks movement and line of sight.", Vector2(1158, y + 20), 13, HUD_MUTED)
		return y + 42
	return y

func draw_combat_hud(current_idx: int, hovered_idx: int, preview: String) -> void:
	var strip := Rect2(16, 742, 1428, 146)
	draw_rect(BattlefieldView.AREA, HUD_LINE, false)
	draw_rect(HUD_RAIL, HUD_SURFACE)
	draw_rect(strip, HUD_SURFACE)
	draw_mission_objectives()
	draw_squad_hud(current_idx)
	var inspected: Dictionary = draw_operative_actions(current_idx)
	if not inspected.is_empty():
		draw_line(Vector2(548, 756), Vector2(548, 874), HUD_LINE)
		draw_label(inspected["label"], Vector2(568, 784), 17, ACTION_YELLOW)
		var details := operative_action_detail(inspected, current_idx)
		var lines := draw_wrapped_label(details, Vector2(568, 807), 852, 14, HUD_TEXT, 18, 3)
		var reason: String = inspected.get("reason", "")
		if not reason.is_empty():
			draw_wrapped_label(reason, Vector2(568, 807 + lines * 18), 852, 13, HUD_MUTED, 17, 2)

	var y := 256.0
	var note: String = status_message
	if ability_aiming():
		draw_label("AIMING  ·  Esc to cancel", Vector2(1158, y), 13, HUD_ACCENT)
		y += 21
		if class_combat.actor >= 0:
			note = class_combat.aim_text()
	y = draw_hover_profile(hovered_idx, y)
	for paragraph in preview.split("\n", false):
		y += draw_wrapped_label(paragraph, Vector2(1158, y), 266, 13, HUD_TEXT, 18, 5) * 18
	if not note.is_empty():
		draw_wrapped_label(note, Vector2(1158, maxf(y + 12, 268)), 266, 13, HUD_MUTED, 17, 4)
	if ai_debug_enabled and not ai_last_decision.is_empty():
		draw_wrapped_label("AI · " + ai_last_decision, Vector2(1158, 552), 266, 11, HUD_OBJECTIVE, 14, 2)
	if show_combat_log:
		for i in range(mini(action_log.size(), 3)):
			draw_wrapped_label(action_log[i], Vector2(1158, 585 + i * 16), 266, 11, HUD_MUTED, 14, 1)

	if not high_ground_tiles.is_empty():
		var cover_x := 1158.0
		for item in [[SabotageVisuals.LIGHT_COVER, "Light"], [SabotageVisuals.REINFORCED_COVER, "High cover"]]:
			draw_line(Vector2(cover_x, 621), Vector2(cover_x + 10, 621), item[0], 3.0)
			draw_label(item[1], Vector2(cover_x + 15, 625), 11, HUD_MUTED)
			cover_x += 86
		draw_polyline(PackedVector2Array([Vector2(cover_x, 624), Vector2(cover_x + 5, 618),
			Vector2(cover_x + 10, 624)]), Color("#d9c38e"), 1.5, true)
		draw_label("High ground", Vector2(cover_x + 15, 625), 11, HUD_MUTED)
	draw_label("Wheel · Zoom    WASD / Middle drag · Pan", Vector2(1158, 645), 12, HUD_MUTED)
	draw_label("Q / E · Rotate    Home · Fit", Vector2(1158, 663), 12, HUD_MUTED)
	var turn_ready: bool = side_to_play == "player" and not game_over and movement_task.is_empty() and not unit_playback.busy()
	draw_rect(END_BUTTON, Color("#377760") if turn_ready else Color("#25343f"))
	if turn_ready and END_BUTTON.has_point(hud_cursor):
		draw_rect(END_BUTTON, HUD_ACCENT, false)
	draw_label("End turn", END_BUTTON.position + Vector2(14, 26), 16, HUD_TEXT if turn_ready else HUD_MUTED)
	draw_label("SPACE", END_BUTTON.position + Vector2(206, 26), 11, HUD_ACCENT if turn_ready else HUD_MUTED)

func _draw() -> void:
	draw_rect(Rect2(0, 0, 1460, 900), COMBAT_BACKGROUND)
	if mission_picker_open:
		draw_combat_header(false)
		draw_mission_picker()
		return
	if loadout_open:
		draw_combat_header(false)
		draw_loadout()
		return
	if room_cleared and not unit_playback.busy():
		draw_combat_header(true)
		draw_room_transition()
		draw_developer_menu()
		return
	var playing_final_effect: bool = unit_playback.busy() or not sabotage_visuals.effects.is_empty()
	if game_over and show_report and not playing_final_effect:
		draw_combat_header(true)
		if show_room_activity and not room_history.is_empty():
			draw_room_activity(room_history[clampi(activity_room_page, 0, room_history.size() - 1)], true)
		else:
			draw_battle_report()
		if show_hit_ledger:
			draw_hit_ledger()
		draw_developer_menu()
		return

	var current_idx: int = find_unit_by_id(selected_id)
	var current_kit: int = operative_kit(current_idx)
	var aiming_overwatch: bool = loadout_action == "overwatch" and current_idx >= 0
	var melee_preview: Dictionary = {}
	var melee_target: int = find_unit_at(hovered_tile)
	if not game_over and side_to_play == "player" and current_idx >= 0 and melee_target >= 0 \
			and units[melee_target]["team"] == "enemy" and not special_mode and not breach_target_mode \
			and class_combat.actor < 0 and int(units[current_idx]["hp"]) > 0:
		var fixture_melee: bool = loadout_action == "melee" and not units[current_idx].has("class_build")
		if loadout_action == "melee" or (loadout_action == "" and basic_is_melee(units[current_idx])):
			melee_preview = basic_melee_plan(current_idx, melee_target, fixture_melee)
	var movement_options: Dictionary = {}
	if not game_over and side_to_play == "player" and current_idx >= 0 and int(units[current_idx]["hp"]) > 0 and int(units[current_idx]["ap"]) > 0:
		if special_mode and current_kit == 0 and shred_landing_tile.x < 0:
			movement_options = reachable(units[current_idx]["pos"], SHRED_CHARGE_DISTANCE, selected_id)
		elif not special_mode and loadout_action == "" and not voluntary_movement_locked(current_idx):
			movement_options = reachable(units[current_idx]["pos"], int(units[current_idx]["move"]), selected_id)

	var sabotage: bool = campaign_operation.get("kind", "") == "relay"
	var surface: Color = Color("#45443c") if sabotage else Color("#323d44")
	match str(campaign_operation.get("kind", "")):
		"patrol": surface = Color("#38433c")
		"rescue": surface = Color("#3d4149")
		"sweep": surface = [Color("#394448"), Color("#47433d"), Color("#444741")][clampi(mission_stage, 0, 2)]
	var backdrop: Rect2 = BattlefieldView.AREA
	draw_polygon(PackedVector2Array([backdrop.position, Vector2(backdrop.end.x, backdrop.position.y),
		backdrop.end, Vector2(backdrop.position.x, backdrop.end.y)]),
		PackedColorArray([Color("#202d35"), Color("#18242a"), Color("#0c141c"), Color("#111a23")]))
	draw_set_transform_matrix(battlefield.camera)
	battlefield.draw_board_sides(self)
	draw_set_transform_matrix(battlefield.ground)
	draw_rect(battlefield.tile_rect(Vector2i.ZERO, Vector2i(board_w, board_h)), surface.darkened(0.39))
	for y in range(board_h):
		for x in range(board_w):
			var tile := Vector2i(x, y)
			var r := Rect2(ORIGIN.x + x * TILE, ORIGIN.y + y * TILE, TILE - 1, TILE - 1)
			sabotage_visuals.draw_floor(self, r, tile, sabotage, surface)
			if movement_options.has(tile) and tile != units[current_idx]["pos"]:
				draw_rect(r.grow(-1), Color(0.23, 0.60, 0.81, 0.42) if special_mode else Color(0.14, 0.66, 0.45, 0.38))
				draw_rect(Rect2(r.position + Vector2(14, 28), Vector2(7, 2)), Color("#86bcd6") if special_mode else Color("#84c5a0"))
			if high_ground_tiles.has(tile):
				draw_rect(r.grow(-2), Color(0.7, 0.63, 0.43, 0.32))
				var center := r.get_center()
				draw_polyline(PackedVector2Array([center + Vector2(-6, 3), center + Vector2(0, -3),
					center + Vector2(6, 3)]), Color("#d9c38e"), 1.5, true)
			if hazards.has(tile):
				draw_hazard_tile(r, str(hazards[tile]["kind"]))

	for idx in range(units.size()):
		var unit: Dictionary = units[idx]
		if unit["reaction_available"] and int(unit["hp"]) > 0 and overwatch_shots(idx) > 0:
			draw_overwatch_cone(unit.get("overwatch_tiles", {}), Color("#78d9fc") if unit["team"] == "player" else Color("#ff9274"))
	if aiming_overwatch and is_in_bounds(hovered_tile):
		draw_overwatch_cone(overwatch_cone(current_idx, hovered_tile), Color("#b2efff"), true)

	var path_destination: Vector2i = melee_preview.get("landing", Vector2i(-1, -1))
	if not special_mode and not breach_target_mode and class_combat.actor < 0 and movement_options.has(hovered_tile):
		path_destination = hovered_tile
	var hovered_path: Array[Vector2i] = []
	if path_destination.x >= 0:
		var previous: Vector2 = unit_board_center(current_idx)
		hovered_path = movement_path(current_idx, path_destination)
		for step in hovered_path:
			var footprint: Rect2i = unit_footprint(units[current_idx], step)
			var point: Vector2 = battlefield.tile_rect(step, footprint.size).get_center()
			draw_line(previous, point, Color("#b5eacd"), 2.0)
			draw_circle(point, 3.0, Color("#b5eacd"))
			previous = point
	draw_hover_enemy_threat()
	if special_mode and current_kit == 0:
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
		draw_cover_edges(cover_rect, cover_tile, cover_edges[cover_tile])
	draw_rect(Rect2(ORIGIN, Vector2(board_w * TILE, board_h * TILE)), Color("#748286"), false, 1.5)

	if show_firing_range and current_idx >= 0 and side_to_play == "player" and not special_mode and not breach_target_mode and loadout_action != "melee":
		draw_base_attack_links(current_idx)
	if class_combat.enabled:
		class_combat.draw_board_zones()
	draw_set_transform_matrix(battlefield.camera)
	draw_battle_depth(sabotage)
	var ability_detail: String = class_combat.draw_board_targeting() if class_combat.enabled else ""
	if current_idx >= 0 and movement_options.has(hovered_tile) and hovered_tile != units[current_idx]["pos"]:
		var destination_size: Vector2i = unit_footprint(units[current_idx], hovered_tile).size
		if destination_size.x > 1:
			draw_rect(battlefield.tile_rect(hovered_tile, destination_size).grow(-2), Color("#ffe7a0"), false, 2.0)
	# Draw Breach atop units so too-heavy targets show an unambiguous red X.
	if breach_target_mode and current_kit == 1:
		draw_sentinel_breach_preview()
	draw_set_transform_matrix(battlefield.camera)
	sabotage_visuals.draw_effects(self, battlefield)
	draw_damage_floaters()
	draw_set_transform_matrix(Transform2D.IDENTITY)
	battlefield.mask_outside(self, COMBAT_BACKGROUND)
	draw_combat_header(true, true)
	var hovered_idx: int = find_unit_at(hovered_tile, true)
	var preview_text := ""

	if aiming_overwatch:
		preview_text = "Click to set this cone · Up to %d shots at 1 AP and 1 ammo each · Holds position" % overwatch_shots(current_idx)
	elif current_kit == 1 and breach_target_mode:
		var breach_data: Dictionary = breach_plan(hovered_tile)
		if bool(breach_data["valid"]):
			var structural: int = breach_data["edges"].size()
			var target: int = int(breach_data["enemy"])
			hovered_path.assign(breach_data["path"])
			preview_text = "BREACH 1 AP: %d steps / %d barriers. %s" % [breach_data["path"].size(), structural, "5 DMG + displacement" if target >= 0 else "Clear landing"]
		else:
			preview_text = "BREACH INVALID: " + str(breach_data["reason"])
	elif current_idx >= 0 and barrel_is_active(hovered_tile):
		var barrel_info: Dictionary = barrel_preview(current_idx, hovered_tile)
		preview_text = "%s BARREL: %s. Blast + knockback up to 2 tiles; 3-round hazard." % [str(barrels[hovered_tile]["kind"]).to_upper(), str(barrel_info["reason"])]
	elif current_idx >= 0 and special_mode and current_kit == 0:
		if shred_landing_tile.x < 0:
			var options: Dictionary = reachable(units[current_idx]["pos"], SHRED_CHARGE_DISTANCE, selected_id)
			preview_text = "Area Shred: select landing (%d/3 steps), then choose an attack direction." % int(options[hovered_tile]) if options.has(hovered_tile) else "Area Shred: click a blue landing tile (0–3 steps)."
			if options.has(hovered_tile):
				hovered_path = movement_path(current_idx, hovered_tile, 0)
		else:
			hovered_path = movement_path(current_idx, shred_landing_tile, 0)
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
			if units[current_idx].has("class_build"):
				objective_hint = object_attack_preview(current_idx, hovered_tile)["reason"]
			else:
				objective_hint = "Shoot or strike machine (1 AP)" if has_attack_ammo(current_idx) else "Magazine empty. Move adjacent to strike or reload [X]."
		preview_text = "%s — %s" % [str(mission_objects[hovered_tile]["label"]), objective_hint]
	elif current_idx >= 0 and radio_is_active() and hovered_tile == RADIO_POS:
		var objective_preview: Dictionary = radio_attack_preview(current_idx)
		preview_text = objective_preview["reason"]
		if objective_preview["valid"]:
			preview_text += " · %d HP damage" % int(objective_preview["damage"])
	elif not melee_preview.is_empty():
		if melee_preview["valid"]:
			var steps: int = hovered_path.size()
			var action: String = "Melee · 1 AP" if steps == 0 else "Move %d + melee · 1 AP total" % steps
			preview_text = "%s\n%d ARM / %d HP damage" % [action, melee_preview["armour_damage"], melee_preview["hp_damage"]]
			if int(melee_preview.get("armour_cap_loss", 0)) > 0:
				preview_text += " · −%d max ARM" % int(melee_preview["armour_cap_loss"])
			if steps > 0:
				preview_text += " before hazards and reactions"
		else:
			preview_text = melee_preview["reason"]
	elif current_idx >= 0 and hovered_idx >= 0 and units[hovered_idx]["team"] == "enemy":
		var bonus: int = 2 if special_mode and current_kit == 2 else (1 if special_mode and current_kit == 3 else 0)
		var pierce: int = 1 if special_mode and current_kit == 2 else 0
		var preview: Dictionary = attack_preview(current_idx, hovered_idx, bonus, pierce, bonus == 0)
		if bool(preview["valid"]):
			preview_text = "Attack · %d ARM / %d HP damage\n%d base − %d cover = %d impact" % [int(preview["armour_damage"]), int(preview["hp_damage"]), int(preview["base"]), int(preview["cover"]), int(preview["damage"])]
		else:
			preview_text = str(preview["reason"])
			if preview.get("blocked_by_cover", false):
				preview_text += " · 0 damage · spends AP and ammo"
	elif hazards.has(hovered_tile):
		var hh: Dictionary = hazards[hovered_tile]
		var effect_text: String = "Applies Burning" if hh["kind"] == "fire" else "Applies Shocked"
		if hh["kind"] == "radiation":
			effect_text = "Applies Irradiated · 1 direct HP per tick"
		preview_text = "%s HAZARD · %s\n1 damage when applied · %d rounds left" % [str(hh["kind"]).to_upper(), effect_text, maxi(0, int(hh["expires_round"]) - turn_number)]
	elif not hovered_path.is_empty():
		preview_text = "Move %d %s · 1 AP" % [hovered_path.size(), "tile" if hovered_path.size() == 1 else "tiles"]
	if loadout_action == "medkit":
		preview_text = "Medkit: heal up to %d HP on yourself or an adjacent ally (1 AP)." % StarterLoadouts.MEDKIT_HP
	if not ability_detail.is_empty():
		preview_text = ability_detail
	elif not hovered_path.is_empty() and side_to_play == "player" and not game_over:
		var shots: int = expected_overwatch_shots(current_idx, hovered_path)
		preview_text += "\nOverwatch · %d expected %s" % [shots, "shot" if shots == 1 else "shots"]
	draw_combat_hud(current_idx, hovered_idx, preview_text)
	if game_over and not playing_final_effect:
		draw_rect(Rect2(338, 313, 468, 134), Color("#0d1c29"), true)
		draw_rect(Rect2(338, 313, 468, 134), Color("#edce93"), false, 2.0)
		var heading: String = "MISSION COMPLETE" if mission_victory else "MISSION FAILED"
		var subheading: String = ("ALL %d ROOMS CLEARED" % mission_room_total()) if mission_victory else mission_failure_reason.to_upper()
		var heading_width: float = ThemeDB.fallback_font.get_string_size(heading, HORIZONTAL_ALIGNMENT_LEFT, -1, 25).x
		var subheading_width: float = ThemeDB.fallback_font.get_string_size(subheading, HORIZONTAL_ALIGNMENT_LEFT, -1, 19).x
		draw_label(heading, Vector2(572.0 - heading_width * 0.5, 360), 25, Color("#f6dba1"))
		draw_label(subheading, Vector2(572.0 - subheading_width * 0.5, 388), 19, Color("#e9f1f5"))
		draw_label("After-action report [V]", Vector2(500, 420), 13, HUD_MUTED)
	if show_hit_ledger:
		draw_hit_ledger()
	draw_developer_menu()
