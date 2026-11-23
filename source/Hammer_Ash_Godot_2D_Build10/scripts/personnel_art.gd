extends RefCounted

class EquipmentIcon extends Control:
    const PIXELS: Array = [
        ["........", ".#######", "..###...", "..#.#...", "..#....."],
        ["......##", ".....##.", "....##..", "..###...", "..##....", ".##....."],
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


class ScytheTree extends Control:
    # Provisional gates from SCYTHE_CLASS_DESIGN.md. The two choices on a row
    # converge on the next planned gate for the origin being browsed.
    const ORIGIN_NODES: Dictionary = {
        "Wolverine": ["Claws", "Regrowth", "Plate Ripper", "Fast Knit", "Phase Surge", "Rabid Frenzy"],
        "Arachnid": ["Spider Agility", "Web Snare", "Tether Yank", "Arachnid Sense", "Phase Surge", "Silkstorm"],
        "Blink": ["Short Blink", "Phase Strike", "Spatial Exchange", "Rift Lunge", "Rift Relay", "Rift Reaper"],
    }
    const STEP: float = 35.0
    const NODE_HEIGHT: float = 28.0

    var origin: String

    func _init(path: String) -> void:
        origin = path
        custom_minimum_size = Vector2(405, 9 * STEP)
        mouse_filter = Control.MOUSE_FILTER_IGNORE

    func _draw() -> void:
        var nodes: Array = ORIGIN_NODES[origin]
        var levels: Array = [
            ["Charge", nodes[0]],
            [nodes[1]],
            ["Threatening Presence"],
            [nodes[2], nodes[3]],
            ["Pursuit", "Execution Drill"],
            [nodes[4]],
            ["Opening Blow"],
            [nodes[5]],
            ["Overdrive"],
        ]
        for level in range(levels.size() - 1):
            var start_y: float = level * STEP + NODE_HEIGHT
            var finish_y: float = (level + 1) * STEP
            var junction := Vector2(node_center(0, 1), (start_y + finish_y) * 0.5)
            for first in range(levels[level].size()):
                var start := Vector2(node_center(first, levels[level].size()), start_y)
                draw_line(start, junction, Color("#b77c63"), 1.5, true)
            for second in range(levels[level + 1].size()):
                var finish := Vector2(node_center(second, levels[level + 1].size()), finish_y)
                draw_line(junction, finish, Color("#b77c63"), 1.5, true)
        for level in range(levels.size()):
            draw_string(get_theme_default_font(), Vector2(2, level * STEP + 20), "%02d" % (level + 1),
                HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#a8bcaf"))
            for index in range(levels[level].size()):
                var width: float = minf(177.0, (size.x - 46.0) * 0.49)
                var center: float = node_center(index, levels[level].size())
                var box := Rect2(center - width * 0.5, level * STEP, width, NODE_HEIGHT)
                var special: bool = level in [0, 3, 7, 8]
                draw_rect(box, Color("#352d2b") if special else Color("#273b39"))
                draw_rect(box, Color("#aa6e59") if special else Color("#526b65"), false, 1.0)
                draw_string(get_theme_default_font(), box.position + Vector2(4, 20), levels[level][index],
                    HORIZONTAL_ALIGNMENT_CENTER, width - 8, 14, Color("#f1e5cf"))

    func node_center(index: int, count: int) -> float:
        var midpoint: float = (size.x + 35.0) * 0.5
        if count == 1:
            return midpoint
        var offset: float = (size.x - 38.0) * 0.25
        return midpoint - offset if index == 0 else midpoint + offset
