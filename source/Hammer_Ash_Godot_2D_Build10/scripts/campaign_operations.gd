extends RefCounted

const MOSCOW_DISTRICT := "central"
const KINDS := ["patrol", "relay", "rescue", "sweep"]
const PIN_LABELS := ["Patrol", "Relay", "Rescue", "Sweep"]
const BRIEFS := [
    "Clear the patrol and secure the crossing.",
    "Destroy the power generator and clear its defenders.",
    "Release both prisoners and clear the guards. Interact from an adjacent tile for 1 AP.",
    "Clear three linked areas. Injuries and used consumables carry forward between rooms.",
]
const RECOMMENDED_LEVELS := {
    "northwestern/patrol": {"general": 1},
    "northwestern/relay": {"general": 3, "fire_support": 1},
    "northwestern/rescue": {"general": 1},
    "northwestern/sweep": {"general": 9, "fire_support": 7},
    "southern/patrol": {"general": 1},
    "southern/relay": {"general": 5, "fire_support": 1},
    "southern/rescue": {"general": 5, "fire_support": 1},
    "southern/sweep": {"general": 3},
    "north_caucasian/patrol": {"general": 1},
    "north_caucasian/relay": {"general": 7, "fire_support": 1},
    "north_caucasian/rescue": {"general": 7, "fire_support": 1},
    "north_caucasian/sweep": {"general": 9, "fire_support": 5},
    "volga/patrol": {"general": 3, "fire_support": 1},
    "volga/relay": {"general": 9, "fire_support": 5},
    "volga/rescue": {"general": 1},
    "volga/sweep": {"general": 9, "fire_support": 3},
    "ural/patrol": {"general": 1},
    "ural/relay": {"general": 3, "fire_support": 1},
    "ural/rescue": {"general": 9, "fire_support": 3},
    "ural/sweep": {"general": 9, "fire_support": 3},
    "siberian/patrol": {"general": 1},
    "siberian/relay": {"general": 1},
    "siberian/rescue": {"general": 3},
    "siberian/sweep": {"general": 7, "fire_support": 1},
    "far_eastern/patrol": {"general": 3, "fire_support": 1},
    "far_eastern/relay": {"general": 9, "fire_support": 1},
    "far_eastern/rescue": {"general": 3, "fire_support": 1},
    "far_eastern/sweep": {"general": 7},
}
const RECON := [
    "The patrol is spread across two approaches. Use the breaks in the cover to isolate its shooters.",
    "The generator sits behind the near partition. You can attack it with a basic attack.",
    "The prisoners are held at opposite ends of the block. Both are secured after the guards fall.",
    "The approach opens into a tighter checkpoint and then a wider yard. You can extract between cleared rooms.",
]

# Each site defines its briefing title, district-map point and ordered enemy posts.
# Sweeps supply separate formations for the approach, checkpoint and yard.
const REGIONS := {
    "northwestern": {
        "cover": Vector2i(8, 4), "mirror": false,
        "sites": [
            ["Breakwater Patrol", [-662, 2678], ["Rifleman", "Assault Operative", "Marksman", "Collectivist Drone", "Rifleman"]],
            ["Dockside Relay", [255, 2170], ["Rifleman", "Man of Steel", "Collectivist Drone", "Pravda Man", "Grenadier"]],
            ["Canal Lockup", [-710, 3298], ["Rifleman", "Kulak", "Marksman", "Captain", "Assault Operative"]],
            ["Freight Yard Sweep", [13, 3016], [
                ["Rifleman", "Collectivist Drone", "Assault Operative", "Kulak"],
                ["Rifleman", "Matryoshka", "Grenadier", "Captain", "Marksman"],
                ["Assault Operative", "Man of Steel", "Matryoshka", "New Soviet Woman", "Rifleman"]]],
        ],
    },
    "southern": {
        "cover": Vector2i(8, 5), "mirror": true,
        "sites": [
            ["Levee Patrol", [-216, 4891], ["Kulak", "Rifleman", "Kulak", "Grenadier", "Marksman"]],
            ["Grain Silo Relay", [138, 4787], ["Collectivist Drone", "Rifleman", "Collectivist Drone", "Combine", "Assault Operative"]],
            ["Pump Station Rescue", [-157, 5114], ["Kulak", "Rifleman", "Kapitalist", "Clergy", "Rifleman"]],
            ["Floodplain Sweep", [138, 5045], [
                ["Kulak", "Kulak", "Rifleman", "Assault Operative"],
                ["Collectivist Drone", "Man of Steel", "Grenadier", "Siberian", "Marksman"],
                ["Kulak", "Kapitalist", "Noble", "Clergy", "Individualist"]]],
        ],
    },
    "north_caucasian": {
        "cover": Vector2i(8, 6), "mirror": false,
        "sites": [
            ["Switchback Patrol", [-79, 5283], ["Assault Operative", "Rifleman", "Marksman", "Kulak", "Vanguard"]],
            ["Ridge Relay", [156, 5216], ["Rifleman", "Grenadier", "Pravda Man", "Red Star", "Marksman"]],
            ["Quarry Lockup", [-14, 5405], ["Kulak", "Kapitalist", "Rifleman", "Individualist", "Assault Operative"]],
            ["Pass Road Sweep", [156, 5383], [
                ["Rifleman", "Collectivist Drone", "Marksman", "Kulak"],
                ["Kulak", "Kapitalist", "Grenadier", "Clergy", "Noble"],
                ["Vanguard", "Hammer", "Proletariat", "Sickle", "New Soviet Woman"]]],
        ],
    },
    "volga": {
        "cover": Vector2i(8, 7), "mirror": true,
        "sites": [
            ["Ferry Crossing", [-67, 3959], ["Rifleman", "Collectivist Drone", "Rifleman", "Grenadier", "Captain"]],
            ["Turbine Relay", [402, 3801], ["Collectivist Drone", "Man of Steel", "Rifleman", "Matryoshka", "Assault Operative"]],
            ["Warehouse Rescue", [11, 4303], ["Rifleman", "Assault Operative", "Kulak", "Sickle", "Pravda Man"]],
            ["Weir Compound Sweep", [402, 4197], [
                ["Collectivist Drone", "Rifleman", "Collectivist Drone", "Pravda Man"],
                ["Collectivist Drone", "Man of Steel", "Captain", "Marksman", "Matryoshka"],
                ["Collectivist Drone", "Hammer", "Proletariat", "Siberian", "Grenadier"]]],
        ],
    },
    "ural": {
        "cover": Vector2i(8, 8), "mirror": false,
        "sites": [
            ["Slag Yard Patrol", [-155, 3207], ["Collectivist Drone", "Collectivist Drone", "Rifleman", "Marksman", "Man of Steel"]],
            ["Smelter Relay", [409, 2927], ["Rifleman", "Collectivist Drone", "Grenadier", "Nevalyashka", "Pravda Man"]],
            ["Mine Office Rescue", [-61, 3811], ["Assault Operative", "Rifleman", "Captain", "Matryoshka", "Collectivist Drone"]],
            ["Ore Terminal Sweep", [409, 3625], [
                ["Collectivist Drone", "Rifleman", "Assault Operative", "Collectivist Drone"],
                ["Collectivist Drone", "Man of Steel", "Pravda Man", "Matryoshka", "Grenadier"],
                ["Collectivist Drone", "Nevalyashka", "Combine", "Man of Steel", "Marksman"]]],
        ],
    },
    "siberian": {
        "cover": Vector2i(8, 9), "mirror": true,
        "sites": [
            ["Logging Road Patrol", [-210, 2958], ["Kulak", "Kulak", "Assault Operative", "Kapitalist", "Marksman"]],
            ["Repeater Relay", [676, 2534], ["Rifleman", "Collectivist Drone", "Marksman", "Siberian", "Rifleman"]],
            ["Transit Camp Rescue", [-155, 3875], ["Kulak", "Individualist", "Kulak", "Clergy", "Grenadier"]],
            ["Timber Depot Sweep", [676, 3593], [
                ["Kulak", "Rifleman", "Kulak", "Grenadier"],
                ["Kulak", "Kapitalist", "Assault Operative", "Clergy", "Noble"],
                ["Kulak", "Kapitalist", "Siberian", "Noble", "Clergy"]]],
        ],
    },
    "far_eastern": {
        "cover": Vector2i(8, 10), "mirror": false,
        "sites": [
            ["Harbour Patrol", [-853, 3606], ["Assault Operative", "Rifleman", "Vanguard", "Collectivist Drone", "Marksman"]],
            ["Clifftop Relay", [663, 3062], ["Collectivist Drone", "Rifleman", "Grenadier", "Red Star", "New Soviet Woman"]],
            ["Ferry Terminal Rescue", [-407, 4539], ["Assault Operative", "Rifleman", "Pravda Man", "Nevalyashka", "Marksman"]],
            ["Coastal Depot Sweep", [574, 4228], [
                ["Rifleman", "Collectivist Drone", "Marksman", "Vanguard"],
                ["Collectivist Drone", "Matryoshka", "Man of Steel", "Marksman", "Assault Operative"],
                ["Vanguard", "New Soviet Man", "Grenadier", "New Soviet Woman", "Red Star"]]],
        ],
    },
}

# Coordinates use the logical grid. Walls and platforms are rectangular groups
# of tiles. A cover mark gives the anchor coordinates and east-edge cover level.
const LAYOUTS := {
    "patrol": {
        "label": "Crossing", "size": Vector2i(19, 14), "entry": [2, 4, 6, 9, 11],
        "posts": [Vector2i(13, 3), Vector2i(12, 9), Vector2i(15, 5), Vector2i(14, 11), Vector2i(16, 8)],
        "walls": [Rect2i(6, 4, 2, 2), Rect2i(10, 7, 3, 1), Rect2i(16, 2, 1, 2)],
        "cover": [Vector3i(4, 4, 1), Vector3i(4, 9, 1), Vector3i(6, 10, 2), Vector3i(11, 4, 2), Vector3i(14, 5, 1), Vector3i(14, 10, 1)],
        "barrels": {"fuel": Vector2i(10, 5), "waste": Vector2i(11, 11)},
    },
    "relay": {
        "label": "Relay Station", "size": Vector2i(21, 15), "entry": [4, 5, 7, 9, 10],
        "posts": [Vector2i(12, 3), Vector2i(15, 6), Vector2i(12, 11), Vector2i(16, 5), Vector2i(18, 10)],
        "walls": [Rect2i(8, 1, 1, 4), Rect2i(9, 6, 1, 4), Rect2i(11, 11, 1, 3), Rect2i(14, 8, 4, 1)],
        "cover": [Vector3i(4, 5, 1), Vector3i(6, 8, 2), Vector3i(6, 11, 1), Vector3i(10, 5, 2), Vector3i(12, 7, 2), Vector3i(17, 5, 1), Vector3i(16, 11, 2)],
        "high_ground": [Rect2i(6, 2, 2, 2), Rect2i(16, 4, 2, 2)],
        "barrels": {"fuel": Vector2i(13, 4), "waste": Vector2i(13, 10)},
        "generator": Vector2i(12, 7),
    },
    "rescue": {
        "label": "Detention Block", "size": Vector2i(18, 16), "entry": [5, 6, 8, 10, 11],
        "posts": [Vector2i(10, 3), Vector2i(12, 6), Vector2i(11, 10), Vector2i(15, 12), Vector2i(15, 5)],
        "walls": [Rect2i(5, 5, 3, 1), Rect2i(5, 10, 3, 1), Rect2i(9, 2, 1, 4), Rect2i(9, 10, 1, 4), Rect2i(13, 3, 3, 1), Rect2i(13, 9, 3, 1)],
        "cover": [Vector3i(4, 4, 1), Vector3i(5, 8, 2), Vector3i(8, 7, 1), Vector3i(11, 6, 2), Vector3i(12, 12, 2), Vector3i(15, 7, 1)],
        "barrels": {"fuel": Vector2i(10, 5), "waste": Vector2i(12, 11)},
        "prisoners": [Vector2i(14, 2), Vector2i(14, 13)],
    },
    "approach": {
        "label": "Depot Approach", "size": Vector2i(18, 14), "entry": [4, 5, 6, 7, 8],
        "posts": [Vector2i(11, 4), Vector2i(13, 2), Vector2i(12, 8), Vector2i(14, 10)],
        "walls": [Rect2i(6, 2, 1, 4), Rect2i(9, 9, 4, 1)],
        "cover": [Vector3i(3, 5, 1), Vector3i(6, 7, 1), Vector3i(8, 5, 2), Vector3i(10, 4, 1), Vector3i(12, 7, 2), Vector3i(14, 9, 1)],
        "barrels": {"fuel": Vector2i(9, 6), "waste": Vector2i(13, 11)},
    },
    "checkpoint": {
        "label": "Inner Checkpoint", "size": Vector2i(19, 13), "entry": [2, 4, 6, 8, 10],
        "posts": [Vector2i(11, 2), Vector2i(12, 6), Vector2i(12, 9), Vector2i(15, 4), Vector2i(15, 8)],
        "walls": [Rect2i(7, 0, 1, 3), Rect2i(7, 5, 1, 3), Rect2i(7, 10, 1, 3), Rect2i(10, 4, 4, 1), Rect2i(10, 8, 4, 1)],
        "cover": [Vector3i(4, 3, 2), Vector3i(4, 9, 2), Vector3i(8, 3, 1), Vector3i(9, 6, 2), Vector3i(10, 10, 1), Vector3i(14, 6, 2)],
        "barrels": {"fuel": Vector2i(9, 5), "waste": Vector2i(14, 10)},
    },
    "yard": {
        "label": "Upper Depot Yard", "size": Vector2i(22, 16), "entry": [3, 5, 7, 9, 12],
        "posts": [Vector2i(13, 4), Vector2i(13, 11), Vector2i(15, 8), Vector2i(18, 5), Vector2i(18, 10)],
        "walls": [Rect2i(6, 6, 2, 2), Rect2i(11, 2, 1, 3), Rect2i(11, 11, 1, 3), Rect2i(15, 6, 4, 1), Rect2i(16, 12, 3, 1)],
        "cover": [Vector3i(4, 4, 1), Vector3i(5, 11, 1), Vector3i(8, 3, 2), Vector3i(10, 8, 2), Vector3i(13, 6, 1), Vector3i(14, 10, 1), Vector3i(17, 5, 2)],
        "high_ground": [Rect2i(7, 2, 3, 2), Rect2i(16, 3, 3, 2)],
        "barrels": {"fuel": Vector2i(12, 5), "waste": Vector2i(15, 11)},
    },
}

static func in_district(district: String) -> Array[String]:
    var operations: Array[String] = []
    if REGIONS.has(district):
        for kind: String in KINDS:
            operations.append(district + "/" + kind)
    return operations

static func has_operation(id: String) -> bool:
    return REGIONS.has(id.get_slice("/", 0)) and KINDS.has(id.get_slice("/", 1)) and id.get_slice_count("/") == 2

static func operation(id: String) -> Dictionary:
    var district := id.get_slice("/", 0)
    var kind := id.get_slice("/", 1)
    var index: int = KINDS.find(kind)
    var site: Array = REGIONS[district]["sites"][index]
    var brief: String = BRIEFS[index]
    if RECOMMENDED_LEVELS.has(id):
        var levels: Dictionary = RECOMMENDED_LEVELS[id]
        brief += "\n\nRecommended minimum\nLevel %d" % levels["general"]
        if levels.has("fire_support"):
            brief += " for general squads\nLevel %d with fire support" % levels["fire_support"]
    return {"label": site[0], "point": site[1], "pin": PIN_LABELS[index],
        "brief": brief, "recon": RECON[index], "kind": kind, "formation": site[2]}

static func room_count(id: String) -> int:
    return 3 if id.get_slice("/", 1) == "sweep" else 1

static func layout(id: String, stage: int) -> Dictionary:
    var kind := id.get_slice("/", 1)
    return LAYOUTS[["approach", "checkpoint", "yard"][stage] if kind == "sweep" else kind]

static func battle_tile(id: String, tile: Vector2i, height: int) -> Vector2i:
    return Vector2i(tile.x, height - 1 - tile.y) if REGIONS[id.get_slice("/", 0)]["mirror"] else tile
