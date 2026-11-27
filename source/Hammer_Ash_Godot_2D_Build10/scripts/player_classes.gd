extends RefCounted

const DATA_PATH: String = "res://data/player_classes_v3.json"
const REVIEW_PATH: String = "res://data/player_class_review.json"
const FORMS: Array[String] = ["Frog", "Jellyfish", "Skunk"]
const TREATMENTS: int = 4
const LEVEL_ONE_STATS: Dictionary = {
    "hp": 12, "max_hp": 12, "damage": 4, "armour": 0, "max_armour": 0, "range": 8, "move": 4,
}

static var catalog: Dictionary = {}

static func data(kit: String) -> Dictionary:
    if catalog.is_empty():
        catalog = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
        var review: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(REVIEW_PATH))
        for class_name_key in review:
            catalog[class_name_key]["origins"] = review[class_name_key]
    return catalog[kit]

static func default_build() -> Dictionary:
    return {"level": 1, "origin": 0, "choices": {}, "form": "Frog"}

static func nodes_at(kit: String, origin: int, level: int) -> Array:
    var tree: Dictionary = data(kit)
    var branch: Dictionary = tree["origins"][origin]
    return branch["levels"][level - 1]

static func unlocked(kit: String, build: Dictionary) -> Dictionary:
    var result: Dictionary = {}
    var choices: Dictionary = build["choices"]
    var origin: int = int(build["origin"])
    for level in range(1, int(build["level"]) + 1):
        var options: Array = nodes_at(kit, origin, level)
        if level == 1:
            for node: Dictionary in options:
                result[node["name"]] = node
        else:
            var node: Dictionary = options[clampi(int(choices.get(level, 0)), 0, options.size() - 1)]
            result[node["name"]] = node
    return result

static func maximum_hp(level: int, skills: Dictionary, supersuit_bonus: int) -> int:
    var hp: int = int(LEVEL_ONE_STATS["max_hp"]) + (level - 1) + supersuit_bonus
    for skill: Dictionary in skills.values():
        hp += int(skill.get("max_hp_bonus", 0))
    return hp

static func base_attack(kit: String, build: Dictionary, form: String, damage: int, reach: int) -> Dictionary:
    var origin: int = int(build["origin"])
    # Attack name, melee, uses charges.
    var attack: Array = ["Ranged Attack", false, false]
    match kit:
        "Scythe": attack = ["Claws" if origin == 0 else "Tail Sting", true, false]
        "Anvil": attack = ["Iron Fist" if origin == 0 else "Mantle Fist", true, false]
        "Needle": attack = ["Sightline", false, true] if origin == 0 else ["Talons", true, false]
        "Iskra":
            attack = ["Arc Pistol" if origin == 0 else "Suit Cannon", false, true]
            reach -= 2
            damage -= int(origin == 0)
        "Glaz": attack = ["Synaptic Prick" if origin == 0 else "Force Bolt", false, false]
        "Alkhimik":
            if origin == 1:
                attack = ["Rending Strike", true, false] if form == "Hyde" else ["Irritant Dart", false, false]
            else:
                damage -= 2
                if form == "Skunk":
                    reach -= 4
                match form:
                    "Jellyfish": attack = ["Sting", true, false]
                    "Skunk": attack = ["Spray", false, false]
                    _: attack = ["Bite", true, false]
    var skills: Dictionary = unlocked(kit, build)
    reach += 2 * int(skills.has("Long Focus")) + int(skills.has("Long Lever"))
    return {"name": attack[0], "melee": attack[1], "damage": damage,
        "range": 1 if attack[1] else reach, "charged": attack[2]}

static func stat_modifiers(skills: Dictionary, form: String, apex: bool = false) -> Vector2i:
    var armour: int = 3 * (int(skills.has("Ferrous Body")) + int(skills.has("Living Mantle")))
    for skill in ["Segmented Carapace", "Deflective Plates", "Rolled Plate", "Thick Mantle", "Mental Fortress", "Paired Deployment"]:
        armour += int(skills.has(skill))
    armour += 2 * (int(skills.has("Work Hardening")) + int(skills.has("Siege Mount")))
    var movement: int = int(skills.has("Rosette Claws")) + int(skills.has("Tempered Knuckles"))
    if skills.has("Darwinian Shift"):
        match form:
            "Frog": movement += 2 if apex else 1
            "Jellyfish":
                movement -= 1
    return Vector2i(armour, movement)

static func armour_capacity(base: int, modifier: int, skills: Dictionary) -> int:
    return 0 if skills.has("Hawk Wings") else maxi(0, base + modifier)
