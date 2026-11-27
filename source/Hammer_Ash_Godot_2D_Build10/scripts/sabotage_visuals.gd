extends RefCounted

const LIGHT_COVER := Color("#77b6ad")
const REINFORCED_COVER := Color("#c7ac77")
const IMPERVIOUS_COVER := Color("#b5bfc7")
var effects: Array[Dictionary] = []
var floor_tiles: Dictionary[int, Texture2D] = {}

func reset() -> void:
    effects.clear()

func advance(delta: float) -> bool:
    var changed: bool = not effects.is_empty()
    for i in range(effects.size() - 1, -1, -1):
        effects[i]["time"] += delta
        if effects[i]["time"] >= effects[i]["duration"]:
            effects.remove_at(i)
    return changed

static func attack_style(ability: String, melee: bool, support: Color) -> StringName:
    if melee:
        if ability in ["Hammer Blow", "Hammer finish", "Hammerfist", "Drop Hammer", "Carapace Slam", "Force Ram", "Colossal Combo"]:
            return &"slam"
        return &"slash"
    match ability:
        "Suit Cannon", "Breach Shell", "Micro-Rocket", "Rocket Salvo", "Cluster Burst", "Incendiary Shell", \
        "Siege Salvo", "Mortar Cup", "Walking Barrage", "Rolling Thunder", "Delayed Mortar", "Iron Rain", "Breach Kit":
            return &"shell"
        "Sightline", "Needle Beam", "Corneal Lance", "Pinhole Sun", "Retinal Lance", "Prism Shot", \
        "Fan Beam", "Sweep Beam", "The Void's Gaze", "Core Melter":
            return &"beam"
        "Arc Pistol", "Arc Net", "Remote Pulse", "Crossfire Protocol", "Shock Mine", "Chain Arc", "Nettle Lock", \
        "Scout Run", "Pincer Run", "Overclock Link", "Flak Curtain":
            return &"arc"
        "Quake Slam", "Iron Cataclysm", "Shell Collapse", "Empty the Shell", "Pressure Front", "Wrecking Ball":
            return &"slam"
        "Force Shell", "Iron Lock", "Anchor", "Gleaming Armour", "Lend Armour", "Shelter Reflex", \
        "Sanctuary", "Plastic Skin", "Shield Run", "Safe Passage", "Interceptor Bot":
            return &"shield"
        "Reload", "Recharge", "Vent", "Emergency Vent", "Emergency Cells", "Field Service", "Emergency Rebuild":
            return &"service"
        "Cell Mender", "Communal Clot", "Crisis Mending", "Regenerative Wave", "Field Hospital", \
        "Field Formula", "Reserve Dose", "Adrenal Rescue", "Medkit", "Passing Trait":
            return &"heal"
        "Designate Target", "Distort Aim", "Aphasia", "Panic Spike", "Thought Arrest", "Crowd Panic", \
        "Compression", "Feedback Spike", "Psychic Burst", "Projected Strike", "Force Hand", "Split Focus", \
        "Vector Pull", "Lateral Slip", "Compel Step", "Spatial Exchange", "Encasing Armour", "Hurl Debris":
            return &"pulse"
    if support.a > 0.0:
        return &"pulse" if support.r > support.g else &"heal"
    return &"shot"

static func action_seconds(style: StringName) -> float:
    match style:
        &"shot": return 0.24
        &"slash", &"arc": return 0.33
        &"shell", &"slam": return 0.44
        _: return 0.36

func strike(from: Vector2, to: Vector2, style: StringName, tint: Color = Color.TRANSPARENT) -> void:
    var palette := {&"shot": Color("#ffcc83"), &"slash": Color("#ffe5b3"),
        &"slam": Color("#ffbe76"), &"shell": Color("#ffab5a"),
        &"beam": Color("#ff6677"), &"arc": Color("#73e2ff"),
        &"pulse": Color("#cd91ff"), &"heal": Color("#88efad"),
        &"shield": Color("#80ccff"), &"service": Color("#f8d38f")}
    effects.append({"kind": style, "from": from, "to": to,
        "duration": 0.31 if style in [&"shot", &"slash"] else 0.51, "time": 0.0,
        "radius": 23.0, "color": palette.get(style, tint)})

func burst(at: Vector2, radius: float, color: Color, style: StringName = &"burst") -> void:
    effects.append({"kind": style, "to": at, "duration": 0.62 if style == &"blast" else 0.38,
        "time": 0.0, "radius": radius, "color": color})

func draw_floor(canvas: CanvasItem, rect: Rect2, cell: Vector2i, deck: bool, base: Color) -> void:
    var p: Vector2 = rect.position
    var seed: int = (cell.x * 131 + cell.y * 317) % 223
    var pattern: int = seed % 19
    var key: int = pattern + (20 if deck else 0)
    if not floor_tiles.has(key):
        floor_tiles[key] = create_floor_tile(pattern, deck)
    var finish: Color = base.lightened(float(seed % 8) * 0.011)
    canvas.draw_texture_rect(floor_tiles[key], rect, false, finish)
    if deck and cell.y in [7, 9]:
        var lane_y: int = 3 if cell.y == 7 else 31
        canvas.draw_rect(Rect2(p + Vector2(3, lane_y), Vector2(25, 2)), Color("#8e7953"))
    elif seed % 13 == 0:
        canvas.draw_polyline(PackedVector2Array([p + Vector2(0, 21), p + Vector2(9, 18),
            p + Vector2(15, 22), p + Vector2(22, 21)]), finish.darkened(0.29))

func create_floor_tile(seed: int, deck: bool) -> Texture2D:
    var image := Image.create_empty(35, 35, false, Image.FORMAT_RGBA8)
    image.fill(Color("#d2d2d2"))
    image.fill_rect(Rect2i(0, 0, 35, 1), Color("#ffffff"))
    image.fill_rect(Rect2i(0, 1, 1, 34), Color("#eeeeee"))
    image.fill_rect(Rect2i(1, 34, 34, 1), Color("#aaaaaa"))
    for i in range(26):
        var grit := Vector2i(2 + (seed * 7 + i * 11) % 29, 2 + (seed * 3 + i * 13) % 29)
        image.fill_rect(Rect2i(grit, Vector2i(1 + (seed + i) % 4, 1)), Color("#b8b8b8").darkened(0.065 * (i % 4)))
    if deck or seed % 7 == 0:
        for corner in [Vector2i(3, 3), Vector2i(30, 3), Vector2i(3, 30), Vector2i(30, 30)]:
            image.fill_rect(Rect2i(corner, Vector2i(2, 2)), Color("#858585"))
    if seed % 11 == 0:
        image.fill_rect(Rect2i(8, 11, 20, 12), Color("#9f9f9f"))
        for y in range(13, 22, 2):
            image.fill_rect(Rect2i(10, y, 16, 1), Color("#666666"))
    return ImageTexture.create_from_image(image)

func draw_shadow(canvas: CanvasItem, at: Vector2, width: float, opacity: float = 1.0) -> void:
    for i in range(3):
        var half: Vector2 = Vector2(width * 0.5 - i * 2, 5 - i)
        canvas.draw_colored_polygon(PackedVector2Array([at - Vector2(half.x, 0), at - half * 0.72,
            at + Vector2(half.x * 0.72, -half.y * 0.72), at + Vector2(half.x, 0),
            at + half * 0.72, at + Vector2(-half.x * 0.72, half.y * 0.72)]), Color(0.025, 0.035, 0.043, opacity * 0.24))

func layered_line(canvas: CanvasItem, from: Vector2, to: Vector2, color: Color, width: float) -> void:
    canvas.draw_line(from, to, Color(color, color.a * 0.19), width + 7, true)
    canvas.draw_line(from, to, Color(color, color.a * 0.65), width + 2, true)
    canvas.draw_line(from, to, color.lightened(0.75), width, true)

func draw_cover(canvas: CanvasItem, view: RefCounted, a: Vector2, b: Vector2, level: int, damaged: bool) -> void:
    var color: Color = LIGHT_COVER if level == 1 else (REINFORCED_COVER if level == 2 else IMPERVIOUS_COVER)
    canvas.draw_line(a, b, Color("#1c2427"), 8.0)
    canvas.draw_line(a, b, Color(color, 0.72), 3.0)
    canvas.draw_set_transform_matrix(view.camera)
    var left: Vector2 = view.project(a)
    var right: Vector2 = view.project(b)
    var rise := Vector2(0, -float([0, 7, 13, 16][level]))
    var top_a: Vector2 = left + rise
    var top_b: Vector2 = right + rise
    var recess := Vector2(0, 2)
    canvas.draw_colored_polygon(PackedVector2Array([top_a, top_b, right, left]), color.darkened(0.65))
    canvas.draw_line(top_a, top_b, color.lightened(0.22), 2.0)
    canvas.draw_line(top_a + recess, top_b + recess, color.darkened(0.12), 1.0)
    for mark in [0.06, 0.33, 0.67, 0.94]:
        var base: Vector2 = left.lerp(right, mark)
        canvas.draw_line(base + rise + recess, base, color.darkened(0.28), 1.5)
    if damaged:
        var nick: Vector2 = top_a.lerp(top_b, 0.54)
        canvas.draw_polyline(PackedVector2Array([nick, nick + Vector2(-2, 4), nick + Vector2(2, 6),
            nick + Vector2(0, 8)]), Color("#433023"), 2.0)
    canvas.draw_set_transform_matrix(view.ground)

func draw_effects(canvas: CanvasItem, view: RefCounted) -> void:
    for effect in effects:
        var t: float = float(effect["time"]) / float(effect["duration"])
        var ground: Vector2 = view.project(effect["to"])
        var to: Vector2 = ground - Vector2(0, 13)
        var from: Vector2 = view.project(effect.get("from", effect["to"])) - Vector2(0, 15)
        var direction: Vector2 = from.direction_to(to)
        var color: Color = effect["color"]
        color.a = 1.0 - t
        var radius: float = effect["radius"]
        match effect["kind"]:
            &"shot":
                if t < 0.44:
                    layered_line(canvas, from.lerp(to, clampf((t - 0.12) * 3.2, 0.0, 1.0)),
                        from.lerp(to, minf(1.0, t * 8.0 + 0.12)), color, 1.5)
                    draw_flash(canvas, from, direction, color, 1.0 - t * 2.0, 1.0)
                if t > 0.09:
                    draw_sparks(canvas, to, color, 15.0 * t, 8)
            &"beam":
                if t < 0.53:
                    layered_line(canvas, from, to, color, maxf(1.0, 4.0 * (1.0 - t * 1.9)))
                    draw_flash(canvas, to, direction, color, 1.0 - t, 1.0)
                draw_sparks(canvas, to, color, 26.0 * t, 12)
            &"arc":
                var bolt := PackedVector2Array([from])
                for segment in range(1, 9):
                    var point: Vector2 = from.lerp(to, segment / 9.0)
                    point += direction.orthogonal() * sin(segment * 51.0 + floorf(t * 16.0)) * 6.0
                    bolt.append(point)
                bolt.append(to)
                if t < 0.67:
                    canvas.draw_polyline(bolt, Color(color, color.a * 0.24), 8.0, true)
                    canvas.draw_polyline(bolt, color.lightened(0.72), 2.0, true)
                draw_sparks(canvas, to, color, 21.0 * t, 10)
            &"slash":
                var angle: float = direction.angle()
                for trail in range(3):
                    var start: float = angle - 1.85 + t * 2.55 + trail * 0.12
                    canvas.draw_arc(to - direction * 11.0, 19.0 - trail * 4.0, start, start + 1.24, 10,
                        Color(color.lightened(0.25), color.a * (1.0 - trail * 0.21)), 3.0 - trail * 0.5, true)
                draw_sparks(canvas, to, color, 23.0 * t, 9)
            &"shell":
                if t < 0.29:
                    var travel: float = t / 0.29
                    var head: Vector2 = from.lerp(to, travel) - Vector2(0, sin(travel * PI) * 20.0)
                    layered_line(canvas, head - direction * 20.0, head, color, 3.0)
                    draw_flash(canvas, from, direction, color, 1.0 - travel, 1.3)
                else:
                    draw_blast(canvas, ground, color, (t - 0.29) / 0.71, radius)
            &"slam", &"blast":
                draw_blast(canvas, ground, color, t, radius)
            &"heal", &"shield", &"service", &"pulse":
                if from.distance_to(to) > 7.0 and t < 0.55:
                    var packet: Vector2 = from.lerp(to, minf(t * 4.5 + 0.1, 1.0))
                    layered_line(canvas, packet.move_toward(from, 14), packet, color, 2.0)
                draw_aura(canvas, ground, color, t, effect["kind"])
            _:
                draw_ring(canvas, ground, lerpf(4.0, radius, t), color, 2.0)
                draw_sparks(canvas, to, color, radius * t, 8)

func draw_flash(canvas: CanvasItem, at: Vector2, direction: Vector2, color: Color, fade: float, scale: float) -> void:
    var side: Vector2 = direction.orthogonal() * scale
    var axis: Vector2 = direction * scale
    canvas.draw_colored_polygon(PackedVector2Array([at - axis * 4, at + side * 6,
        at + axis * 13, at - side * 6]), Color(color, fade * 0.75))
    canvas.draw_colored_polygon(PackedVector2Array([at - axis * 2, at + side * 2.5,
        at + axis * 9, at - side * 2.5]), Color(color.lightened(0.9), fade))

func draw_ring(canvas: CanvasItem, at: Vector2, radius: float, color: Color, width: float) -> void:
    var points := PackedVector2Array()
    for step in range(25):
        var axis: Vector2 = Vector2.from_angle(step * TAU / 24.0)
        points.append(at + axis * Vector2(radius, radius * 0.45))
    canvas.draw_polyline(points, color, width, true)

func draw_sparks(canvas: CanvasItem, center: Vector2, color: Color, spread: float, count: int) -> void:
    for index in range(count):
        var axis: Vector2 = Vector2.from_angle(index * 2.39996)
        var point: Vector2 = (center + axis * spread * (0.45 + 0.13 * (index % 5))).round()
        canvas.draw_line(point, point + axis * (2 + index % 6), color.lightened(0.38), 1 + index % 2)

func draw_blast(canvas: CanvasItem, ground: Vector2, color: Color, t: float, radius: float) -> void:
    var spread: float = lerpf(7.0, radius, ease(t, 0.45))
    var hot: Color = color.lightened(0.73)
    draw_ring(canvas, ground, spread, Color(color, color.a * 0.88), 2.0)
    draw_ring(canvas, ground, spread * 0.76, Color(color, color.a * 0.32), 4.0)
    if t < 0.22:
        var flash: Vector2 = ground - Vector2(0, 9)
        canvas.draw_circle(flash, 12.0 + t * 24.0, Color(color, (1.0 - t / 0.22) * 0.4))
        draw_flash(canvas, flash, Vector2.UP, hot, 1.0 - t / 0.22, 1.65)
    for i in range(12):
        var ray: Vector2 = Vector2.from_angle(i * 2.39996)
        var mote: Vector2 = ground + ray * Vector2(spread * 0.66, spread * 0.42) - Vector2(0, 8 + t * 14)
        var size: float = (4 + i % 4) * (1.25 - t * 0.45)
        canvas.draw_circle(mote.round(), size, Color(Color("#514653"), color.a * 0.46))
        if t < 0.44:
            canvas.draw_circle(mote.round(), size * (0.85 - t), Color(hot if i % 3 == 0 else color, color.a))
    draw_sparks(canvas, ground - Vector2(0, 9), color, spread * 0.9, 14)

func draw_aura(canvas: CanvasItem, ground: Vector2, color: Color, t: float, style: StringName) -> void:
    draw_ring(canvas, ground, 10.0 + t * 16.0, color, 2.0)
    if style == &"shield":
        var top: Vector2 = ground - Vector2(0, 17)
        canvas.draw_arc(top, 24.0, PI, TAU, 16, color, 2.0, true)
        canvas.draw_arc(top, 21.0, PI, TAU, 16, Color(color, color.a * 0.4), 3.0, true)
    for i in range(7):
        var axis: Vector2 = Vector2.from_angle(i * TAU / 7.0 + t * 2.5)
        var mote: Vector2 = (ground + axis * Vector2(13, 6) - Vector2(0, (t + i * 0.065) * 36)).round()
        canvas.draw_rect(Rect2(mote, Vector2(3, 3)), color.lightened(0.5))
        if style == &"heal":
            canvas.draw_rect(Rect2(mote + Vector2(-1, 1), Vector2(5, 1)), color)
            canvas.draw_rect(Rect2(mote + Vector2(1, -1), Vector2(1, 5)), color)
