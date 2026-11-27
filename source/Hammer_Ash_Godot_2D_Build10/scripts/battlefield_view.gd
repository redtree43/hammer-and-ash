extends RefCounted

## An orthographic 2D projection of the existing square grid.
## Board-space pixels are shared by ground geometry and animation tracks.
const AREA := Rect2(16, 64, 1112, 668)
const AXIS_X := Vector2(0.88, 0.59)
const AXIS_Y := Vector2(-0.88, 0.59)
const MAX_SCALE := 3.2
const PIVOT_SECONDS := 0.34
const WALL_HEIGHT := 23.0
const NO_TILE := Vector2i(-1, -1)
const SIDES := [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]

var ground := Transform2D.IDENTITY
var camera := Transform2D.IDENTITY
var inverse_ground := Transform2D.IDENTITY
var projection := Transform2D(AXIS_X, AXIS_Y, Vector2.ZERO)
var bounds := Rect2()
var dimensions := Vector2i.ZERO
var origin := Vector2.ZERO
var tile_size := 0.0
var fit_scale := 1.0
var scale := 1.0
var offset := Vector2.ZERO
var dragging := false
var quarter_turns := 0
var pivot_direction := 0
var pending_pivots := 0
var pivot_elapsed := 0.0
var pivot_anchor := Vector2.ZERO
var pivot_zoom := 1.0
var pivot_fitted := false

func frame(size: Vector2i, board_origin: Vector2, cell_size: float) -> void:
    dimensions = size
    origin = board_origin
    tile_size = cell_size
    quarter_turns = 0
    pivot_direction = 0
    pending_pivots = 0
    rebuild_projection(0.0)
    reset_camera()

func rebuild_projection(yaw: float) -> void:
    projection = Transform2D(AXIS_X, AXIS_Y, Vector2.ZERO) * Transform2D(yaw, Vector2.ZERO)
    projection.origin = -projection.basis_xform(origin)
    var corners: PackedVector2Array = projected_corners(tile_rect(Vector2i.ZERO, dimensions))
    bounds = Rect2(corners[0], Vector2.ZERO)
    for corner in corners:
        bounds = bounds.expand(corner)
    # Leave space for upright art at the far edge and the board's front lip.
    bounds.position -= Vector2(22, 46)
    bounds.size += Vector2(44, 64)
    fit_scale = minf(MAX_SCALE, minf(AREA.size.x / bounds.size.x, AREA.size.y / bounds.size.y))

func reset_camera() -> void:
    dragging = false
    scale = fit_scale
    offset = AREA.get_center() - bounds.get_center() * scale
    update_camera()
    update_pivot_anchor()

func update_camera() -> void:
    var scaled_size: Vector2 = bounds.size * scale
    var min_offset: Vector2 = AREA.end - bounds.end * scale
    var max_offset: Vector2 = AREA.position - bounds.position * scale
    var centered: Vector2 = AREA.get_center() - bounds.get_center() * scale
    offset.x = clampf(offset.x, min_offset.x, max_offset.x) if scaled_size.x > AREA.size.x else centered.x
    offset.y = clampf(offset.y, min_offset.y, max_offset.y) if scaled_size.y > AREA.size.y else centered.y
    camera = Transform2D(Vector2(scale, 0), Vector2(0, scale), offset)
    ground = camera * projection
    inverse_ground = ground.affine_inverse()

func zoom_at(screen_pos: Vector2, factor: float) -> void:
    var anchor: Vector2 = (screen_pos - offset) / scale
    scale = clampf(scale * factor, fit_scale, MAX_SCALE)
    offset = screen_pos - anchor * scale
    update_camera()
    update_pivot_anchor()

func pan(delta: Vector2) -> void:
    offset += delta
    update_camera()
    update_pivot_anchor()

func pivot(direction: int) -> void:
    if pivot_direction != 0:
        pending_pivots += direction
        return
    pivot_direction = direction
    pivot_elapsed = 0.0
    update_pivot_anchor()

func update_pivot_anchor() -> void:
    if pivot_direction == 0:
        return
    pivot_anchor = inverse_ground * AREA.get_center()
    pivot_zoom = scale
    pivot_fitted = is_equal_approx(scale, fit_scale)

func advance_pivot(delta: float) -> bool:
    if pivot_direction == 0:
        return false
    pivot_elapsed += delta
    var progress: float = minf(pivot_elapsed / PIVOT_SECONDS, 1.0)
    var yaw: float = (quarter_turns + pivot_direction * smoothstep(0.0, 1.0, progress)) * PI * 0.5
    rebuild_projection(yaw)
    scale = fit_scale if pivot_fitted else maxf(pivot_zoom, fit_scale)
    offset = AREA.get_center() - project(pivot_anchor) * scale
    update_camera()
    if progress >= 1.0:
        quarter_turns = posmod(quarter_turns + pivot_direction, 4)
        pivot_direction = 0
        if pending_pivots != 0:
            var next: int = signi(pending_pivots)
            pending_pivots -= next
            pivot(next)
    return true

func tile_at(screen_pos: Vector2) -> Vector2i:
    if not AREA.has_point(screen_pos):
        return NO_TILE
    var cell := Vector2i(((inverse_ground * screen_pos - origin) / tile_size).floor())
    return cell if Rect2i(Vector2i.ZERO, dimensions).has_point(cell) else NO_TILE

func ground_to_screen(board_pos: Vector2) -> Vector2:
    return ground * board_pos

func project(board_pos: Vector2) -> Vector2:
    return projection * board_pos

func tile_rect(cell: Vector2i, footprint: Vector2i = Vector2i.ONE) -> Rect2:
    return Rect2(origin + Vector2(cell) * tile_size, Vector2(footprint) * tile_size)

func draw_board_sides(canvas: CanvasItem) -> void:
    var corners: PackedVector2Array = projected_corners(tile_rect(Vector2i.ZERO, dimensions))
    var rim: PackedVector2Array = corners.duplicate()
    for index in range(4):
        rim[index] += Vector2(0, 13)
    draw_front_faces(canvas, rim, 5.0, Color("#182228"))
    draw_front_faces(canvas, corners, 13.0, Color("#4a5860"))

func projected_corners(rect: Rect2) -> PackedVector2Array:
    var corners := [rect.position, Vector2(rect.end.x, rect.position.y),
        rect.end, Vector2(rect.position.x, rect.end.y)]
    var result := PackedVector2Array()
    for corner in corners:
        result.append(project(corner))
    return result

func draw_front_faces(canvas: CanvasItem, corners: PackedVector2Array, height: float, color: Color,
        joined_sides: Array[bool] = []) -> void:
    var center: Vector2 = (corners[0] + corners[2]) * 0.5
    var down := Vector2(0, height)
    for index in range(4):
        var a: Vector2 = corners[index]
        var b: Vector2 = corners[(index + 1) % 4]
        var outward: Vector2 = (a + b) * 0.5 - center
        if outward.y <= 0.001 or (not joined_sides.is_empty() and joined_sides[index]):
            continue
        var shade: float = 0.345 + 0.08 * outward.normalized().x
        canvas.draw_colored_polygon(PackedVector2Array([a, b, b + down, a + down]), color.darkened(shade))

func wall_bounds(rect: Rect2) -> Rect2:
    var corners: PackedVector2Array = projected_corners(rect)
    var wall := Rect2(corners[0], Vector2.ZERO)
    for corner in corners:
        wall = wall.expand(corner)
    wall.position.y -= WALL_HEIGHT
    wall.size.y += WALL_HEIGHT
    return wall

func draw_wall(canvas: CanvasItem, rect: Rect2, color: Color, joined_sides: Array[bool]) -> void:
    var rise := Vector2(0, -WALL_HEIGHT)
    var top: PackedVector2Array = projected_corners(rect)
    for index in range(top.size()):
        top[index] += rise
    draw_front_faces(canvas, top, WALL_HEIGHT, color, joined_sides)
    var center: Vector2 = (top[0] + top[2]) * 0.5
    for i in range(4):
        var a: Vector2 = top[i]
        var b: Vector2 = top[(i + 1) % 4]
        if ((a + b) * 0.5 - center).y <= 0.001 or joined_sides[i]:
            continue
        var base: Vector2 = a + Vector2(0, WALL_HEIGHT)
        var edge: Vector2 = b - a
        canvas.draw_line(base + Vector2(0, -4), base + edge + Vector2(0, -4), color.darkened(0.58), 2.0)
        for fraction in [0.12, 0.88]:
            var rib: Vector2 = a + edge * fraction
            canvas.draw_line(rib + Vector2(0, 2), rib + Vector2(0, WALL_HEIGHT - 5), color.darkened(0.46), 2.0)
        var recess: Vector2 = a + edge * 0.27
        for height in [7, 10, 13]:
            var slot: Vector2 = recess + Vector2(0, height)
            canvas.draw_line(slot, slot + edge * 0.46, color.darkened(0.65), 1.5)
    canvas.draw_colored_polygon(top, color)
    var panel := PackedVector2Array()
    for corner in top:
        panel.append(center.lerp(corner, 0.74))
    canvas.draw_colored_polygon(panel, color.darkened(0.12))
    canvas.draw_line(panel[0], panel[1], color.lightened(0.21), 1.5)
    canvas.draw_line(panel[0], panel[3], color.lightened(0.12), 1.0)
    top.append(top[0])
    canvas.draw_polyline(top, color.darkened(0.34), 1.2)

func mask_outside(canvas: CanvasItem, color: Color) -> void:
    # The combat canvas also owns the HUD. The board pass precedes the HUD,
    # so these strips clip the zoomed board without clipping UI draw commands.
    if is_equal_approx(scale, fit_scale):
        return
    var outer := Rect2(-640, -640, 2740, 2180)
    canvas.draw_rect(Rect2(outer.position, Vector2(outer.size.x, AREA.position.y - outer.position.y)), color)
    canvas.draw_rect(Rect2(outer.position.x, AREA.end.y, outer.size.x, outer.end.y - AREA.end.y), color)
    canvas.draw_rect(Rect2(outer.position.x, AREA.position.y, AREA.position.x - outer.position.x, AREA.size.y), color)
    canvas.draw_rect(Rect2(AREA.end.x, AREA.position.y, outer.end.x - AREA.end.x, AREA.size.y), color)
