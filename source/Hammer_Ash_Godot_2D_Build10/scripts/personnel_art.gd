extends RefCounted

class EquipmentIcon extends Control:
    const PIXELS: Array = [
        [".##..##.", "##.##.##", "###..###", ".######.", ".#.##.#.", ".######."],
        ["..####..", "########", "###..###", "##....##", "###..###", "########"],
    ]

    var slot: int
    var equipped: bool

    func _init(equipment_slot: int, has_item: bool) -> void:
        slot = equipment_slot
        equipped = has_item
        custom_minimum_size = Vector2(52, 52)
        size_flags_vertical = Control.SIZE_SHRINK_CENTER
        mouse_filter = Control.MOUSE_FILTER_IGNORE

    func _draw() -> void:
        draw_style_box(icon_frame(), Rect2(Vector2.ZERO, size))
        var pattern: Array = PIXELS[slot]
        var tint := Color("#e8ba81") if equipped else Color("#728683")
        var pixel := 4.0
        var top_left: Vector2 = (size - Vector2(8.0, float(pattern.size())) * pixel) * 0.5
        for y in range(pattern.size()):
            for x in range(8):
                if pattern[y][x] == "#":
                    draw_rect(Rect2(top_left + Vector2(x, y) * pixel, Vector2.ONE * pixel), tint)

    func icon_frame() -> StyleBoxFlat:
        var frame := StyleBoxFlat.new()
        frame.bg_color = Color("#192324")
        frame.border_color = Color("#3e5552")
        frame.set_border_width_all(1)
        frame.set_corner_radius_all(5)
        return frame


class ClassTree extends Control:
    const STEP: float = 43.0
    const NODE_HEIGHT: float = 34.0
    const LEVEL_GUTTER: float = 48.0
    const MUTED := Color("#59605e")

    var accent: Color
    var levels: Array[Array] = []

    func _init(class_color: Color) -> void:
        accent = class_color
        mouse_filter = Control.MOUSE_FILTER_IGNORE
        resized.connect(layout_nodes)

    func add_level(options: Array, unlocked: Dictionary, earned: bool, choose: Callable) -> void:
        var nodes: Array[AbilityNode] = []
        for index in range(options.size()):
            var ability: Dictionary = options[index]
            var selected: bool = unlocked.has(ability["name"])
            var selectable: bool = earned and choose.is_valid()
            var node := AbilityNode.new(ability, selected, earned, selectable, accent)
            if selectable:
                node.pressed.connect(choose.bind(index))
            add_child(node)
            nodes.append(node)
        levels.append(nodes)
        custom_minimum_size.y = (levels.size() - 1) * STEP + NODE_HEIGHT

    func node_center(index: int, count: int) -> float:
        return LEVEL_GUTTER + (size.x - LEVEL_GUTTER) * (index + 0.5) / count

    func layout_nodes() -> void:
        for level in range(levels.size()):
            var nodes: Array = levels[level]
            var width: float = minf(222.0, (size.x - LEVEL_GUTTER) / nodes.size() - 14.0)
            for index in range(nodes.size()):
                var node: AbilityNode = nodes[index]
                node.position = Vector2(node_center(index, nodes.size()) - width * 0.5, level * STEP)
                node.size = Vector2(width, NODE_HEIGHT)
        queue_redraw()

    func _draw() -> void:
        for level in range(levels.size()):
            var nodes: Array = levels[level]
            draw_string(get_theme_default_font(), Vector2(3, level * STEP + 22), "Lv %d" % (level + 1),
                HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#a6b9b0"))
            if level == levels.size() - 1:
                continue
            var next: Array = levels[level + 1]
            var junction := Vector2(node_center(0, 1), level * STEP + (STEP + NODE_HEIGHT) * 0.5)
            # Draw the muted alternatives first so the chosen route stays visible at the junction.
            for selected in [false, true]:
                for index in range(nodes.size()):
                    if nodes[index].selected == selected:
                        var start := Vector2(node_center(index, nodes.size()), level * STEP + NODE_HEIGHT)
                        draw_line(start, junction, accent if selected and next.any(is_selected) else MUTED, 1.5, true)
                for index in range(next.size()):
                    if next[index].selected == selected:
                        var finish := Vector2(node_center(index, next.size()), (level + 1) * STEP)
                        draw_line(junction, finish, accent if selected else MUTED, 1.5, true)

    func is_selected(node: AbilityNode) -> bool:
        return node.selected


class AbilityNode extends Button:
    var selected: bool
    var detail: String
    var metadata: String

    func _init(ability: Dictionary, equipped: bool, earned: bool, selectable: bool, accent: Color) -> void:
        selected = equipped
        var passive: bool = ability["type"] == "P"
        text = "%s  %s" % ["●" if passive else "■", ability["name"]]
        text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
        focus_mode = Control.FOCUS_ALL if selectable else Control.FOCUS_NONE
        mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if selectable else Control.CURSOR_ARROW
        add_theme_font_size_override("font_size", 15)
        var ink := Color("#f1e5d2") if selected else Color("#a7aead")
        add_theme_color_override("font_color", ink)
        add_theme_color_override("font_hover_color", ink)
        var style := StyleBoxFlat.new()
        style.bg_color = Color("#282f2f").lerp(accent, 0.16) if selected else Color("#262d2e")
        style.border_color = accent if selected else Color("#59605e")
        style.set_border_width_all(1)
        style.set_corner_radius_all(16 if passive else 3)
        add_theme_stylebox_override("normal", style)
        var hover: StyleBoxFlat = style.duplicate()
        hover.bg_color = style.bg_color.lightened(0.08)
        hover.border_color = style.border_color.lightened(0.15)
        add_theme_stylebox_override("hover", hover)
        add_theme_stylebox_override("pressed", hover)
        var kind: String = "Passive" if passive else "Active · %d AP" % int(ability["ap"])
        var state: String = "Selected" if selected else ("Unselected" if earned else "Locked")
        metadata = "%s · %s · %s" % [kind, ability["limit"], state]
        detail = "%s\n\n%s" % [ability["mechanic"], ability["rule"]]
        if selectable and not selected:
            detail += "\n\nClick to select this ability."
        tooltip_text = ability["name"]

    func _make_custom_tooltip(ability_name: String) -> Object:
        var panel := PanelContainer.new()
        var style := StyleBoxFlat.new()
        style.bg_color = Color("#142020")
        style.border_color = Color("#60776e")
        style.set_border_width_all(1)
        style.set_corner_radius_all(6)
        style.set_content_margin_all(12)
        panel.add_theme_stylebox_override("panel", style)
        var entries := VBoxContainer.new()
        entries.custom_minimum_size.x = 332
        entries.add_theme_constant_override("separation", 6)
        panel.add_child(entries)
        for value in [ability_name, metadata, detail]:
            var entry := Label.new()
            entry.text = value
            entry.custom_minimum_size.x = 332
            entry.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
            entry.add_theme_font_size_override("font_size", 18 if value == ability_name else 15)
            entries.add_child(entry)
        return panel
