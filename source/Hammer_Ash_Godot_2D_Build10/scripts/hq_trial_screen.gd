extends CanvasLayer

const State = preload("res://scripts/hq_trial_state.gd")
const Loadouts = preload("res://scripts/starter_loadouts.gd")
const Art = preload("res://scripts/personnel_art.gd")
const PlayerClasses = preload("res://scripts/player_classes.gd")
const ClassCombat = preload("res://scripts/class_combat.gd")
const OriginAvatars = preload("res://scripts/origin_avatars.gd")
const USSRMap = preload("res://scripts/ussr_map.gd")
const Operations = preload("res://scripts/campaign_operations.gd")
const TABS: Array[String] = ["USSR", "Personnel", "Workshop", "Research"]
const RESEARCH_TITLES: Dictionary = {"Stratagems": "Stratagems", "Intelligence Ops": "Intelligence Operations"}

signal deployed(operation: String)

var campaign: State = State.new()
var surface: PanelContainer
var body: VBoxContainer
var tab: String = "USSR"
var operation: String = ""
var region: int = -1
var preparing_squad: bool = false
var viewing_intel: bool = false
var squad: Array[int] = []
var draft_gear: Dictionary = {}
var draft_profiles: Dictionary = {}
var prepare_reload: bool = false
var selected_operative: int = 0
var personnel_operative: int = 0
var sort_by_type: bool = true
var kit_profiles: Dictionary = {}
var recruit_class: String = ""

func _ready() -> void:
	layer = 2
	hide()

func open() -> void:
	tab = "USSR"
	show()
	refresh()

func go_back() -> void:
	if tab != "USSR":
		select_tab("USSR")
	elif preparing_squad:
		return_to_briefing()
	elif viewing_intel:
		toggle_intel()
	elif not operation.is_empty():
		select_operation("")
	elif region >= 0:
		select_region(-1)
	else:
		return
	refresh()

func refresh(keep_scroll: bool = false) -> void:
	var scroll_position := 0
	if keep_scroll and is_instance_valid(body):
		scroll_position = (body.get_parent() as ScrollContainer).scroll_vertical
	if is_instance_valid(surface):
		remove_child(surface)
		surface.queue_free()
	surface = PanelContainer.new()
	add_child(surface)
	surface.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	surface.theme = make_theme()
	var frame := MarginContainer.new()
	for side in ["top", "bottom", "left", "right"]:
		frame.add_theme_constant_override("margin_" + side, 54 if side in ["left", "right"] else 32)
	surface.add_child(frame)
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 14)
	frame.add_child(layout)
	var header := HBoxContainer.new()
	layout.add_child(header)
	line(header, "Resistance Bunker", 32).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line(layout, "Day %d    ·    Supplies %d    ·    Intel %d    ·    %d ready / %d operatives" % [
		campaign.day, campaign.supplies, campaign.intel, ready_count(), campaign.roster.size()], 19)
	var navigation := HBoxContainer.new()
	navigation.add_theme_constant_override("separation", 32)
	layout.add_child(navigation)
	var toolbar := HBoxContainer.new()
	toolbar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	navigation.add_child(toolbar)
	for name_text in TABS:
		action(toolbar, name_text, select_tab.bind(name_text), tab == name_text)
	if tab == "Workshop":
		line(navigation, "Equipment inventory", 23).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	layout.add_child(scroll)
	body = VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 8)
	scroll.add_child(body)
	if scroll_position > 0:
		scroll.set_deferred("scroll_vertical", scroll_position)
	match tab:
		"USSR": show_ussr()
		"Personnel": show_personnel()
		"Workshop": show_workshop()
		"Research": show_research()
	var footer := HBoxContainer.new()
	layout.add_child(footer)
	line(footer, job_summary()).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	action(footer, "Debug: Advance Day", campaign.advance_day)

func make_theme() -> Theme:
	var style := Theme.new()
	style.default_font_size = 17
	var background := StyleBoxFlat.new()
	background.bg_color = Color("#172223")
	style.set_stylebox("panel", "PanelContainer", background)
	var button := StyleBoxFlat.new()
	button.bg_color = Color("#2c4440")
	button.content_margin_left = 15
	button.content_margin_right = 15
	button.content_margin_top = 6
	button.content_margin_bottom = 6
	style.set_stylebox("normal", "Button", button)
	var hover: StyleBoxFlat = button.duplicate()
	hover.bg_color = Color("#416155")
	style.set_stylebox("hover", "Button", hover)
	var disabled: StyleBoxFlat = button.duplicate()
	disabled.bg_color = Color("#263030")
	style.set_stylebox("disabled", "Button", disabled)
	style.set_color("font_color", "Label", Color("#e3ebdd"))
	return style

func action(parent: Control, title: String, callback: Callable, disabled: bool = false) -> Button:
	var button := Button.new()
	button.text = title
	button.disabled = disabled
	button.pressed.connect(run_action.bind(callback))
	parent.add_child(button)
	return button

func run_action(callback: Callable) -> void:
	var loadout_operation := operation if tab == "USSR" and preparing_squad else ""
	callback.call()
	if visible:
		refresh.call_deferred(not loadout_operation.is_empty() and operation == loadout_operation
			and tab == "USSR" and preparing_squad)

func line(parent: Control, value: String, size: int = 17) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size", size)
	parent.add_child(label)
	return label

func row() -> HBoxContainer:
	var entry := HBoxContainer.new()
	entry.add_theme_constant_override("separation", 16)
	body.add_child(entry)
	return entry

func select_tab(name_text: String) -> void:
	tab = name_text

func ready_count() -> int:
	var count: int = 0
	for id in campaign.roster:
		if campaign.available(id):
			count += 1
	return count

func job_summary() -> String:
	var active_project: String = "Research idle"
	if not campaign.research.is_empty():
		active_project = "%s due day %d" % [State.PROJECTS[campaign.research["id"]]["label"], campaign.research["finish"]]
	var active_recruit: String = "Recruitment idle"
	if not campaign.recruitment.is_empty():
		active_recruit = "%s recruit due day %d" % [campaign.recruitment["kit"], campaign.recruitment["finish"]]
	return "%s    ·    %s" % [active_project, active_recruit]

func show_ussr() -> void:
	if preparing_squad:
		show_loadout()
		return
	var heading := row()
	if region < 0:
		line(heading, "Russia / Federal districts", 26).size_flags_horizontal = Control.SIZE_EXPAND_FILL
		show_country_map()
	else:
		line(heading, USSRMap.DISTRICTS[region]["name"], 26).size_flags_horizontal = Control.SIZE_EXPAND_FILL
		action(heading, "Back to Russia", select_region.bind(-1))
		show_district_map()
	if not campaign.debrief.is_empty():
		line(body, "Latest operation report", 22)
		for entry in campaign.debrief:
			line(body, entry)

func map_sidebar(columns: HBoxContainer) -> VBoxContainer:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#1c2b2c")
	style.border_color = Color("#3b5150")
	style.set_border_width_all(1)
	for side in [SIDE_LEFT, SIDE_RIGHT, SIDE_TOP, SIDE_BOTTOM]:
		style.set_content_margin(side, 16)
	panel.add_theme_stylebox_override("panel", style)
	columns.add_child(panel)
	var sidebar := VBoxContainer.new()
	sidebar.custom_minimum_size.x = 296
	sidebar.add_theme_constant_override("separation", 10)
	panel.add_child(sidebar)
	return sidebar

func show_country_map() -> void:
	var columns := row()
	var map := USSRMap.new()
	map.configure(-1, {})
	map.district_selected.connect(func(index: int) -> void: run_action(select_region.bind(index)))
	columns.add_child(map)
	var sidebar := map_sidebar(columns)
	line(sidebar, "Select a district", 20)
	for index in range(USSRMap.DISTRICTS.size()):
		var entry: Dictionary = USSRMap.DISTRICTS[index]
		var item := HBoxContainer.new()
		sidebar.add_child(item)
		var swatch := ColorRect.new()
		swatch.color = entry["colour"]
		swatch.custom_minimum_size = Vector2(10, 0)
		swatch.mouse_filter = Control.MOUSE_FILTER_IGNORE
		item.add_child(swatch)
		var locked: bool = entry["id"] == Operations.MOSCOW_DISTRICT
		var title: String = "Moscow · Locked" if locked else entry["name"]
		var button := action(item, title, select_region.bind(index), locked)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL

func show_district_map() -> void:
	var columns := row()
	var map := USSRMap.new()
	var district_id: String = USSRMap.DISTRICTS[region]["id"]
	var sites := Operations.in_district(district_id)
	var markers: Dictionary = {}
	for id in sites:
		var site := Operations.operation(id)
		var button := action(map, site["pin"], select_operation.bind(id))
		button.tooltip_text = site["label"]
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		var pin_style := StyleBoxFlat.new()
		pin_style.bg_color = Color("#172526")
		pin_style.border_color = Color("#e3bb75") if operation == id else Color("#61766d")
		pin_style.set_border_width_all(1)
		pin_style.set_corner_radius_all(3)
		pin_style.content_margin_left = 28
		pin_style.content_margin_right = 10
		pin_style.content_margin_top = 6
		pin_style.content_margin_bottom = 6
		button.add_theme_stylebox_override("normal", pin_style)
		var hover_style: StyleBoxFlat = pin_style.duplicate()
		hover_style.bg_color = Color("#344a42")
		button.add_theme_stylebox_override("hover", hover_style)
		button.add_theme_stylebox_override("pressed", hover_style)
		button.draw.connect(draw_mission_pin.bind(button, operation == id))
		markers[id] = {"button": button, "point": site["point"]}
	map.configure(region, markers)
	columns.add_child(map)
	var sidebar := map_sidebar(columns)
	if operation.is_empty():
		line(sidebar, "Available missions", 20)
		for id in sites:
			action(sidebar, Operations.operation(id)["label"], select_operation.bind(id))
		return
	var mission := Operations.operation(operation)
	line(sidebar, mission["label"], 28)
	wrapped_line(sidebar, mission["brief"])
	var actions := HBoxContainer.new()
	sidebar.add_child(actions)
	action(actions, "Deploy", begin_squad_preparation)
	action(actions, "Intel Op", toggle_intel)
	action(actions, "Back", select_operation.bind(""))
	if viewing_intel:
		sidebar.add_child(HSeparator.new())
		show_facility_recon(sidebar)

func draw_mission_pin(button: Button, selected: bool) -> void:
	var point := Vector2(15, roundf(button.size.y * 0.5))
	var colour := Color("#f5d792") if selected else Color("#d6ad6c")
	button.draw_colored_polygon(PackedVector2Array([point + Vector2(-5, 0), point + Vector2(5, 0), point + Vector2(0, 8)]), colour)
	button.draw_circle(point + Vector2(0, -2), 6, colour, true, -1, true)
	button.draw_circle(point + Vector2(0, -2), 2.2, Color("#172526"), true, -1, true)

func select_region(index: int) -> void:
	if index >= 0 and USSRMap.DISTRICTS[index]["id"] == Operations.MOSCOW_DISTRICT:
		return
	region = index
	select_operation("")

func select_operation(id: String) -> void:
	operation = id
	preparing_squad = false
	viewing_intel = false
	squad.clear()
	draft_gear.clear()
	draft_profiles.clear()
	selected_operative = 0
	prepare_reload = false

func begin_squad_preparation() -> void:
	preparing_squad = true

func return_to_briefing() -> void:
	preparing_squad = false

func toggle_intel() -> void:
	viewing_intel = not viewing_intel

func show_facility_recon(parent: VBoxContainer) -> void:
	if campaign.prepared_recon == operation:
		line(parent, "Facility Recon active", 18)
		wrapped_line(parent, Operations.operation(operation)["recon"])
		return
	var support := HBoxContainer.new()
	parent.add_child(support)
	action(support, "Facility Recon (%d Intel)" % State.RECON_COST, campaign.buy_recon.bind(operation),
		not campaign.unlocks.has("recon") or campaign.intel < State.RECON_COST or not campaign.prepared_recon.is_empty())
	if not campaign.unlocks.has("recon"):
		wrapped_line(parent, "Unlock Facility Recon in Research.")
	elif not campaign.prepared_recon.is_empty():
		wrapped_line(parent, "Recon already prepared for %s." % Operations.operation(campaign.prepared_recon)["label"])
	elif campaign.intel < State.RECON_COST:
		wrapped_line(parent, "Insufficient Intel.")

func show_loadout() -> void:
	var title: String = Operations.operation(operation)["label"]
	line(body, "%s / Squad loadout" % title, 26)
	var launch := row()
	action(launch, "Back to briefing", return_to_briefing)
	var can_launch: bool = campaign.can_deploy(operation, squad, draft_gear)
	action(launch, "Deploy", deploy, not can_launch)
	line(launch, "%d / %d operatives selected" % [squad.size(), State.SQUAD_SIZE])
	if squad.any(func(id: int) -> bool: return loadout_profile(id).has("playtest_level")):
		line(launch, "Manual level · XP paused", 15)
	if squad.size() == State.SQUAD_SIZE and not can_launch:
		line(launch, "Pack fewer medkits to fit available stock.")
	show_facility_recon(body)
	var stratagems := row()
	line(stratagems, "Stratagem")
	var stratagem := OptionButton.new()
	stratagem.add_item("None")
	stratagem.add_item("Emergency Reload")
	stratagem.set_item_disabled(1, not campaign.unlocks.has("reload"))
	stratagem.select(1 if prepare_reload else 0)
	stratagem.item_selected.connect(select_stratagem)
	stratagems.add_child(stratagem)
	var reload_detail: String = "%d Intel on use · Refills ranged charges · No AP · Once per operation [G]" % State.RELOAD_COST
	line(stratagems, reload_detail if campaign.unlocks.has("reload") else "Requires research")
	var columns := row()
	var roster_column := column(columns, 420)
	var equipment := column(columns, 450)
	equipment.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line(roster_column, "Squad", 22)
	for id in campaign.roster:
		if not campaign.available(id):
			continue
		var entry := HBoxContainer.new()
		roster_column.add_child(entry)
		var selected: bool = squad.has(id)
		var profile := loadout_profile(id)
		entry.add_child(origin_portrait(profile, 1))
		var identity := VBoxContainer.new()
		identity.custom_minimum_size.x = 178
		identity.add_theme_constant_override("separation", 0)
		entry.add_child(identity)
		line(identity, campaign.operative_name(id), 17)
		line(identity, "Lv %d · %s" % [profile["class_build"]["level"], origin_label(profile)], 13).modulate = Color("#b4c9c0")
		action(entry, "Remove" if selected else "Select", toggle_squad.bind(id),
			not selected and squad.size() == State.SQUAD_SIZE)
		if selected:
			action(entry, "Gear & build", inspect_operative.bind(id), selected_operative == id)
	if squad.has(selected_operative):
		var profile := loadout_profile(selected_operative)
		var build: Dictionary = profile["class_build"]
		var header := HBoxContainer.new()
		header.add_theme_constant_override("separation", 12)
		equipment.add_child(header)
		header.add_child(origin_portrait(profile, 2))
		var details := VBoxContainer.new()
		details.alignment = BoxContainer.ALIGNMENT_CENTER
		header.add_child(details)
		line(details, campaign.operative_name(selected_operative), 22)
		line(details, "Level %d · %s" % [int(build["level"]), origin_label(profile)], 16)
		if profile["kit"] == "Alkhimik" and int(build["origin"]) == 0:
			class_picker(equipment, "Starting form", PlayerClasses.FORMS,
				PlayerClasses.FORMS.find(build["form"]), change_form.bind(selected_operative, true))
		line(equipment, Loadouts.SUPERSUIT, 19)
		var attack: Dictionary = PlayerClasses.base_attack(profile["kit"], build, build["form"],
			kit_profiles[profile["kit"]]["damage"], kit_profiles[profile["kit"]]["range"])
		line(equipment, "%s · %d damage · %d tile%s" % [attack["name"], attack["damage"],
			attack["range"], "" if attack["melee"] else "s"])
		line(equipment, "Consumable")
		add_consumable_picker(equipment, selected_operative, draft_gear[selected_operative], true)
		var build_actions := HBoxContainer.new()
		equipment.add_child(build_actions)
		line(build_actions, "Build for this operation", 16).size_flags_horizontal = Control.SIZE_EXPAND_FILL
		action(build_actions, "Reset to Personnel", func(): draft_profiles.erase(selected_operative),
			not draft_profiles.has(selected_operative))
		show_class_path(equipment, selected_operative, profile["kit"], true)

func loadout_profile(id: int) -> Dictionary:
	return draft_profiles.get(id, campaign.roster[id])

func edit_profile(id: int, preparing: bool) -> Dictionary:
	if not preparing:
		return campaign.roster[id]
	if not draft_profiles.has(id):
		draft_profiles[id] = campaign.roster[id].duplicate(true)
	return draft_profiles[id]

func toggle_squad(id: int) -> void:
	if squad.has(id):
		squad.erase(id)
		draft_gear.erase(id)
		draft_profiles.erase(id)
		if selected_operative == id:
			selected_operative = 0 if squad.is_empty() else squad.back()
	elif campaign.available(id) and squad.size() < State.SQUAD_SIZE:
		squad.append(id)
		draft_gear[id] = campaign.roster[id]["consumable"]
		selected_operative = id

func select_stratagem(index: int) -> void:
	prepare_reload = index == 1

func deploy() -> void:
	if campaign.deploy(operation, squad, draft_gear, prepare_reload, draft_profiles):
		var deployed_operation: String = operation
		select_operation("")
		hide()
		deployed.emit(deployed_operation)

func inspect_operative(id: int) -> void:
	if tab == "Personnel":
		personnel_operative = id
	else:
		selected_operative = id

func set_sort(index: int) -> void:
	sort_by_type = index == 0
	refresh.call_deferred()

func roster_order(first: int, second: int) -> bool:
	var first_kit: String = campaign.roster[first]["kit"]
	var second_kit: String = campaign.roster[second]["kit"]
	if sort_by_type and first_kit != second_kit:
		return campaign.classes.find(first_kit) < campaign.classes.find(second_kit)
	return campaign.operative_name(first).naturalnocasecmp_to(campaign.operative_name(second)) < 0

func show_personnel() -> void:
	var ids: Array = campaign.roster.keys()
	ids.sort_custom(roster_order)
	if not ids.is_empty() and not campaign.roster.has(personnel_operative):
		personnel_operative = ids[0]
	var controls := row()
	var roster := OptionButton.new()
	roster.custom_minimum_size.x = 232
	roster.disabled = ids.is_empty()
	roster.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	for id in ids:
		var ready: String = "  ·  Recovering" if not campaign.available(id) else ""
		roster.add_icon_item(operative_avatar(campaign.roster[id]), campaign.operative_name(id) + ready, id)
	if not ids.is_empty():
		roster.select(roster.get_item_index(personnel_operative))
	roster.item_selected.connect(func(index: int) -> void:
		run_action(inspect_operative.bind(roster.get_item_id(index))))
	controls.add_child(roster)
	var sort := OptionButton.new()
	sort.add_item("Sort by Type")
	sort.add_item("Sort by Name")
	sort.select(0 if sort_by_type else 1)
	sort.item_selected.connect(set_sort)
	controls.add_child(sort)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	controls.add_child(spacer)
	var classes := OptionButton.new()
	for kit in campaign.classes:
		classes.add_item(kit)
	classes.select(maxi(0, campaign.classes.find(recruit_class)))
	classes.item_selected.connect(select_class)
	classes.tooltip_text = "Class of the next recruit"
	controls.add_child(classes)
	action(controls, "Train recruit · %d Supplies · %d days" % [State.RECRUIT_COST, State.RECRUIT_DAYS],
		train_recruit, not campaign.recruitment.is_empty() or campaign.supplies < State.RECRUIT_COST)
	if ids.is_empty():
		line(body, "No operatives in the roster.", 24)
		return

	var id: int = personnel_operative
	var kit: String = campaign.roster[id]["kit"]
	var columns := row()
	show_operative_card(bunker_panel(columns, 344, false), id)
	show_class_path(bunker_panel(columns, 495, true), id, kit)
	var equipment := bunker_panel(columns, 338, false)
	line(equipment, "Equipment", 24)
	show_personnel_gear(equipment, id, 0)
	show_personnel_gear(equipment, id, 1)
	equipment.add_child(HSeparator.new())
	show_operative_stats(equipment, id)

func bunker_panel(parent: HBoxContainer, width: float, expand: bool) -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size.x = width
	if expand:
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#20302f")
	style.border_color = Color("#536761")
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 15
	style.content_margin_right = 15
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	panel.add_theme_stylebox_override("panel", style)
	parent.add_child(panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	panel.add_child(content)
	return content

func show_operative_card(parent: VBoxContainer, id: int) -> void:
	var profile: Dictionary = campaign.roster[id]
	var tree: Dictionary = PlayerClasses.data(profile["kit"])
	var origin: Dictionary = tree["origins"][int(profile["class_build"]["origin"])]
	line(parent, campaign.operative_name(id), 25)
	line(parent, origin_label(profile), 17).modulate = Color(tree["color"])
	if profile["kit"] == "Alkhimik" and int(profile["class_build"]["origin"]) == 0:
		class_picker(parent, "Starting form", PlayerClasses.FORMS,
			PlayerClasses.FORMS.find(profile["class_build"]["form"]), change_form.bind(id))

	var portrait_frame := PanelContainer.new()
	var backdrop := StyleBoxFlat.new()
	backdrop.bg_color = Color("#142020").lerp(Color(tree["color"]), 0.07)
	backdrop.border_color = Color("#405753")
	backdrop.set_border_width_all(1)
	backdrop.set_corner_radius_all(6)
	portrait_frame.add_theme_stylebox_override("panel", backdrop)
	portrait_frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(portrait_frame)
	var portrait: TextureRect = origin_portrait(profile, 10)
	portrait.custom_minimum_size.y = 348
	portrait_frame.add_child(portrait)
	if origin.has("identity"):
		line(parent, str(origin["identity"]).capitalize(), 15).autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var ready: bool = campaign.available(id)
	var status: String = "Ready to deploy" if ready else "Recovering until day %d" % profile["ready_day"]
	line(parent, status, 15).modulate = Color("#a3d9b1") if ready else Color("#efbd82")

func show_operative_stats(parent: VBoxContainer, id: int) -> void:
	line(parent, "Current stats", 24)
	var stats := GridContainer.new()
	stats.columns = 2
	stats.add_theme_constant_override("h_separation", 14)
	stats.add_theme_constant_override("v_separation", 10)
	parent.add_child(stats)
	var profile: Dictionary = campaign.roster[id]
	var build: Dictionary = profile["class_build"]
	var equipped: Dictionary = kit_profiles[profile["kit"]].duplicate()
	Loadouts.equip(equipped, profile["consumable"])
	var skills: Dictionary = PlayerClasses.unlocked(profile["kit"], build)
	var modifiers: Vector2i = PlayerClasses.stat_modifiers(skills, build["form"])
	var attack: Dictionary = PlayerClasses.base_attack(profile["kit"], build, build["form"],
		equipped["damage"], equipped["range"])
	var values: Dictionary = {
		"Max HP": PlayerClasses.maximum_hp(build["level"], skills, equipped["supersuit_hp_bonus"]),
		"Protection": PlayerClasses.armour_capacity(equipped["max_armour"], modifiers.x, skills),
		"Action points": equipped["max_ap"], "Move": "%d tiles" % maxi(1, int(equipped["move"]) + modifiers.y),
		"Base attack": attack["name"],
		"Base damage": attack["damage"], "Attack range": attack["range"],
	}
	for stat in values:
		line(stats, stat, 15).size_flags_horizontal = Control.SIZE_EXPAND_FILL
		line(stats, str(values[stat]), 15).modulate = Color("#ebbe8e")

func origin_label(profile: Dictionary) -> String:
	var branch: Dictionary = PlayerClasses.data(profile["kit"])["origins"][int(profile["class_build"]["origin"])]
	return str(branch["name"])

func operative_avatar(profile: Dictionary, scale: int = 1) -> Texture2D:
	return OriginAvatars.texture(OriginAvatars.variant(profile["kit"], profile["class_build"]), scale)

func origin_portrait(profile: Dictionary, scale: int) -> TextureRect:
	var portrait := TextureRect.new()
	portrait.texture = operative_avatar(profile, scale)
	portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return portrait

func class_picker(parent: Control, caption: String, options: Array, selected: int, on_select: Callable,
		icons: Array[Texture2D] = []) -> void:
	var fields := HBoxContainer.new()
	fields.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(fields)
	line(fields, caption, 15)
	var picker := OptionButton.new()
	picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	picker.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	for index in range(options.size()):
		if icons.is_empty():
			picker.add_item(str(options[index]))
		else:
			picker.add_icon_item(icons[index], str(options[index]))
	picker.select(selected)
	picker.item_selected.connect(on_select)
	fields.add_child(picker)

func change_form(index: int, id: int, preparing: bool = false) -> void:
	edit_profile(id, preparing)["class_build"]["form"] = PlayerClasses.FORMS[index]
	refresh.call_deferred(preparing)

func change_class_build(index: int, id: int, field: String, level: int = 0, preparing: bool = false) -> void:
	var profile := edit_profile(id, preparing)
	var build: Dictionary = profile["class_build"]
	match field:
		"origin":
			build["origin"] = index
			build["choices"].clear()
		"level":
			campaign.set_playtest_level(id, index, profile)
		"choice":
			if level > int(build["level"]):
				return
			build["choices"][level] = index
	refresh.call_deferred(preparing)

func show_class_path(parent: VBoxContainer, id: int, kit: String, preparing: bool = false) -> void:
	parent.add_theme_constant_override("separation", 6)
	line(parent, "%s class path" % kit, 24)
	var tree: Dictionary = PlayerClasses.data(kit)
	var profile: Dictionary = loadout_profile(id) if preparing else campaign.roster[id]
	var build: Dictionary = profile["class_build"]
	var origin: int = int(build["origin"])
	var current_level: int = int(build["level"])
	line(parent, str(tree["role"]).capitalize(), 15).modulate = Color("#a6b9b0")
	var origins: Array = tree["origins"].map(func(branch: Dictionary) -> String:
		return str(branch["name"]))
	var icons: Array[Texture2D] = []
	for index in range(origins.size()):
		var preview: Dictionary = build.duplicate()
		preview["origin"] = index
		icons.append(OriginAvatars.texture(OriginAvatars.variant(kit, preview)))
	var build_controls := HBoxContainer.new()
	build_controls.add_theme_constant_override("separation", 12)
	parent.add_child(build_controls)
	class_picker(build_controls, "Origin", origins, origin, change_class_build.bind(id, "origin", 0, preparing), icons)
	var levels: Array = ["Earned"]
	levels.append_array(range(1, 10))
	class_picker(build_controls, "Dev level", levels, profile.get("playtest_level", 0),
		change_class_build.bind(id, "level", 0, preparing))
	var xp: int = campaign.roster[id].get("xp", 0)
	var earned_level: int = campaign.earned_level(id)
	var progress := "%d XP  •  Level %d" % [xp, earned_level]
	if earned_level < State.LEVEL_XP.size():
		progress += "  •  %d XP to Level %d" % [State.LEVEL_XP[earned_level] - xp, earned_level + 1]
	else:
		progress += "  •  Trial level cap"
	if profile.has("playtest_level"):
		progress += "  •  Manual level %d (deployment XP paused)" % current_level
	line(parent, progress, 14).modulate = Color("#a6b9b0")
	line(parent, "■ Active    ● Passive    ·    Hover for details", 14).modulate = Color("#a6b9b0")
	var graph := Art.ClassTree.new(Color(tree["color"]))
	var unlocked: Dictionary = PlayerClasses.unlocked(kit, build)
	for level in range(1, 10):
		var options: Array = PlayerClasses.nodes_at(kit, origin, level)
		var is_choice: bool = level > 1 and options.size() > 1
		var displayed: Array = []
		for node: Dictionary in options:
			var detail := node.duplicate()
			if node["type"] == "A" and not ClassCombat.supports_review_action(node["name"]):
				detail["rule"] = "Combat implementation pending."
			displayed.append(detail)
		var earned: bool = level <= current_level
		graph.add_level(displayed, unlocked, earned,
			change_class_build.bind(id, "choice", level, preparing) if is_choice else Callable())
	parent.add_child(graph)

func show_personnel_gear(parent: VBoxContainer, id: int, slot: int) -> void:
	var consumable: int = campaign.roster[id]["consumable"]
	parent.add_child(HSeparator.new())
	var entry := HBoxContainer.new()
	entry.add_theme_constant_override("separation", 12)
	parent.add_child(entry)
	entry.add_child(Art.EquipmentIcon.new(slot, slot == 0 or consumable == 0))
	var details := VBoxContainer.new()
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details.add_theme_constant_override("separation", 4)
	entry.add_child(details)
	if slot == 0:
		line(details, Loadouts.SUPERSUIT, 17).modulate = Color("#ebbe8e")
		line(details, Loadouts.SUPERSUIT_DETAIL, 15).autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		return
	line(details, "Consumable", 15).modulate = Color("#ebbe8e")
	add_consumable_picker(details, id, consumable, false)
	if consumable == 0:
		line(details, "%s · %d in stock" % [Loadouts.MEDKIT_DETAIL, campaign.medkits], 15).autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func add_consumable_picker(parent: VBoxContainer, id: int, consumable: int, preparing: bool) -> void:
	var options := OptionButton.new()
	for option in Loadouts.CONSUMABLES:
		options.add_item(option)
	options.set_item_disabled(0, campaign.medkits == 0)
	options.select(consumable)
	options.item_selected.connect(change_consumable.bind(id, preparing))
	parent.add_child(options)

func change_consumable(option: int, id: int, preparing: bool) -> void:
	if preparing:
		draft_gear[id] = option
	else:
		campaign.roster[id]["consumable"] = option
	refresh.call_deferred()

func select_class(index: int) -> void:
	recruit_class = campaign.classes[index]

func train_recruit() -> void:
	campaign.start_recruit(recruit_class if not recruit_class.is_empty() else campaign.classes[0])

func show_workshop() -> void:
	var columns := row()
	columns.add_theme_constant_override("separation", 32)
	var purchases := column(columns, 0)
	var inventory := column(columns, 0)
	purchases.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inventory.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var inset := MarginContainer.new()
	inset.add_theme_constant_override("margin_top", 56)
	purchases.add_child(inset)
	line(inset, "Purchase consumables", 23)
	for id in State.RECIPES:
		var entry := HBoxContainer.new()
		entry.add_theme_constant_override("separation", 16)
		purchases.add_child(entry)
		var recipe: Dictionary = State.RECIPES[id]
		line(entry, "%s ×%d  ·  %d Supplies" % [recipe["label"], recipe["quantity"], recipe["cost"]]).custom_minimum_size.x = 275
		action(entry, "Purchase", campaign.produce.bind(id), campaign.supplies < int(recipe["cost"]))

	wrapped_line(inventory, "%s · %s" % [Loadouts.SUPERSUIT, Loadouts.SUPERSUIT_DETAIL])
	wrapped_line(inventory, "%s · %s · %d in stock" % [Loadouts.MEDKIT_NAME, Loadouts.MEDKIT_DETAIL, campaign.medkits])

func show_research() -> void:
	var columns := row()
	columns.add_theme_constant_override("separation", 32)
	for branch_id in RESEARCH_TITLES:
		var board := bunker_panel(columns, 0, true)
		board.add_theme_constant_override("separation", 16)
		line(board, RESEARCH_TITLES[branch_id], 23).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var project_ids: Array[String] = []
		for id in State.PROJECTS:
			if State.PROJECTS[id]["branch"] == branch_id:
				project_ids.append(id)
		for group in range(2):
			var lanes := HBoxContainer.new()
			lanes.add_theme_constant_override("separation", 12)
			board.add_child(lanes)
			for lane_index in range(4):
				var lane := column(lanes, 0)
				lane.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				lane.add_theme_constant_override("separation", 0)
				var project_index: int = group * 4 + lane_index
				if project_index < project_ids.size():
					show_research_project(lane, project_ids[project_index])
				else:
					show_research_placeholder(lane)
				for tier in range(2):
					var link := ColorRect.new()
					link.color = Color("#536761")
					link.custom_minimum_size = Vector2(2, 19)
					link.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
					link.mouse_filter = Control.MOUSE_FILTER_IGNORE
					lane.add_child(link)
					show_research_placeholder(lane)
		for index in range(8, project_ids.size()):
			show_research_project(board, project_ids[index])
	line(body, "Outlined slots are reserved for future projects.", 15).modulate = Color("#a6b9b0")

func show_research_project(parent: VBoxContainer, id: String) -> void:
	var project: Dictionary = State.PROJECTS[id]
	var block: String = campaign.research_block(id)
	var status: String = "Start research" if block.is_empty() else block
	var details: String = "%s\n%d Supplies · %d days" % [project["label"], project["cost"], project["days"]]
	var card_status: String = "Slot occupied" if block == "Research slot occupied" else status
	var card := action(parent, details + "\n" + card_status, campaign.start_research.bind(id), not block.is_empty())
	card.custom_minimum_size.y = 72
	card.clip_text = true
	card.add_theme_font_size_override("font_size", 13)
	card.add_theme_color_override("font_disabled_color", Color("#c4d4ca"))
	card.tooltip_text = details + "\n" + status
	if campaign.unlocks.has(project["unlock"]):
		card.tooltip_text += "\nEquip in squad preparation. Press G in combat." if id == "emergency_reload" else "\nAvailable from Intel Op in the mission briefing."

func show_research_placeholder(parent: VBoxContainer) -> void:
	var slot := Panel.new()
	slot.custom_minimum_size.y = 72
	slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var outline := StyleBoxFlat.new()
	outline.bg_color = Color("#1a2727")
	outline.border_color = Color("#536761")
	outline.set_border_width_all(1)
	slot.add_theme_stylebox_override("panel", outline)
	parent.add_child(slot)

func column(parent: HBoxContainer, width: int) -> VBoxContainer:
	var result := VBoxContainer.new()
	result.custom_minimum_size.x = width
	result.add_theme_constant_override("separation", 8)
	parent.add_child(result)
	return result

func wrapped_line(parent: Control, value: String) -> void:
	var label := line(parent, value)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
