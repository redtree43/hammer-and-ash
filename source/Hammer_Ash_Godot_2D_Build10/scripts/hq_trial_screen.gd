extends CanvasLayer

const State = preload("res://scripts/hq_trial_state.gd")
const Loadouts = preload("res://scripts/starter_loadouts.gd")
const Art = preload("res://scripts/personnel_art.gd")
const TABS: Array[String] = ["USSR", "Personnel", "Workshop", "Research"]
const BRANCHES: Array[String] = ["Stratagems", "Intelligence Ops"]
const CLASS_ROLES: Dictionary = {
    "Scythe": "Close-quarters damage",
    "Anvil": "Defence and squad protection",
    "Needle": "Precision target elimination",
    "Iskra": "Technology and environmental manipulation",
    "Alkhimik": "Healing and enhancement",
}

signal deployed(operation: String)

var campaign: State = State.new()
var surface: PanelContainer
var body: VBoxContainer
var tab: String = "USSR"
var branch: String = "Stratagems"
var operation: String = ""
var region: int = 0
var squad: Array[int] = []
var draft_gear: Dictionary = {}
var prepare_reload: bool = false
var selected_operative: int = 0
var personnel_operative: int = 0
var personnel_origin_preview: String = "Wolverine"
var sort_by_type: bool = true
var gear_filter: int = 0
var kit_profiles: Dictionary = {}
var portraits: Dictionary = {}
var recruit_class: String = ""

func _ready() -> void:
    layer = 2
    hide()

func open() -> void:
    tab = "USSR"
    show()
    refresh()

func refresh() -> void:
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
    var toolbar := HBoxContainer.new()
    layout.add_child(toolbar)
    for name_text in TABS:
        action(toolbar, name_text, select_tab.bind(name_text), tab == name_text)
    var scroll := ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    layout.add_child(scroll)
    body = VBoxContainer.new()
    body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    body.add_theme_constant_override("separation", 8)
    scroll.add_child(body)
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

func action(parent: Control, title: String, callback: Callable, disabled: bool = false) -> void:
    var button := Button.new()
    button.text = title
    button.disabled = disabled
    button.pressed.connect(run_action.bind(callback))
    parent.add_child(button)

func run_action(callback: Callable) -> void:
    callback.call()
    if visible:
        refresh.call_deferred()

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
    return "%s    ·    %s    ·    Medkits %d" % [active_project, active_recruit, campaign.medkits]

func show_ussr() -> void:
    if not operation.is_empty():
        show_loadout()
        return
    line(body, "Regions", 26)
    var regions := row()
    for index in range(1, 9):
        var title: String = "Moscow" if index == 8 else "Region %d" % index
        action(regions, title, select_region.bind(index), index == region)
    if region > 0:
        line(body, "Test region" if region == 1 else "No operations available in this region.", 22)
    if region == 1:
        for id in State.OPERATIONS:
            var entry := row()
            action(entry, State.OPERATIONS[id]["label"], select_operation.bind(id))
            line(entry, State.OPERATIONS[id]["brief"])
    if not campaign.debrief.is_empty():
        line(body, "Latest operation report", 22)
        for entry in campaign.debrief:
            line(body, entry)

func select_region(index: int) -> void:
    region = index

func select_operation(id: String) -> void:
    operation = id
    squad.clear()
    draft_gear.clear()
    selected_operative = 0
    prepare_reload = false

func show_loadout() -> void:
    line(body, "%s / Squad loadout" % State.OPERATIONS[operation]["label"], 26)
    var launch := row()
    action(launch, "Back to operations", select_operation.bind(""))
    var can_launch: bool = campaign.can_deploy(operation, squad, draft_gear)
    action(launch, "Deploy", deploy, not can_launch)
    line(launch, "%d / %d operatives selected" % [squad.size(), State.SQUAD_SIZE])
    if squad.size() == State.SQUAD_SIZE and not can_launch:
        line(launch, "Reduce shared rifles or medkits to fit available stock.")
    var support := row()
    line(support, "Intelligence Op")
    if campaign.prepared_recon == operation:
        line(support, "Facility Recon active")
    else:
        action(support, "Facility Recon (%d Intel)" % State.RECON_COST, campaign.buy_recon.bind(operation),
            not campaign.unlocks.has("recon") or campaign.intel < State.RECON_COST or not campaign.prepared_recon.is_empty())
        if not campaign.unlocks.has("recon"):
            line(support, "Requires research")
        elif not campaign.prepared_recon.is_empty():
            line(support, "Recon already prepared for %s" % State.OPERATIONS[campaign.prepared_recon]["label"])
        elif campaign.intel < State.RECON_COST:
            line(support, "Insufficient Intel")
    if campaign.prepared_recon == operation:
        wrapped_line(body, State.OPERATIONS[operation]["recon"])
    var stratagems := row()
    line(stratagems, "Stratagem")
    var stratagem := OptionButton.new()
    stratagem.add_item("None")
    stratagem.add_item("Emergency Reload")
    stratagem.set_item_disabled(1, not campaign.unlocks.has("reload"))
    stratagem.select(1 if prepare_reload else 0)
    stratagem.item_selected.connect(select_stratagem)
    stratagems.add_child(stratagem)
    var reload_detail: String = "%d Intel on use · Full magazine · No AP · Once per operation [G]" % State.RELOAD_COST
    line(stratagems, reload_detail if campaign.unlocks.has("reload") else "Requires research")
    var columns := row()
    var roster_column := column(columns, 420)
    var equipment := column(columns, 450)
    line(roster_column, "Squad", 22)
    for id in campaign.roster:
        if not campaign.available(id):
            continue
        var entry := HBoxContainer.new()
        roster_column.add_child(entry)
        var selected: bool = squad.has(id)
        line(entry, campaign.operative_name(id)).custom_minimum_size.x = 170
        action(entry, "Remove" if selected else "Select", toggle_squad.bind(id),
            not selected and squad.size() == State.SQUAD_SIZE)
        if selected:
            action(entry, "Gear", inspect_operative.bind(id), selected_operative == id)
    if squad.has(selected_operative):
        line(equipment, campaign.operative_name(selected_operative), 22)
        show_gear_slots(equipment, selected_operative, draft_gear[selected_operative], true)

func toggle_squad(id: int) -> void:
    if squad.has(id):
        squad.erase(id)
        draft_gear.erase(id)
        if selected_operative == id:
            selected_operative = 0 if squad.is_empty() else squad.back()
    elif campaign.available(id) and squad.size() < State.SQUAD_SIZE:
        squad.append(id)
        draft_gear[id] = campaign.roster[id]["loadout"].duplicate()
        selected_operative = id

func select_stratagem(index: int) -> void:
    prepare_reload = index == 1

func deploy() -> void:
    if campaign.deploy(operation, squad, draft_gear, prepare_reload):
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
    for id in ids:
        var ready: String = "  ·  Recovering" if not campaign.available(id) else ""
        roster.add_item(campaign.operative_name(id) + ready, id)
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
    var choices: Array = campaign.roster[id]["loadout"]
    var equipped: Dictionary = kit_profiles[kit].duplicate()
    Loadouts.equip(equipped, choices)
    var columns := row()
    columns.alignment = BoxContainer.ALIGNMENT_CENTER
    show_operative_card(personnel_panel(columns, 282, false), id, kit, equipped)
    show_class_path(personnel_panel(columns, 445, true), kit)
    var equipment := personnel_panel(columns, 390, true)
    line(equipment, "Equipment", 24)
    var equipment_note := line(equipment, "Defaults for future deployments", 15)
    equipment_note.modulate = Color("#a6b9b0")
    for slot in [1, 0, 2, 3]:
        show_personnel_gear(equipment, id, choices, equipped, slot)

func personnel_panel(parent: HBoxContainer, width: float, expand: bool) -> VBoxContainer:
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

func show_operative_card(parent: VBoxContainer, id: int, kit: String, equipped: Dictionary) -> void:
    line(parent, campaign.operative_name(id), 25)
    var ready: bool = campaign.available(id)
    var status: String = "Ready to deploy" if ready else "Recovering until day %d" % campaign.roster[id]["ready_day"]
    line(parent, status, 15).modulate = Color("#a3d9b1") if ready else Color("#efbd82")

    var portrait_frame := PanelContainer.new()
    var backdrop := StyleBoxFlat.new()
    backdrop.bg_color = Color("#172424")
    backdrop.border_color = Color("#405753")
    backdrop.set_border_width_all(1)
    backdrop.set_corner_radius_all(6)
    portrait_frame.add_theme_stylebox_override("panel", backdrop)
    parent.add_child(portrait_frame)
    var portrait := TextureRect.new()
    portrait.texture = portraits[kit]
    portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    portrait.custom_minimum_size = Vector2(214, 220)
    portrait_frame.add_child(portrait)

    line(parent, "Combat stats", 21)
    var stats := GridContainer.new()
    stats.columns = 2
    stats.add_theme_constant_override("h_separation", 14)
    stats.add_theme_constant_override("v_separation", 5)
    parent.add_child(stats)
    var values: Dictionary = {
        "HP": equipped["hp"], "Armour": equipped["max_armour"],
        "Base melee": equipped["melee_damage"], "Base ranged": equipped["damage"],
        "Action points": equipped["max_ap"], "Move": "%d tiles" % equipped["move"],
        "Resistances": "None",
    }
    for stat in values:
        line(stats, stat, 15).size_flags_horizontal = Control.SIZE_EXPAND_FILL
        line(stats, str(values[stat]), 15).modulate = Color("#ebbe8e")

func show_class_path(parent: VBoxContainer, kit: String) -> void:
    parent.add_theme_constant_override("separation", 6)
    line(parent, "Class path", 24)
    line(parent, CLASS_ROLES[kit], 15).modulate = Color("#a6b9b0")
    if kit == "Scythe":
        line(parent, "Provisional progression", 15).modulate = Color("#ebbe8e")
        var paths := HBoxContainer.new()
        parent.add_child(paths)
        for path in Art.ScytheTree.ORIGIN_NODES:
            action(paths, path, select_origin_preview.bind(path), personnel_origin_preview == path)
        parent.add_child(Art.ScytheTree.new(personnel_origin_preview))
    else:
        line(parent, "Progression in development", 15).modulate = Color("#ebbe8e")
    parent.add_child(HSeparator.new())
    line(parent, "Prototype abilities", 19)
    for description in kit_profiles[kit]["ability_text"]:
        var detail := line(parent, description, 15)
        detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    if kit == "Anvil":
        var breach := line(parent, "Breach · 1 AP · Charge through cover and shove an enemy on contact.", 15)
        breach.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func select_origin_preview(path: String) -> void:
    personnel_origin_preview = path

func show_personnel_gear(parent: VBoxContainer, id: int, choices: Array, equipped: Dictionary, slot: int) -> void:
    parent.add_child(HSeparator.new())
    var entry := HBoxContainer.new()
    entry.add_theme_constant_override("separation", 12)
    parent.add_child(entry)
    var item: Dictionary = Loadouts.ITEMS[slot][choices[slot]]
    entry.add_child(Art.EquipmentIcon.new(slot, item["name"] != "Empty"))
    var details := VBoxContainer.new()
    details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    details.add_theme_constant_override("separation", 4)
    entry.add_child(details)
    line(details, "Consumable" if slot == 3 else Loadouts.SLOTS[slot], 15).modulate = Color("#ebbe8e")
    add_gear_picker(details, id, choices, slot, false)
    var effect: String = item["detail"]
    if slot == 0 and choices[slot] == 0:
        effect = "%d damage · %d range · 3 rounds" % [equipped["damage"], equipped["range"]]
    elif slot == 1 and Loadouts.blocks_melee(equipped["id"], choices[0]):
        effect = "Melee unavailable with a two-handed weapon"
    elif slot == 2:
        effect = "%d armour" % equipped["max_armour"]
    elif slot == 3 and choices[slot] == 0:
        effect += " · %d in stock" % campaign.medkits
    var description := line(details, effect, 15)
    description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    description.modulate = Color("#a6b9b0")


func show_gear_slots(parent: VBoxContainer, id: int, choices: Array, preparing: bool) -> void:
    for slot in range(Loadouts.SLOTS.size()):
        var name_text: String = "Consumable" if slot == 3 else Loadouts.SLOTS[slot]
        line(parent, name_text)
        add_gear_picker(parent, id, choices, slot, preparing)

func add_gear_picker(parent: VBoxContainer, id: int, choices: Array, slot: int, preparing: bool) -> void:
    var kit: String = campaign.roster[id]["kit"]
    var kit_index: int = campaign.classes.find(kit)
    var options := OptionButton.new()
    for option in range(Loadouts.ITEMS[slot].size()):
        var item: Dictionary = Loadouts.ITEMS[slot][option]
        var label: String = item["name"]
        if slot == 0 and option == 0:
            label = kit_profiles[kit]["basic_attack"]
        options.add_item(label, option)
        options.set_item_disabled(option, not gear_option_available(kit_index, choices, slot, option))
    options.select(choices[slot])
    options.item_selected.connect(change_gear.bind(id, slot, preparing))
    parent.add_child(options)

func gear_option_available(kit_index: int, choices: Array, slot: int, option: int) -> bool:
    if slot == 0 and option == 1 and campaign.armoury.is_empty():
        return false
    if slot == 3 and option == 0 and campaign.medkits == 0:
        return false
    return Loadouts.can_equip(kit_index, choices, slot, option)

func change_gear(option: int, id: int, slot: int, preparing: bool) -> void:
    var choices: Array = draft_gear[id] if preparing else campaign.roster[id]["loadout"]
    var kit_index: int = campaign.classes.find(campaign.roster[id]["kit"])
    if gear_option_available(kit_index, choices, slot, option):
        Loadouts.select_item(kit_index, choices, slot, option)
    refresh.call_deferred()

func select_class(index: int) -> void:
    recruit_class = campaign.classes[index]

func train_recruit() -> void:
    campaign.start_recruit(recruit_class if not recruit_class.is_empty() else campaign.classes[0])

func show_workshop() -> void:
    line(body, "Consumables in stock", 24)
    line(body, "Medkit ×%d" % campaign.medkits)
    line(body, "Purchase consumables", 23)
    for id in State.RECIPES:
        var entry := row()
        var recipe: Dictionary = State.RECIPES[id]
        line(entry, "%s ×%d  ·  %d Supplies" % [recipe["label"], recipe["quantity"], recipe["cost"]]).custom_minimum_size.x = 310
        action(entry, "Purchase", campaign.produce.bind(id), campaign.supplies < int(recipe["cost"]))
    line(body, "Equipment inventory", 23)
    var filters := row()
    for index in range(3):
        action(filters, ["Ranged", "Melee", "Armour"][index], select_gear_filter.bind(index), gear_filter == index)
    for item in Loadouts.ITEMS[gear_filter]:
        if item["name"] == "Empty":
            continue
        if item["name"] == "Service Rifle":
            line(body, "%s · %s · %d captured" % [item["name"], item["detail"], campaign.armoury.size()])
        else:
            line(body, "%s · %s · Issued stock" % [item["name"], item["detail"]])

func select_gear_filter(index: int) -> void:
    gear_filter = index

func show_research() -> void:
    var filters := row()
    for name_text in BRANCHES:
        action(filters, name_text, select_branch.bind(name_text), branch == name_text)
    var columns := row()
    var projects := column(columns, 535)
    var unlocks := column(columns, 365)
    line(projects, "Projects", 23)
    line(unlocks, "Unlocked " + branch, 23)
    var has_unlock: bool = false
    for id in State.PROJECTS:
        var project: Dictionary = State.PROJECTS[id]
        if project["branch"] != branch:
            continue
        line(projects, "%s  ·  %d Supplies  ·  %d days" % [project["label"], project["cost"], project["days"]])
        var block: String = campaign.research_block(id)
        action(projects, "Start research" if block.is_empty() else block, campaign.start_research.bind(id), not block.is_empty())
        if campaign.unlocks.has(project["unlock"]):
            has_unlock = true
            line(unlocks, project["label"])
            line(unlocks, "Equip in squad preparation. Press G in combat." if id == "emergency_reload" else "Available during squad preparation.")
    if not has_unlock:
        line(unlocks, "None yet")

func select_branch(name_text: String) -> void:
    branch = name_text

func column(parent: HBoxContainer, width: int) -> VBoxContainer:
    var result := VBoxContainer.new()
    result.custom_minimum_size.x = width
    result.add_theme_constant_override("separation", 8)
    parent.add_child(result)
    return result

func wrapped_line(parent: Control, value: String) -> void:
    var label := line(parent, value)
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
