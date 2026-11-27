extends Control

const Geography = preload("res://maps/russia_districts.json")
const DISTRICTS: Array[Dictionary] = [
    {"id": "central", "name": "Central Federal District", "colour": Color("#bb9666")},
    {"id": "northwestern", "name": "Northwestern Federal District", "colour": Color("#688f86")},
    {"id": "southern", "name": "Southern Federal District", "colour": Color("#ab795e")},
    {"id": "north_caucasian", "name": "North Caucasian Federal District", "colour": Color("#ab818c")},
    {"id": "volga", "name": "Volga Federal District", "colour": Color("#8e9965")},
    {"id": "ural", "name": "Ural Federal District", "colour": Color("#638e9b")},
    {"id": "siberian", "name": "Siberian Federal District", "colour": Color("#7a9276")},
    {"id": "far_eastern", "name": "Far Eastern Federal District", "colour": Color("#8990a9")},
]

signal district_selected(index: int)

var district: int = -1
var hovered: int = -1
var polygons: Array[Array] = []
var subject_lines: Array[PackedVector2Array] = []
var bounds: Rect2
var map_transform: Transform2D
var markers: Dictionary = {}

func configure(index: int, sites: Dictionary) -> void:
    district = index
    var data: Dictionary = Geography.data["overview"] if district < 0 else Geography.data[DISTRICTS[district]["id"]]
    var limits: Array = data["bounds"]
    bounds = Rect2(limits[0], limits[1], limits[2] - limits[0], limits[3] - limits[1])
    for entry in DISTRICTS:
        var outlines: Array = []
        for ring in data["districts"].get(entry["id"], []):
            outlines.append(unpack_points(ring))
        polygons.append(outlines)
    for ring in data.get("subjects", []):
        subject_lines.append(unpack_points(ring))
    markers = sites
    custom_minimum_size.y = 522
    size_flags_horizontal = Control.SIZE_EXPAND_FILL
    clip_contents = true

func _ready() -> void:
    resized.connect(layout_map)
    mouse_exited.connect(highlight.bind(-1))
    layout_map()

func unpack_points(coordinates: Array) -> PackedVector2Array:
    var points := PackedVector2Array()
    for index in range(0, coordinates.size(), 2):
        points.append(Vector2(coordinates[index], coordinates[index + 1]))
    return points

func layout_map() -> void:
    var available := (size - Vector2(128, 76)).max(Vector2.ONE)
    var scale_factor := minf(available.x / bounds.size.x, available.y / bounds.size.y)
    map_transform = Transform2D(0.0, Vector2.ONE * scale_factor, 0.0,
        size * 0.5 - bounds.get_center() * scale_factor)
    for site in markers.values():
        var point: Array = site["point"]
        var button: Button = site["button"]
        button.size = button.get_combined_minimum_size()
        button.position = (map_transform * Vector2(point[0], point[1])).round() - Vector2(15, roundf(button.size.y * 0.5) + 8)
    queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, size), Color("#111d20"))
    for x in range(22, int(size.x), 36):
        draw_line(Vector2(x, 0), Vector2(x, size.y), Color("#1d2d2f"))
    for y in range(22, int(size.y), 36):
        draw_line(Vector2(0, y), Vector2(size.x, y), Color("#1d2d2f"))
    draw_rect(Rect2(Vector2(0.5, 0.5), size - Vector2.ONE), Color("#3b5150"), false)
    for index in range(polygons.size()):
        var fill: Color = DISTRICTS[index]["colour"]
        if index == hovered:
            fill = fill.lightened(0.23)
        for outline in polygons[index]:
            var points: PackedVector2Array = map_transform * outline
            draw_colored_polygon(points, fill)
            points.append(points[0])
            draw_polyline(points, Color("#18282b"), 1.4, true)
    for outline in subject_lines:
        draw_polyline(map_transform * outline, Color(0.10, 0.17, 0.17, 0.42), 1.1, true)

func highlight(index: int) -> void:
    if hovered == index:
        return
    hovered = index
    tooltip_text = DISTRICTS[index]["name"] if index >= 0 else ""
    mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if index >= 0 else Control.CURSOR_ARROW
    queue_redraw()

func district_at(position_on_map: Vector2) -> int:
    var projected := map_transform.affine_inverse() * position_on_map
    for index in range(polygons.size()):
        for outline in polygons[index]:
            if Geometry2D.is_point_in_polygon(projected, outline):
                return index
    return -1

func _gui_input(event: InputEvent) -> void:
    if district >= 0:
        return
    if event is InputEventMouseMotion:
        highlight(district_at(event.position))
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
        var index := district_at(event.position)
        if index >= 0:
            district_selected.emit(index)
            accept_event()
