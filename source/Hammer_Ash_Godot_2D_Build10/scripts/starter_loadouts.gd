extends RefCounted

const SUPERSUIT: String = "Supersuit"
const SUPERSUIT_DETAIL: String = "Standard issue for every operative"
const MEDKIT_NAME: String = "Medkit"
const MEDKIT_DETAIL: String = "Heal up to 3 HP · 1 AP · single use"
const MEDKIT_HP: int = 3
const MELEE_AP: int = 1
const MEDKIT_AP: int = 1
const CONSUMABLES: Array[String] = [MEDKIT_NAME, "Empty"]
const NO_CONSUMABLE: int = 1

static func defaults() -> Array[int]:
    return [0, 0, 0, 0, 0]

static func equip(unit: Dictionary, consumable: int) -> void:
    unit["supersuit"] = SUPERSUIT
    unit["supersuit_hp_bonus"] = 0
    unit["medkit_charges"] = int(consumable == 0)
