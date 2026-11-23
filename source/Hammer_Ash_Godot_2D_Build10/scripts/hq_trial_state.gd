extends RefCounted

const Loadouts = preload("res://scripts/starter_loadouts.gd")

const SQUAD_SIZE: int = 5
const RECRUIT_COST: int = 6
const RECRUIT_DAYS: int = 3
const RECOVERY_DAYS: int = 2
const RECON_COST: int = 2
const RELOAD_COST: int = 3
const STARTING_SUPPLIES: int = 20
const STARTING_INTEL: int = 7
const STARTING_MEDKITS: int = 2
const OPERATION_DAYS: int = 1
const PROJECTS: Dictionary = {
    "emergency_reload": {"label": "Emergency Reload", "branch": "Stratagems", "cost": 4, "days": 2, "unlock": "reload"},
    "facility_recon": {"label": "Facility Recon", "branch": "Intelligence Ops", "cost": 5, "days": 2, "unlock": "recon"},
}
const RECIPES: Dictionary = {
    "basic_medkit": {"label": "Medkit", "cost": 2, "quantity": 1},
    "batch_medkit": {"label": "Medkit batch", "cost": 3, "quantity": 2},
}
const OPERATIONS: Dictionary = {
    "assassination": {"label": "Assassination", "brief": "Reach and eliminate the fleeing officer.", "recon": "Orlov starts his escape in the final room on Round 3. Cover the east exit."},
    "sabotage": {"label": "Sabotage", "brief": "Destroy the generator and neutralise the prototype.", "recon": "The prototype activates at the end of player Round 3 if the pod is still active. A nearby terminal can disable it."},
    "rescue": {"label": "Rescue", "brief": "Free the two prisoners and clear the guards.", "recon": "Five guards cover two cells. Release both prisoners and clear the guards to secure the rescue."},
    "defence": {"label": "Defence", "brief": "Protect the safehouse from enemy waves.", "recon": "Enemy waves arrive on Rounds 1, 3, 5 and 7. Protect the safehouse through Round 8."},
}
const REWARDS: Dictionary = {
    "sabotage_complete": {"label": "Secured a Service Rifle, 6 Supplies and 2 Intel.", "gear": "Service Rifle", "supplies": 6, "intel": 2},
    "rescue_complete": {"label": "Secured a recruit and 4 Supplies.", "recruit": "Needle", "supplies": 4},
}

var classes: Array[String] = []
var supplies: int = STARTING_SUPPLIES
var intel: int = STARTING_INTEL
var day: int = 1
var medkits: int = STARTING_MEDKITS
var roster: Dictionary = {}
var armoury: Dictionary = {}
var research: Dictionary = {}
var recruitment: Dictionary = {}
var researched: Dictionary = {}
var unlocks: Dictionary = {}
var processed_rewards: Dictionary = {}
var mission: Dictionary = {}
var prepared_recon: String = ""
var debrief: Array[String] = []
var next_operative: int = 1
var next_operation: int = 1

func seed(playable_classes: Array[String]) -> void:
    classes.assign(playable_classes)
    for class_name_text in classes:
        add_operative(class_name_text)
    for class_name_text in classes:
        add_operative(class_name_text)
    roster[next_operative - 1]["ready_day"] = day + RECOVERY_DAYS

func add_operative(kit: String) -> void:
    if not classes.has(kit):
        return
    var melee: int = Loadouts.EMPTY_MELEE if Loadouts.blocks_melee(classes.find(kit), 0) else 0
    roster[next_operative] = {"kit": kit, "ready_day": day, "loadout": [0, melee, 0, 1]}
    next_operative += 1

func operative_name(id: int) -> String:
    return "%s %02d" % [roster[id]["kit"], id]

func available(id: int) -> bool:
    return roster.has(id) and int(roster[id]["ready_day"]) <= day

func start_recruit(kit: String) -> bool:
    if not recruitment.is_empty() or not classes.has(kit) or supplies < RECRUIT_COST:
        return false
    supplies -= RECRUIT_COST
    recruitment = {"kit": kit, "finish": day + RECRUIT_DAYS}
    return true

func research_block(id: String) -> String:
    var project: Dictionary = PROJECTS[id]
    if researched.has(id):
        return "Complete"
    if research.get("id") == id:
        return "Ready on day %d" % int(research["finish"])
    if not research.is_empty():
        return "Research slot occupied"
    if supplies < int(project["cost"]):
        return "Insufficient Supplies"
    return ""

func start_research(id: String) -> bool:
    if not PROJECTS.has(id) or not research_block(id).is_empty():
        return false
    var project: Dictionary = PROJECTS[id]
    supplies -= int(project["cost"])
    research = {"id": id, "finish": day + int(project["days"])}
    return true

func advance_day() -> void:
    day += 1
    if not research.is_empty() and day >= int(research["finish"]):
        var id: String = research["id"]
        researched[id] = true
        unlocks[PROJECTS[id]["unlock"]] = true
        research.clear()
    if not recruitment.is_empty() and day >= int(recruitment["finish"]):
        add_operative(recruitment["kit"])
        recruitment.clear()

func produce(id: String) -> bool:
    if not RECIPES.has(id) or supplies < int(RECIPES[id]["cost"]):
        return false
    supplies -= int(RECIPES[id]["cost"])
    medkits += int(RECIPES[id]["quantity"])
    return true

func buy_recon(operation: String) -> bool:
    if not mission.is_empty() or not OPERATIONS.has(operation) or not prepared_recon.is_empty():
        return false
    if not unlocks.has("recon") or intel < RECON_COST:
        return false
    intel -= RECON_COST
    prepared_recon = operation
    return true

func can_deploy(operation: String, squad: Array[int], gear: Dictionary) -> bool:
    if not mission.is_empty() or not OPERATIONS.has(operation) or squad.size() != SQUAD_SIZE:
        return false
    var seen: Dictionary = {}
    var rifles: int = 0
    var kits: int = 0
    for id in squad:
        if not available(id) or seen.has(id) or not gear.has(id):
            return false
        seen[id] = true
        var choices: Array = gear[id]
        var kit_index: int = classes.find(roster[id]["kit"])
        if choices.size() != Loadouts.SLOTS.size():
            return false
        for slot in range(choices.size()):
            if choices[slot] < 0 or choices[slot] >= Loadouts.ITEMS[slot].size():
                return false
        if not Loadouts.can_equip(kit_index, choices, 1, choices[1]):
            return false
        if choices[0] == 1:
            rifles += 1
        if choices[3] == 0:
            kits += 1
    return rifles <= armoury.size() and kits <= medkits

func deploy(operation: String, squad: Array[int], gear: Dictionary, prepare_reload: bool = false) -> bool:
    if not can_deploy(operation, squad, gear) or (prepare_reload and not unlocks.has("reload")):
        return false
    if prepared_recon == operation:
        prepared_recon = ""
    var packed: Array[int] = []
    for id in squad:
        if gear[id][3] == 0:
            packed.append(id)
    mission = {"id": next_operation, "squad": squad.duplicate(), "gear": gear.duplicate(true),
        "packed": packed, "emergency_reload": prepare_reload}
    next_operation += 1
    debrief.clear()
    return true

func spend_medkit(operative: int) -> void:
    if not mission.is_empty() and mission["packed"].has(operative):
        mission["packed"].erase(operative)
        medkits -= 1

func use_emergency_reload() -> bool:
    if not mission.get("emergency_reload", false) or intel < RELOAD_COST:
        return false
    intel -= RELOAD_COST
    mission["emergency_reload"] = false
    return true

func credit_reward(id: String, secured: bool) -> bool:
    if mission.is_empty() or not secured or not REWARDS.has(id):
        return false
    var transaction: String = "%d:%s" % [int(mission["id"]), id]
    if processed_rewards.has(transaction):
        return false
    processed_rewards[transaction] = true
    var reward: Dictionary = REWARDS[id]
    supplies += int(reward.get("supplies", 0))
    intel += int(reward.get("intel", 0))
    if reward.has("gear"):
        armoury[transaction] = reward["gear"]
    if reward.has("recruit"):
        add_operative(reward["recruit"])
    debrief.append(reward["label"])
    return true

func finish(outcome: String, battle_units: Array[Dictionary]) -> void:
    if mission.is_empty():
        return
    var squad: Array = mission["squad"]
    for idx in range(squad.size()):
        var id: int = squad[idx]
        var unit: Dictionary = battle_units[idx]
        if bool(unit["permanently_dead"]):
            debrief.append("%s was killed." % operative_name(id))
            roster.erase(id)
        elif int(unit["downs"]) > 0:
            roster[id]["ready_day"] = day + OPERATION_DAYS + RECOVERY_DAYS
            debrief.append("%s is recovering until day %d." % [operative_name(id), int(roster[id]["ready_day"])])
    debrief.push_front(outcome)
    mission.clear()
    for elapsed in range(OPERATION_DAYS):
        advance_day()
