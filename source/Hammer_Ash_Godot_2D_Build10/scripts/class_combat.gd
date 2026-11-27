extends RefCounted

const Classes = preload("res://scripts/player_classes.gd")
const INVALID := Vector2i(-1, -1)
const FORMS = Classes.FORMS
const TREATMENT_COST := {"Cell Mender": 1, "Communal Clot": 2, "Crisis Mending": 2, "Regenerative Wave": 2}
const HEAT_COST := {"Power Routing": 1, "Micro-Rocket": 1, "Rocket Salvo": 1, "Cluster Burst": 1,
    "Arc Net": 1, "Delayed Mortar": 1, "Iron Rain": 2}
const DRONE_ACTIONS := ["Remote Pulse", "Interceptor Bot", "Saboteur Bot", "Remote Override", "Crossfire Protocol"]
const SELF_ACTIONS := ["Overdrive", "Chitin Dodge", "Force Shell", "Iron Lock", "Quake Slam", "Iron Cataclysm",
    "Psychic Burst", "Perfect Opportunity", "Power Routing", "Emergency Vent", "Interceptor Bot",
    "Emergency Overdrive", "Darwinian Shift", "Catalytic Cascade", "Apex Reconfiguration", "Regenerative Wave"]
const MODES := {"Force Hand": ["Push", "Pull"], "Power Routing": ["Mobility", "Overcharge"],
    "Adaptive Catalyst": ["Mobility", "Barrier"], "Darwinian Shift": FORMS,
    "Shed Skin": FORMS, "Rapid Metamorph": FORMS, "Perfect Adaptation": FORMS, "Lateral Slip": ["Left", "Right"], "Vector Pull": ["1 Tile", "2 Tiles"],
    "Charge": ["1 AP", "2 AP", "3 AP"], "Mosaic Body": ["Frog / Jellyfish", "Frog / Skunk", "Jellyfish / Frog", "Jellyfish / Skunk", "Skunk / Frog", "Skunk / Jellyfish"]}
const REVIEW_HEAT := {"Breach Shell": 2, "Mortar Cup": 2, "Walking Barrage": 2, "Flak Curtain": 2,
    "Incendiary Shell": 2, "Siege Salvo": 3, "Rolling Thunder": 2}
const DRONE_ORDERS := ["Scout Run", "Pincer Run", "Shield Run", "Recovery Winch", "Overclock Link"]
const GENERATED_ACTION_DETAILS := {
    "Follow-up Step": "Take the free movement step granted by your previous action.",
    "Suppress Reaction": "Disrupt reactions on the enemy just hit by your basic attack.",
    "Impulse Push": "Push the enemy just hit by your basic attack away from you.",
    "Treat Patient": "Treat a standing ally in your Field Hospital who has yet to receive treatment.",
    "Lend Armour": "Transfer up to 3 current armour to another standing ally in range.",
    "Tandem Move": "Move the drone up to two steps after the operator moves.",
    "Tailwind Flight": "Fly to a legal landing within two tiles after defeating your quarry.",
    "Bedside Cover": "Give 1 barrier to an adjacent ally below half their healing ceiling.",
    "Hyde Follow-through": "Step into the tile vacated by the enemy you struck.",
    "Counterweight Slide": "Move a standing ally within three tiles to a legal adjacent tile.",
    "Transform": "Switch from Jekyll to Hyde.",
    "Revert": "Return to Jekyll before the automatic reversion.",
    "Fly": "Fly to a legal landing within five tiles, or six with Spread Your Wings.",
    "Anchor": "Mount the artillery suit for heavy fire and hold position until the next squad turn.",
    "Vent": "Remove 2 Heat, or 3 with Cooling Fins.",
    "Breach Shell": "Spend 2 Heat to hit a cover edge four to eight tiles away for 5 structural damage. Units on either side take 2 damage.",
    "Scout Run": "Move the drone up to two tiles and optionally fire an Arc Bolt for 2 damage within four tiles.",
    "Pincer Run": "Move the drone up to three tiles and fire for 3 damage within four tiles. Flanking can cancel Overwatch.",
    "Shield Run": "Move the drone up to three tiles and project three full-cover edges in a chosen direction.",
    "Tongue Vault": "Leap to a legal landing, then optionally pull a nearby enemy one tile toward you.",
    "Nettle Lock": "Strike an adjacent enemy and slow them.",
    "Musk Trail": "Lay a trail that damages and blinds enemies who enter it.",
}
const TARGET_STEPS := {"Compel Step": 2, "Lift Ally": 2, "Raptor Descent": 2, "Iron Rain": 3,
    "Wingover": 2, "Banking Turn": 2, "Safe Passage": 2, "Breach Kit": 2, "Breach Shell": 2, "Rolling Thunder": 2,
    "Rake": 3, "Split Focus": 2, "Phantom Threat": 2, "Spatial Exchange": 2, "Strike and Drop": 3,
    "Hurl Debris": 3, "Rosette Rush": 5, "Overclock Link": 5, "Mosaic Body": 2,
    "Scout Run": 2, "Pincer Run": 3, "Shield Run": 3, "Tongue Vault": 2, "Breach Relay": 2, "Adrenal Rescue": 2,
    "Passing Trait": 2, "Rampage": 3, "Field Hospital": 4, "Sanctuary": 99,
    "Throw": 2, "Wrecking Ball": 2, "Counterweight Slide": 2}
const REVIEW_RANGED := {
    "Needle Beam": [7, 4], "Corneal Lance": [5, 2], "Pinhole Sun": [8, 8],
    "The Void's Gaze": [7, 4],
    "Feedback Spike": [5, 4], "Compression": [4, 4], "Encasing Armour": [4, 6],
}
const REVIEW_TARGETS := {
    "Designate Target": 8, "Distort Aim": 4, "Aphasia": 5, "Panic Spike": 5,
    "Thought Arrest": 4, "Crowd Panic": 5, "Vector Pull": 5, "Lateral Slip": 4,
    "Throw": 1, "Drop Hammer": 1, "Claw Grab": 1, "Hooked Pincers": 2,
    "Carapace Slam": 1, "Colossal Combo": 1, "Stooping Strike": 1,
    "Crush Bite": 1, "Open the Seam": 1, "Hurl Aside": 1,
}
# These nodes use the same target validation for board previews and resolution.
const REVIEW_ACTIONS := [
    "Field Formula", "Reserve Dose", "Finish the Job", "Taunt", "Thundering Taunt",
    "Gleaming Armour", "Mortar Cup", "Breach Kit", "Breach Shell", "Siege Salvo", "Anchor", "Flak Curtain", "Incendiary Shell", "Rolling Thunder",
    "Vent", "Pressure Front", "Empty the Shell", "Emergency Cells", "Lend Armour", "Defence is the Best Offense",
    "Shelter Reflex", "Adrenal Rescue", "Quarantine Field", "Rampage", "Field Hospital",
    "Transform", "Break the Vial", "Fly", "Scout Run", "Pincer Run", "Shield Run",
    "Field Service", "Emergency Rebuild", "Tongue Vault", "Nettle Lock", "Musk Trail",
    "Darwinian Shift", "Charge", "Breach Relay", "Shed Skin", "Safe Passage",
    "Revert", "Express Trait", "Wingover", "Peregrine Dive",
    "Banking Turn", "Bounding Pounce", "Walking Barrage", "Burrowing Strike",
    "Rake", "Split Focus", "Sweep Beam", "Venom Jet", "Linebreaker", "Plastic Skin", "Sanctuary",
    "Strike and Drop", "Raking Pass", "Phantom Threat", "Spatial Exchange", "Wrecking Ball",
    "Recovery Winch", "Shock Mine", "Passing Trait",
    "Hurl Debris", "Rapid Metamorph", "Perfect Adaptation", "Rosette Rush", "Overclock Link", "Mosaic Body",
    "Suppress Reaction", "Impulse Push", "Treat Patient", "Tandem Move", "Tailwind Flight", "Bedside Cover", "Hyde Follow-through", "Counterweight Slide",
]
const STATUS_LABELS := {"root": "Rooted", "poison": "Poisoned", "reaction_off": "Reactions disabled",
    "brace": "Braced", "panic": "Panicked", "mind_lock": "Mind Locked"}

var battle: Node2D
var enabled: bool = false
var actor: int = -1
var ability: String = ""
var mode: String = ""
var picks: Array[Vector2i] = []
var zones: Array[Dictionary] = []
var ordnance: Array[Dictionary] = []
var drones: Dictionary = {}
var smoke_tiles: Array[Vector2i] = []
var water_tiles: Array[Vector2i] = []

func _init(board: Node2D) -> void:
    battle = board

func unit(index: int) -> Dictionary:
    return battle.units[index]

func living(index: int) -> bool:
    return index >= 0 and index < battle.units.size() and int(unit(index)["hp"]) > 0

func pos(index: int) -> Vector2i:
    return unit(index)["pos"]

func knows(index: int, skill: String) -> bool:
    return index >= 0 and unit(index).get("skills", {}).has(skill)

func state(index: int) -> Dictionary:
    return unit(index)["class_state"]

func effects(index: int) -> Dictionary:
    return unit(index)["class_effects"]

func once(index: int, skill: String, commit: bool = true) -> bool:
    var used: Dictionary = state(index)["used"]
    if int(used.get(skill, 0)) == battle.turn_number:
        return false
    if commit:
        used[skill] = battle.turn_number
    return true

func begin_room(active: bool) -> void:
    enabled = active
    cancel()
    zones.clear()
    ordnance.clear()
    drones.clear()
    smoke_tiles.clear()
    water_tiles.clear()

func setup_unit(index: int, build: Dictionary, carry: Dictionary) -> void:
    var operative: Dictionary = unit(index)
    operative["skills"] = Classes.unlocked(operative["kit_name"], build)
    operative["class_build"] = build
    operative["max_hp"] = Classes.maximum_hp(build["level"], operative["skills"], operative["supersuit_hp_bonus"])
    if not carry.has("hp"):
        operative["hp"] = operative["max_hp"]
    operative["class_state"] = {"ready": {}, "used": {}, "room_uses": {}, "mission_uses": carry.get("mission_uses", {}),
        "treatment": int(carry.get("treatment", Classes.TREATMENTS)), "heat": 0, "mark": -1,
        "form": "Jekyll" if knows(index, "Dual Nature") else carry.get("form", build["form"]),
        "recovery": bool(carry.get("recovery", false)), "drone_hp": int(carry.get("drone_hp", drone_max_hp(index))),
        "moved": 0, "spare_ap": 0, "mark_open": false,
        "apex_until": 0, "withdraw": -1, "transfer": -1}
    operative["base_move"] = int(operative["move"])
    operative["base_armour"] = int(operative["max_armour"])
    operative["armour_loss"] = int(carry.get("armour_loss", 0))
    operative["armour_broken"] = bool(carry.get("armour_broken", false))
    operative["ranged_damage"] = int(operative["damage"])
    operative["ranged_range"] = int(operative["range"])
    refresh_stats(index)
    refresh_base_attack(index)
    if state(index)["recovery"]:
        operative["ap"] = maxi(0, int(operative["ap"]) - 1)
        if carry.get("form") == "Hyde" and knows(index, "Adrenal Rebound"):
            barrier(index, 2)
        state(index)["recovery"] = false
        state(index)["recovery_turn"] = battle.turn_number

func refresh_base_attack(index: int) -> void:
    var operative: Dictionary = unit(index)
    var attack: Dictionary = Classes.base_attack(operative["kit_name"], operative["class_build"],
        state(index)["form"], operative["ranged_damage"], operative["ranged_range"])
    if operative["reaction_type"] == "overwatch" and operative.get("basic_attack") != attack["name"]:
        cancel_reaction(index)
    operative["basic_attack"] = attack["name"]
    operative["basic_melee"] = attack["melee"]
    operative["damage"] = attack["damage"]
    operative["range"] = attack["range"]
    if state(index).get("form_mastery", false) and state(index)["form"] == "Skunk":
        operative["range"] += 1
    operative["magazine_capacity"] = battle.DEFAULT_MAGAZINE_CAPACITY if attack["charged"] else 0

func deploy_devices() -> void:
    for index in range(5):
        if not living(index) or not knows(index, "Paired Deployment") or int(state(index)["drone_hp"]) <= 0:
            continue
        for step in battle.MOVE_DIRECTIONS:
            var cell: Vector2i = pos(index) + step
            if battle.tile_is_open(cell):
                drones[index] = {"pos": cell, "hp": state(index)["drone_hp"],
                    "armour": drone_max_armour(index), "intercept": false}
                break

func save_carry(index: int, carry: Dictionary) -> void:
    carry["treatment"] = state(index)["treatment"]
    carry["mission_uses"] = state(index)["mission_uses"].duplicate()
    carry["armour_loss"] = unit(index).get("armour_loss", 0)
    carry["armour_broken"] = unit(index).get("armour_broken", false)
    carry["form"] = state(index)["form"]
    carry["recovery"] = state(index)["form"] == "Hyde" or bool(state(index)["recovery"])
    carry["drone_hp"] = drones[index]["hp"] if drones.has(index) else state(index)["drone_hp"]

func refresh_stats(index: int) -> void:
    var operative: Dictionary = unit(index)
    var info: Dictionary = state(index)
    var modifiers: Vector2i = Classes.stat_modifiers(operative["skills"], info["form"], apex(index))
    var move: int = int(operative["base_move"]) + modifiers.y
    var cap: int = Classes.armour_capacity(int(operative["base_armour"]) - int(operative["armour_loss"]), modifiers.x, operative["skills"])
    operative["max_armour"] = 0 if bool(operative["armour_broken"]) else cap
    operative["armour"] = mini(int(operative["armour"]), int(operative["max_armour"]))
    move += int(effects(index).get("move_bonus", 0)) - int(effects(index).get("move_penalty", 0))
    operative["move"] = maxi(1, move)

func apex(index: int) -> bool:
    return int(state(index)["apex_until"]) > battle.turn_number

func organic(index: int) -> bool:
    return unit(index).get("family") != "Robots" and not bool(unit(index).get("prototype_robot", false))

func anchored(index: int) -> bool:
    return int(unit(index).get("weight", 2)) >= 3 or bool(unit(index).get("mission_target", false)) or unit(index).get("kind") == "boss"

func drone_max_hp(index: int) -> int:
    return 4 + 2 * int(knows(index, "Hardened Frame"))

func drone_max_armour(index: int) -> int:
    return 1 + int(knows(index, "Guardian Chassis"))

func drone_live(index: int) -> bool:
    return drones.has(index) and int(drones[index]["hp"]) > 0

func drone_at(tile: Vector2i) -> bool:
    for index in drones:
        if drone_live(index) and drones[index]["pos"] == tile:
            return true
    return false

func actions(index: int) -> Array[Dictionary]:
    var result: Array[Dictionary] = []
    if not unit(index).has("class_state"):
        return result
    for skill in unit(index).get("skills", {}):
        var node: Dictionary = unit(index)["skills"][skill]
        if node["type"] != "A" or not supports_review_action(skill):
            continue
        var options: Array = ["", "Drone"] if skill == "Breach Kit" and knows(index, "Remote Breach") and drone_live(index) else MODES.get(skill, [""])
        for option in options:
            result.append({"skill": skill, "mode": option, "ap": action_cost(index, skill, option, node)})
    for skill in ["Transform", "Revert", "Fly", "Vent", "Anchor", "Breach Shell", "Scout Run", "Pincer Run", "Shield Run",
            "Treat Patient", "Lend Armour", "Suppress Reaction", "Impulse Push", "Tandem Move", "Tailwind Flight",
            "Bedside Cover", "Hyde Follow-through", "Counterweight Slide", "Tongue Vault", "Nettle Lock", "Musk Trail", "Darwinian Shift"]:
        var node := review_extra(index, skill)
        if node.is_empty() or unit(index)["skills"].get(skill, {}).get("type") == "A":
            continue
        for option in MODES.get(skill, [""]):
            result.append({"skill": skill, "mode": option, "ap": action_cost(index, skill, option, node)})
    if free_step(index) > 0:
        result.append({"skill": "Follow-up Step", "mode": "", "ap": 0})
    return result

static func supports_review_action(skill: String) -> bool:
    return skill in REVIEW_ACTIONS or REVIEW_RANGED.has(skill) or REVIEW_TARGETS.has(skill)

func review_extra(index: int, skill: String) -> Dictionary:
    match skill:
        "Suppress Reaction", "Impulse Push":
            var pending: int = effects(index).get(skill, -1)
            if living(pending):
                return {"type": "A", "ap": 0, "limit": "T1"}
        "Treat Patient":
            if knows(index, "Field Hospital") and not hospital_candidates(index).is_empty():
                return {"type": "A", "ap": 0, "limit": ""}
        "Lend Armour":
            if knows(index, "Living Mantle"):
                return {"type": "A", "ap": 1, "limit": ""}
        "Tandem Move", "Tailwind Flight", "Bedside Cover", "Hyde Follow-through", "Counterweight Slide":
            if effects(index).get(skill, false):
                return {"type": "A", "ap": 0, "limit": "T1"}
        "Revert":
            if state(index)["form"] == "Hyde" and int(state(index)["hyde_until"]) == battle.turn_number + 1:
                return {"type": "A", "ap": 0, "limit": "T1"}
        "Transform":
            if knows(index, "Dual Nature") and state(index)["form"] != "Hyde":
                return {"type": "A", "ap": 1, "limit": "R1"}
        "Fly":
            if knows(index, "Hawk Wings"):
                return {"type": "A", "ap": 1, "limit": "T1"}
        "Anchor", "Vent", "Breach Shell":
            if knows(index, "Siege Mount"):
                return {"type": "A", "ap": {"Anchor": 0, "Vent": 1, "Breach Shell": 2}[skill], "limit": "CD2" if skill == "Breach Shell" else ""}
        "Scout Run", "Pincer Run", "Shield Run":
            var unlock: String = {"Scout Run": "Paired Deployment", "Pincer Run": "Assault Chassis", "Shield Run": "Guardian Chassis"}[skill]
            if knows(index, unlock):
                return {"type": "A", "ap": 1, "limit": "" if skill == "Scout Run" else "CD2"}
        "Tongue Vault", "Nettle Lock", "Musk Trail":
            var signature: String = {"Frog": "Tongue Vault", "Jellyfish": "Nettle Lock", "Skunk": "Musk Trail"}.get(state(index)["form"], "")
            if knows(index, "Darwinian Shift") and signature == skill:
                return {"type": "A", "ap": 1, "limit": "CD2"}
        "Darwinian Shift":
            if knows(index, skill):
                return {"type": "A", "ap": 1, "limit": "T1"}
    return {}

func review_node(index: int, skill: String) -> Dictionary:
    var extra: Dictionary = review_extra(index, skill)
    return unit(index).get("skills", {}).get(skill, {}) if extra.is_empty() else extra

func action_detail(index: int, skill: String) -> String:
    var node: Dictionary = unit(index).get("skills", {}).get(skill, {})
    return node.get("mechanic", GENERATED_ACTION_DETAILS.get(skill, ""))

func action_cost(index: int, skill: String, option: String, node: Dictionary) -> int:
    if skill == "Charge":
        return clampi(option.to_int(), 1, 3)
    if skill == "Darwinian Shift" and knows(index, "Reflex Shift") and not state(index)["room_uses"].has("Reflex Shift"):
        return 0
    return int(node["ap"])

func cancel() -> void:
    actor = -1
    ability = ""
    mode = ""
    picks.clear()

func arm_action(index: int, skill: String, option: String) -> void:
    var blocked: String = unavailable(index, skill, option)
    if not blocked.is_empty():
        battle.status_message = blocked
        return
    var was_selected: bool = actor == index and ability == skill and mode == option
    cancel()
    if was_selected:
        battle.status_message = "Ability targeting cancelled."
        return
    actor = index
    ability = skill
    mode = option
    if ability in SELF_ACTIONS or ability in ["Charge", "Transform", "Revert", "Vent", "Anchor", "Emergency Cells", "Pressure Front", "Empty the Shell",
            "Thundering Taunt", "Defence is the Best Offense", "Emergency Rebuild", "Shed Skin", "Plastic Skin"]:
        submit(pos(actor))
    else:
        battle.status_message = aim_text()

func aim_text() -> String:
    if ability.is_empty():
        return ""
    if ability == "Rosette Rush" and not picks.is_empty():
        if picks.size() % 2 == 1:
            return "Rosette Rush · choose a landing up to two steps away, or click the last enemy again to finish."
        return "Rosette Rush · choose a new enemy adjacent to the landing."
    if ability == "Mosaic Body":
        return "Mosaic Body · select a tile for an available form signature (%d of 2)." % (picks.size() + 1)
    if ability == "Overclock Link":
        if picks.is_empty():
            return "Overclock Link · choose the drone landing."
        if knows(actor, "Guardian Chassis"):
            if picks.size() < 3:
                return "Overclock Link · choose a cardinal facing. Use a different facing for the second line."
            return "Overclock Link · select up to two adjacent squadmates, or click the drone landing to finish."
        return "Overclock Link · choose a target. Click the last enemy again to end the chain."
    if ability in ["Breach Kit", "Breach Shell"]:
        return "%s · %s" % [ability, "choose a tile beside the cover edge." if picks.is_empty() else "choose the tile on the other side of the edge."]
    if ability in ["Scout Run", "Pincer Run", "Shield Run"]:
        if picks.is_empty():
            return "%s · choose the drone's landing, or click the drone to hold." % ability
        if ability == "Shield Run":
            return "Shield Run · " + ("choose a cardinal facing." if picks.size() == 1 else "choose one adjacent ally, or click the drone landing to finish.")
        if ability == "Scout Run":
            return "Scout Run · choose a target, or click the landing again to move only."
        return "Pincer Run · " + ("choose a target." if picks.size() == 1 else "choose a second enemy within two tiles, or click the first target again.")
    if ability == "Rolling Thunder":
        return "Rolling Thunder · " + ("choose your landing within three steps, or your own tile to hold." if picks.is_empty() else "choose a direction for the four-tile firing line.")
    if ability == "Tandem Move":
        return "Tandem Move · choose a drone landing within two tiles."
    if ability == "Field Hospital" and not picks.is_empty():
        return "Field Hospital · choose up to three patients, or click the ward centre again to open it."
    if ability == "Sanctuary":
        return "Sanctuary · click an ally once per assigned armour point (%d remaining)." % (int(unit(actor)["armour"]) - picks.size())
    if ability == "Tongue Vault" and not picks.is_empty():
        return "Tongue Vault · select a foe to pull, or click the landing again to hop only."
    if ability == "Rake":
        return "Rake · choose up to three adjacent tiles. Repeat the last tile to finish early."
    if ability == "Strike and Drop" and picks.size() == 2:
        return "Strike and Drop · choose a legal drop tile adjacent to your landing."
    if TARGET_STEPS.has(ability):
        if ability == "Iron Rain":
            return "Iron Rain · choose blast centre %d of 3." % (picks.size() + 1)
        if not picks.is_empty():
            return "%s · choose a destination." % ability
    return "%s%s · choose a target tile. [Esc] cancels." % [ability, "" if mode.is_empty() else " / " + mode]

func unavailable(index: int, skill: String, option: String) -> String:
    if not living(index) or battle.side_to_play != "player" or battle.game_over or battle.room_cleared:
        return "Choose a standing operative during the player phase."
    if skill == "Follow-up Step":
        return "" if free_step(index) > 0 else "No follow-up step available."
    var node: Dictionary = review_node(index, skill)
    if node.is_empty() or node["type"] != "A":
        return "This skill is not unlocked."
    var info: Dictionary = state(index)
    if not supports_review_action(skill):
        return "Combat implementation pending."
    if node["limit"] == "T1" and not once(index, skill, false):
        return "Already used this turn."
    if (skill in DRONE_ORDERS or skill in ["Field Service", "Tandem Move"] or (skill == "Breach Kit" and option == "Drone")) and not drone_live(index):
        return "Requires a surviving drone."
    if skill == "Breach Kit" and option == "Drone" and not knows(index, "Remote Breach"):
        return "Requires Remote Breach."
    if skill in DRONE_ORDERS and not once(index, "Drone order", false):
        return "The drone has already acted this turn."
    if skill == "Anchor":
        if effects(index).get("anchored", false):
            return "The suit is already anchored."
        if int(info["moved"]) > 0 and not quick_lock_ready(index):
            return "Anchor before moving, or use Quick-Lock."
    if REVIEW_HEAT.has(skill) and skill != "Rolling Thunder" and not effects(index).get("anchored", false):
        return "Anchor before firing heavy weapons."
    if skill in ["Transform", "Break the Vial"] and info["form"] != "Hyde":
        if info["room_uses"].has("Transform") or int(info.get("recovery_turn", -1)) == battle.turn_number:
            return "Hyde is unavailable this turn."
    if skill in ["Adrenal Rescue", "Quarantine Field", "Field Hospital"] and info["form"] != "Jekyll":
        return "Available as Jekyll."
    if skill in ["Hurl Aside", "Rampage"] and info["form"] != "Hyde":
        return "Available as Hyde."
    if skill == "Emergency Rebuild" and (drone_live(index) or int(info["drone_hp"]) > 0 and not drones.has(index)):
        return "Requires a destroyed drone."
    if skill == "Vent" and int(info["heat"]) == 0:
        return "The suit is already cool."
    if skill in ["Empty the Shell", "Sanctuary"] and int(unit(index)["armour"]) < 2:
        return "Requires at least two current armour."
    if REVIEW_HEAT.has(skill) and int(info["heat"]) + int(REVIEW_HEAT[skill]) > 4:
        return "Vent before firing."
    if skill in ["Darwinian Shift", "Shed Skin", "Rapid Metamorph", "Perfect Adaptation"] and not once(index, "form change", false):
        return "Already shifted this turn."
    var cost := action_cost(index, skill, option, node)
    if int(unit(index)["ap"]) < cost and not (skill == "Designate Target" and effects(index).has("free_quarry")):
        return "Needs %d AP." % cost
    if int(info["ready"].get(skill, 0)) > battle.turn_number:
        return "Ready on turn %d." % int(info["ready"][skill])
    if info["room_uses"].has(skill) or info["mission_uses"].has(skill):
        return "Already used."
    if int(info["treatment"]) < int(TREATMENT_COST.get(skill, 0)):
        return "Insufficient Treatment charges."
    if (HEAT_COST.has(skill) or skill in DRONE_ACTIONS) and heat_locked(index):
        return "Suit locked. Use Emergency Vent or Emergency Overdrive."
    if skill in DRONE_ACTIONS and not drone_live(index):
        return "Requires a surviving drone."
    if skill in ["Darwinian Shift", "Rapid Metamorph"]:
        if apex(index) or not once(index, "form change", false):
            return "Form switching is locked."
        if info["form"] == option:
            return "This form is already active."
    if skill == "Breakthrough" or skill == "Charge":
        if not once(index, skill, false):
            return "Already used this turn."
    if skill == "Aegis Relay" and int(effects(index).get("force_shell", 0)) == 0:
        return "Requires an active Force Shell."
    if skill == "Tethered Ascent" and int(info["withdraw"]) < 0:
        return "Make a close-range attack first."
    return ""

func heat_locked(index: int) -> bool:
    if effects(index).get("heat_override", false):
        return false
    var heat: int = int(state(index)["heat"])
    if can_cool(index):
        heat -= 1
    return heat >= 3 or bool(effects(index).get("must_vent", false))

func can_cool(index: int) -> bool:
    return knows(index, "Cooling Circuit") and int(state(index)["moved"]) >= 2 and once(index, "Cooling Circuit", false)

func commit(index: int, skill: String, option: String = "") -> void:
    var info: Dictionary = state(index)
    if skill != "Follow-up Step":
        var node: Dictionary = review_node(index, skill)
        var limit: String = node["limit"]
        var free_quarry: bool = skill == "Designate Target" and effects(index).erase("free_quarry")
        var cost := action_cost(index, skill, option, node)
        unit(index)["ap"] -= 0 if free_quarry else cost
        if skill == "Darwinian Shift" and cost == 0:
            info["room_uses"]["Reflex Shift"] = true
        info["treatment"] -= int(TREATMENT_COST.get(skill, 0))
        if limit.begins_with("CD"):
            info["ready"][skill] = battle.turn_number + int(limit.substr(2))
        if limit == "R1":
            info["room_uses"][skill] = true
        if limit.begins_with("M1"):
            info["mission_uses"][skill] = true
        if HEAT_COST.has(skill) or skill in DRONE_ACTIONS:
            if can_cool(index):
                cool(index, 1)
                once(index, "Cooling Circuit")
            info["heat"] = mini(3, int(info["heat"]) + int(HEAT_COST.get(skill, 0)))
        if REVIEW_HEAT.has(skill):
            info["heavy_bonus"] = int(knows(index, "Hot Breech") and int(info["heat"]) >= 2 and once(index, "Hot Breech"))
            info["heat"] += REVIEW_HEAT[skill]
        once(index, skill)
        battle.record_ability_use(index, skill, true)
        battle.add_log("%s uses %s." % [unit(index)["name"], skill])
        battle.status_message = "%s uses %s." % [unit(index)["name"], skill]

func submit(tile: Vector2i) -> void:
    var blocked: String = unavailable(actor, ability, mode)
    if not blocked.is_empty():
        battle.status_message = blocked
        return
    var planned: Array[Vector2i] = picks.duplicate()
    planned.append(tile)
    var plan: Dictionary = plan_action(actor, ability, mode, planned)
    if plan.has("error"):
        battle.status_message = plan["error"]
        return
    if planned.size() < target_steps(actor, ability, mode) and not plan.get("ready", false):
        picks = planned
        battle.status_message = aim_text()
        return
    var index: int = actor
    var skill: String = ability
    var option: String = mode
    cancel()
    commit(index, skill, option)
    battle.resolving_class_action = true
    resolve(index, skill, option, planned, plan)
    battle.resolving_class_action = false
    battle.assess_winner()

func target_steps(index: int, skill: String, option: String) -> int:
    if skill in ["Pincer Run", "Shield Run"] and not knows(index, "Hardpoint Upgrade"):
        return 2
    if skill == "Passing Trait" and state(index)["form"] != "Frog":
        return 1
    if skill == "Rapid Metamorph" and option == "Frog":
        return 2
    if skill == "Mosaic Body" and "Frog" in option:
        return 3
    return int(TARGET_STEPS.get(skill, 1))

func summary(index: int) -> String:
    var info: Dictionary = state(index)
    var build: Dictionary = unit(index)["class_build"]
    var branch: Dictionary = Classes.data(unit(index)["kit_name"])["origins"][int(build["origin"])]
    var result: String = "L%d · %s" % [int(build["level"]), str(branch["name"]).capitalize()]
    if knows(index, "Siege Mount"):
        result += " · Heat %d/4" % int(info["heat"])
        if effects(index).get("anchored", false):
            result += " · Anchored"
    if knows(index, "Paired Deployment"):
        result += " · Drone %d/%d HP" % [int(drones.get(index, {}).get("hp", 0)), drone_max_hp(index)]
    if knows(index, "Cell Mender"):
        result += " · Treatment %d/4" % int(info["treatment"])
    if knows(index, "Darwinian Shift"):
        result += " · " + str(info["form"])
    if living(int(info["mark"])):
        result += " · Mark: " + str(unit(int(info["mark"]))["name"])
    return result

func draw_drone(owner: int, center: Vector2) -> void:
    var guardian: bool = knows(owner, "Guardian Chassis")
    var color := Color("#9cdbe9") if guardian else Color("#ffc581")
    var bob: float = sin(battle.atmosphere_time * 8.0 + owner) * 2.0
    var body: Vector2 = center - Vector2(0, 12 + bob)
    var sprite: Texture2D = battle.unit_sprites["drone"]
    battle.sabotage_visuals.draw_shadow(battle, center, 21.0)
    battle.draw_texture_rect(sprite, Rect2(body - Vector2(12, 10), Vector2(24, 22)), false, Color.WHITE.lerp(color, 0.3))
    battle.draw_rect(Rect2(body + Vector2(-3, -2), Vector2(6, 2)), color)
    battle.draw_label(str(drones[owner]["hp"]), center + Vector2(-3, 7), 10, color)

func draw_board_zones() -> void:
    for entry in ordnance:
        draw_tiles(entry["tiles"], Color("#e99057"))
    for zone in zones:
        draw_tiles(zone["tiles"], Color("#a59ad8"))
    for owner: int in drones:
        if drone_live(owner):
            for line in ["barricade", "barricade_second"]:
                draw_shield_line(drones[owner].get(line, {}))

func draw_board_targeting() -> String:
    if actor < 0 or ability.is_empty():
        return ""
    draw_tiles(picks, Color("#e9bc68"))
    var tile: Vector2i = battle.hovered_tile
    if not battle.is_in_bounds(tile):
        return aim_text()
    var preview: Array[Vector2i] = picks.duplicate()
    preview.append(tile)
    var plan: Dictionary = plan_action(actor, ability, mode, preview)
    draw_tiles(plan.get("tiles", [tile]), Color("#db817c") if plan.has("error") else Color("#8edac4"))
    if not plan.has("error") and ability in ["Strike and Drop", "Raking Pass"]:
        if plan.has("landing"):
            draw_tiles([plan["landing"]], Color("#e9bc68"))
        if plan.has("drop"):
            draw_tiles([plan["drop"]], Color("#8edac4"))
    for line: Dictionary in plan.get("cover_lines", []):
        draw_shield_line(line)
    var hint: String = plan.get("error", plan.get("warning", aim_text()))
    if not plan.has("error") and plan.has("drone_path"):
        var shots := expected_drone_overwatch(actor, plan["drone_path"])
        if shots > 0:
            hint += " · %d expected Overwatch %s" % [shots, "shot" if shots == 1 else "shots"]
    return hint

func draw_shield_line(line: Dictionary) -> void:
    for tile: Vector2i in line.get("tiles", []):
        var rect: Rect2 = battle.battlefield.tile_rect(tile)
        var face: String = line["face"]
        var start := rect.position
        var end := rect.end
        match face:
            "N": end.y = start.y
            "S": start.y = end.y
            "W": end.x = start.x
            "E": start.x = end.x
        battle.draw_line(start, end, Color("#7ac3d5"), 4.0)

func draw_tiles(tiles: Array, color: Color) -> void:
    for tile in tiles:
        var rect: Rect2 = battle.battlefield.tile_rect(tile).grow(-3)
        battle.draw_rect(rect, color, false, 2)

func error(message: String) -> Dictionary:
    return {"error": message}

func distance(a: Vector2i, b: Vector2i) -> int:
    return steps_between(a, b)

func steps_between(a: Vector2i, b: Vector2i) -> int:
    return maxi(absi(a.x - b.x), absi(a.y - b.y))

func visible(a: Vector2i, b: Vector2i, reach: int) -> bool:
    return distance(a, b) <= reach and battle.has_line_of_sight(a, b)

func neighbours(index: int, tile: Vector2i) -> bool:
    var footprint: Rect2i = battle.unit_footprint(unit(index), pos(index))
    var nearest := tile.clamp(footprint.position, footprint.end - Vector2i.ONE)
    return distance(nearest, tile) == 1

func legal_walk(index: int, tile: Vector2i, reach: int) -> bool:
    return not battle.voluntary_movement_locked(index) and tile != pos(index) and battle.reachable(pos(index), reach, index).has(tile)

func can_vault(index: int, source: Vector2i, tile: Vector2i, reach: int) -> bool:
    return not battle.voluntary_movement_locked(index) and source != tile and steps_between(source, tile) <= reach and battle.has_line_of_sight(source, tile) \
        and battle.footprint_is_open(unit(index), tile)

func attack_landing(index: int, target: int, reach: int, flight: bool, occupied_limit: int = -1) -> Vector2i:
    var source: Vector2i = pos(index)
    if not flight and neighbours(target, source):
        return source
    if battle.voluntary_movement_locked(index):
        return INVALID
    var search: Dictionary = battle.reachable(source, reach, index) if not flight else {}
    var footprint: Rect2i = battle.unit_footprint(unit(target), pos(target)).grow(1)
    var best: Vector2i = INVALID
    var score: int = 999
    for x in range(footprint.position.x, footprint.end.x):
        for y in range(footprint.position.y, footprint.end.y):
            var tile := Vector2i(x, y)
            if not neighbours(target, tile):
                continue
            var length: int = steps_between(source, tile) if flight else int(search.get(tile, 999))
            if length >= score or length > reach:
                continue
            if flight and (length < 2 or not can_vault(index, source, tile, reach)):
                continue
            if occupied_limit >= 0 and in_tiles(line_tiles(source, tile)).size() > occupied_limit:
                continue
            if not flight and not battle.has_line_of_sight(source, tile):
                continue
            best = tile
            score = length
    return best

func area(center: Vector2i, radius: int, square: bool = true) -> Array[Vector2i]:
    var cells: Array[Vector2i] = []
    for y in range(center.y - radius, center.y + radius + 1):
        for x in range(center.x - radius, center.x + radius + 1):
            var tile := Vector2i(x, y)
            if battle.is_in_bounds(tile) and (square or distance(center, tile) <= radius) \
                    and not battle.walls.has(tile) and battle.has_line_of_sight(center, tile):
                cells.append(tile)
    return cells

func cross_tiles(center: Vector2i) -> Array[Vector2i]:
    return area(center, 1).filter(func(cell: Vector2i) -> bool: return battle.grid_distance(center, cell) <= 1)

func direction(a: Vector2i, b: Vector2i) -> Vector2i:
    var delta: Vector2i = b - a
    return Vector2i(signi(delta.x), signi(delta.y))

func cone(source: Vector2i, aim: Vector2i, reach: int) -> Array[Vector2i]:
    var cells: Array[Vector2i] = []
    var forward: Vector2 = Vector2(aim - source).normalized()
    for tile in area(source, reach):
        if tile != source and forward.dot(Vector2(tile - source).normalized()) >= 0.70:
            cells.append(tile)
    return cells

func in_tiles(tiles: Array, team: String = "") -> Array[int]:
    var indices: Array[int] = []
    for index in range(battle.units.size()):
        if not living(index) or (not team.is_empty() and unit(index)["team"] != team):
            continue
        var footprint: Rect2i = battle.unit_footprint(unit(index), pos(index))
        for tile in tiles:
            if footprint.has_point(tile):
                indices.append(index)
                break
    return indices

func light_edges(tile: Vector2i) -> Array[String]:
    var edges: Array[String] = []
    for face in ["N", "E", "S", "W"]:
        var key: String = battle.edge_key(tile, face)
        if int(battle.destructible_edges.get(key, {}).get("level", 0)) == 1:
            edges.append(key)
    return edges

func cover_between(a: Vector2i, b: Vector2i) -> String:
    if distance(a, b) != 1:
        return ""
    return battle.edge_key(a, battle.direction_to_face(a, b))

func bio_range(index: int, reach: int) -> int:
    return reach + int(state(index)["form"] == "Skunk" and knows(index, "Darwinian Shift"))

func drone_reach(index: int, reach: int) -> int:
    return reach + int(effects(index).get("overcharge", false)) + redline(index)

func redline(index: int) -> int:
    return int(knows(index, "Redline") and int(state(index)["heat"]) >= 2)

func free_step(index: int) -> int:
    return int(effects(index).get("free_step", 0))

func plan_action(index: int, skill: String, option: String, tiles: Array[Vector2i]) -> Dictionary:
    var source: Vector2i = pos(index)
    var tile: Vector2i = tiles[0]
    var target: int = battle.find_unit_at(tile)
    var enemy: bool = living(target) and unit(target)["team"] == "enemy"
    var ally: bool = living(target) and unit(target)["team"] == "player"
    var form: String = state(index)["form"]
    var plan: Dictionary = {"target": target, "tiles": [tile]}
    if supports_review_action(skill):
        return plan_review(index, skill, option, tiles, plan, enemy, ally)
    if not battle.is_in_bounds(tile) or battle.walls.has(tile):
        return error("Choose a clear battlefield tile.")
    match skill:
        "Charge", "Breakthrough", "Talon Descent", "Raptor Descent", "Deathsting":
            var flight: bool = skill in ["Talon Descent", "Raptor Descent"]
            if not enemy or (flight and int(state(index)["mark"]) != target):
                return error("Choose your marked enemy." if flight else "Choose a standing enemy.")
            var landing: Vector2i = attack_landing(index, target, 4 if flight else 2, flight)
            if landing == INVALID:
                return error("No legal landing beside the target.")
            plan["landing"] = landing
            plan["tiles"] = [landing, tile]
            if tiles.size() >= 2 and tiles[1] != landing and not can_vault(index, landing, tiles[1], 2):
                return error("Choose a clear withdrawal tile within two steps of the landing.")
        "Carapace Rush", "Siege Momentum", "Follow-up Step", "Rapid Metamorph":
            var reach: int = free_step(index) if skill == "Follow-up Step" else 2
            if not legal_walk(index, tile, reach) and not (skill == "Rapid Metamorph" and tile == source):
                return error("Choose a walkable tile within %d steps." % reach)
        "Wing Hop", "Tethered Ascent":
            if not can_vault(index, source, tile, 3):
                return error("Choose a visible, open landing within three steps.")
        "Hammerfist", "Force Ram", "Savage Counter", "Rabid Frenzy":
            if not enemy or not neighbours(target, source):
                return error("Choose an adjacent enemy.")
        "Wallbreaker":
            var edge: String = cover_between(source, tile)
            if int(battle.destructible_edges.get(edge, {}).get("level", 0)) != 1:
                return error("Choose a tile immediately across a light-cover edge.")
            plan["edge"] = edge
        "Hook Sting", "Barbed Impaler", "Wing Buffet", "Force Hand", "Kinetic Drag", "Kinetic Slam":
            var reach: int = 4 if skill in ["Force Hand", "Kinetic Drag", "Kinetic Slam"] else 2
            if not enemy or not visible(source, tile, reach):
                return error("Choose a visible enemy within %d tiles." % reach)
            if anchored(target) and skill in ["Barbed Impaler", "Wing Buffet", "Force Hand", "Kinetic Drag"]:
                return error("This enemy resists forced movement.")
            if skill == "Barbed Impaler" and not neighbours(target, source):
                var dragged: Vector2i = pos(target) + direction(pos(target), source)
                if distance(dragged, source) != 1 or not battle.can_take_move_step(unit(target), pos(target), dragged):
                    return error("Choose an enemy you can pull into melee.")
        "Contract Mark", "Disrupt Focus", "Intrusive Thought", "Panic Spike", "Borrow Sight", "Mind Lock":
            var reach: int = 8 if skill == "Contract Mark" else 5
            if not enemy or not visible(source, tile, reach):
                return error("Choose a visible enemy within %d tiles." % reach)
            if skill not in ["Contract Mark", "Disrupt Focus"] and not organic(target):
                return error("This action requires an organic enemy.")
            if skill == "Contract Mark" and int(state(index)["mark"]) == target:
                return error("This enemy is already your mark.")
        "Compel Step", "Lift Ally":
            if (skill == "Lift Ally" and (not ally or target == index)) or \
                    (skill == "Compel Step" and (not enemy or not organic(target) or anchored(target))):
                return error("Choose a visible ally." if skill == "Lift Ally" else "Choose a movable organic enemy.")
            if not visible(source, tile, 4):
                return error("The target needs to be within four tiles and visible.")
            if tiles.size() > 1:
                var destination: Vector2i = tiles[1]
                var legal: bool = can_vault(target, pos(target), destination, 2) if skill == "Lift Ally" \
                    else safe_walk(target, destination, 2)
                if not legal:
                    return error("Choose a legal destination within two steps.")
                plan["tiles"] = [tile, destination]
        "Retinal Lance", "Prism Shot", "Core Melter", "Projected Strike":
            var reach: int = 3 if skill == "Projected Strike" else 8
            if not enemy or not visible(source, tile, reach):
                return error("Choose an enemy in a clear firing line within %d tiles." % reach)
            if skill != "Projected Strike" and int(state(index)["mark"]) != target:
                return error("This beam requires your marked enemy.")
            if not shot_through_smoke(index, source, tile):
                return error("Smoke obscures the firing line.")
        "Fan Beam", "Shell Collapse":
            if tile == source or steps_between(source, tile) > 3:
                return error("Aim the cone at a tile within three steps.")
            plan["tiles"] = cone(source, tile, 3)
        "Micro-Rocket", "Rocket Salvo", "Cluster Burst", "Delayed Mortar", "Iron Rain", "Arc Net", \
        "Vector Pull", "Gravity Well", "Master Interference", "Mass Panic", "Communal Clot":
            var reach: int = bio_range(index, 4) if skill == "Communal Clot" else 7
            if skill in ["Vector Pull", "Gravity Well", "Master Interference", "Mass Panic"]:
                reach = 5
            for aim in tiles:
                if not battle.is_in_bounds(aim) or battle.walls.has(aim) or not visible(source, aim, reach):
                    return error("Choose a visible centre within %d tiles." % reach)
            if skill == "Micro-Rocket" and steps_between(source, tile) <= 1:
                return error("The rocket needs more distance from the pilot.")
            if skill == "Iron Rain" and tiles.count(tiles.back()) > 1:
                return error("Choose a different blast centre.")
            var cells: Array[Vector2i] = []
            if skill == "Arc Net":
                var along: Vector2i = direction(source, tile)
                if along == Vector2i.ZERO:
                    return error("Aim away from the pilot.")
                var side := Vector2i(-along.y, along.x)
                for cell: Vector2i in [tile, tile + side, tile - side]:
                    if battle.is_in_bounds(cell) and not battle.walls.has(cell) and not battle.barrel_is_active(cell):
                        cells.append(cell)
                for cell: Vector2i in cells.duplicate():
                    if not water_tiles.has(cell):
                        continue
                    for step in battle.DIRECTIONS:
                        var wet: Vector2i = cell + step
                        if water_tiles.has(wet) and not cells.has(wet) and not battle.walls.has(wet) \
                                and not battle.barrel_is_active(wet):
                            cells.append(wet)
            else:
                for aim in tiles:
                    for cell in area(aim, 2 if skill == "Cluster Burst" else 1, skill not in ["Micro-Rocket", "Iron Rain"]):
                        if not cells.has(cell):
                            cells.append(cell)
            plan["tiles"] = cells
            if skill == "Communal Clot" and healing_targets(cells, false).is_empty():
                return error("No standing wounded ally in the selected area.")
        "Remote Pulse":
            var origin: Vector2i = drones[index]["pos"]
            if not drone_path(origin, tile, drone_reach(index, 3)):
                return error("Choose a tile the drone can reach in %d steps." % drone_reach(index, 3))
        "Saboteur Bot", "Remote Override", "Crossfire Protocol":
            var origin: Vector2i = drones[index]["pos"]
            var reach: int = drone_reach(index, 1 if skill == "Saboteur Bot" else 5)
            if not enemy or (skill != "Crossfire Protocol" and not visible(origin, tile, reach)):
                return error("Choose an enemy within the drone's reach.")
            if skill == "Remote Override" and organic(target):
                return error("Choose a robotic enemy.")
            if skill == "Crossfire Protocol" and (not battle.has_attack_ammo(index) or not visible(source, tile, int(unit(index)["range"]))):
                return error("The pilot needs ammunition and a clear firing line.")
        "Aegis Relay", "Adaptive Catalyst", "Protective Clot", "Scar Weave", "Gene Transfer", "Cell Mender", "Crisis Mending":
            var reach: int = 3 if skill == "Aegis Relay" else bio_range(index, 4 if skill in ["Cell Mender", "Crisis Mending"] else 3)
            if not ally or not visible(source, tile, reach) or (skill == "Aegis Relay" and target == index):
                return error("Choose a standing ally in range.")
            if skill in ["Cell Mender", "Crisis Mending"] and not wounded(target):
                return error("This ally is at their HP ceiling.")
            if skill == "Crisis Mending" and int(unit(target)["hp"]) * 2 >= int(unit(target)["max_hp"]):
                return error("Crisis Mending requires an ally below half their normal HP.")
        "Adaptive Technique":
            match form:
                "Frog":
                    if not enemy:
                        return error("Choose an enemy to lunge at.")
                    plan["landing"] = attack_landing(index, target, 1, false)
                    if plan["landing"] == INVALID:
                        return error("No legal one-step approach.")
                "Jellyfish":
                    if not ally or distance(source, tile) > 1:
                        return error("Choose yourself or an adjacent standing ally.")
                "Skunk":
                    var reach: int = 3 + int(knows(index, "Stable Adaptation"))
                    if not enemy or not organic(target) or not visible(source, tile, reach):
                        return error("Choose an organic enemy in musk range.")
        "Regenerative Wave":
            plan["tiles"] = area(source, 3, false)
            if healing_targets(plan["tiles"], false).is_empty():
                return error("No standing wounded ally within three tiles.")
        "Quake Slam", "Iron Cataclysm", "Psychic Burst":
            plan["tiles"] = area(source, 1)
    return plan

func plan_review(index: int, skill: String, option: String, tiles: Array[Vector2i],
        plan: Dictionary, enemy: bool, ally: bool) -> Dictionary:
    var source: Vector2i = plan.get("source_override", pos(index))
    var tile := tiles[0]
    var target: int = plan["target"]
    if not battle.is_in_bounds(tile) or (battle.walls.has(tile) and skill not in ["Venom Jet", "Gleaming Armour", "Flak Curtain", "Breach Kit", "Breach Shell"]):
        return error("Choose a clear battlefield tile.")
    if skill in ["Rapid Metamorph", "Perfect Adaptation"]:
        if option == state(index)["form"]:
            return error("Choose a different form.")
        var signature: String = "Express Trait" if skill == "Perfect Adaptation" else form_signature(option)
        if skill == "Rapid Metamorph" and int(state(index)["ready"].get(signature, 0)) > battle.turn_number:
            return error("The new form's signature is still on cooldown.")
        plan["form"] = option
        return plan_review(index, signature, "", tiles, plan, enemy, ally)
    if REVIEW_RANGED.has(skill) or REVIEW_TARGETS.has(skill):
        var reach: int = REVIEW_RANGED[skill][0] if REVIEW_RANGED.has(skill) else REVIEW_TARGETS[skill]
        if skill in ["Vector Pull", "Lateral Slip"]:
            reach += int(knows(index, "Long Lever"))
        if (not enemy and not (ally and skill in ["Vector Pull", "Lateral Slip"])) or not visible(source, tile, reach):
            return error("Choose a target within %d tiles and line of sight." % reach)
        if skill in ["Aphasia", "Panic Spike", "Thought Arrest", "Crowd Panic", "Feedback Spike"] and not organic(target):
            return error("Choose an organic target.")
        if REVIEW_RANGED.has(skill):
            var cover_block: String = battle.ranged_cover_block_reason(source, tile)
            if cover_block == battle.FULL_COVER_BLOCK:
                plan["warning"] = cover_block
            elif not cover_block.is_empty():
                return error(cover_block)
        if skill in ["Vector Pull", "Lateral Slip", "Throw", "Hooked Pincers"] and anchored(target):
            return error("This target is too heavy to move.")
        if skill in ["Vector Pull", "Lateral Slip"]:
            var from := pos(target)
            var vector := direction(tile, source)
            if skill == "Lateral Slip":
                vector = Vector2i(-vector.y, vector.x) * (-1 if option == "Right" else 1)
            if not battle.can_take_move_step(unit(target), from, from + vector):
                return error("Choose a target with a clear displacement path.")
        if skill == "Throw" and tiles.size() > 1:
            var landing: Vector2i = tiles[1]
            if distance(pos(target), landing) > 3 or landing == pos(target):
                return error("Choose a landing or collision up to three tiles from the enemy.")
            return plan_throw(index, target, landing, plan)
        return plan
    match skill:
        "Breach Relay", "Rampage":
            if not enemy or not neighbours(target, source):
                return error("Choose an adjacent enemy.")
            if tiles.size() > 1:
                var landing: Vector2i = tiles[1]
                var steps := 1 if skill == "Breach Relay" else 2
                var swap: int = battle.find_unit_at(landing)
                if landing == source:
                    plan["ready"] = true
                    return plan
                if battle.voluntary_movement_locked(index):
                    return error(battle.movement_lock_reason(index))
                if skill == "Breach Relay" and living(swap) and unit(swap)["team"] == "player" and distance(source, landing) == 1:
                    if not can_swap(index, swap, index):
                        return error("Both squadmates must fit.")
                    plan["swap"] = swap
                elif not legal_walk(index, landing, steps):
                    return error("Choose a legal follow-up landing, or your own tile to hold.")
                else:
                    plan["landing"] = landing
                if skill == "Rampage":
                    plan["follow_up_tile"] = landing
                    if tiles.size() > 2:
                        var second: int = battle.find_unit_at(tiles[2])
                        if tiles[2] != landing and (not living(second) or second == target or unit(second)["team"] != "enemy" or not neighbours(second, landing)):
                            return error("Choose another adjacent enemy, or click the landing again.")
                        plan["follow_up_target"] = second
                plan["tiles"].append(landing)
                if landing == source:
                    plan["ready"] = true
        "Treat Patient":
            if target not in hospital_candidates(index):
                return error("Choose an untreated standing ally in your ward.")
        "Bedside Cover":
            if not ally or target == index or distance(source, tile) != 1 or not below_half_healing(target):
                return error("Choose a wounded adjacent ally below half their healing ceiling.")
        "Tailwind Flight":
            if not can_vault(index, source, tile, 2):
                return error("Choose a legal flight landing within two tiles.")
        "Hyde Follow-through":
            if tile != effects(index).get("hydefollow_tile", INVALID) or not legal_walk(index, tile, 1):
                return error("Choose the vacated tile.")
        "Tandem Move":
            var origin: Vector2i = drones[index]["pos"]
            var path := drone_route(origin, tile, 2)
            if path.is_empty():
                return error("Choose a different tile the drone can reach in two steps.")
            plan["drone_path"] = path
            plan["tiles"] = path
        "Field Formula", "Reserve Dose":
            if (not ally and (not enemy or skill == "Reserve Dose")) or distance(source, tile) > 1:
                return error("Choose yourself or an adjacent eligible target.")
            if skill == "Field Formula" and ally and not wounded(target):
                return error("This ally is already at their healing ceiling.")
        "Lend Armour", "Shelter Reflex", "Adrenal Rescue":
            var reach: int = {"Lend Armour": 4, "Shelter Reflex": 1, "Adrenal Rescue": 4}[skill]
            if skill in ["Lend Armour", "Shelter Reflex"] and knows(index, "Long Mantle"):
                reach += 1
            if not ally or not visible(source, tile, reach):
                return error("Choose a standing ally in range.")
            if skill == "Lend Armour" and (target == index or int(unit(index)["armour"]) == 0):
                return error("Choose another ally and have armour to lend.")
            if skill == "Adrenal Rescue" and tiles.size() > 1:
                if tiles[1] != pos(target) and not legal_walk(target, tiles[1], 2):
                    return error("Choose a legal landing up to two steps away, or the ally's tile to stay.")
                plan["landing"] = tiles[1]
        "Break the Vial", "Finish the Job":
            if not enemy:
                return error("Choose a standing enemy.")
            if skill == "Break the Vial" or (skill == "Finish the Job" and unit(index)["basic_melee"]):
                var reach: int = 3 if skill == "Break the Vial" else int(unit(index)["move"])
                var landing := attack_landing(index, target, reach, false)
                if landing == INVALID:
                    return error("No legal approach to this target.")
                plan["landing"] = landing
            elif skill == "Finish the Job":
                if not battle.has_attack_ammo(index) or not visible(source, tile, int(unit(index)["range"])):
                    return error("Needs a charge and a target in range.")
                var cover_block: String = battle.ranged_cover_block_reason(source, tile)
                if cover_block == battle.FULL_COVER_BLOCK:
                    plan["warning"] = cover_block
                elif not cover_block.is_empty():
                    return error(cover_block)
            elif not neighbours(target, source):
                return error("Choose an adjacent enemy.")
        "Fly", "Tongue Vault":
            var reach: int = 3 + int(state(index)["form"] == "Frog" and state(index).get("form_mastery", false)) if skill == "Tongue Vault" else 5 + int(knows(index, "Spread Your Wings"))
            if not can_vault(index, source, tile, reach):
                return error("Choose a legal landing in range.")
            if skill == "Tongue Vault" and tiles.size() > 1 and tiles[1] != tile:
                var foe: int = battle.find_unit_at(tiles[1])
                if not living(foe) or unit(foe)["team"] != "enemy" or anchored(foe) or not visible(tile, tiles[1], 2):
                    return error("Choose an eligible enemy within two tiles of the landing.")
                plan["pull"] = foe
        "Nettle Lock", "Wingover", "Banking Turn":
            if not enemy or not neighbours(target, source):
                return error("Choose an adjacent enemy.")
            if tiles.size() > 1 and not can_vault(index, source, tiles[1], 5 if skill == "Wingover" else 3):
                return error("Choose a legal flight destination.")
        "Bounding Pounce", "Burrowing Strike", "Peregrine Dive":
            if not enemy or (skill == "Peregrine Dive" and int(state(index)["mark"]) != target):
                return error("Choose a standing enemy%s." % (" marked as quarry" if skill == "Peregrine Dive" else ""))
            var reach: int = {"Bounding Pounce": 4, "Burrowing Strike": 4, "Peregrine Dive": 6}[skill]
            var landing := attack_landing(index, target, reach, true, 1 if skill == "Bounding Pounce" else -1)
            if landing == INVALID:
                return error("No legal landing beside this enemy.")
            plan["landing"] = landing
        "Safe Passage":
            if ally and distance(source, tile) <= 1 and tiles.size() == 1:
                return plan
            if ally and tiles.size() == 2 and legal_walk(target, tiles[1], 3):
                plan["landing"] = tiles[1]
                return plan
            return error("Select yourself or an adjacent ally, then a destination within three steps.")
        "Suppress Reaction", "Impulse Push":
            if not enemy or target != effects(index).get(skill, -1):
                return error("Choose the enemy hit by your basic attack.")
            if skill == "Impulse Push" and not battle.can_take_move_step(unit(target), pos(target), pos(target) + direction(source, pos(target))):
                return error("This enemy has no legal push destination.")
        "Counterweight Slide":
            if not ally or target == index or distance(source, tile) > 3:
                return error("Choose a standing ally within three tiles.")
            if tiles.size() > 1:
                if not battle.can_take_move_step(unit(target), tile, tiles[1]):
                    return error("Choose a legal adjacent landing for that ally.")
                plan["landing"] = tiles[1]
        "Rosette Rush":
            var victims: Array[int] = []
            var landings: Array[Vector2i] = []
            var from := source
            for step in range(tiles.size()):
                var pick: Vector2i = tiles[step]
                if step % 2 == 1:
                    if battle.unit_footprint(unit(victims.back()), pos(victims.back())).has_point(pick):
                        plan["ready"] = true
                        break
                    if pick != from and (battle.voluntary_movement_locked(index) or not battle.reachable(from, 2, index).has(pick)):
                        return error("Choose an open landing within two legal steps.")
                    from = pick
                    continue
                var foe: int = battle.find_unit_at(pick)
                if not living(foe) or unit(foe)["team"] != "enemy" or victims.has(foe):
                    return error("Choose a different standing enemy.")
                if not neighbours(foe, from):
                    return error("Choose an enemy adjacent to the landing.")
                victims.append(foe)
                landings.append(from)
            plan["victims"] = victims
            plan["landings"] = landings
        "Scout Run", "Pincer Run", "Shield Run", "Overclock Link":
            return plan_drone_run(index, skill, tiles, plan)
        "Breach Kit", "Breach Shell":
            if skill == "Breach Kit" and option == "Drone":
                if not drone_live(index):
                    return error("Requires a surviving drone.")
                source = drones[index]["pos"]
            return plan_breach(source, skill, tiles, plan)
        "Flak Curtain":
            var aim := tile - source
            if aim == Vector2i.ZERO:
                return error("Choose a direction for the flak lane.")
            var facing := Vector2i(signi(aim.x), 0) if absi(aim.x) >= absi(aim.y) else Vector2i(0, signi(aim.y))
            var lateral := Vector2i(-facing.y, facing.x)
            plan["tiles"] = []
            for depth in range(1, 7):
                for offset in range(-1, 2):
                    var cell := source + depth * facing + offset * lateral
                    if battle.is_in_bounds(cell) and not battle.walls.has(cell) and visible(source, cell, 6):
                        plan["tiles"].append(cell)
            if plan["tiles"].is_empty():
                return error("No visible tiles in the flak lane.")
        "Rolling Thunder":
            if tile != source and not legal_walk(index, tile, 3):
                return error("Choose a legal landing up to three steps away, or hold position.")
            plan["landing"] = tile
            if tiles.size() > 1:
                var aim: Vector2i = tiles[1] - tile
                if aim == Vector2i.ZERO or (aim.x != 0 and aim.y != 0 and absi(aim.x) != absi(aim.y)):
                    return error("Choose a straight firing direction from the landing.")
                plan["tiles"] = []
                var facing := direction(tile, tiles[1])
                for step in range(1, 5):
                    var cell := tile + step * facing
                    if not battle.is_in_bounds(cell) or battle.walls.has(cell):
                        break
                    plan["tiles"].append(cell)
                if plan["tiles"].is_empty():
                    return error("The firing line is blocked.")
        "Mosaic Body":
            var signatures: Array[String] = []
            var selections: Array[Array] = []
            var forms := option.split(" / ")
            if forms.size() != 2:
                return error("Choose an ordered pair of forms.")
            var projected := source
            var cursor := 0
            for form in forms:
                if cursor >= tiles.size():
                    break
                var pick: Vector2i = tiles[cursor]
                var victim: int = battle.find_unit_at(pick)
                var is_enemy: bool = living(victim) and unit(victim)["team"] == "enemy"
                var signature := form_signature(form)
                if int(state(index)["ready"].get(signature, 0)) > battle.turn_number:
                    return error("That signature is still on cooldown.")
                var selection: Array[Vector2i] = [pick]
                cursor += 1
                if signature == "Tongue Vault" and cursor < tiles.size():
                    selection.append(tiles[cursor])
                    cursor += 1
                var provisional_plan := plan_review(index, signature, "", selection,
                    {"target": victim, "tiles": [pick], "source_override": projected}, is_enemy, false)
                if provisional_plan.has("error"):
                    return provisional_plan
                signatures.append(signature)
                selections.append(selection)
                if signature == "Tongue Vault":
                    projected = pick
            plan["signatures"] = signatures
            plan["signature_selections"] = selections
        "Rake":
            var cells: Array[Vector2i] = []
            for pick in tiles:
                if not cells.is_empty() and pick == cells.back():
                    plan["ready"] = true
                    break
                if distance(source, pick) != 1 or pick in cells or not battle.has_line_of_sight(source, pick):
                    return error("Choose a different adjacent tile, or repeat the last tile to strike.")
                cells.append(pick)
            plan["tiles"] = cells
        "Strike and Drop":
            if not enemy or not neighbours(target, source) or anchored(target) \
                    or battle.unit_footprint(unit(target), pos(target)).size != Vector2i.ONE:
                return error("Choose an adjacent enemy you can carry.")
            if tiles.size() >= 2:
                var landing: Vector2i = tiles[1]
                if not can_vault(index, source, landing, 3):
                    return error("Choose a legal flight landing within three tiles.")
                plan["landing"] = landing
                if tiles.size() == 3:
                    var drop: Vector2i = tiles[2]
                    var ignored: int = unit(index if drop == source else target)["id"]
                    if distance(landing, drop) != 1 or not battle.has_line_of_sight(landing, drop) or not battle.tile_is_open(drop, ignored):
                        return error("Choose a free drop tile adjacent to the landing.")
                    plan["drop"] = drop
        "Split Focus", "Phantom Threat", "Spatial Exchange":
            var first_reach: int = {"Split Focus": 6,
                "Phantom Threat": 5, "Spatial Exchange": 4}.get(skill, 1)
            if not enemy or not visible(source, tile, first_reach):
                return error("Choose an enemy in range.")
            if skill == "Phantom Threat" and not organic(target):
                return error("Choose an organic enemy.")
            if skill == "Split Focus":
                var cover_block: String = battle.ranged_cover_block_reason(source, tile)
                if cover_block == battle.FULL_COVER_BLOCK:
                    plan["warning"] = cover_block
                elif not cover_block.is_empty():
                    return error(cover_block)
            if skill == "Spatial Exchange" and anchored(target):
                return error("This target is too heavy.")
            if tiles.size() == 2:
                var second: int = battle.find_unit_at(tiles[1])
                if not living(second) or second == target:
                    return error("Choose a second standing unit.")
                var expected_team := "player" if skill in ["Phantom Threat", "Spatial Exchange"] else "enemy"
                if unit(second)["team"] != expected_team:
                    return error("Choose a %s unit." % expected_team)
                var reach: int = maxi(battle.board_w, battle.board_h) if skill == "Phantom Threat" else first_reach
                if not visible(source, tiles[1], reach) or (skill == "Split Focus" and distance(tile, tiles[1]) != 1):
                    return error("The second target is out of position.")
                if skill == "Split Focus":
                    var cover_block: String = battle.ranged_cover_block_reason(source, tiles[1])
                    if cover_block == battle.FULL_COVER_BLOCK:
                        plan["warning"] = cover_block
                    elif not cover_block.is_empty():
                        return error(cover_block)
                    plan["second_tile"] = tiles[1]
                if skill == "Spatial Exchange" and not can_swap(index, target, second):
                    return error("Both units need a valid landing.")
                plan["second"] = second
        "Linebreaker":
            if battle.voluntary_movement_locked(index):
                return error(battle.movement_lock_reason(index))
            if tile == source or distance(source, tile) > 4:
                return error("Choose a tile up to four spaces ahead.")
            var offset := tile - source
            if offset.x != 0 and offset.y != 0 and absi(offset.x) != absi(offset.y):
                return error("Choose a straight charge line.")
            plan["tiles"] = line_tiles(source, tile)
        "Sanctuary":
            if tiles.size() > int(unit(index)["armour"]):
                return error("All available armour is already assigned.")
            var distribution := {}
            for pick in tiles:
                var patient: int = battle.find_unit_at(pick)
                if not living(patient) or patient == index or unit(patient)["team"] != "player" or not visible(source, pick, 4):
                    return error("Choose another standing ally within four tiles.")
                distribution[patient] = int(distribution.get(patient, 0)) + 1
            plan["distribution"] = distribution
            plan["ready"] = tiles.size() == int(unit(index)["armour"])
        "Passing Trait":
            if not ally or not visible(source, tile, 4 if skill == "Sanctuary" else 3):
                return error("Choose a standing ally in range.")
            if tiles.size() > 1:
                if tiles[1] != pos(target) and not legal_walk(target, tiles[1], 2):
                    return error("Choose a legal destination within two steps.")
                plan["landing"] = tiles[1]
        "Venom Jet", "Gleaming Armour":
            plan["tiles"] = []
            for cell: Vector2i in battle.grid_cone(source, tile, 3, 3):
                if not battle.walls.has(cell) and visible(source, cell, 3):
                    plan["tiles"].append(cell)
            if plan["tiles"].is_empty():
                return error("Choose a direction with visible tiles.")
        "Sweep Beam":
            plan["tiles"] = review_line(source, tile, 6)
            if plan["tiles"].is_empty():
                return error("Choose the centre of three visible tiles within six.")
        "Raking Pass":
            if not can_vault(index, source, tile, 3):
                return error("Choose a legal landing within three tiles.")
            plan["landing"] = tile
            plan["tiles"] = line_tiles(source, tile)
            plan["tiles"].pop_back()
        "Wrecking Ball":
            if not enemy or not visible(source, tile, 4):
                return error("Choose an enemy within four tiles.")
            if anchored(target):
                return error("This target is too heavy.")
            elif tiles.size() > 1:
                var offset: Vector2i = tiles[1] - tile
                if offset == Vector2i.ZERO or distance(tile, tiles[1]) > 3 or (offset.x != 0 and offset.y != 0 and absi(offset.x) != absi(offset.y)):
                    return error("Choose a straight throwing direction up to three tiles away.")
                plan["facing"] = direction(tile, tiles[1])
                plan["length"] = distance(tile, tiles[1])
        "Shock Mine":
            if not battle.tile_is_open(tile) or (not visible(source, tile, 2) and
                    (not drone_live(index) or not visible(drones[index]["pos"], tile, 2))):
                return error("Choose an open tile within two tiles of Iskra or its drone.")
        "Recovery Winch":
            if not drone_live(index) or not ally or battle.unit_footprint(unit(target), pos(target)).size != Vector2i.ONE \
                    or not visible(drones[index]["pos"], tile, 3):
                return error("Choose a standing one-tile ally visible within three tiles of the drone.")
        "Express Trait":
            var selected_form: String = plan.get("form", state(index)["form"])
            if selected_form == "Jellyfish":
                if not enemy or not neighbours(target, source):
                    return error("Choose an adjacent enemy.")
            elif selected_form == "Frog":
                if not enemy:
                    return error("Choose an enemy to pounce on.")
                var landing := attack_landing(index, target, 3, true)
                if landing == INVALID:
                    return error("No legal landing beside this enemy.")
                plan["landing"] = landing
            else:
                plan["tiles"] = review_line(source, tile, 5)
                if plan["tiles"].is_empty():
                    return error("Choose the centre of three visible tiles within five.")
        "Emergency Rebuild":
            for step: Vector2i in battle.MOVE_DIRECTIONS:
                if battle.tile_is_open(source + step):
                    plan["landing"] = source + step
                    return plan
            return error("No open tile beside the operator.")
        "Field Service":
            if not drone_live(index) or tile != drones[index]["pos"] or distance(source, tile) != 1:
                return error("Choose your adjacent drone.")
        "Walking Barrage", "Incendiary Shell":
            var reach := 8 if skill == "Walking Barrage" else 6
            plan["tiles"] = review_line(source, tile, reach)
            if plan["tiles"].is_empty() or source in plan["tiles"]:
                return error("Choose the centre of three visible tiles in a line within %d." % reach)
        "Mortar Cup", "Siege Salvo", "Field Hospital", "Quarantine Field", "Musk Trail":
            var reach: int = {"Mortar Cup": 7, "Siege Salvo": 8}.get(skill, 4)
            var minimum := 4 if skill in ["Mortar Cup", "Siege Salvo"] else 0
            if not visible(source, tile, reach) or distance(source, tile) < minimum:
                return error("Choose a visible tile in range.")
            plan["tiles"] = cross_tiles(tile) if skill in ["Mortar Cup", "Siege Salvo", "Field Hospital", "Quarantine Field"] else area(tile, 1, false)
            if skill == "Field Hospital":
                var patients: Array[int] = []
                for pick in tiles.slice(1):
                    if pick == tile and (not patients.is_empty() or battle.find_unit_at(pick) < 0):
                        plan["ready"] = true
                        break
                    var patient: int = battle.find_unit_at(pick)
                    if not living(patient) or unit(patient)["team"] != "player" or pick not in plan["tiles"] or patient in patients:
                        return error("Choose an untreated standing ally inside the ward.")
                    patients.append(patient)
                plan["patients"] = patients
            if skill == "Musk Trail":
                plan["tiles"] = review_line(source, tile, reach)
                if plan["tiles"].is_empty():
                    return error("Choose the centre of three visible tiles in range.")
        "Hurl Debris":
            var edges := light_edges(tile)
            if edges.is_empty() or not visible(source, tile, 3):
                return error("Choose a tile bordering destructible light cover within three.")
            if tiles.size() >= 2:
                var edge := cover_between(tile, tiles[1])
                if edge not in edges:
                    return error("Choose the tile directly across the light-cover edge.")
                plan["edge"] = edge
            if tiles.size() == 3:
                var victim: int = battle.find_unit_at(tiles[2])
                if not living(victim) or unit(victim)["team"] != "enemy" or not visible(tile, tiles[2], 4):
                    return error("Choose an enemy within four tiles of that cover.")
                var cover_block: String = battle.ranged_cover_block_reason(tile, tiles[2])
                if cover_block == battle.FULL_COVER_BLOCK:
                    plan["warning"] = cover_block
                elif not cover_block.is_empty():
                    return error(cover_block)
                plan["target"] = victim
                plan["target_tile"] = tiles[2]
        "Shed Skin":
            if option == state(index)["form"]:
                return error("Choose a different form.")
    return plan

func crossed_cover_edges(from: Vector2i, to: Vector2i) -> Array[String]:
    var edges: Array[String] = []
    for step in [Vector2i(to.x - from.x, 0), Vector2i(0, to.y - from.y)]:
        if step != Vector2i.ZERO:
            var edge := cover_between(from, from + step)
            if battle.destructible_edges.has(edge):
                edges.append(edge)
    return edges

func plan_throw(index: int, target: int, destination: Vector2i, plan: Dictionary) -> Dictionary:
    var landing := pos(target)
    var path: Array[Vector2i] = []
    for cell in line_tiles(landing, destination):
        var edges := crossed_cover_edges(landing, cell)
        path.append(cell)
        if not edges.is_empty():
            plan["collision_edge"] = edges.front()
            break
        var blocker: int = battle.find_unit_at(cell)
        if living(blocker) and blocker != target and unit(blocker)["team"] != unit(index)["team"]:
            plan["collision_unit"] = blocker
            break
        if not battle.footprint_is_open(unit(target), cell):
            return error("The throw is blocked. Choose another landing.")
        landing = cell
    plan["landing"] = landing
    plan["tiles"] = path
    return plan

func plan_breach(source: Vector2i, skill: String, tiles: Array[Vector2i], plan: Dictionary) -> Dictionary:
    var first := tiles[0]
    var reach := 8 if skill == "Breach Shell" else 3
    var minimum := 4 if skill == "Breach Shell" else 0
    if tiles.size() == 1:
        for offset in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
            var candidate: Array[Vector2i] = [first, first + offset]
            if not plan_breach(source, skill, candidate, {}).has("error"):
                return plan
        return error("Choose a tile bordering a visible destructible edge in range.")
    var second := tiles[1]
    var face: String = battle.direction_to_face(first, second)
    if face.is_empty() or not battle.is_in_bounds(second):
        return error("Choose the adjacent tile across the cover edge.")
    var edge: String = battle.edge_key(first, face)
    var near_distance := mini(distance(source, first), distance(source, second))
    var first_visible: bool = not battle.walls.has(first) and visible(source, first, reach)
    var second_visible: bool = not battle.walls.has(second) and visible(source, second, reach)
    if not battle.destructible_edges.has(edge) or near_distance < minimum or not (first_visible or second_visible):
        return error("Choose a visible destructible cover edge in range.")
    plan["edge"] = edge
    plan["tiles"] = [first, second]
    return plan

func plan_drone_run(index: int, skill: String, tiles: Array[Vector2i], plan: Dictionary) -> Dictionary:
    if not drone_live(index):
        return error("Requires a surviving drone.")
    var origin: Vector2i = drones[index]["pos"]
    var landing := tiles[0]
    var guardian := skill == "Shield Run" or (skill == "Overclock Link" and knows(index, "Guardian Chassis"))
    var reach := 2 if skill == "Scout Run" else (4 if skill == "Overclock Link" and not guardian else 3)
    var path := drone_route(origin, landing, reach)
    if landing != origin and path.is_empty():
        return error("Choose a reachable drone landing within %d tiles." % reach)
    plan["drone_path"] = path
    plan["tiles"] = path.duplicate()
    if tiles.size() == 1:
        return plan
    if guardian:
        return plan_drone_cover(skill, tiles, plan)
    if skill == "Scout Run" and tiles[1] == landing:
        if origin == landing:
            return error("Move the drone or choose a target.")
        return plan
    return plan_arc(landing, tiles.slice(1), plan, index if not path.is_empty() else -1)

func plan_drone_cover(skill: String, tiles: Array[Vector2i], plan: Dictionary) -> Dictionary:
    var landing := tiles[0]
    var facings := 2 if skill == "Overclock Link" else 1
    var lines: Array[Dictionary] = []
    for selected in tiles.slice(1, 1 + facings):
        var forward: Vector2i = selected - landing
        if absi(forward.x) + absi(forward.y) != 1:
            return error("Choose a cardinal facing adjacent to the drone.")
        var face: String = battle.attacked_side(selected, landing)
        if not lines.is_empty() and lines[0]["face"] == face:
            return error("Choose a different facing for the second cover line.")
        var tangent := Vector2i(-forward.y, forward.x)
        var cells: Array[Vector2i] = []
        for cell: Vector2i in [landing - tangent, landing, landing + tangent]:
            if battle.is_in_bounds(cell) and not battle.walls.has(cell) and battle.is_in_bounds(cell + forward) and not battle.walls.has(cell + forward):
                cells.append(cell)
        if cells.is_empty():
            return error("No open edges in this facing.")
        lines.append({"face": face, "tiles": cells})
        plan["tiles"].append_array(cells)
    plan["cover_lines"] = lines
    var protected: Array[int] = []
    for pick in tiles.slice(1 + facings):
        if pick == landing:
            plan["ready"] = true
            break
        var ally: int = battle.find_unit_at(pick)
        if not living(ally) or unit(ally)["team"] != "player" or distance(pick, landing) != 1 or ally in protected:
            return error("Choose a different adjacent squadmate, or repeat the drone landing to finish.")
        protected.append(ally)
        plan["tiles"].append(pick)
    plan["protected"] = protected
    return plan

func plan_arc(origin: Vector2i, tiles: Array[Vector2i], plan: Dictionary, ignored_drone: int) -> Dictionary:
    var targets: Array[int] = []
    for pick in tiles:
        var foe: int = battle.find_unit_at(pick)
        if not targets.is_empty() and foe == targets.back():
            plan["ready"] = true
            break
        if not living(foe) or unit(foe)["team"] != "enemy" or foe in targets or not visible(origin, pick, 4 if targets.is_empty() else 2):
            return error("Choose a new visible enemy within reach of the last link.")
        var cover_block: String = battle.ranged_cover_block_reason(origin, pick, 0, ignored_drone)
        if cover_block == battle.FULL_COVER_BLOCK:
            plan["warning"] = cover_block
        elif not cover_block.is_empty():
            return error(cover_block)
        targets.append(foe)
        plan["tiles"].append(pick)
        origin = pick
    plan["arc_targets"] = targets
    plan["arc_target_tiles"] = tiles.slice(0, targets.size())
    return plan

func form_signature(form: String) -> String:
    return {"Frog": "Tongue Vault", "Jellyfish": "Nettle Lock", "Skunk": "Musk Trail"}.get(form, "")

func review_line(source: Vector2i, tile: Vector2i, reach: int) -> Array[Vector2i]:
    var facing := direction(source, tile)
    if facing == Vector2i.ZERO:
        return []
    var cells: Array[Vector2i] = [tile - facing, tile, tile + facing]
    for cell in cells:
        if not battle.is_in_bounds(cell) or battle.walls.has(cell) or not visible(source, cell, reach):
            return []
    return cells

func can_swap(index: int, first: int, second: int) -> bool:
    return index != first and first != second \
        and battle.unit_footprint(unit(first), pos(first)).size == Vector2i.ONE \
        and battle.unit_footprint(unit(second), pos(second)).size == Vector2i.ONE

func swap_units(first: int, second: int) -> void:
    var original := pos(first)
    battle.apply_unit_position(first, pos(second), &"displace")
    battle.apply_unit_position(second, original, &"displace")
    battle.apply_hazard_entry(first)
    battle.apply_hazard_entry(second)

func safe_walk(index: int, destination: Vector2i, reach: int) -> bool:
    if not legal_walk(index, destination, reach):
        return false
    for cell in battle.shortest_tile_path(pos(index), destination, index):
        if battle.footprint_has_hazard(unit(index), cell):
            return false
    return true

func drone_path(origin: Vector2i, destination: Vector2i, reach: int) -> bool:
    return origin == destination or not drone_route(origin, destination, reach).is_empty()

func drone_route(origin: Vector2i, destination: Vector2i, reach: int) -> Array[Vector2i]:
    var parents: Dictionary = {origin: origin}
    var frontier: Array[Vector2i] = [origin]
    for _step in range(reach):
        var next: Array[Vector2i] = []
        for cell in frontier:
            for delta in battle.MOVE_DIRECTIONS:
                var tile: Vector2i = cell + delta
                if parents.has(tile) or not battle.can_take_move_step({}, cell, tile):
                    continue
                parents[tile] = cell
                if tile == destination:
                    var route: Array[Vector2i] = []
                    while tile != origin:
                        route.push_front(tile)
                        tile = parents[tile]
                    return route
                next.append(tile)
        frontier = next
    return []

func wounded(index: int) -> bool:
    return living(index) and int(unit(index)["hp"]) < battle.recoverable_hp(unit(index))

func healing_targets(cells: Array, include_healthy: bool) -> Array[int]:
    var result: Array[int] = []
    for index in in_tiles(cells, "player"):
        if include_healthy or wounded(index):
            result.append(index)
    result.sort_custom(func(a: int, b: int) -> bool:
        return int(unit(a)["hp"]) < int(unit(b)["hp"]))
    if result.size() > 3:
        result.resize(3)
    return result

func resolve(index: int, skill: String, option: String, selected: Array[Vector2i], plan: Dictionary) -> void:
    if supports_review_action(skill):
        if selected.size() > 1 and skill in ["Wingover", "Banking Turn"]:
            plan["landing"] = selected[1]
        resolve_review(index, skill, option, selected[0], plan)
        return
    var tile: Vector2i = selected[0]
    var target: int = plan["target"]
    var cells: Array = plan["tiles"]
    var info: Dictionary = state(index)
    var fx: Dictionary = effects(index)
    var source: Vector2i = pos(index)
    match skill:
        "Charge", "Breakthrough", "Deathsting", "Talon Descent", "Raptor Descent", \
        "Carapace Rush", "Siege Momentum", "Follow-up Step", "Rapid Metamorph", "Wing Hop", "Tethered Ascent", \
        "Hammerfist", "Force Ram", "Savage Counter", "Rabid Frenzy", "Projected Strike", \
        "Retinal Lance", "Prism Shot", "Core Melter", "Crossfire Protocol":
            # Relocations and direct strikes supply their own playback at resolution.
            pass
        "Adaptive Technique":
            if info["form"] != "Frog":
                battle.play_unit_action(index, battle.board_center(tile), false, Color("#9de2ba"), skill)
        "Delayed Mortar", "Iron Rain":
            for aim in selected:
                battle.play_unit_action(index, battle.board_center(aim), false, Color.TRANSPARENT, skill)
        _:
            var color := Color("#d2b4f5")
            if skill in ["Quake Slam", "Iron Cataclysm", "Psychic Burst", "Fan Beam", "Shell Collapse",
                    "Micro-Rocket", "Rocket Salvo", "Cluster Burst", "Arc Net"]:
                color = Color("#ffca8a")
            elif skill in SELF_ACTIONS or (living(target) and unit(target)["team"] == "player"):
                color = Color("#9de2ba")
            battle.play_unit_action(index, battle.board_center(tile), false, color, skill)
    match skill:
        "Charge", "Breakthrough", "Deathsting", "Talon Descent", "Raptor Descent":
            var flying: bool = skill in ["Talon Descent", "Raptor Descent"]
            var landing: Vector2i = plan["landing"]
            if flying and knows(index, "Feather Guard") and once(index, "Feather Guard"):
                barrier(index, 1, "feather_barrier")
            if not relocate(index, landing, flying, true, skill == "Charge") or not living(target):
                return
            var bonus: int = {"Breakthrough": 1, "Talon Descent": 2, "Raptor Descent": 3}.get(skill, 0)
            var poisoned: bool = effects(target).has("poison")
            melee(index, target, skill, bonus)
            if skill == "Deathsting" and living(target):
                poison(index, target)
                melee(index, target, skill, int(poisoned))
                if living(target) and poisoned:
                    slow(target, 2)
            if skill == "Raptor Descent" and living(index) and selected[1] != landing:
                relocate(index, selected[1], true)
        "Hook Sting":
            poison(index, target)
            if not anchored(target):
                effects(target)["root"] = true
        "Barbed Impaler":
            if not neighbours(target, source):
                force_move(index, target, direction(pos(target), source), 1)
            if living(target) and neighbours(target, source):
                hit(index, target, skill, 2, {"melee": true, "visual_queued": true})
        "Carapace Rush":
            barrier(index, 1)
            relocate(index, tile, false)
        "Savage Counter":
            melee(index, target, skill, 1)
            fx["counter"] = true
        "Rabid Frenzy":
            melee(index, target, skill)
            if living(target):
                melee(index, target, skill)
        "Chitin Dodge":
            fx["dodge"] = true
        "Overdrive":
            add_move(index, 2)
            fx["melee_bonus"] = 1
        "Follow-up Step":
            fx.erase("free_step")
            relocate(index, tile, false, true, false, bool(fx.get("safe_step", false)))
            fx.erase("safe_step")
        "Force Shell":
            fx["force_shell"] = 2
        "Hammerfist":
            melee(index, target, skill, 1, 1)
            var edges: Array[String] = light_edges(tile)
            if not edges.is_empty():
                battle.damage_cover_edge(edges[0], 1, index, skill)
        "Force Ram":
            var shield: int = spend_shell(index, 1)
            melee(index, target, skill, 1)
            force_move(index, target, direction(source, tile), 1 + shield)
        "Iron Lock":
            fx["brace"] = true
            fx["approach_counter"] = true
            refresh_stats(index)
        "Wallbreaker":
            battle.damage_cover_edge(plan["edge"], 2, index, skill)
            if living(target) and unit(target)["team"] == "enemy":
                hit(index, target, skill, 3, {"melee": true, "visual_queued": true})
        "Aegis Relay":
            barrier(target, spend_shell(index, 2))
            battle.battle_stats[index]["buffs"] += 1
        "Quake Slam", "Iron Cataclysm", "Psychic Burst":
            var shield: int = spend_shell(index, 2) if skill == "Psychic Burst" else 0
            for foe in in_tiles(cells, "enemy"):
                if skill == "Iron Cataclysm":
                    hit(index, foe, skill, 4, {"break": 2, "area": true})
                else:
                    hit(index, foe, skill, 1 + (shield if skill == "Psychic Burst" else 1), {"area": true})
                    if living(foe) and not anchored(foe):
                        if skill == "Quake Slam" and int(unit(foe)["weight"]) == 1:
                            slow(foe, 1)
                        elif skill == "Psychic Burst":
                            force_move(index, foe, direction(source, pos(foe)), 1)
            if skill == "Iron Cataclysm":
                fx["electrical_weak"] = true
            if skill != "Psychic Burst":
                battle.damage_cover_in_tiles(cells, 1, index, skill, true)
        "Projected Strike":
            hit(index, target, skill, 2 + spend_shell(index, 1), {"source": source, "ranged": true})
        "Shell Collapse":
            blast(index, cells, 1 + spend_shell(index, 2), skill, 0, true, false)
        "Siege Momentum":
            fx["siege"] = true
            relocate(index, tile, false)
        "Disrupt Focus":
            suppress(index, target)
        "Intrusive Thought":
            if not anchored(target):
                effects(target)["attack_penalty"] = 1
            disrupt(index, target)
        "Panic Spike":
            suppress(index, target)
            if not anchored(target):
                effects(target)["panic"] = true
        "Borrow Sight":
            effects(target)["borrow_sight"] = index
        "Compel Step":
            relocate(target, selected[1], false, false)
            disrupt(index, target)
        "Mind Lock":
            suppress(index, target)
            if not anchored(target):
                effects(target)["mind_lock"] = true
        "Force Hand", "Kinetic Drag", "Kinetic Slam", "Wing Buffet":
            var pull: bool = skill == "Kinetic Drag" or option == "Pull"
            var vector: Vector2i = direction(tile, source) if pull else direction(source, tile)
            var old_cover: int = battle.cover_level_at(pos(target), source)
            var moved: int = force_move(index, target, vector, 2 if skill == "Kinetic Drag" else 1,
                skill in ["Kinetic Drag", "Force Hand"], skill == "Kinetic Slam")
            if skill == "Kinetic Slam":
                hit(index, target, skill, 1 + int(moved < 1 and not anchored(target)), {"visual_queued": true})
            if skill != "Wing Buffet" and living(target) and (moved > 0 or skill == "Kinetic Slam"):
                disrupt(index, target)
                if skill == "Force Hand" and old_cover > battle.cover_level_at(pos(target), source):
                    effects(target)["exposed_side"] = index
        "Lift Ally":
            relocate(target, selected[1], true, false)
        "Vector Pull":
            var moved: int = 0
            for foe in in_tiles(cells, "enemy"):
                if int(unit(foe)["weight"]) == 1 and force_move(index, foe, direction(pos(foe), tile), 1, true) > 0:
                    disrupt(index, foe)
                    moved += 1
                    if moved == 2:
                        break
        "Mass Panic":
            for foe in in_tiles(cells, "enemy"):
                if organic(foe):
                    suppress(index, foe)
                    slow(foe, 1 if anchored(foe) else 2)
        "Gravity Well", "Master Interference":
            create_zone(index, skill, tile, cells)
        "Contract Mark":
            info["mark"] = target
            info["mark_open"] = true
        "Retinal Lance", "Prism Shot", "Core Melter":
            var damage: int = int(unit(index)["damage"]) + (3 if skill == "Core Melter" else 0)
            var bypass: int = 2 if skill == "Core Melter" else int(skill == "Retinal Lance")
            var secondary: int = aligned_foe(index, target, tile) if skill == "Prism Shot" else -1
            hit(index, target, skill, damage, {"source": source, "ranged": true, "bypass": bypass})
            if living(secondary):
                hit(index, secondary, skill, maxi(1, floori(damage / 2.0)), {"source": source, "ranged": true})
        "Fan Beam":
            blast(index, cells, 1, skill, 0)
        "Wing Hop", "Tethered Ascent":
            relocate(index, tile, true)
            if skill == "Tethered Ascent":
                info["withdraw"] = -1
        "Perfect Opportunity":
            fx["perfect"] = true
        "Power Routing":
            if option == "Mobility":
                add_move(index, 2)
            else:
                fx["overcharge"] = true
        "Emergency Vent":
            cool(index, 2)
            fx.erase("must_vent")
            unit(index)["statuses"].erase("shocked")
        "Emergency Overdrive":
            fx["heat_override"] = true
            fx["must_vent"] = true
        "Remote Pulse":
            drones[index]["pos"] = tile
            for foe in in_tiles(area(tile, 1, false), "enemy"):
                cancel_reaction(foe)
                recalibrate(index)
                break
        "Interceptor Bot":
            drones[index]["intercept"] = true
        "Saboteur Bot", "Remote Override":
            cancel_reaction(target)
            if not organic(target):
                effects(target)["reaction_off"] = true
                slow(target, 2)
            recalibrate(index)
        "Crossfire Protocol":
            if battle.spend_shot(index):
                hit(index, target, skill, int(unit(index)["damage"]), {"source": source, "ranged": true})
            var origin: Vector2i = drones[index]["pos"]
            if living(target) and visible(origin, tile, drone_reach(index, 5)):
                hit(index, target, skill, 2, {"source": origin, "ranged": true})
        "Micro-Rocket", "Rocket Salvo", "Cluster Burst", "Delayed Mortar", "Iron Rain":
            var damage: int = (1 if skill == "Cluster Burst" else 2) + redline(index) + int(fx.get("overcharge", false))
            if skill in ["Delayed Mortar", "Iron Rain"]:
                ordnance.append({"owner": index, "tiles": cells, "aims": selected, "damage": damage, "skill": skill})
            else:
                blast(index, cells, damage, skill, 1, skill != "Rocket Salvo")
            fx.erase("overcharge")
        "Arc Net":
            for cell in cells:
                battle.spawn_hazard(cell, "shock", index)
                if battle.hazards.get(cell, {}).get("kind") == "shock":
                    battle.hazards[cell]["expires_round"] = battle.turn_number + 2
            for occupant in in_tiles(cells):
                battle.apply_hazard_entry(occupant)
            fx.erase("overcharge")
        "Adaptive Catalyst":
            support(index, target, option, true)
        "Darwinian Shift", "Rapid Metamorph":
            info["form"] = option
            once(index, "form change")
            refresh_stats(index)
            refresh_base_attack(index)
            if skill == "Rapid Metamorph":
                relocate(index, tile, false, true, false, true)
        "Adaptive Technique":
            match info["form"]:
                "Frog":
                    if relocate(index, plan["landing"], false) and living(target):
                        var extra: int = int(knows(index, "Stable Adaptation") and once(index, "Stable Adaptation"))
                        melee(index, target, skill, extra)
                "Jellyfish":
                    barrier(index, 1 + int(knows(index, "Stable Adaptation")))
                    if target != index:
                        support(index, target, "Barrier", false)
                    else:
                        support_passives(index, index)
                "Skunk":
                    suppress(index, target)
        "Gene Transfer":
            var earlier: int = int(info["transfer"])
            if living(earlier):
                clear_transfer(index, earlier)
            info["transfer"] = target
            support(index, target, {"Frog": "Mobility", "Jellyfish": "Barrier", "Skunk": "Range"}[info["form"]], true, true)
        "Apex Reconfiguration":
            info["apex_until"] = battle.turn_number + 2
            refresh_stats(index)
            match info["form"]:
                "Jellyfish":
                    barrier(index, 2)
                    fx["apex_intercept"] = true
                "Skunk":
                    create_zone(index, skill, source, area(source, 3, false), 2)
        "Catalytic Cascade":
            fx["cascade"] = true
        "Protective Clot", "Scar Weave":
            if skill == "Scar Weave":
                cleanse(target)
            support(index, target, "Barrier", true)
        "Cell Mender", "Crisis Mending":
            heal(index, target, 2 if skill == "Cell Mender" else 3, skill)
            support_passives(index, target)
        "Communal Clot", "Regenerative Wave":
            for ally in healing_targets(cells, skill == "Regenerative Wave"):
                heal(index, ally, 1, skill)
                if skill == "Regenerative Wave":
                    barrier(ally, 1)
                support_passives(index, ally)
    if skill in DRONE_ACTIONS:
        fx.erase("overcharge")
    if knows(index, "Adaptive Catalyst") and skill != "Follow-up Step":
        if knows(index, "Metabolic Reserve") and once(index, "Metabolic Reserve"):
            add_move(index, 1)
        if knows(index, "Controlled Change") and once(index, "Controlled Change"):
            fx["free_step"] = 1
            fx["safe_step"] = true

func resolve_review(index: int, skill: String, option: String, tile: Vector2i, plan: Dictionary) -> void:
    var target: int = plan["target"]
    var info := state(index)
    var source := pos(index)
    if not REVIEW_RANGED.has(skill) and living(target) and unit(target)["team"] == "enemy" and organic(target) and knows(index, "Empathic Echo"):
        effects(target)["empathic_owner"] = index
    if skill in ["Rapid Metamorph", "Perfect Adaptation"]:
        shift_form(index, option)
        var signature: String = "Express Trait" if skill == "Perfect Adaptation" else form_signature(option)
        info["ready"][signature] = battle.turn_number + 2
        resolve_review(index, signature, "", tile, plan)
        return
    if REVIEW_RANGED.has(skill):
        var damage: int = REVIEW_RANGED[skill][1]
        var piercing: bool = skill in ["Needle Beam", "Corneal Lance", "Pinhole Sun"]
        if skill == "Compression" and battle.walls.has(tile + direction(source, tile)):
            damage += 2
        if skill == "Feedback Spike" and effects(target).get("reaction_cancelled_by", {}).get(index, -1) == battle.turn_number:
            damage += 2
        var landed: bool = hit(index, target, skill, damage, {"ranged": true, "target_tile": tile, "bypass": int(unit(target)["armour"]) if piercing else 0})
        if landed and living(target):
            match skill:
                "Corneal Lance": battle.apply_status(target, "blinded", 3 if knows(index, "Rangefinder") else 1)
                "The Void's Gaze", "Encasing Armour": set_root(target)
        if skill == "Encasing Armour":
            unit(index)["armour"] = 0
        return
    match skill:
        "Designate Target", "Distort Aim", "Aphasia", "Panic Spike", "Crowd Panic", "Thought Arrest", \
        "Throw", "Vector Pull", "Lateral Slip", "Spatial Exchange", "Taunt", "Thundering Taunt", \
        "Phantom Threat", "Suppress Reaction", "Impulse Push", "Musk Trail", "Quarantine Field", "Venom Jet":
            battle.play_unit_action(index, battle.board_center(tile), false, Color("#c5a7f1"), skill)
        "Gleaming Armour", "Reserve Dose", "Lend Armour", "Shelter Reflex", "Emergency Cells", \
        "Adrenal Rescue", "Field Hospital", "Anchor", "Vent", "Safe Passage", "Sanctuary", \
        "Plastic Skin", "Transform", "Revert", "Darwinian Shift", "Shed Skin", "Field Service", "Emergency Rebuild":
            battle.play_unit_action(index, battle.board_center(tile), false, Color("#9de2ba"), skill)
        "Breach Kit", "Breach Shell", "Siege Salvo", "Mortar Cup", "Walking Barrage", "Incendiary Shell", \
        "Flak Curtain", "Rolling Thunder", "Pressure Front", "Empty the Shell", "Sweep Beam", "Shock Mine":
            battle.play_unit_action(index, battle.board_center(tile), false, Color.TRANSPARENT, skill)
    match skill:
        "Designate Target":
            var old: int = int(info["mark"])
            if living(old) and int(effects(old).get("quarry_owner", -1)) == index:
                clear_quarry(old)
            clear_quarry(target)
            info["mark"] = target
            effects(target).merge({"quarry_hits": 3, "quarry_owner": index}, true)
        "Distort Aim":
            effects(target)["distorted_by"] = index
        "Aphasia":
            effects(target)["aphasia"] = true
        "Panic Spike", "Crowd Panic":
            var targets: Array = in_tiles(area(tile, 1), "enemy") if skill == "Crowd Panic" else [target]
            for foe: int in targets:
                if not organic(foe):
                    continue
                suppress(index, foe)
                slow(foe, 2)
        "Thought Arrest":
            effects(target)["review_ap_loss"] = 2
        "Throw", "Vector Pull", "Lateral Slip":
            if skill == "Throw":
                var edge: String = plan.get("collision_edge", "")
                var blocker: int = plan.get("collision_unit", -1)
                if edge != "":
                    battle.damage_cover_edge(edge, int(battle.destructible_edges[edge]["hp"]), index, skill)
                if edge != "" or blocker >= 0:
                    hit(index, target, skill, 2, {"area": true})
                if blocker >= 0:
                    hit(index, blocker, skill, 2, {"area": true})
                if living(target) and pos(target) != plan["landing"]:
                    battle.apply_unit_position(target, plan["landing"], &"displace")
                    battle.apply_hazard_entry(target)
                return
            var vector := direction(tile, source)
            var length := 1 if option == "1 Tile" else 2
            if skill == "Lateral Slip":
                vector = Vector2i(-vector.y, vector.x) * (-1 if option == "Right" else 1)
                length = 1
            force_move(index, target, vector, length)
        "Taunt", "Thundering Taunt":
            var targets: Array = in_tiles(area(source, 2), "enemy") if skill == "Thundering Taunt" else [target]
            for foe: int in targets:
                effects(foe)["taunted_by"] = index
        "Gleaming Armour":
            for foe in in_tiles(plan["tiles"], "enemy"):
                battle.apply_status(foe, "blinded")
        "Field Formula":
            if unit(target)["team"] == "player":
                heal(index, target, 2, skill)
            else:
                var bonus := int(knows(index, "Clinical Eye") and int(unit(target)["hp"]) * 2 < int(unit(target)["max_hp"])
                    and once(index, "Clinical Eye"))
                hit(index, target, skill, 2 + bonus, {"melee": true})
                if living(target):
                    effects(target)["attack_penalty"] = 1
        "Reserve Dose":
            if not unit(target)["statuses"].erase("burning"):
                effects(target).erase("poison")
            effects(target)["reserve_dose"] = 1
        "Defence is the Best Offense":
            barrier(index, 2)
            effects(index)["attack_boost"] = 1
        "Lend Armour", "Shelter Reflex":
            var amount := 3
            var previous_owner: int = effects(target).get("mantle_owner", -1)
            if previous_owner >= 0:
                end_mantle(previous_owner, target, true, false)
            if skill == "Lend Armour":
                amount = mini(amount, int(unit(index)["armour"]))
                unit(index)["armour"] -= amount
            else:
                barrier(index, amount)
            effects(target)["mantle"] = amount
            effects(target)["mantle_owner"] = index
            state(index)["mantles"] = state(index).get("mantles", {})
            state(index)["mantles"][target] = skill
        "Emergency Cells":
            restore_weapon_charges(index, 2)
            barrier(index, 2)
        "Adrenal Rescue":
            if relocate(target, plan["landing"], false, true, false, true, true) and living(target):
                heal(index, target, 2, skill)
        "Field Hospital", "Quarantine Field":
            var zone := {"owner": index, "skill": skill, "center": tile, "tiles": plan["tiles"],
                "used": {}, "expires": battle.turn_number + (2 if skill == "Field Hospital" else 1)}
            zones.append(zone)
            var patients: Array = plan.get("patients", []) if skill == "Field Hospital" else in_tiles(plan["tiles"], "player")
            for patient: int in patients:
                treat_in_zone(zone, patient)
        "Charge":
            add_move(index, 2 * clampi(option.to_int(), 1, 3))
        "Breach Relay", "Rampage":
            hit(index, target, skill, 4 if skill == "Rampage" else int(unit(index)["damage"]), {"melee": true})
            if not living(index) or battle.room_cleared:
                return
            if skill == "Breach Relay" and plan.has("swap") and living(plan["swap"]):
                swap_units(index, plan["swap"])
            elif skill == "Breach Relay" and plan.has("landing"):
                relocate(index, plan["landing"], false)
            elif skill == "Rampage" and not living(target) and plan.has("follow_up_target") and living(plan["follow_up_target"]):
                if relocate(index, plan["follow_up_tile"], false):
                    hit(index, plan["follow_up_target"], skill, 3, {"melee": true})
        "Finish the Job", "Break the Vial":
            if skill == "Break the Vial" and info["form"] != "Hyde":
                enter_hyde(index)
            if plan.has("landing") and not relocate(index, plan["landing"], false):
                return
            var bonus := 2 if skill == "Finish the Job" and int(unit(target)["hp"]) * 2 <= int(unit(target)["max_hp"]) else 0
            var damage: int = {"Break the Vial": 5, "Rampage": 4}.get(skill, int(unit(index)["damage"]) + bonus)
            if not unit(index)["basic_melee"]:
                battle.spend_shot(index)
            hit(index, target, skill, damage, {"melee": unit(index)["basic_melee"], "ranged": not unit(index)["basic_melee"],
                "review_basic": skill == "Finish the Job", "target_tile": tile})
        "Drop Hammer", "Claw Grab", "Hooked Pincers", "Carapace Slam", "Colossal Combo", "Stooping Strike", \
        "Crush Bite", "Open the Seam", "Hurl Aside", "Nettle Lock":
            if skill == "Hooked Pincers" and not neighbours(target, source):
                force_move(index, target, direction(tile, source), 1)
                if not living(target) or not neighbours(target, source):
                    return
            var damage: int = {"Drop Hammer": 5 + int(unit(index)["armour"] == unit(index)["max_armour"]),
                "Carapace Slam": 2 + mini(3, int(unit(index)["armour"])),
                "Stooping Strike": 3 + int(once(index, "Fly", false) == false), "Hurl Aside": 3,
                "Nettle Lock": 2 + int(info.get("form_mastery", false))}.get(skill, int(unit(index)["damage"]))
            for strike in range(3 if skill == "Colossal Combo" else 1):
                var shred := 4 if skill == "Crush Bite" else (2 if skill == "Colossal Combo" and strike == 0 else 0)
                hit(index, target, skill, damage, {"melee": true, "pre_break": shred})
            if living(target):
                match skill:
                    "Colossal Combo": force_move(index, target, direction(source, tile), 2)
                    "Claw Grab":
                        set_root(target)
                        effects(index)["root"] = true
                    "Stooping Strike": slow(target, 1)
                    "Nettle Lock": slow(target, 2)
                    "Hurl Aside": force_move(index, target, direction(source, tile), 2, false, false, false, 1)
                    "Open the Seam": effects(target)["seam_owner"] = index
        "Breach Kit":
            battle.damage_cover_edge(plan["edge"], 3, index, skill)
        "Breach Shell", "Siege Salvo":
            var cells: Array = plan["tiles"]
            var edges: Array = [plan["edge"]] if skill == "Breach Shell" else battle.destructible_edges.keys()
            var follow_up: Array[Vector2i] = []
            for edge_key: String in edges:
                var edge: Dictionary = battle.destructible_edges[edge_key]
                var from: Vector2i = edge["tile"]
                var to: Vector2i = from + battle.tile_offset_for_face(edge["face"])
                if from not in cells and to not in cells:
                    continue
                battle.damage_cover_edge(edge_key, 5 if skill == "Breach Shell" else int(edge["hp"]), index, skill)
                if not battle.destructible_edges.has(edge_key):
                    follow_up.append_array([from, to])
            if knows(index, "Breach Follow-Up"):
                effects(index)["breach_follow_up"] = follow_up
            if skill == "Breach Shell":
                blast(index, cells, 2 + int(info["heavy_bonus"]), skill, 0)
            else:
                blast(index, [tile], 6 + int(info["heavy_bonus"]), skill, 0)
                blast(index, cells.filter(func(cell: Vector2i) -> bool: return cell != tile), 4 + int(info["heavy_bonus"]), skill, 0,
                    false, true, [tile])
        "Mortar Cup", "Walking Barrage", "Incendiary Shell":
            var damage: int = {"Mortar Cup": 3, "Walking Barrage": 4, "Incendiary Shell": 2}[skill]
            blast(index, plan["tiles"], damage + int(info["heavy_bonus"]), skill, 0)
            if skill == "Incendiary Shell":
                for cell: Vector2i in plan["tiles"]:
                    if battle.barrel_is_active(cell):
                        battle.hit_barrel(cell, damage, index, skill)
                    battle.spawn_hazard(cell, "fire", index)
                for victim in in_tiles(plan["tiles"]):
                    battle.apply_status(victim, "burning")
        "Flak Curtain":
            zones.append({"owner": index, "skill": skill, "tiles": plan["tiles"], "expires": battle.turn_number + 1,
                "damage": 3 + int(info["heavy_bonus"])})
        "Rolling Thunder":
            if relocate(index, plan["landing"], false, true):
                effects(index)["anchored"] = true
                blast(index, plan["tiles"], 4 + int(info["heavy_bonus"]), skill, 0)
        "Pressure Front", "Empty the Shell":
            var armour: int = unit(index)["armour"]
            unit(index)["armour"] = 0
            effects(index)["review_skip_armour"] = true
            for victim in in_tiles(area(source, 2), "enemy" if skill == "Pressure Front" else ""):
                if victim != index:
                    hit(index, victim, skill, mini(6, 2 + armour) if skill == "Empty the Shell" else armour, {"area": true})
        "Anchor":
            if int(info["moved"]) > 0:
                info["room_uses"]["Quick-Lock"] = true
            effects(index)["anchored"] = true
        "Vent":
            cool(index, 3 if knows(index, "Cooling Fins") else 2)
            if knows(index, "Feed Mechanism"):
                restore_weapon_charges(index, 1)
        "Transform":
            enter_hyde(index)
        "Revert":
            revert_hyde(index)
        "Safe Passage":
            relocate(target, plan["landing"], false, true, false, true)
        "Suppress Reaction", "Impulse Push":
            effects(index).erase(skill)
            if skill == "Suppress Reaction":
                if suppress(index, target):
                    if knows(index, "Quiet Mind"):
                        barrier(index, 1)
                    if knows(index, "Divided Attention"):
                        slow(target, 1)
            else:
                force_move(index, target, direction(source, pos(target)), 2 if knows(index, "Follow Through") else 1, false, false, true)
        "Counterweight Slide":
            battle.apply_unit_position(target, plan["landing"], &"displace")
            battle.apply_hazard_entry(target)
            effects(index).erase(skill)
        "Treat Patient":
            for zone in zones:
                if zone["skill"] == "Field Hospital" and zone["owner"] == index and pos(target) in zone["tiles"]:
                    treat_in_zone(zone, target)
                    break
        "Bedside Cover":
            barrier(target, 1)
            effects(index).erase(skill)
        "Hyde Follow-through":
            relocate(index, tile, false)
            effects(index).erase(skill)
        "Tailwind Flight":
            relocate(index, tile, true)
            effects(index).erase(skill)
        "Tandem Move":
            move_drone(index, plan["drone_path"])
            effects(index).erase(skill)
        "Rosette Rush":
            for step in range(plan["victims"].size()):
                var victim: int = plan["victims"][step]
                if not living(index) or not living(victim) or not relocate(index, plan["landings"][step], false):
                    break
                review_strike(index, victim, skill)
        "Mosaic Body":
            for step in range(plan["signatures"].size()):
                if not living(index):
                    break
                var signature: String = plan["signatures"][step]
                var selection: Array[Vector2i] = plan["signature_selections"][step]
                var pick: Vector2i = selection[0]
                var victim: int = battle.find_unit_at(pick)
                var enemy: bool = living(victim) and unit(victim)["team"] == "enemy"
                var signature_plan := plan_review(index, signature, "", selection, {"target": victim, "tiles": [pick]}, enemy, false)
                if signature_plan.has("error"):
                    break
                info["ready"][signature] = battle.turn_number + 2
                resolve_review(index, signature, "", pick, signature_plan)
        "Scout Run", "Pincer Run", "Shield Run", "Overclock Link":
            resolve_drone_run(index, skill, plan)
        "Rake":
            for victim in in_tiles(plan["tiles"], "enemy"):
                review_strike(index, victim, skill)
        "Split Focus":
            hit(index, target, skill, 4, {"ranged": true, "target_tile": tile})
            hit(index, plan["second"], skill, 4, {"ranged": true, "target_tile": plan["second_tile"]})
        "Phantom Threat":
            effects(target)["phantom_target"] = plan["second"]
        "Spatial Exchange":
            swap_units(target, plan["second"])
        "Hurl Debris":
            hit(index, target, skill, 4, {"ranged": true, "source": tile, "target_tile": plan["target_tile"]})
            battle.damage_cover_edge(plan["edge"], 99, index, skill)
        "Strike and Drop":
            hit(index, target, skill, 3, {"melee": true})
            if relocate(index, plan["landing"], true):
                note_flight(index)
                if living(target) and battle.footprint_is_open(unit(target), plan["drop"]):
                    battle.apply_unit_position(target, plan["drop"], &"displace")
                    battle.apply_hazard_entry(target)
        "Venom Jet":
            for victim in in_tiles(plan["tiles"]):
                poison(index, victim)
        "Sweep Beam":
            blast(index, plan["tiles"], 3, skill, 0)
            if knows(index, "Rangefinder"):
                battle.damage_cover_in_tiles(plan["tiles"], 99, index, skill)
        "Linebreaker":
            var facing := direction(source, tile)
            var struck: Array[int] = []
            for cell: Vector2i in plan["tiles"]:
                var previous := pos(index)
                if not living(index) or battle.walls.has(cell):
                    break
                for edge in crossed_cover_edges(previous, cell):
                    battle.damage_cover_edge(edge, 5, index, skill)
                var foe: int = battle.find_unit_at(cell)
                if living(foe) and unit(foe)["team"] == "enemy" and foe not in struck:
                    struck.append(foe)
                    hit(index, foe, skill, 1, {"melee": true})
                    force_move(index, foe, facing, 2)
                if not battle.can_take_move_step(unit(index), previous, cell) or not relocate(index, cell, false):
                    break
        "Plastic Skin":
            unit(index)["armour"] = 0
            effects(index)["plastic_skin"] = true
        "Sanctuary":
            for patient: int in plan["distribution"]:
                barrier(patient, plan["distribution"][patient], "sanctuary")
                effects(patient)["sanctuary_expiry"] = battle.turn_number + 2
            unit(index)["armour"] = 0
            effects(index)["review_skip_armour"] = true
        "Raking Pass":
            var victims := in_tiles(plan["tiles"], "enemy")
            if relocate(index, plan["landing"], true):
                note_flight(index)
                for victim in victims:
                    hit(index, victim, skill, 4, {"melee": true, "source": source})
        "Wrecking Ball":
            var facing: Vector2i = plan["facing"]
            hit(index, target, skill, 4, {"area": true})
            for _step in range(plan["length"]):
                if not living(target):
                    break
                var blocker: int = battle.find_unit_at(pos(target) + facing)
                if living(blocker) and blocker != target:
                    hit(index, blocker, skill, 4, {"area": true})
                    break
                if force_move(index, target, facing, 1) == 0:
                    break
        "Recovery Winch":
            var original: Vector2i = drones[index]["pos"]
            move_drone(index, [tile], false)
            battle.apply_unit_position(target, original, &"displace")
            battle.apply_hazard_entry(target)
            if living(target):
                barrier(target, 2)
            once(index, "Drone order")
        "Shock Mine":
            for zone in zones.duplicate():
                if zone["skill"] == skill and zone["owner"] == index:
                    zones.erase(zone)
            create_zone(index, skill, tile, [tile])
        "Passing Trait":
            match info["form"]:
                "Frog": relocate(target, plan["landing"], false)
                "Jellyfish":
                    barrier(target, 2)
                    effects(target)["passing_shove"] = true
                "Skunk": effects(target)["passing_reach"] = 2
        "Wingover", "Banking Turn":
            var piercing := skill == "Wingover"
            hit(index, target, skill, int(unit(index)["damage"]), {"melee": true,
                "bypass": int(unit(target)["armour"]) if piercing else 0})
            if piercing and living(target):
                battle.apply_status(target, "bleeding")
            if relocate(index, plan["landing"], true):
                note_flight(index)
            if piercing:
                effects(index)["free_quarry"] = true
        "Bounding Pounce", "Burrowing Strike", "Peregrine Dive":
            if relocate(index, plan["landing"], true, skill != "Burrowing Strike") and living(target):
                if skill == "Peregrine Dive":
                    note_flight(index)
                    if distance(source, pos(index)) >= 3:
                        effects(index)["flight_bonus"] = 2
                hit(index, target, skill, 5 if skill == "Peregrine Dive" else int(unit(index)["damage"]), {"melee": true})
        "Express Trait":
            match info["form"]:
                "Frog":
                    if relocate(index, plan["landing"], true) and living(target):
                        hit(index, target, skill, 2, {"melee": true})
                        force_move(index, target, direction(pos(index), pos(target)), 2)
                        if living(target):
                            suppress(index, target)
                "Jellyfish":
                    hit(index, target, skill, 1, {"melee": true})
                    if living(target) and not anchored(target) and not info["room_uses"].has("Jellyfish Stun"):
                        info["room_uses"]["Jellyfish Stun"] = true
                        suppress(index, target)
                        effects(target)["stunned"] = true
                "Skunk":
                    blast(index, plan["tiles"], 3, skill, 0)
        "Darwinian Shift", "Shed Skin":
            if skill == "Shed Skin":
                if not unit(index)["statuses"].erase("burning") and not effects(index).erase("poison"):
                    unit(index)["statuses"].erase("blinded")
            shift_form(index, option)
        "Fly", "Tongue Vault":
            if relocate(index, tile, true):
                if skill == "Fly":
                    note_flight(index)
                if skill == "Fly" and distance(source, tile) >= 3:
                    effects(index)["flight_bonus"] = 2
                if skill == "Tongue Vault" and plan.has("pull") and living(plan["pull"]):
                    force_move(index, plan["pull"], direction(pos(plan["pull"]), tile), 1)
        "Musk Trail":
            create_zone(index, skill, tile, plan["tiles"])
        "Field Service":
            drones[index]["hp"] = mini(drone_max_hp(index), int(drones[index]["hp"]) + 2)
            info["ready"].erase("Shield Run" if knows(index, "Guardian Chassis") else "Pincer Run")
        "Emergency Rebuild":
            drones[index] = {"pos": plan["landing"], "hp": ceili(drone_max_hp(index) * 0.5),
                "armour": drone_max_armour(index), "intercept": false}
            once(index, "Drone order")

func restore_weapon_charges(index: int, charges: int) -> void:
    unit(index)["rounds"] = mini(int(unit(index)["magazine_capacity"]), int(unit(index)["rounds"]) + charges)

func quick_lock_ready(index: int) -> bool:
    var info := state(index)
    return knows(index, "Quick-Lock") and not info["room_uses"].has("Quick-Lock") \
        and int(info.get("standard_move", 0)) == int(info["moved"])

func breach_follow_up_ready(index: int, target: int) -> bool:
    if not knows(index, "Breach Follow-Up") or not living(target) or battle.side_to_play != "player":
        return false
    var footprint: Rect2i = battle.unit_footprint(unit(target), pos(target))
    for cell: Vector2i in effects(index).get("breach_follow_up", []):
        if footprint.has_point(cell):
            return true
    return false

func resolve_drone_run(index: int, skill: String, plan: Dictionary) -> void:
    once(index, "Drone order")
    if not move_drone(index, plan["drone_path"]):
        return
    var guardian: bool = plan.has("cover_lines")
    if skill == "Overclock Link":
        state(index)["ready"]["Shield Run" if guardian else "Pincer Run"] = battle.turn_number + 2
    if guardian:
        drones[index]["barricade"] = plan["cover_lines"][0]
        battle.queue_burst(battle.board_center(drones[index]["pos"]), 24.0, Color("#80ccff"), &"shield")
        if plan["cover_lines"].size() == 2:
            drones[index]["barricade_second"] = plan["cover_lines"][1]
        for ally: int in plan["protected"]:
            barrier(ally, 2)
        return
    var origin: Vector2i = drones[index]["pos"]
    var damage: int = {"Scout Run": 2, "Pincer Run": 3, "Overclock Link": 4}[skill]
    var arc_targets: Array = plan.get("arc_targets", [])
    for arc in range(arc_targets.size()):
        var target: int = arc_targets[arc]
        if not living(target):
            break
        var target_tile: Vector2i = plan["arc_target_tiles"][arc]
        if not hit(index, target, skill, damage, {"ranged": true, "source": origin, "target_tile": target_tile, "drone": true}):
            break
        if arc == 0 and skill in ["Pincer Run", "Overclock Link"] and living(target) and unit(target)["reaction_type"] == "overwatch" \
                and battle.attacked_side(origin, target_tile) != battle.attacked_side(pos(index), target_tile):
            cancel_reaction(target)
            battle.add_log("%s's drone cancels %s's Overwatch." % [unit(index)["name"], unit(target)["name"]])
        origin = target_tile
        damage -= 1

func expected_drone_overwatch(index: int, path: Array) -> int:
    var budgets := {}
    var remaining: int = int(drones[index]["hp"]) + int(drones[index]["armour"])
    var shots := 0
    for cell: Vector2i in path:
        for watcher in drone_watchers(cell, index):
            var budget: int = budgets.get(watcher, battle.overwatch_shots(watcher))
            if budget <= 0:
                continue
            budgets[watcher] = budget - 1
            shots += 1
            remaining -= drone_shot_damage(watcher, cell)
            if remaining <= 0:
                return shots
    return shots

func move_drone(index: int, path: Array, overwatch: bool = true) -> bool:
    if path.is_empty():
        return drone_live(index)
    var drone: Dictionary = drones[index]
    drone.erase("barricade")
    drone.erase("barricade_second")
    for cell: Vector2i in path:
        var previous: Vector2i = drone["pos"]
        battle.unit_playback.motion(-index - 2, battle.board_center(previous), battle.board_center(cell),
            direction(previous, cell), &"drone", 0.095)
        drone["pos"] = cell
        if overwatch:
            for watcher: int in drone_watchers(cell):
                if not drone_live(index):
                    return false
                if battle.spend_shot(watcher):
                    unit(watcher)["ap"] -= battle.OVERWATCH_SHOT_AP
                    battle.play_unit_action(watcher, battle.board_center(cell), false, Color.TRANSPARENT, str(unit(watcher)["basic_attack"]))
                    battle.battle_stats[watcher]["reactions"] += 1
                    battle.battle_stats[watcher]["overwatch_shots"] = int(battle.battle_stats[watcher].get("overwatch_shots", 0)) + 1
                    if battle.ranged_cover_block_reason(pos(watcher), cell, 0, index) == battle.FULL_COVER_BLOCK:
                        battle.report_full_cover_block(watcher)
                    else:
                        damage_drone(index, drone_shot_damage(watcher, cell))
                        battle.add_log("%s fires Overwatch at the drone." % unit(watcher)["name"])
    return drone_live(index)

func drone_watchers(cell: Vector2i, ignored_drone: int = -1) -> Array[int]:
    var watchers: Array[int] = []
    for watcher in range(5, battle.units.size()):
        if not battle.basic_is_melee(unit(watcher)) and battle.overwatch_budget_for_team(watcher, "player") > 0 \
                and unit(watcher).get("overwatch_tiles", {}).has(cell) \
                and battle.has_line_of_sight(pos(watcher), cell) and shot_through_smoke(watcher, pos(watcher), cell) \
                and battle.ranged_cover_block_reason(pos(watcher), cell, 0, ignored_drone) != "Shield Run blocks this shot.":
            watchers.append(watcher)
    return watchers

func drone_shot_damage(watcher: int, cell: Vector2i) -> int:
    var source := pos(watcher)
    if not battle.basic_is_melee(unit(watcher)) and battle.ranged_cover_block_reason(source, cell) == battle.FULL_COVER_BLOCK:
        return 0
    var base_damage: int = int(unit(watcher)["damage"]) + battle.formation_damage_bonus(watcher, source, cell)
    var cover: int = 0 if battle.basic_is_melee(unit(watcher)) else battle.cover_level_at(cell, source)
    var damage: int = base_damage - battle.blinded_damage_penalty(watcher)
    return 0 if damage <= 0 else maxi(1, damage - cover)

func review_strike(index: int, target: int, skill: String) -> void:
    hit(index, target, skill, int(unit(index)["damage"]), {"melee": true})

func set_root(target: int) -> void:
    effects(target)["root"] = true

func enter_hyde(index: int) -> void:
    state(index)["form"] = "Hyde"
    state(index)["hyde_until"] = battle.turn_number + 2
    state(index)["hyde_entered"] = battle.turn_number
    state(index)["room_uses"]["Transform"] = true
    refresh_base_attack(index)

func shift_form(index: int, form: String) -> void:
    state(index)["form"] = form
    state(index)["form_mastery"] = false
    once(index, "form change")
    if knows(index, "Vestigial Plates"):
        barrier(index, 2)
    if knows(index, "Quick Adaptation"):
        effects(index)["free_step"] = maxi(1, free_step(index))
    refresh_stats(index)
    refresh_base_attack(index)

func revert_hyde(index: int) -> void:
    state(index)["form"] = "Jekyll"
    state(index)["recovery_turn"] = battle.turn_number
    unit(index)["ap"] = maxi(0, int(unit(index)["ap"]) - 1)
    if knows(index, "Controlled Reversion"):
        effects(index)["free_step"] = maxi(1, free_step(index))
    if knows(index, "Adrenal Rebound"):
        barrier(index, 2)
    refresh_base_attack(index)

func end_mantle(owner: int, patient: int, return_armour: bool, expired: bool = true) -> void:
    var mantles: Dictionary = state(owner).get("mantles", {})
    if not mantles.has(patient):
        return
    var lending: bool = mantles[patient] == "Lend Armour"
    mantles.erase(patient)
    if int(effects(patient).get("mantle_owner", -1)) != owner:
        return
    var unused: int = effects(patient).get("mantle", 0)
    effects(patient).erase("mantle")
    effects(patient).erase("mantle_owner")
    if return_armour and lending and living(owner):
        unit(owner)["armour"] = mini(int(unit(owner)["max_armour"]), int(unit(owner)["armour"]) + unused)
    if expired and knows(owner, "Returning Defence") and living(owner):
        barrier(owner, 1)

func note_flight(index: int) -> void:
    if knows(index, "Pinion Guard"):
        effects(index)["pinion_guard"] = true
    if knows(index, "Silent Landing"):
        effects(index)["silent_landing_primed"] = true

func barricade_at(tile: Vector2i, face: String, ignored_drone: int = -1) -> bool:
    for owner: int in drones:
        if owner == ignored_drone or not drone_live(owner):
            continue
        for key in ["barricade", "barricade_second"]:
            var line: Dictionary = drones[owner].get(key, {})
            if line.get("face") == face and tile in line.get("tiles", []):
                return true
    return false

func aligned_foe(index: int, target: int, tile: Vector2i) -> int:
    var delta: Vector2i = tile - pos(index)
    var closest: int = -1
    var reach: int = 9
    for candidate in range(5, battle.units.size()):
        if candidate == target or not living(candidate):
            continue
        var offset: Vector2i = pos(candidate) - tile
        if delta.x * offset.y == delta.y * offset.x and delta.x * offset.x + delta.y * offset.y > 0 \
                and visible(pos(index), pos(candidate), reach - 1):
            reach = distance(pos(index), pos(candidate))
            closest = candidate
    return closest

func melee(index: int, target: int, skill: String, bonus: int = 0, armour_break: int = 0, reaction: bool = false) -> void:
    hit(index, target, skill, 2 + bonus,
        {"melee": true, "break": armour_break, "reaction": reaction})

func hit(index: int, target: int, skill: String, damage: int, context: Dictionary) -> bool:
    if not living(target):
        return false
    var from: Vector2i = context.get("source", pos(index))
    context["source"] = from
    var cover := 0
    if context.get("ranged", false):
        var target_tile: Vector2i = context.get("target_tile", pos(target))
        var cover_block: String = battle.ranged_cover_block_reason(from, target_tile)
        if not cover_block.is_empty():
            if cover_block == battle.FULL_COVER_BLOCK:
                battle.play_unit_action(index, battle.board_center(target_tile), false, Color.TRANSPARENT, skill)
                battle.report_full_cover_block(index)
            else:
                battle.status_message = cover_block
            return false
        cover = battle.cover_level_at(target_tile, from)
        context["obstruction"] = intervening_cover(index, from, target_tile)
    var attack: Dictionary = impact(index, target, damage, cover, context)
    if organic(target) and knows(index, "Empathic Echo"):
        effects(target)["empathic_owner"] = index
    if from != pos(index):
        attack["visual_source"] = from
    if context.get("visual_queued", false):
        attack["visual_queued"] = true
    battle.resolve_attack(index, target, attack, skill, 0, false, false)
    return true

func blast(index: int, cells: Array, damage: int, skill: String, structure: int,
        light_only: bool = false, friendly_fire: bool = true, exclude: Array = []) -> void:
    var excluded := in_tiles(exclude)
    for target in in_tiles(cells, "" if friendly_fire else "enemy"):
        if target in excluded:
            continue
        hit(index, target, skill, damage, {"area": true})
    for owner in drones:
        if drone_live(owner) and cells.has(drones[owner]["pos"]) and drones[owner]["pos"] not in exclude:
            damage_drone(owner, damage)
    if structure > 0:
        battle.damage_cover_in_tiles(cells, structure, index, skill, light_only)
        for cell: Vector2i in cells:
            if battle.barrel_is_active(cell):
                battle.hit_barrel(cell, damage, index, skill)

func relocate(index: int, tile: Vector2i, vault: bool, reactions: bool = true,
        interrupt_on_overwatch: bool = false, safe_melee: bool = false, landing_hazards_only: bool = false) -> bool:
    if not living(index):
        return false
    if tile == pos(index):
        return true
    if reactions and battle.voluntary_movement_locked(index):
        return false
    if effects(index).get("brace", false) and reactions:
        return false
    var path: Array[Vector2i] = [tile]
    if not vault:
        path = battle.shortest_tile_path(pos(index), tile, index)
    if path.is_empty():
        return false
    battle.unit_action_counters[index]["moves"] += 1
    for cell in path:
        var previous: Vector2i = pos(index)
        if not battle.footprint_is_open(unit(index), cell):
            return false
        if reactions and not vault and not safe_melee:
            opportunity(index, previous, cell)
            if not living(index):
                return false
        battle.apply_unit_position(index, cell, &"leap" if vault else &"walk")
        moved(index, steps_between(previous, cell))
        if not landing_hazards_only or cell == tile:
            battle.apply_hazard_entry(index)
        if not living(index):
            return false
        if reactions and battle.trigger_reactions_to_step(index, previous) and interrupt_on_overwatch:
            return false
        if not living(index):
            return false
    return true

func can_leverage(index: int, target: int) -> bool:
    return knows(index, "Leverage") and int(unit(target).get("weight", 2)) == 3 \
        and not unit(target).get("mission_target", false) and unit(target).get("kind") != "boss"

func force_move(index: int, target: int, vector: Vector2i, length: int,
        avoid_hazards: bool = false, crush_cover: bool = false, leverage: bool = false, collision_damage: int = 0) -> int:
    if not living(target) or vector == Vector2i.ZERO or (anchored(target) and not (leverage and can_leverage(index, target))) or resists_displacement(target):
        return 0
    var moved_steps: int = 0
    for _step in range(displacement_distance(target, length)):
        var from: Vector2i = pos(target)
        var tile: Vector2i = from + vector
        var edge: String = cover_between(from, tile)
        if not edge.is_empty() and battle.destructible_edges.has(edge) and crush_cover \
                and int(battle.destructible_edges[edge]["level"]) == 1:
            battle.damage_cover_edge(edge, 1, index, "Kinetic Slam")
            break
        if not battle.can_take_move_step(unit(target), from, tile) or \
                (avoid_hazards and battle.footprint_has_hazard(unit(target), tile)):
            if collision_damage > 0:
                var blockers := in_tiles([tile])
                blockers.erase(target)
                if not blockers.is_empty():
                    hit(index, target, "Hurl Aside collision", collision_damage, {"area": true})
                    hit(index, blockers[0], "Hurl Aside collision", collision_damage, {"area": true})
            break
        battle.apply_unit_position(target, tile, &"displace")
        battle.battle_stats[target]["tiles"] += 1
        moved_steps += 1
        battle.apply_hazard_entry(target)
        if not living(target):
            break
    if moved_steps > 0:
        effects(target)["displaced_by"] = index
        if knows(index, "Counterweight") and unit(target)["team"] == "enemy" and once(index, "Counterweight Slide", false):
            effects(index)["Counterweight Slide"] = true
    return moved_steps

func barrier(index: int, amount: int, key: String = "barrier") -> void:
    if amount > 0:
        effects(index)[key] = int(effects(index).get(key, 0)) + amount

func spend_shell(index: int, amount: int) -> int:
    var shield: int = mini(amount, int(effects(index).get("force_shell", 0)))
    effects(index)["force_shell"] = int(effects(index).get("force_shell", 0)) - shield
    return shield

func add_move(index: int, amount: int) -> void:
    var fx: Dictionary = effects(index)
    fx["move_bonus"] = int(fx.get("move_bonus", 0)) + amount
    refresh_stats(index)

func slow(index: int, amount: int) -> void:
    var fx: Dictionary = effects(index)
    fx["slow"] = maxi(amount, int(fx.get("slow", 0)))

func cool(index: int, amount: int) -> void:
    state(index)["heat"] = maxi(0, int(state(index)["heat"]) - amount)

func recalibrate(index: int) -> void:
    if knows(index, "Rapid Recalibration") and once(index, "Rapid Recalibration"):
        effects(index)["recalibrate"] = true

func heal(index: int, target: int, amount: int, skill: String) -> void:
    if knows(index, "Clinical Eye") and int(unit(target)["hp"]) * 2 < int(battle.recoverable_hp(unit(target))) and once(index, "Clinical Eye"):
        amount += 1
    if battle.apply_healing(index, target, amount, skill, false):
        battle.queue_burst(battle.unit_board_center(target), 21.0, Color("#88efad"), &"heal")

func cleanse(index: int) -> void:
    if effects(index).erase("poison"):
        return
    for status in ["irradiated", "burning"]:
        if unit(index)["statuses"].erase(status):
            return

func support_passives(index: int, target: int) -> void:
    if knows(index, "Potent Formula") and once(index, "Potent Formula"):
        barrier(target, 1)
    if knows(index, "Condition Control") and once(index, "Condition Control"):
        cleanse(target)

func support(index: int, target: int, benefit: String, copyable: bool, transfer: bool = false) -> void:
    apply_benefit(index, target, benefit, transfer)
    support_passives(index, target)
    battle.battle_stats[index]["buffs"] += 1
    if copyable and effects(index).get("cascade", false):
        for ally in in_tiles(area(pos(index), bio_range(index, 3), false), "player"):
            if ally != target:
                # One-point effects round up when copied to an integer grid.
                apply_benefit(index, ally, benefit, false)
                effects(index).erase("cascade")
                break

func apply_benefit(index: int, target: int, benefit: String, transfer: bool) -> void:
    match benefit:
        "Mobility": add_move(target, 1)
        "Barrier": barrier(target, 1)
        "Range": effects(target)["range_bonus"] = 1
    if transfer:
        effects(target)["transfer"] = {"owner": index, "benefit": benefit}

func clear_transfer(index: int, target: int) -> void:
    var transfer: Dictionary = effects(target).get("transfer", {})
    if int(transfer.get("owner", -1)) != index:
        return
    match transfer["benefit"]:
        "Mobility": add_move(target, -1)
        "Barrier": effects(target)["barrier"] = maxi(0, int(effects(target).get("barrier", 0)) - 1)
        "Range": effects(target).erase("range_bonus")
    effects(target).erase("transfer")

func cancel_reaction(index: int) -> void:
    battle.clear_overwatch(index)

func has_available_reaction(index: int) -> bool:
    if reaction_disabled(index):
        return false
    var operative := unit(index)
    if operative["reaction_available"] and battle.overwatch_shots(index) > 0:
        return true
    var used: int = operative.get("departure_reaction_hits", 0) if operative.get("departure_reaction_turn", -1) == battle.turn_number else 0
    return battle.basic_is_melee(operative) and used < 1 + int(knows(index, "Threatening Presence"))

func suppress(index: int, target: int) -> bool:
    var removed := has_available_reaction(target)
    cancel_reaction(target)
    var fx := effects(target)
    fx["reaction_off"] = true
    if removed:
        if not fx.has("reaction_cancelled_by"):
            fx["reaction_cancelled_by"] = {}
        fx["reaction_cancelled_by"][index] = battle.turn_number
    disrupt(index, target)
    return removed

func disrupt(index: int, target: int) -> void:
    var fx: Dictionary = effects(target)
    fx["disrupted_by"] = index
    if knows(index, "Deny Response") and once(index, "Deny Response"):
        fx["reaction_off"] = true
        cancel_reaction(target)

func reaction_disabled(index: int) -> bool:
    return bool(effects(index).get("reaction_off", false))

func poison(index: int, target: int) -> void:
    if organic(target) and not effects(target).has("poison") and not quarantine_protects(target, "poison"):
        effects(target)["poison"] = {"owner": index, "ticks": 2 + int(knows(index, "Stronger Poison"))}

func quarantine_protects(index: int, status: String) -> bool:
    if index >= 5 or not status in ["poison", "burning", "irradiated"]:
        return false
    for zone in zones:
        if zone["skill"] == "Quarantine Field" and pos(index) in zone["tiles"]:
            return true
    return false

func below_half_healing(index: int) -> bool:
    return int(unit(index)["hp"]) * 2 < int(battle.recoverable_hp(unit(index)))

func hospital_candidates(owner: int) -> Array[int]:
    for zone in zones:
        if zone["skill"] == "Field Hospital" and zone["owner"] == owner and zone["used"].size() < 3:
            return in_tiles(zone["tiles"], "player").filter(func(patient: int) -> bool: return not zone["used"].has(patient))
    return []

func treat_in_zone(zone: Dictionary, index: int) -> void:
    match zone["skill"]:
        "Field Hospital":
            if not zone["used"].has(index) and zone["used"].size() < 3 and living(index):
                zone["used"][index] = true
                heal(zone["owner"], index, 3, "Field Hospital")
                barrier(index, 2, "hospital_armour")
                effects(index)["hospital_expiry"] = battle.turn_number + 1
        "Quarantine Field":
            unit(index)["statuses"].erase("burning")
            unit(index)["statuses"].erase("irradiated")
            effects(index).erase("poison")

func safe_passage(reactor: int, mover: int, previous: Vector2i) -> bool:
    var controller := safe_passage_source(reactor, mover, previous, pos(mover))
    return controller >= 0 and once(controller, "Safe Passage")

func safe_passage_source(reactor: int, mover: int, previous: Vector2i, landing: Vector2i) -> int:
    if mover >= 5 or reactor < 5:
        return -1
    var controller: int = int(effects(reactor).get("disrupted_by", -1))
    if not living(controller) or not knows(controller, "Safe Passage") or not once(controller, "Safe Passage", false):
        return -1
    return controller if distance(pos(reactor), previous) == 1 or distance(pos(reactor), landing) == 1 else -1

func shot_through_smoke(index: int, from: Vector2i, to: Vector2i) -> bool:
    if knows(index, "Focused Retina") or smoke_tiles.is_empty():
        return true
    for tile in line_tiles(from, to):
        if smoke_tiles.has(tile):
            return false
    return true

func line_tiles(from: Vector2i, to: Vector2i) -> Array[Vector2i]:
    var cells: Array[Vector2i] = []
    var length: int = steps_between(from, to)
    for step in range(1, length + 1):
        var fraction: float = float(step) / float(length)
        cells.append(Vector2i(Vector2(from).lerp(Vector2(to), fraction).round()))
    return cells

func intervening_cover(index: int, from: Vector2i, to: Vector2i) -> int:
    if not knows(index, "Focused Retina"):
        return 0
    var previous: Vector2i = from
    var low_edges: int = 0
    for tile in line_tiles(from, to):
        if tile != to and battle.shared_cover_on_side(previous, battle.attacked_side(tile, previous)) == 1:
            low_edges += 1
        previous = tile
    return mini(1, maxi(0, low_edges - int(knows(index, "X-Ray Angle"))))

func displacement_distance(target: int, length: int) -> int:
    return length - int(length > 0 and effects(target).erase("passing_shove"))

func resists_displacement(target: int) -> bool:
    var fx: Dictionary = effects(target)
    if fx.get("brace", false) or fx.erase("shove_guard"):
        return true
    if knows(target, "Hard to Shift") and once(target, "Hard to Shift"):
        fx["shift_counter"] = true
        return true
    return false

func position_changed(index: int, previous: Vector2i) -> void:
    if previous == pos(index):
        return
    if effects(index).erase("anchored"):
        for zone in zones.duplicate():
            if zone["skill"] == "Flak Curtain" and zone["owner"] == index:
                zones.erase(zone)
    if not living(index):
        return
    if unit(index)["team"] == "player":
        for zone in zones:
            if zone["skill"] == "Quarantine Field" and pos(index) in zone["tiles"]:
                treat_in_zone(zone, index)
        return
    var before: Rect2i = battle.unit_footprint(unit(index), previous)
    var after: Rect2i = battle.unit_footprint(unit(index), pos(index))
    for zone in zones.duplicate():
        if zone["skill"] == "Musk Trail" and zone["tiles"].any(func(tile: Vector2i) -> bool: return after.has_point(tile) and not before.has_point(tile)):
            affect_zone(zone, index)
        if zone["skill"] != "Flak Curtain" or not living(zone["owner"]):
            continue
        if zone["tiles"].any(func(tile: Vector2i) -> bool: return before.has_point(tile)):
            continue
        for tile: Vector2i in zone["tiles"]:
            if after.has_point(tile):
                zones.erase(zone)
                var was_resolving: bool = battle.resolving_class_action
                battle.resolving_class_action = true
                blast(zone["owner"], cross_tiles(tile), zone["damage"], "Flak Curtain", 0)
                battle.resolving_class_action = was_resolving
                if not was_resolving:
                    battle.assess_winner()
                break
        if not living(index):
            return

func moved(index: int, count: int) -> void:
    battle.battle_stats[index]["tiles"] += count
    if index < 5:
        state(index)["moved"] += count
    else:
        for zone in zones.duplicate():
            if zone["skill"] not in ["Flak Curtain", "Musk Trail"] and zone["tiles"].has(pos(index)):
                affect_zone(zone, index)

func finished_standard_move(index: int, steps: int) -> void:
    if not living(index) or not unit(index).has("class_state"):
        return
    var info := state(index)
    info["standard_move"] = steps if int(info.get("standard_move", 0)) == 0 else -1
    if knows(index, "Tandem Drive") and drone_live(index) and once(index, "Tandem Move", false):
        effects(index)["Tandem Move"] = true
    if knows(index, "Bedside Cover") and state(index)["form"] == "Jekyll" and once(index, "Bedside Cover", false):
        effects(index)["Bedside Cover"] = true

func voluntary_step(index: int, from: Vector2i, to: Vector2i) -> bool:
    var fx: Dictionary = effects(index)
    if fx.get("brace", false) or fx.get("root", false) or fx.get("anchored", false):
        return false
    if fx.get("panic", false) and squad_distance(to) < squad_distance(from):
        return false
    return true

func squad_distance(tile: Vector2i) -> int:
    var best: int = 999
    for ally in range(5):
        if living(ally):
            best = mini(best, distance(pos(ally), tile))
    return best

func movement_budget(index: int, limit: int) -> int:
    var fx: Dictionary = effects(index)
    var venom_penalty := int(fx.has("poison") and knows(int(fx.get("poison", {}).get("owner", -1)), "Numbing Sting"))
    return 0 if fx.get("root", false) or fx.get("brace", false) else maxi(1, limit - int(fx.get("slow", 0)) - venom_penalty)

func create_zone(index: int, skill: String, tile: Vector2i, cells: Array, phases: int = 1) -> void:
    var zone := {"owner": index, "skill": skill, "center": tile, "tiles": cells,
        "used": {}, "expires": battle.turn_number + phases}
    zones.append(zone)
    if skill != "Musk Trail":
        for enemy in in_tiles(cells, "enemy"):
            affect_zone(zone, enemy)

func affect_zone(zone: Dictionary, enemy: int) -> void:
    if zone["used"].has(enemy) or not living(enemy):
        return
    zone["used"][enemy] = true
    var index: int = zone["owner"]
    match zone["skill"]:
        "Musk Trail":
            hit(index, enemy, "Musk Trail", 1, {"area": true})
            battle.apply_status(enemy, "blinded")
        "Shock Mine":
            zones.erase(zone)
            hit(index, enemy, "Shock Mine", 2, {"area": true})
            battle.apply_status(enemy, "shocked")
        "Gravity Well":
            if not anchored(enemy):
                var vector: Vector2i = direction(pos(enemy), zone["center"])
                slow(enemy, 2)
                if vector != Vector2i.ZERO and force_move(index, enemy, vector, 1) == 0 and living(enemy):
                    hit(index, enemy, "Gravity Well Impact", 1, {"area": true})
            if living(enemy):
                disrupt(index, enemy)
        "Master Interference":
            suppress(index, enemy)
            if not anchored(enemy):
                effects(enemy)["first_move_short"] = 2
        "Apex Reconfiguration":
            if organic(enemy):
                suppress(index, enemy)

func opportunity(mover: int, from: Vector2i, to: Vector2i) -> void:
    for index in range(battle.units.size()):
        if not living(mover) or not living(index) or unit(index)["team"] == unit(mover)["team"]:
            continue
        if enabled and reaction_disabled(index):
            continue
        if (enabled and knows(index, "Protecting Interceptor") and distance(pos(index), to) <= 3
                and once(index, "Protecting Interceptor", false)):
            var landing := attack_landing(index, mover, int(unit(index)["move"]), false)
            if landing != INVALID and landing != to and relocate(index, landing, false, false) and living(mover):
                once(index, "Protecting Interceptor")
                reaction_hit(index, mover, "Protecting Interceptor")
                effects(mover)["intercept_stopped"] = true
                return
        if not battle.basic_is_melee(unit(index)) or not melee_adjacent_at(index, mover, from) or melee_adjacent_at(index, mover, to):
            continue
        var previous_hits: int = int(unit(index).get("departure_reaction_hits", 0)) \
            if int(unit(index).get("departure_reaction_turn", -1)) == battle.turn_number else 0
        if previous_hits >= 1 + int(enabled and knows(index, "Threatening Presence")):
            continue
        if enabled and effects(mover).erase("silent_landing_primed"):
            battle.add_log("%s slips past %s's melee reaction." % [unit(mover)["name"], unit(index)["name"]])
            continue
        if enabled and effects(mover).get("slipping_foe", -1) == index:
            effects(mover).erase("slipping_foe")
            if not knows(mover, "Slipping Guard") or once(mover, "Slipping Guard"):
                battle.add_log("%s slips past %s's melee reaction." % [unit(mover)["name"], unit(index)["name"]])
                continue
        unit(index)["departure_reaction_turn"] = battle.turn_number
        unit(index)["departure_reaction_hits"] = previous_hits + 1
        var skill := "Threatening Presence" if knows(index, "Threatening Presence") else "Melee Reaction"
        reaction_hit(index, mover, skill)

func melee_adjacent_at(reactor: int, mover: int, mover_tile: Vector2i) -> bool:
    var attacking: Rect2i = battle.unit_footprint(unit(reactor), pos(reactor))
    var moving: Rect2i = battle.unit_footprint(unit(mover), mover_tile)
    return attacking.grow(1).intersects(moving) and not attacking.intersects(moving)

func reaction_hit(index: int, target: int, skill: String) -> void:
    battle.battle_stats[index]["reactions"] += 1
    battle.record_ability_use(index, skill, true)
    if enabled:
        var damage: int = maxi(0, int(unit(index)["damage"]) - battle.blinded_damage_penalty(index))
        hit(index, target, skill, damage, {"melee": true, "reaction": true, "review_basic": true})
    else:
        var attack: Dictionary = battle.melee_impact(index, target, int(unit(index)["damage"]), false)
        battle.resolve_attack(index, target, attack, skill, 0, false, false)

func isolated(index: int) -> bool:
    for other in range(battle.units.size()):
        if other != index and living(other) and unit(other)["team"] == unit(index)["team"] \
                and neighbours(index, pos(other)):
            return false
    return true

func range_bonus(index: int, target: int) -> int:
    var extra: int = int(effects(index).get("range_bonus", 0)) + int(effects(index).get("passing_reach", 0))
    var observer: int = int(effects(target).get("borrow_sight", -1))
    return extra + int(observer >= 0 and observer != index and unit(index)["team"] == "player")

func impact(index: int, target: int, damage: int, cover: int, context: Dictionary) -> Dictionary:
    var attacker_effects: Dictionary = effects(index) if index >= 0 else {}
    var defender_effects: Dictionary = effects(target)
    var melee_hit: bool = context.get("melee", false)
    var area_hit: bool = context.get("area", false)
    var ranged_hit: bool = context.get("ranged", false)
    var hit_mods: bool = not area_hit and index >= 0 and unit(index)["team"] != unit(target)["team"]
    var bypass: int = int(context.get("bypass", 0))
    var armour_break: int = int(context.get("break", 0))
    var uses: Array[String] = []
    var eat: Array[String] = []
    var eat_target: Array[String] = []
    var source: Vector2i = context.get("source", pos(index) if index >= 0 else pos(target))
    var mantle_owner: int = defender_effects.get("mantle_owner", -1)
    if ranged_hit and (knows(target, "Mental Fortress") or (living(mantle_owner) and knows(mantle_owner, "Returning Mantle"))):
        cover = maxi(cover, 1)
    if hit_mods and ranged_hit and defender_effects.has("pinion_guard"):
        damage -= 1
        eat_target.append("pinion_guard")
    var shock_mounts: bool = hit_mods and context.get("overwatch", false) and knows(target, "Shock Mounts") and once(target, "Shock Mounts", false)
    if shock_mounts:
        damage -= 1
    var quarry_bonus: int = 2 if index >= 0 and index == int(defender_effects.get("quarry_owner", -1)) \
        and unit(index)["team"] != unit(target)["team"] \
        and int(defender_effects.get("quarry_hits", 0)) > 0 and not context.get("hazard", false) \
        and not context.get("bypass_barriers", false) else 0
    var distorted: bool = hit_mods and attacker_effects.has("distorted_by")
    if distorted:
        damage = maxi(1, damage - 2)
    if hit_mods and ranged_hit and knows(index, "Focal Lens"):
        var reach := distance(source, pos(target))
        damage += int(reach >= 5)
        damage += 2 * int(reach <= 4 and knows(index, "Short-Sighted"))
        if context.get("review_basic", false) and knows(index, "Steady Gaze"):
            damage += 2
    if index >= 0 and not context.get("hazard", false) and unit(index)["team"] != unit(target)["team"]:
        damage += int(attacker_effects.get("attack_boost", 0))
        if attacker_effects.has("high_perch"):
            damage += 2
            eat.append("high_perch")
    if hit_mods and context.get("review_basic", false):
        damage += int(attacker_effects.get("reserve_dose", 0))
        eat.append("reserve_dose")
        if ranged_hit:
            eat.append("passing_reach")
    if melee_hit and knows(index, "Rosette Claws"):
        armour_break += 2 * int(knows(index, "Predator's Instinct"))
        if once(index, "Rosette Claws", false):
            uses.append("Rosette Claws")
            armour_break += 1
        if knows(index, "Scent Trail"):
            var streak: int = int(state(index).get("scent_count", 0)) if int(state(index).get("scent_target", -1)) == target else 0
            damage += mini(2, maxi(streak, int(attacker_effects.get("carried_hunt", 0))))
            eat.append("carried_hunt")
    if melee_hit and knows(index, "Heavy Hands") and int(unit(target)["armour"]) > 0 and context.get("review_basic", false):
        damage += 1
    if melee_hit and attacker_effects.has("flight_bonus"):
        damage += int(attacker_effects["flight_bonus"])
        eat.append("flight_bonus")
    if context.get("review_basic", false) and knows(index, "Read Intent") and has_available_reaction(target) and once(index, "Read Intent", false):
        damage += 1
        uses.append("Read Intent")
    if context.get("review_basic", false) and knows(index, "Set the Angle") and int(defender_effects.get("displaced_by", -1)) == index and once(index, "Set the Angle", false):
        damage += 1
        uses.append("Set the Angle")
    if hit_mods and defender_effects.has("seam_owner") and int(defender_effects["seam_owner"]) != index:
        damage += 2
        eat_target.append("seam_owner")
    if hit_mods and index < 5 and int(state(index)["mark"]) == target and knows(index, "Read the Opening") \
            and int(defender_effects.get("quarry_ally_hit", -1)) != index and defender_effects.has("quarry_ally_hit") \
            and once(index, "Read the Opening", false):
        damage += 1
        uses.append("Read the Opening")
    if context.get("ranged", false) and knows(target, "Shining Knight"):
        damage = maxi(0, damage - 1)
    if hit_mods and defender_effects.get("review_guard", false):
        damage = maxi(0, damage - 1)
        eat_target.append("review_guard")
    if knows(target, "Ferrous Body"):
        armour_break = 0
    if hit_mods:
        var penalty: int = attacker_effects.get("attack_penalty", 0)
        if penalty > 0 and damage > 0:
            damage = maxi(1, damage - penalty)
        if melee_hit:
            damage += int(attacker_effects.get("melee_bonus", 0)) + int(attacker_effects.get("shift_counter", false))
            eat.append("shift_counter")
            if attacker_effects.get("siege", false):
                cover = 0
                eat.append("siege")
            if knows(index, "Feral Claws"):
                armour_break += 1 + int(knows(index, "Plate Ripper"))
            if attacker_effects.get("bloodied", false) and once(index, "Bloodied Charge", false):
                armour_break += 1
                uses.append("Bloodied Charge")
                eat.append("bloodied")
            if knows(index, "Execution Drill") and isolated(target) and once(index, "Execution Drill", false):
                damage += 1
                uses.append("Execution Drill")
            if int(defender_effects.get("opening_blow", -1)) >= 0 and int(defender_effects["opening_blow"]) != index:
                damage += 1
                eat_target.append("opening_blow")
        if index < 5:
            if knows(index, "Focused Retina") and cover == 1:
                cover = 0
            var mark_bonus: int = 0
            var info: Dictionary = state(index)
            var moved_steps: int = int(info["moved"]) + int(context.get("approach_steps", 0))
            if int(info["mark"]) == target:
                if info["mark_open"]:
                    cover = 0
                    uses.append("mark_open")
                if knows(index, "Cold Precision") and moved_steps == 0 and once(index, "Cold Precision", false):
                    bypass += 1
                    uses.append("Cold Precision")
                if knows(index, "Moving Execution") and moved_steps >= 2 and once(index, "Moving Execution", false):
                    mark_bonus += 1
                    uses.append("Moving Execution")
                if knows(index, "Target Isolation") and isolated(target) and once(index, "Target Isolation", false):
                    mark_bonus += 1
                    uses.append("Target Isolation")
                if attacker_effects.get("perfect", false):
                    mark_bonus += 1
                    bypass += 1
                    eat.append("perfect")
                damage += mini(mark_bonus, 2)
            if knows(index, "Apex Reconfiguration") and apex(index) and info["form"] == "Frog" \
                    and once(index, "Frog Apex", false):
                damage += 1
                uses.append("Frog Apex")
            for flag in ["borrow_sight", "exposed_side", "pressure_breaker", "exploit_window"]:
                if int(defender_effects.get(flag, -1)) >= 0 and int(defender_effects[flag]) != index:
                    eat_target.append(flag)
                    if flag in ["exposed_side", "pressure_breaker"]:
                        cover = 0
                    elif flag == "exploit_window":
                        bypass += 1
            var controller: int = int(defender_effects.get("disrupted_by", -1))
            if controller >= 0 and controller != index and living(controller):
                if knows(controller, "Create Opening") and once(controller, "Create Opening", false):
                    cover = 0
                if knows(controller, "Expose Weakness") and once(controller, "Expose Weakness", false):
                    armour_break += 1
    cover += int(context.get("obstruction", 0))
    var remaining: int = 0 if damage <= 0 else (maxi(0, damage - cover) if area_hit else maxi(1, damage - cover))
    var absorbed: Dictionary = {}
    var dodge: bool = hit_mods and bool(defender_effects.get("dodge", false))
    var plastic: bool = defender_effects.has("plastic_skin") and hit_mods and (melee_hit or context.get("ranged", false))
    if dodge:
        quarry_bonus = 0
        remaining = 0
        armour_break = 0
        eat.clear()
        eat_target.clear()
        uses.clear()
        eat_target.append("dodge")
    if plastic:
        remaining = 0
        armour_break = 0
        quarry_bonus = 0
    for key in ["feather_barrier", "mantle", "sanctuary", "hospital_armour", "barrier", "force_shell"]:
        if context.get("bypass_barriers", false):
            break
        if key == "feather_barrier" and area_hit:
            continue
        var amount: int = mini(remaining, int(defender_effects.get(key, 0)))
        if amount > 0:
            absorbed[key] = amount
            remaining -= amount
    var armour: int = int(unit(target)["armour"])
    var pre_shred: int = int(context.get("pre_break", 0)) if not dodge and not plastic and not knows(target, "Ferrous Body") else 0
    var shredded: int = mini(armour, pre_shred)
    var armour_hit: int = mini(maxi(0, armour - shredded - bypass), remaining)
    var extra_break: int = shredded + mini(maxi(0, armour - shredded - armour_hit), armour_break)
    armour_break += pre_shred
    var hp_hit: int = mini(int(unit(target)["hp"]), remaining - armour_hit + quarry_bonus)
    var burrow: bool = (index >= 0 and hp_hit >= int(unit(target)["hp"]) and knows(target, "Burrow Defense")
        and not state(target)["mission_uses"].has("Burrow Defense"))
    if burrow:
        hp_hit = int(unit(target)["hp"]) - 1
    if defender_effects.has("burrowed"):
        hp_hit = 0
        armour_hit = 0
        extra_break = 0
        armour_break = 0
        absorbed.clear()
    return {"armour_damage": armour_hit + extra_break, "hp_damage": hp_hit,
        "quarry_bonus": quarry_bonus, "distorted": distorted and not dodge, "burrow": burrow,
        "review_basic": context.get("review_basic", false), "armour_before_hit": armour,
        "quarry_owner_at_hit": defender_effects.get("quarry_owner", -1),
        "hp_or_armour_damage": hp_hit + armour_hit, "ranged": ranged_hit,
        "cover": cover, "shock_mounts": shock_mounts and not dodge, "armour_cap_loss": armour_break, "barriers": absorbed, "hit_mods": hit_mods,
        "melee": melee_hit, "reaction": context.get("reaction", false), "area": area_hit,
        "uses": uses, "eat": eat, "eat_target": eat_target, "dodge": dodge, "remaining": remaining}

func clear_quarry(target: int) -> void:
    var marked: Dictionary = effects(target)
    var owner: int = marked.get("quarry_owner", -1)
    if owner >= 0 and int(state(owner)["mark"]) == target:
        state(owner)["mark"] = -1
    marked.erase("quarry_hits")
    marked.erase("quarry_owner")
    marked.erase("quarry_ally_hit")

func consume_hit(index: int, target: int, attack: Dictionary) -> void:
    var defender: Dictionary = effects(target)
    if attack.get("shock_mounts", false):
        once(target, "Shock Mounts")
        battle.record_ability_use(target, "Shock Mounts", true)
    if attack.get("burrow", false):
        defender["burrowed"] = true
        state(target)["mission_uses"]["Burrow Defense"] = true
    var mark_owner: int = defender.get("quarry_owner", -1)
    if mark_owner >= 0 and index != mark_owner and attack.get("hit_mods", false) and not attack.get("dodge", false) \
            and unit(index)["team"] == unit(mark_owner)["team"] and int(attack.get("hp_or_armour_damage", 0)) > 0:
        defender["quarry_ally_hit"] = index
    if int(attack.get("quarry_bonus", 0)) > 0:
        defender["quarry_hits"] = int(defender.get("quarry_hits", 0)) - 1
        if int(defender["quarry_hits"]) <= 0:
            clear_quarry(target)
    for key in attack.get("barriers", {}):
        defender[key] = int(defender[key]) - int(attack["barriers"][key])
    for key in attack.get("eat_target", []):
        defender.erase(key)
    if attack.get("dodge", false):
        battle.add_log("%s dodges the targeted attack." % unit(target)["name"])
    if index < 0:
        return
    if attack.get("hit_mods", false):
        spend_basic_attack_effects(index)
    var attacker: Dictionary = effects(index)
    for key in attack.get("eat", []):
        attacker.erase(key)
    for key in attack.get("uses", []):
        if key == "mark_open":
            state(index)["mark_open"] = false
        else:
            once(index, key)
    if not attack.get("hit_mods", false) or attack.get("dodge", false):
        return
    var controller: int = int(defender.get("disrupted_by", -1))
    if index < 5 and controller >= 0 and controller != index and living(controller):
        for skill in ["Create Opening", "Expose Weakness"]:
            if knows(controller, skill):
                once(controller, skill)
func spend_basic_attack_effects(index: int) -> int:
    var fx: Dictionary = effects(index)
    var penalty: int = int(fx.get("attack_penalty", 0))
    fx.erase("attack_penalty")
    if fx.get("mind_lock", false):
        fx["mind_lock_shot"] = true
    return penalty

func on_damage(target: int, armour_break: int, hp_damage: int) -> void:
    var defender: Dictionary = unit(target)
    if armour_break > 0:
        var broken: int = mini(armour_break, int(defender["max_armour"]))
        defender["armour_loss"] = int(defender.get("armour_loss", 0)) + broken
        defender["max_armour"] = maxi(0, int(defender["max_armour"]) - broken)
    if hp_damage > 0 and knows(target, "Bloodied Charge"):
        effects(target)["bloodied"] = true

func after_hit(index: int, target: int, attack: Dictionary) -> void:
    if attack.get("dodge", false) or not attack.get("hit_mods", false):
        return
    var melee_hit: bool = attack.get("melee", false)
    if living(target) and unit(target)["team"] == "player" and below_half_healing(target):
        for medic in range(5):
            if medic != target and living(medic) and knows(medic, "Trauma Ward") and state(medic)["form"] == "Jekyll" and distance(pos(medic), pos(target)) <= 2 and once(medic, "Trauma Ward"):
                barrier(target, 2)
                break
    var empath: int = effects(target).get("empathic_owner", -1)
    if index < 5 and empath != index and living(empath) and wounded(empath) and once(empath, "Empathic Echo"):
        heal(empath, empath, 1, "Empathic Echo")
    if index < 5 and living(index):
        if not living(target) and knows(index, "Tailwind") and int(attack.get("quarry_owner_at_hit", -1)) == index and once(index, "Tailwind Flight", false):
            effects(index)["Tailwind Flight"] = true
        if living(target) and melee_hit:
            if knows(index, "Slipping Guard"):
                effects(index)["slipping_foe"] = target
        if living(target) and attack.get("review_basic", false) and knows(index, "Fiery Gaze"):
            battle.apply_status(target, "burning")
        if melee_hit and living(target) and attack.get("review_basic", false) and int(attack.get("hp_or_armour_damage", 0)) > 0 and knows(index, "Break Through") and state(index).get("hyde_entered", -1) == battle.turn_number and once(index, "Break Through"):
            var before := pos(target)
            if force_move(index, target, direction(pos(index), before), 1) > 0:
                effects(index)["Hyde Follow-through"] = true
                effects(index)["hydefollow_tile"] = before
        if melee_hit and knows(index, "Hunt Rhythm") and int(attack.get("armour_before_hit", 0)) > 0 and int(unit(target)["armour"]) == 0 and once(index, "Hunt Rhythm"):
            unit(index)["ap"] += 1
        if melee_hit and knows(index, "Scent Trail"):
            var previous: int = state(index).get("scent_target", -1)
            var streak: int = int(state(index).get("scent_count", 0)) + 1 if previous == target else 1
            state(index)["scent_target"] = target
            state(index)["scent_count"] = streak
            if not living(target) and streak > 1 and knows(index, "Carry the Hunt") and once(index, "Carry the Hunt"):
                effects(index)["carried_hunt"] = mini(2, streak - 1)
        if melee_hit and knows(index, "Blood Trail") and int(attack["hp_damage"]) > 0 and once(index, "Blood Trail"):
            heal(index, index, 1, "Blood Trail")
        if living(target) and attack.get("review_basic", false):
            if knows(index, "Surface Thought") and organic(target) and not reaction_disabled(target) and once(index, "Suppress Reaction", false):
                effects(index)["Suppress Reaction"] = target
            if knows(index, "Impulse") and once(index, "Impulse Push", false):
                var eligible := not anchored(target) or can_leverage(index, target)
                if eligible and battle.can_take_move_step(unit(target), pos(target), pos(target) + direction(pos(index), pos(target))):
                    effects(index)["Impulse Push"] = target
            if knows(index, "Segmented Carapace") and organic(target):
                poison(index, target)
        var info: Dictionary = state(index)
        var fx: Dictionary = effects(index)
        if melee_hit:
            info["withdraw"] = target
            if living(target) and knows(index, "Chitinous Stinger") and organic(target) and once(index, "Chitinous Stinger"):
                poison(index, target)
            if living(target) and knows(index, "Opening Blow") and once(index, "Opening Blow"):
                effects(target)["opening_blow"] = index
            if living(target) and knows(index, "Pressure Breaker") and battle.tile_has_adjacent_cover(pos(target)) \
                    and once(index, "Pressure Breaker"):
                effects(target)["pressure_breaker"] = index
            if not living(target) and knows(index, "Pursuit") and once(index, "Pursuit"):
                fx["free_step"] = 2
            if not living(target) and knows(index, "Unyielding Route") and once(index, "Unyielding Route"):
                fx["free_step"] = 1
                fx["shove_guard"] = true
        if living(target) and int(info["mark"]) == target and knows(index, "Exploit Window") and once(index, "Exploit Window"):
            effects(target)["exploit_window"] = index
    if attack.get("distorted", false):
        var controller: int = effects(index).get("distorted_by", -1)
        effects(index).erase("distorted_by")
        if living(target) and unit(target)["team"] == "player" and knows(controller, "Residual Distortion"):
            var step: String = "residual_step_pending" if battle.side_to_play == "enemy" else "free_step"
            effects(target)[step] = maxi(1, int(effects(target).get(step, 0)))
    if melee_hit and living(index) and living(target) and organic(index) and distance(pos(index), pos(target)) == 1 and knows(target, "Intrusive Thought") and once(target, "Intrusive Thought"):
        suppress(target, index)
    if melee_hit and living(index) and living(target) and distance(pos(index), pos(target)) == 1 and knows(target, "Barbed Retort") and not attack.get("reaction", false) and once(target, "Barbed Retort"):
        reaction_hit(target, index, "Barbed Retort")
    if melee_hit and not attack.get("reaction", false) and living(index) and living(target) \
            and distance(pos(index), pos(target)) == 1 and effects(target).erase("counter") and not reaction_disabled(target):
        reaction_hit(target, index, "Savage Counter")

func intercept(index: int, target: int, attack: Dictionary) -> Dictionary:
    if index < 5 or target >= 5 or not attack.get("hit_mods", false) or attack.get("melee", false):
        return {}
    for owner in drones:
        if drone_live(owner) and bool(drones[owner]["intercept"]) and distance(drones[owner]["pos"], pos(target)) == 1:
            drones[owner]["intercept"] = false
            damage_drone(owner, int(attack.get("raw_damage", 1)))
            recalibrate(owner)
            battle.add_log("Drone intercepts the shot aimed at %s." % unit(target)["name"])
            return {"blocked": true}
    for owner in range(5):
        if owner != target and living(owner) and effects(owner).get("apex_intercept", false) \
                and distance(pos(owner), pos(target)) == 1:
            effects(owner).erase("apex_intercept")
            return {"target": owner}
    return {}

func damage_drone(owner: int, damage: int) -> void:
    var drone: Dictionary = drones[owner]
    var absorbed: int = mini(damage, int(drone.get("armour", 0)))
    drone["armour"] = int(drone.get("armour", 0)) - absorbed
    drone["hp"] = maxi(0, int(drone["hp"]) - (damage - absorbed))
    if not drone_live(owner):
        battle.add_log("%s's drone is destroyed." % unit(owner)["name"])

func try_enemy_drone_attack(enemy: int) -> bool:
    var taunter: int = effects(enemy).get("taunted_by", -1)
    if not battle.has_attack_ammo(enemy) or (living(taunter) and battle.can_attack(enemy, taunter)):
        return false
    var source := pos(enemy)
    var reach: int = int(unit(enemy)["range"])
    var target := -1
    var closest := reach + 1
    for owner: int in drones:
        if not drone_live(owner):
            continue
        var cell: Vector2i = drones[owner]["pos"]
        var gap := distance(source, cell)
        if gap >= closest or not visible(source, cell, reach):
            continue
        if not battle.basic_is_melee(unit(enemy)) and not battle.ranged_cover_block_reason(source, cell).is_empty():
            continue
        target = owner
        closest = gap
    if target < 0:
        return false
    for ally in range(5):
        if living(ally) and distance(source, pos(ally)) <= closest and battle.can_attack(enemy, ally):
            return false
    var drone_cell: Vector2i = drones[target]["pos"]
    var damage := drone_shot_damage(enemy, drone_cell)
    unit(enemy)["ap"] -= 1
    battle.spend_shot(enemy)
    battle.play_unit_action(enemy, battle.board_center(drone_cell), false, Color.TRANSPARENT, str(unit(enemy)["basic_attack"]))
    damage_drone(target, damage)
    return true

func start_enemy_phase() -> void:
    for index in range(5):
        state(index)["spare_ap"] = int(unit(index)["ap"])
        for key in ["Suppress Reaction", "Impulse Push", "reserve_dose", "passing_reach"]:
            effects(index).erase(key)
        if knows(index, "Settled Form") and once(index, "form change", false):
            effects(index)["review_guard"] = true
        if knows(index, "Power Routing"):
            effects(index)["redline_penalty"] = redline(index)
            cool(index, 1)
    for entry in ordnance:
        for aim in entry["aims"]:
            battle.queue_burst(battle.board_center(aim), 29.0, Color("#ffca8a"), &"blast")
        blast(entry["owner"], entry["tiles"], entry["damage"], entry["skill"], 1)
    ordnance.clear()
    for zone in zones.duplicate():
        if zone["skill"] == "Musk Trail":
            for foe in in_tiles(zone["tiles"], "enemy"):
                affect_zone(zone, foe)
    tick_poison("enemy")

func finish_enemy_phase() -> void:
    for index in range(5):
        if not living(index) or not knows(index, "Moulting Skin") or state(index)["room_uses"].has("Moulting Skin"):
            continue
        var statuses: Dictionary = unit(index)["statuses"]
        var burning := statuses.erase("burning")
        var irradiated := statuses.erase("irradiated")
        if burning or irradiated:
            state(index)["room_uses"]["Moulting Skin"] = true
            battle.record_ability_use(index, "Moulting Skin")

func prime_high_perch(index: int) -> void:
    if living(index) and knows(index, "High Perch") and battle.high_ground_tiles.has(pos(index)):
        effects(index)["high_perch"] = true

func start_player_phase() -> void:
    for index in range(5, battle.units.size()):
        for key in ["root", "slow", "panic", "mind_lock", "mind_lock_shot", "aphasia", "reaction_off", "attack_penalty",
                "disrupted_by", "first_move_short", "taunted_by", "quarry_hits", "quarry_owner", "reaction_cancelled_by",
                "distorted_by", "seam_owner", "stunned", "quarry_ally_hit", "intercept_stopped", "phantom_target", "displaced_by",
                "empathic_owner"]:
            effects(index).erase(key)
    for zone in zones.duplicate():
        if int(zone["expires"]) <= battle.turn_number:
            zones.erase(zone)
        elif zone["skill"] in ["Field Hospital", "Quarantine Field", "Musk Trail"]:
            continue
        else:
            zone["used"].clear()
            for foe in in_tiles(zone["tiles"], "enemy"):
                affect_zone(zone, foe)
    for index in range(5):
        var fx: Dictionary = effects(index)
        var info: Dictionary = state(index)
        info["mark"] = -1
        if fx.erase("burrowed"):
            unit(index)["statuses"].clear()
        if fx.erase("review_skip_armour"):
            unit(index)["armour"] = 0
        if knows(index, "Siege Mount"):
            cool(index, 1)
        var movement_penalty: int = int(fx.get("redline_penalty", 0))
        if fx.get("recalibrate", false):
            cool(index, 1)
        for key in ["barrier", "force_shell", "feather_barrier", "move_bonus", "melee_bonus", "dodge", "brace",
                "approach_counter", "counter", "electrical_weak", "siege", "perfect", "heat_override", "overcharge",
                "recalibrate", "free_step", "safe_step", "transfer", "range_bonus", "apex_intercept",
                "plastic_skin", "free_quarry", "root", "flight_bonus", "carried_hunt", "review_guard", "pinion_guard",
                "Tandem Move", "Tailwind Flight", "Bedside Cover", "Hyde Follow-through", "Counterweight Slide",
                "slipping_foe", "silent_landing_primed", "attack_boost", "high_perch", "anchored", "breach_follow_up", "passing_shove"]:
            fx.erase(key)
        if fx.erase("residual_step_pending"):
            fx["free_step"] = 1
        if int(fx.get("sanctuary_expiry", 0)) <= battle.turn_number:
            fx.erase("sanctuary")
        if int(fx.get("hospital_expiry", 0)) <= battle.turn_number:
            fx.erase("hospital_armour")
        for patient: int in info.get("mantles", {}).keys():
            end_mantle(index, patient, true)
        prime_high_perch(index)
        info["form_mastery"] = knows(index, "Form Mastery") and int(info["used"].get("form change", -1)) != battle.turn_number - 1
        refresh_base_attack(index)
        fx["move_penalty"] = movement_penalty
        info["moved"] = 0
        info["standard_move"] = 0
        info["withdraw"] = -1
        info["transfer"] = -1
        if drones.has(index):
            drones[index]["intercept"] = false
            drones[index]["armour"] = drone_max_armour(index)
            drones[index].erase("barricade")
            drones[index].erase("barricade_second")
        if info["form"] == "Hyde" and int(info.get("hyde_until", 0)) <= battle.turn_number:
            revert_hyde(index)
        refresh_stats(index)
        if living(index) and knows(index, "Regrowth"):
            heal(index, index, 1 + int(knows(index, "Fast Knit") and int(info["spare_ap"]) > 0), "Regrowth")
        if living(index) and knows(index, "Apex Reconfiguration") and apex(index) and info["form"] == "Jellyfish":
            barrier(index, 2)
            fx["apex_intercept"] = true
    tick_poison("player")

func tick_poison(team: String) -> void:
    for index in range(battle.units.size()):
        if not living(index) or unit(index)["team"] != team or not effects(index).has("poison"):
            continue
        var venom: Dictionary = effects(index)["poison"]
        venom["ticks"] -= 1
        if int(venom["ticks"]) <= 0:
            effects(index).erase("poison")
            battle.environment_hit_unit(int(venom["owner"]), index, 1, "Scorpion Venom", true)
