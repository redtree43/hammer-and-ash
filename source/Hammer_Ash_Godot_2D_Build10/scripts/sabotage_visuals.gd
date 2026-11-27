extends RefCounted

const GRID := Color("#2e3437")
const LIGHT_COVER := Color("#77b6ad")
const REINFORCED_COVER := Color("#c7ac77")
const IMPERVIOUS_COVER := Color("#b5bfc7")
const ACTIVATION_SECONDS := 1.15

var effects: Array[Dictionary] = []
var activation: Dictionary = {}

func reset() -> void:
    effects.clear()
    activation.clear()

func advance(delta: float) -> bool:
    var changed: bool = not effects.is_empty() or not activation.is_empty()
    for i in range(effects.size() - 1, -1, -1):
        effects[i]["time"] += delta
        if effects[i]["time"] >= effects[i]["duration"]:
            effects.remove_at(i)
    if not activation.is_empty():
        activation["time"] += delta
        if activation["time"] >= ACTIVATION_SECONDS:
            activation.clear()
    return changed

func strike(from: Vector2, to: Vector2, melee: bool) -> void:
    effects.append({"kind": "melee" if melee else "shot", "from": from, "to": to,
        "duration": 0.22, "time": 0.0, "radius": 12.0, "color": Color("#ffdb9b")})

func burst(at: Vector2, radius: float, color: Color) -> void:
    effects.append({"kind": "burst", "to": at, "duration": 0.34, "time": 0.0,
        "radius": radius, "color": color})

func open_pod(pod: Vector2, hatch: Vector2, robot_id: int) -> void:
    activation = {"pod": pod, "hatch": hatch, "id": robot_id, "time": 0.0}

func pod_opening() -> float:
    if activation.is_empty():
        return 1.0
    return smoothstep(0.08, 0.42, float(activation["time"]))

func robot_reveal(id: int) -> float:
    if activation.is_empty() or int(activation["id"]) != id:
        return 1.0
    return smoothstep(0.42, 0.9, float(activation["time"]))

func draw_floor(canvas: CanvasItem, rect: Rect2, cell: Vector2i, annex_start: int) -> void:
    var p: Vector2 = rect.position
    var annex: bool = cell.x >= annex_start or cell.y >= 16
    var service_lane: bool = cell.y in [7, 8, 9]
    var base := Color("#535355") if annex else (Color("#565651") if service_lane else Color("#494b4a"))
    if (cell.x + cell.y * 3) % 5 < 2:
        base = base.lightened(0.035)
    canvas.draw_rect(rect, base)
    canvas.draw_rect(Rect2(p, Vector2(35, 1)), base.lightened(0.13))
    if cell.y in [7, 9]:
        var lane_y: int = 3 if cell.y == 7 else 31
        canvas.draw_rect(Rect2(p + Vector2(6, lane_y), Vector2(23, 2)), Color("#707063"))
    elif (cell.x * 3 + cell.y) % 7 == 0:
        canvas.draw_rect(Rect2(p + Vector2(6, 22), Vector2(15, 2)), base.darkened(0.18))
        canvas.draw_rect(Rect2(p + Vector2(9, 25), Vector2(10, 1)), base.darkened(0.12))

func draw_cover(canvas: CanvasItem, a: Vector2, b: Vector2, level: int, damaged: bool) -> void:
    var color: Color = LIGHT_COVER if level == 1 else (REINFORCED_COVER if level == 2 else IMPERVIOUS_COVER)
    var width: float = 4.0 if level == 1 else (6.0 if level == 2 else 8.0)
    var along: Vector2 = (b - a).normalized()
    var cross := Vector2(-along.y, along.x)
    canvas.draw_line(a, b, Color("#20262a"), width + 4.0)
    canvas.draw_line(a, b, color, width)
    if level == 2:
        canvas.draw_line(a + cross, b + cross, color.darkened(0.5), 2.0)
    elif level == 3:
        for offset in [6, 14, 22]:
            var tick: Vector2 = a + along * offset
            canvas.draw_line(tick - cross * 3, tick + cross * 3, GRID, 2.0)
    for end in [a, b]:
        canvas.draw_rect(Rect2(Vector2(end) - Vector2(2, 2), Vector2(4, 4)), color.lightened(0.28))
    if damaged:
        var middle: Vector2 = (a + b) * 0.5
        canvas.draw_line(middle - cross * 3 - along * 2, middle + cross * 3 + along * 2, Color("#402e2b"), 3.0)

func draw_pod(canvas: CanvasItem, center: Vector2, working: bool, deployed: bool) -> void:
    var p: Vector2 = center - Vector2(17, 16)
    var light := Color("#f3b16f") if working or deployed else Color("#828986")
    canvas.draw_rect(Rect2(p + Vector2(0, 3), Vector2(34, 31)), Color("#27272a"))
    canvas.draw_rect(Rect2(p + Vector2(1, 1), Vector2(32, 29)), Color("#61645f"))
    canvas.draw_rect(Rect2(p + Vector2(5, 3), Vector2(24, 24)), Color("#292c2e"))
    for x in [2, 8, 14, 20, 26]:
        canvas.draw_rect(Rect2(p + Vector2(x, 27), Vector2(4, 2)), light)
    var opening: float = roundf(pod_opening() * 8.0) if deployed else 0.0
    var door := Color("#afb0a0") if working or deployed else Color("#747773")
    canvas.draw_rect(Rect2(p + Vector2(6 - opening * 0.5, 5), Vector2(10, 19)), door)
    canvas.draw_rect(Rect2(p + Vector2(18 + opening * 0.5, 5), Vector2(10, 19)), door)
    if not working and not deployed:
        canvas.draw_line(p + Vector2(11, 7), p + Vector2(23, 19), Color("#373b3b"), 2.0)
        canvas.draw_line(p + Vector2(23, 7), p + Vector2(11, 19), Color("#373b3b"), 2.0)

func draw_effects(canvas: CanvasItem) -> void:
    for effect in effects:
        var t: float = float(effect["time"]) / float(effect["duration"])
        var to: Vector2 = effect["to"]
        var color: Color = effect["color"]
        color.a *= 1.0 - t
        match effect["kind"]:
            "shot":
                var from: Vector2 = effect["from"]
                var head: Vector2 = from.lerp(to, minf(t * 4.0, 1.0))
                if t < 0.48:
                    canvas.draw_line(from.lerp(to, maxf(0.0, (t - 0.12) * 2.8)), head, color, 2.0)
                    canvas.draw_circle(from, 3.5 * (1.0 - t), color)
                if t > 0.12:
                    draw_sparks(canvas, to, color, t * 13.0)
            "melee":
                var direction: Vector2 = (to - Vector2(effect["from"])).normalized()
                var cross := Vector2(-direction.y, direction.x)
                var sweep: Vector2 = to - direction * (1.0 - t) * 17.0
                canvas.draw_line(sweep - cross * 11.0, sweep + cross * 11.0 + direction * 8.0, color, 4.0)
                draw_sparks(canvas, to, color, t * 12.0)
            "burst":
                var spread: float = lerpf(4.0, float(effect["radius"]), t)
                canvas.draw_circle(to, spread, color, false, 3.0)
                draw_sparks(canvas, to, color, spread * 0.8)
    if not activation.is_empty():
        var time: float = activation["time"]
        var pod: Vector2 = activation["pod"]
        var hatch: Vector2 = activation["hatch"]
        var amber := Color("#ffbc72")
        amber.a = 0.9 * (1.0 - time / ACTIVATION_SECONDS)
        draw_sparks(canvas, pod, amber, 5.0 + time * 28.0)
        if time >= 0.3:
            var rise: float = clampf((time - 0.3) / 0.6, 0.0, 1.0)
            canvas.draw_rect(Rect2(hatch - Vector2(34, 34), Vector2(68, 68)), amber, false, 3.0)
            draw_sparks(canvas, hatch, amber, 8.0 + rise * 28.0)

func draw_sparks(canvas: CanvasItem, center: Vector2, color: Color, spread: float) -> void:
    for axis in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT, Vector2(-0.7, -0.7), Vector2(0.7, 0.7)]:
        var point: Vector2 = (center + Vector2(axis) * spread).round()
        canvas.draw_line(point, point + Vector2(axis) * 4.0, color, 2.0)
