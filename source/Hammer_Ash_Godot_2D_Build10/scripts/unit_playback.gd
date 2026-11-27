extends RefCounted

## Plays resolved actions in order. Board positions can advance ahead of the cutouts.
const WALK_SECONDS := 0.10
const LEAP_SECONDS := 0.36
const LEAP_HEIGHT := 34.0
const DISPLACE_SECONDS := 0.12
const TURN_SECONDS := 0.045
const IMPACT_FRACTION := 0.38
const INITIAL_FACING := Vector2i.RIGHT

var facing: Dictionary[int, Vector2i] = {}
var motion_counts: Dictionary[int, int] = {}
var ground_positions: Dictionary[int, Vector2] = {}
var events: Array[Dictionary] = []
var current: Dictionary = {}
var elapsed := 0.0
var lift := 0.0
var stride := 0

static func nearest_facing(delta: Vector2, directions: Array[Vector2i]) -> Vector2i:
    var best := Vector2i.ZERO
    var alignment := 0.0
    for direction in directions:
        var score: float = delta.dot(Vector2(direction).normalized())
        if score > alignment:
            best = direction
            alignment = score
    return best

func reset() -> void:
    facing.clear()
    motion_counts.clear()
    ground_positions.clear()
    events.clear()
    current.clear()
    elapsed = 0.0
    lift = 0.0
    stride = 0

func busy() -> bool:
    return not current.is_empty() or not events.is_empty()

func motion(id: int, from: Vector2, to: Vector2, direction: Vector2i, kind: StringName, duration: float) -> void:
    if not ground_positions.has(id):
        ground_positions[id] = from
    motion_counts[id] = motion_counts.get(id, 0) + 1
    events.append({"id": id, "kind": kind, "from": from, "to": to, "facing": direction,
        "duration": duration})

func action(id: int, direction: Vector2i, style: StringName, duration: float, effect: Callable) -> void:
    events.append({"id": id, "kind": &"turn", "facing": direction, "duration": TURN_SECONDS})
    events.append({"id": id, "kind": &"attack", "style": style, "impact": effect, "duration": duration})

func after_queued_actions(effect: Callable) -> void:
    if busy():
        events.append({"effect": effect, "duration": 0.0})
    else:
        effect.call()

func pose(id: int) -> StringName:
    if current.get("id", -1) == id:
        return current.get("style", current["kind"])
    return &"idle"

func progress() -> float:
    return 0.0 if current.is_empty() else elapsed / float(current["duration"])

func advance(delta: float) -> bool:
    if not busy():
        return false
    if not current.is_empty():
        elapsed = minf(elapsed + delta, current["duration"])
        if current.has("impact") and progress() >= IMPACT_FRACTION:
            current["impact"].call()
            current.erase("impact")
        if current.has("from"):
            var id: int = current["id"]
            var t: float = progress()
            var travel: float = float(t >= 0.48) if current["kind"] == &"blink" else t
            ground_positions[id] = Vector2(current["from"]).lerp(current["to"], travel)
            if current["kind"] == &"leap":
                lift = LEAP_HEIGHT * 4.0 * t * (1.0 - t)
        if elapsed < float(current["duration"]):
            return true
        if current.has("from"):
            var id: int = current["id"]
            motion_counts[id] -= 1
            if motion_counts[id] == 0:
                motion_counts.erase(id)
                ground_positions.erase(id)
        current = {}
        lift = 0.0
    while not events.is_empty():
        var next: Dictionary = events.pop_front()
        var direction: Vector2i = next.get("facing", Vector2i.ZERO)
        if direction != Vector2i.ZERO:
            facing[next["id"]] = direction
        if next.has("effect"):
            next["effect"].call()
        if float(next["duration"]) > 0.0:
            current = next
            elapsed = 0.0
            if current["kind"] == &"walk":
                stride += 1
            break
    return true
