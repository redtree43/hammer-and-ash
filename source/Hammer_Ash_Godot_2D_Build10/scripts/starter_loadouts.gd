extends RefCounted

const MEDKIT_NAME: String = "Medkit"
const MEDKIT_HP: int = 3
const MELEE_AP: int = 1
const MEDKIT_AP: int = 1
const NEEDLE_INDEX: int = 2  # Needle's issued firearm is a two-handed rifle.
const EMPTY_MELEE: int = 1

const SLOTS: Array[String] = ["Ranged weapon", "Melee weapon", "Armour", "Equipment"]
const ITEMS: Array = [
    [
        {"name": "Issued firearm", "detail": "Class weapon · 3 rounds"},
        {"name": "Service Rifle", "detail": "3 damage · 7 range · 3 rounds", "damage": 3, "range": 7, "two_handed": true},
        {"name": "Service Pistol", "detail": "2 damage · 5 range · 3 rounds", "damage": 2, "range": 5},
    ],
    [
        {"name": "Utility Knife", "detail": "2 damage · adjacent · 1 AP", "damage": 2},
        {"name": "Empty", "detail": "No melee weapon"},
    ],
    [
        {"name": "Issued armour", "detail": "Keeps the class's starting armour"},
        {"name": "Field Vest", "detail": "2 armour", "armour": 2},
    ],
    [
        {"name": MEDKIT_NAME, "detail": "Heal up to 3 HP · 1 AP · single use", "charges": 1},
        {"name": "Empty", "detail": "No equipment item"},
    ],
]

static func defaults() -> Array[Array]:
    var loadouts: Array[Array] = []
    for idx in range(5):
        loadouts.append([0, EMPTY_MELEE if idx == NEEDLE_INDEX else 0, 0, 0])
    return loadouts

static func blocks_melee(idx: int, ranged_option: int) -> bool:
    return (ranged_option == 0 and idx == NEEDLE_INDEX) or bool(ITEMS[0][ranged_option].get("two_handed", false))

static func can_equip(idx: int, choices: Array, slot: int, option: int) -> bool:
    return slot != 1 or option == EMPTY_MELEE or not blocks_melee(idx, choices[0])

static func select_item(idx: int, choices: Array, slot: int, option: int) -> void:
    if not can_equip(idx, choices, slot, option):
        return
    choices[slot] = option
    if slot == 0 and blocks_melee(idx, option):
        choices[1] = EMPTY_MELEE

static func equip(unit: Dictionary, choices: Array) -> void:
    unit["issued_firearm"] = {"name": unit["basic_attack"], "damage": unit["damage"], "range": unit["range"]}
    unit["issued_armour"] = unit["max_armour"]
    var ranged: Dictionary = ITEMS[0][choices[0]]
    if ranged.has("damage"):
        unit["basic_attack"] = ranged["name"]
        unit["damage"] = ranged["damage"]
        unit["range"] = ranged["range"]
    var kit_index: int = int(unit.get("kit_index", unit["id"]))
    var melee_option: int = EMPTY_MELEE if blocks_melee(kit_index, choices[0]) else int(choices[1])
    var melee: Dictionary = ITEMS[1][melee_option]
    unit["melee_weapon"] = melee["name"] if melee.has("damage") else ""
    unit["melee_damage"] = int(melee.get("damage", 0))
    var armour: Dictionary = ITEMS[2][choices[2]]
    unit["armour_name"] = str(armour["name"])
    unit["max_armour"] = int(armour.get("armour", unit["max_armour"]))
    var equipment: Dictionary = ITEMS[3][choices[3]]
    unit["medkit_charges"] = int(equipment.get("charges", 0))
