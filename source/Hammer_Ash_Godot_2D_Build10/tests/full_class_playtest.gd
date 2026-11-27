extends SceneTree

const SCENE = preload("res://Main.tscn")
const CLASSES = preload("res://scripts/player_classes.gd")
const LEVELS := [2, 3, 5, 6, 9]
const P := Vector2i(8, 8)
const A := Vector2i(7, 8)
const B := Vector2i(7, 9)
const E := Vector2i(9, 8)
const F := Vector2i(9, 9)
const G := Vector2i(11, 8)
const LAND := Vector2i(8, 7)
const EDGE := Vector2i(10, 8)
const EDGE_OTHER := Vector2i(10, 9)

var board
var rules
var campaign
var builds_checked := 0
var checks := 0
var failures := 0
var origins_completed := 0

func _initialize() -> void:
    call_deferred("run")

func require(ok: bool, message: String) -> void:
    checks += 1
    if not ok:
        failures += 1
        print("FAIL ", message)

func run() -> void:
    root.size = Vector2i(1460, 900)
    board = SCENE.instantiate()
    root.add_child(board)
    await process_frame
    rules = board.class_combat
    campaign = board.headquarters.campaign
    var hp_skills := {"Class bonus": {"max_hp_bonus": 2}, "Origin bonus": {"max_hp_bonus": 1}}
    require(CLASSES.maximum_hp(5, hp_skills, 3) == 22, "level, class, origin and Supersuit HP stack")
    for kit: String in ["Scythe", "Anvil", "Needle", "Iskra", "Alkhimik", "Glaz"]:
        for origin in range(2):
            play_origin(kit, origin)
            await process_frame
    test_quarry_refresh()
    require(origins_completed == 12, "completed all twelve origin passes")
    print("MATRIX RESULT builds=%d checks=%d failures=%d" % [builds_checked, checks, failures])
    quit(int(failures > 0))

func select_build(kit: String, origin: int, bits: int) -> Dictionary:
    var build := CLASSES.default_build()
    build["level"] = 9
    build["origin"] = origin
    for step in range(LEVELS.size()):
        build["choices"][LEVELS[step]] = (bits >> step) & 1
    return build

func play_origin(kit: String, origin: int) -> void:
    var name: String = CLASSES.data(kit)["origins"][origin]["name"]
    var starter := CLASSES.default_build()
    starter["origin"] = origin
    deploy(kit, starter)
    var operative: Dictionary = board.units[0]
    var profile: Dictionary = board.headquarters.kit_profiles[kit]
    var melee := kit in ["Scythe", "Anvil"] or (kit == "Needle" and origin == 1) or (kit == "Alkhimik" and origin == 0)
    var armour: int = {"Scorpion": 1, "Steel Skin": 3, "Psionic Armour": 3, "Drone Command": 1, "Artillery Suit": 2}.get(name, 0)
    var move := 5 if name in ["Jaguar", "Darwinian"] else 4
    require(profile["hp"] == 12 and profile["max_armour"] == 0 and profile["move"] == 4
        and profile["damage"] == 4 and profile["range"] == 8, name + " shared base profile")
    require(operative["hp"] == 12 and operative["max_hp"] == 12 and operative["armour"] == armour
        and operative["max_armour"] == armour and operative["move"] == move, name + " level 1 deployment stats")
    require(operative["basic_melee"] == melee and operative["damage"] == 4
        and operative["range"] == (1 if melee else 8), name + " level 1 basic attack")
    for bits in range(32):
        var build := select_build(kit, origin, bits)
        var unlocked := CLASSES.unlocked(kit, build)
        var valid := unlocked.size() == 10
        for step in range(LEVELS.size()):
            var pair := CLASSES.nodes_at(kit, origin, LEVELS[step])
            valid = valid and unlocked.has(pair[(bits >> step) & 1]["name"]) and not unlocked.has(pair[1 - ((bits >> step) & 1)]["name"])
        require(valid, "%s loadout bits %d" % [name, bits])
        builds_checked += 1
    var empty_carry: Array[Dictionary] = []
    var seen := {}
    var passives := {}
    var start_failed := failures
    for bits in [0, 31]:
        var build := select_build(kit, origin, bits)
        var id := deploy(kit, build)
        require(board.units[0]["hp"] == 20 and board.units[0]["max_hp"] == 20, name + " starts at full level 9 HP")
        var skills: Dictionary = board.units[0]["skills"].duplicate()
        var cases: Array[String] = []
        for skill: String in skills:
            if skills[skill]["type"] == "A" and not seen.has(skill):
                seen[skill] = true
                cases.append(skill)
        for skill in cases:
            board.load_mission_room(0, empty_carry)
            stage()
            test_action(name, skill)
        for level in LEVELS:
            var node: Dictionary = CLASSES.nodes_at(kit, origin, level)[0 if bits == 0 else 1]
            if node["type"] == "P":
                board.load_mission_room(0, empty_carry)
                stage()
                test_passive(name, node["name"])
                passives[node["name"]] = true
        board.load_mission_room(0, empty_carry)
        stage()
        test_carry(name, kit, origin, id)
    print("ORIGIN %s | 32 build combinations | %d active nodes | %d branch passives | 4 room transitions | %d failures" % [name, seen.size(), passives.size(), failures - start_failed])
    origins_completed += 1

func deploy(kit: String, build: Dictionary) -> int:
    campaign.mission.clear()
    var squad: Array[int] = []
    var gear := {}
    var lead := -1
    for id: int in campaign.roster:
        if campaign.roster[id]["kit"] == kit:
            lead = id
            campaign.roster[id]["class_build"] = build
            squad.append(id)
            gear[id] = 0
            break
    for id: int in campaign.roster:
        if squad.size() >= 5:
            break
        if id != lead:
            squad.append(id)
            gear[id] = 1
    require(campaign.deploy("assassination", squad, gear), "deploy " + kit)
    board.deploy_hq_operation("assassination")
    board.headquarters.hide()
    return lead

func stage() -> void:
    board.walls.clear()
    board.cover_edges.clear()
    board.destructible_edges.clear()
    board.hazards.clear()
    board.barrels.clear()
    for index in range(board.units.size()):
        board.units[index]["pos"] = Vector2i(1 + index % 18, 2 + index / 18)
        if index >= 5:
            board.units[index]["hp"] = 20
            board.units[index]["armour"] = 0
            board.units[index]["weight"] = 1
    for index in range(5):
        var tile: Vector2i = [P, A, B, Vector2i(7, 7), Vector2i(6, 9)][index]
        board.units[index]["pos"] = tile
        board.units[index]["ap"] = 3
    for index in range(5, 8):
        board.units[index]["pos"] = [E, F, G][index - 5]
    board.units[1]["hp"] = 2
    if rules.drone_live(0):
        rules.drones[0]["pos"] = Vector2i(8, 6)

func test_action(origin: String, skill: String) -> void:
    var picks: Array[Vector2i] = [E]
    var option := ""
    match skill:
        "Charge":
            option = "2 AP"
            picks.clear()
        "Breach Relay", "Rampage":
            picks.assign([E, P])
        "Rake", "Split Focus":
            picks.assign([E, F])
        "Rosette Rush":
            picks.assign([E, E])
        "Throw", "Hook and Drop":
            picks.assign([E, LAND])
        "Linebreaker", "Venom Jet":
            picks.assign([G])
        "Lend Armour", "Shelter Reflex", "Reserve Dose":
            picks.assign([A])
        "Safe Passage", "Adrenal Rescue", "Passing Trait":
            picks.assign([A, Vector2i(6, 8)])
        "Sanctuary":
            picks.clear()
            for point in range(board.units[0]["armour"]):
                picks.append(A if point % 2 == 0 else B)
        "Empty the Shell", "Pressure Front", "Gleaming Armour", "Thundering Taunt", "Plastic Skin", "Blowdown":
            picks.clear()
        "Wingover", "Banking Turn":
            picks.assign([E, LAND])
        "Peregrine Dive":
            rules.state(0)["mark"] = 5
        "Raking Pass":
            picks.assign([E])
        "Field Service":
            rules.drones[0]["pos"] = LAND
            rules.drones[0]["hp"] = 2
            picks.assign([LAND])
        "Emergency Rebuild":
            rules.damage_drone(0, 20)
            picks.clear()
        "Overclock Link":
            if rules.knows(0, "Guardian Chassis"):
                picks.assign([Vector2i(8, 6), Vector2i(8, 5), Vector2i(9, 6), Vector2i(8, 6)])
            else:
                picks.assign([Vector2i(8, 6), E, F, F])
        "Magnetic Tow", "Rescue Winch":
            picks.assign([E if skill == "Magnetic Tow" else A])
        "Shock Mine":
            picks.assign([LAND])
        "Field Rewire":
            picks.assign([P])
        "Mortar Cup", "Arc Canister", "Siege Salvo":
            picks.assign([Vector2i(12, 8)])
        "Walking Barrage", "Sweep Beam":
            picks.assign([G])
        "Shed Skin", "Rapid Metamorph":
            option = "Jellyfish"
            if skill == "Shed Skin":
                picks.clear()
        "Mosaic Body":
            option = "Jellyfish / Skunk"
            picks.assign([E, G])
        "Perfect Adaptation":
            option = "Jellyfish"
        "Field Formula":
            picks.assign([A])
        "Field Hospital":
            picks.assign([LAND, P, LAND])
            board.units[0]["hp"] = 3
        "Quarantine Field":
            picks.assign([A])
        "Phantom Threat", "Spatial Exchange":
            picks.assign([E, A])
        "Lateral Slip":
            option = "Left"
        "Hurl Debris":
            var edge: String = board.edge_key(EDGE, "S")
            board.destructible_edges[edge] = {"level": 1, "hp": 2, "max_hp": 2, "tile": EDGE, "face": "S"}
            board.cover_edges[EDGE] = {"S": 1}
            picks.assign([EDGE, EDGE_OTHER, G])
        "Wrecking Ball":
            picks.assign([E, Vector2i(12, 8)])
    if skill in ["Hurl Aside", "Rampage"]:
        rules.enter_hyde(0)
    if skill == "Blowdown":
        rules.state(0)["heat"] = 3
    var label := "%s / %s" % [origin, skill]
    var ap: int = board.units[0]["ap"]
    rules.arm_action(0, skill, option)
    for pick in picks:
        rules.submit(pick)
    require(int(board.units[0]["ap"]) < ap and rules.ability.is_empty(), label + " did not resolve: " + str(board.status_message))
    if rules.ability != "":
        rules.cancel()
    else:
        check_cost_and_limit(skill, option, ap, label)
        check_capstone(skill, label)
        if skill == "Pressure Front":
            require(board.units[0]["armour"] == 0 and board.units[5]["hp"] == 17, label + " spends armour and deals three")
            board.finish_enemy_phase()
            require(board.units[0]["armour"] == 0, label + " skips the first refresh")
            board.finish_enemy_phase()
            require(board.units[0]["armour"] == board.units[0]["max_armour"], label + " resumes ordinary refresh afterward")
        if skill == "Shelter Reflex":
            require(rules.effects(1).get("mantle", 0) == 3 and rules.effects(0).get("barrier", 0) == 3, label + " protects both operatives")
            board.finish_enemy_phase()
            require(not rules.effects(1).has("mantle") and int(rules.effects(0).get("barrier", 0)) <= 1, label + " expires at the next player turn")

func check_cost_and_limit(skill: String, option: String, before: int, label: String) -> void:
    var node: Dictionary = rules.review_node(0, skill)
    var info: Dictionary = rules.state(0)
    require(before - int(board.units[0]["ap"]) == rules.action_cost(0, skill, option, node), label + " AP cost")
    var limit: String = node["limit"]
    if limit.begins_with("CD"):
        require(info["ready"].get(skill, 0) == board.turn_number + limit.substr(2).to_int(), label + " cooldown set correctly")
    elif limit == "R1":
        require(info["room_uses"].has(skill), label + " consumes room allowance")
    elif limit == "M1":
        require(info["mission_uses"].has(skill), label + " consumes operation allowance")

func check_capstone(skill: String, label: String) -> void:
    var foe: Dictionary = board.units[5]
    var primary: Dictionary = board.units[0]
    var info: Dictionary = rules.state(0)
    var hp: int = foe["hp"]
    var passed := true
    match skill:
        "Rosette Rush", "Burrowing Strike":
            passed = hp == 20 - int(primary["damage"])
        "Plastic Skin":
            passed = primary["armour"] == 0 and rules.impact(5, 0, 8, 0, {"melee": true})["hp_damage"] == 0
        "Colossal Combo":
            passed = hp == 20 - 3 * int(primary["damage"]) and info["ready"].get(skill) == board.turn_number + 2
        "Empty the Shell":
            passed = primary["armour"] == 0 and hp < 20 and rules.effects(0).has("review_skip_armour")
        "Sanctuary":
            passed = primary["armour"] == 0 and rules.effects(1).get("sanctuary", 0) > 0 and rules.effects(2).get("sanctuary", 0) > 0
        "Pinhole Sun":
            passed = hp == 14 and foe["statuses"].has("burning")
        "Prismatic Burst":
            passed = hp == 17 and rules.effects(5).get("root", false)
        "Peregrine Dive":
            passed = hp == 15
        "Wingover":
            passed = hp == 20 - int(primary["damage"]) and foe["statuses"].has("bleeding") and rules.pos(0) == LAND
        "Emergency Rebuild":
            passed = rules.drone_live(0) and rules.drones[0]["hp"] == 2 and info["mission_uses"].has(skill)
        "Overclock Link":
            if rules.knows(0, "Guardian Chassis"):
                passed = rules.barricade_at(Vector2i(8, 6), "N") and rules.barricade_at(Vector2i(8, 6), "E")
            else:
                passed = hp == 16 and board.units[6]["hp"] == 17
        "Siege Salvo":
            passed = board.units[7]["hp"] == 15 and info["heat"] == 3
        "Blowdown":
            passed = hp == 17 and info["heat"] == 0
        "Mosaic Body":
            passed = hp == 18 and info["form"] == "Frog" and info["ready"].has("Nettle Lock") and info["ready"].has("Musk Trail")
        "Perfect Adaptation":
            passed = hp == 19 and info["form"] == "Jellyfish" and rules.effects(5).get("stunned", false)
        "Field Hospital":
            passed = primary["hp"] == 7 and rules.effects(0).get("hospital_armour", 0) == 2
        "Break the Vial":
            passed = hp == 15 and info["form"] == "Hyde" and info["room_uses"].has("Transform")
        "Crowd Panic":
            passed = rules.effects(5).get("slow", 0) == 2 and rules.effects(6).get("slow", 0) == 2
        "Thought Arrest":
            passed = rules.effects(5).get("review_ap_loss", 0) == 2
        "Spatial Exchange":
            passed = rules.pos(5) == A and rules.pos(1) == E
        "Wrecking Ball":
            passed = hp == 16 and board.units[7]["hp"] == 16 and rules.pos(5) == EDGE
        _:
            return
    if not passed:
        print("CAPSTONE DIAGNOSTIC ", label, " foe=", hp, " third=", board.units[7]["hp"], " self=", primary["hp"], " heat=", info["heat"], " effects=", rules.effects(0), " foe_fx=", rules.effects(5))
    require(passed, label + " capstone did not produce its expected effect")

func test_carry(name: String, kit: String, origin: int, id: int) -> void:
    var skills: Array = board.units[0]["skills"].keys()
    var max_hp: int = int(board.units[0]["max_hp"])
    var hp: int = max_hp - 2
    board.units[0]["hp"] = hp
    require(int(board.units[0]["medkit_charges"]) == 1, name + " starts with a medkit to spend")
    board.units[0]["medkit_charges"] = 0
    board.units[0]["armour_loss"] = 1
    rules.state(0)["room_uses"]["test_room"] = true
    rules.state(0)["ready"]["test_cooldown"] = 5
    rules.state(0)["mission_uses"]["test_operation"] = true
    if kit == "Iskra" and origin == 0 and rules.knows(0, "Emergency Rebuild"):
        rules.damage_drone(0, 20)
        rules.arm_action(0, "Emergency Rebuild", "")
        require(rules.drone_live(0) and rules.state(0)["mission_uses"].has("Emergency Rebuild"), name + " spends its actual operation-limit capstone")
    if rules.knows(0, "Burrow Defense"):
        board.units[0]["armour"] = 0
        rules.hit(5, 0, "Lethal carry-over test", 20, {"melee": true})
        require(board.units[0]["hp"] == 1 and rules.state(0)["mission_uses"].has("Burrow Defense"), name + " spends Burrow Defense in room 1")
        board.units[0]["hp"] = hp
    if kit == "Alkhimik":
        if origin == 0:
            rules.shift_form(0, "Skunk")
        else:
            rules.enter_hyde(0)
    if kit == "Iskra" and origin == 0:
        rules.damage_drone(0, 20)
    board.room_cleared = true
    board.next_mission_room()
    require(board.mission_stage == 1 and board.hq_operative_id(0) == id, name + " reaches room 2 with the same operative")
    require(board.units[0]["max_hp"] == max_hp, name + " keeps level-scaled maximum HP in room 2")
    require(board.units[0]["skills"].keys() == skills and board.units[0]["hp"] == hp and board.units[0]["medkit_charges"] == 0 and int(board.units[0]["armour_loss"]) == 1, name + " carries build, HP, consumable and armour loss")
    require(rules.state(0)["room_uses"].is_empty() and rules.state(0)["ready"].is_empty() and rules.state(0)["mission_uses"].has("test_operation"), name + " resets room limits and preserves operation limits")
    if kit == "Alkhimik":
        require(rules.state(0)["form"] == ("Skunk" if origin == 0 else "Jekyll"), name + " correct transition form")
        if origin == 1:
            require(int(board.units[0]["ap"]) == 2, name + " carries the Hyde AP recovery")
    if kit == "Iskra" and origin == 0:
        require(not rules.drone_live(0), name + " carries drone destruction")
        if rules.knows(0, "Emergency Rebuild"):
            require(rules.unavailable(0, "Emergency Rebuild", "") == "Already used.", name + " cannot rebuild again in room 2")
    if rules.knows(0, "Burrow Defense"):
        board.units[0]["armour"] = 0
        var next_hit: Dictionary = rules.impact(5, 0, 20, 0, {"melee": true})
        require(not next_hit["burrow"] and next_hit["hp_damage"] == hp, name + " cannot trigger Burrow Defense again in room 2")
    board.room_cleared = true
    board.next_mission_room()
    require(board.units[0]["max_hp"] == max_hp, name + " keeps level-scaled maximum HP in room 3")
    require(board.mission_stage == 2 and board.units[0]["hp"] == hp and board.units[0]["skills"].keys() == skills and rules.state(0)["mission_uses"].has("test_operation"), name + " reaches room 3 with build, HP and operation limits")
    if kit == "Alkhimik" and origin == 1:
        require(int(board.units[0]["ap"]) == 3, name + " clears the carried Hyde penalty after room 2")

func test_quarry_refresh() -> void:
    deploy("Needle", select_build("Needle", 0, 0))
    stage()
    var other: Dictionary = board.units[1]
    other["kit_name"] = "Needle"
    rules.setup_unit(1, select_build("Needle", 1, 0), {})
    rules.arm_action(0, "Designate Quarry", "")
    rules.submit(E)
    rules.hit(0, 5, "Test hit", 1, {"ranged": true})
    require(int(rules.effects(5).get("quarry_hits", 0)) == 2, "first Needle leaves two uses")
    rules.arm_action(1, "Designate Quarry", "")
    rules.submit(E)
    require(int(rules.effects(5).get("quarry_hits", 0)) == 3, "second Needle refreshes to three")
    require(rules.state(1)["mark"] == 5 and rules.state(0)["mark"] == -1, "refreshed quarry belongs to the latest Needle")
    for strike in range(3):
        rules.hit(1, 5, "Test hit", 1, {"ranged": true})
    require(not rules.effects(5).has("quarry_hits") and not rules.effects(5).has("quarry_owner") and rules.state(1)["mark"] == -1,
        "refreshed mark clears its owner when its three hits are used")

func test_passive(origin: String, skill: String) -> void:
    var ok := false
    var primary: Dictionary = board.units[0]
    var foe: Dictionary = board.units[5]
    var fx: Dictionary = rules.effects(0)
    var enemy_fx: Dictionary = rules.effects(5)
    var info: Dictionary = rules.state(0)
    var melee := {"melee": true, "review_basic": true}
    var ranged := {"ranged": true, "review_basic": true}
    primary["hp"] = 5
    match skill:
        "Blood Trail":
            rules.hit(0, 5, skill, 2, melee)
            ok = primary["hp"] == 6
        "Slipping Guard", "Silent Landing":
            if skill == "Silent Landing":
                rules.note_flight(0)
            foe["basic_melee"] = true
            rules.hit(0, 5, skill, 2, melee)
            rules.opportunity(0, P, A)
            ok = board.battle_stats[5]["reactions"] == 0 and not fx.has("slipping_foe")
        "Hunt Rhythm":
            foe["armour"] = 1
            primary["ap"] = 1
            rules.hit(0, 5, skill, 3, melee)
            ok = primary["ap"] == 2
        "Predator's Instinct":
            foe["armour"] = 5
            ok = int(rules.impact(0, 5, 1, 0, melee)["armour_cap_loss"]) == 3
        "Carry the Hunt":
            info["scent_target"] = 5
            info["scent_count"] = 2
            foe["hp"] = 1
            rules.hit(0, 5, skill, 2, melee)
            ok = fx.get("carried_hunt", 0) == 2
        "Deflective Plates", "Rolled Plate", "Thick Mantle", "Tempered Knuckles":
            var standing: Vector2i = CLASSES.stat_modifiers(primary["skills"], info["form"])
            var without: Dictionary = primary["skills"].duplicate()
            without.erase(skill)
            var comparison: Vector2i = CLASSES.stat_modifiers(without, info["form"])
            ok = standing - comparison == (Vector2i(0, 1) if skill == "Tempered Knuckles" else Vector2i(1, 0))
        "Stronger Poison":
            rules.hit(0, 5, skill, 2, melee)
            ok = enemy_fx.get("poison", {}).get("ticks") == 3
        "Moulting Skin":
            primary["armour"] = 1
            rules.hit(5, 0, skill, 2, melee)
            ok = primary["armour"] == primary["max_armour"]
            rules.hit(5, 0, skill, int(primary["armour"]), melee)
            ok = ok and primary["armour"] == 0
        "Barbed Retort":
            rules.hit(5, 0, skill, 2, melee)
            ok = board.battle_stats[0]["reactions"] == 1 and foe["hp"] < 20
        "Burrow Defense":
            primary["armour"] = 0
            rules.hit(5, 0, skill, 20, melee)
            ok = primary["hp"] == 1 and info["mission_uses"].has(skill)
            rules.hit(5, 0, skill, 20, melee)
            ok = ok and primary["hp"] == 1
        "Heavy Hands":
            foe["armour"] = 1
            var attack: Dictionary = rules.impact(0, 5, 3, 0, melee)
            ok = int(attack["armour_damage"]) + int(attack["hp_damage"]) == 4
        "Shining Knight", "Heat Jacket":
            info["heat"] = 3
            primary["armour"] = 0
            ok = rules.impact(5, 0, 3, 0, ranged)["hp_damage"] == 2
        "Long Mantle":
            board.units[1]["pos"] = Vector2i(2, 8)
            var pick: Array[Vector2i] = [Vector2i(2, 8)]
            ok = not rules.plan_action(0, "Lend Armour", "", pick).has("error")
        "Returning Mantle", "Shock Grapple":
            rules.arm_action(0, "Lend Armour" if rules.knows(0, "Lend Armour") else "Shelter Reflex", "")
            rules.submit(A)
            if skill == "Returning Mantle":
                board.units[5]["pos"] = P + Vector2i(1, 0)
                ok = rules.impact(5, 1, 3, 0, ranged)["hp_damage"] == 0 and rules.effects(1).has("mantle")
            else:
                rules.start_player_phase()
                ok = int(fx.get("barrier", 0)) == 1 and not rules.effects(1).has("mantle")
        "Long Focus", "Peripheral Vision", "Long Lever":
            var without: Dictionary = primary["class_build"].duplicate(true)
            var level := 2 if skill == "Long Focus" else 6
            without["choices"][level] = 1 - int(without["choices"][level])
            var compare := CLASSES.base_attack(primary["kit_name"], without, info["form"],
                primary["ranged_damage"], primary["ranged_range"])
            ok = int(primary["range"]) == int(compare["range"]) + 1
        "Afterglow":
            rules.hit(0, 5, "Sightline", 3, ranged)
            primary["rounds"] = 0
            ok = board.spend_shot(0, 5) and not board.spend_shot(0, 5)
        "Steady Gaze":
            foe["pos"] = Vector2i(12, 8)
            ok = rules.impact(0, 5, 2, 0, ranged)["hp_damage"] == 3
        "Long Primaries":
            var pick: Array[Vector2i] = [Vector2i(8, 14)]
            ok = not rules.plan_action(0, "Fly", "", pick).has("error")
        "Tailwind":
            foe["hp"] = 2
            enemy_fx["quarry_owner"] = 0
            enemy_fx["quarry_hits"] = 1
            info["mark"] = 5
            rules.hit(0, 5, skill, 2, melee)
            ok = fx.get("Tailwind Flight", false)
        "Pinion Guard":
            rules.note_flight(0)
            var attack: Dictionary = rules.impact(5, 0, 3, 0, ranged)
            rules.consume_hit(5, 0, attack)
            ok = attack["hp_damage"] == 2 and not fx.has("pinion_guard")
        "Assault Chassis":
            rules.arm_action(0, "Chain Arc", "")
            rules.submit(E)
            rules.submit(F)
            rules.submit(F)
            ok = foe["hp"] == 17 and board.units[6]["hp"] == 18
        "Guardian Chassis":
            rules.arm_action(0, "Rolling Barricade", "")
            rules.submit(Vector2i(8, 6))
            rules.submit(Vector2i(8, 5))
            ok = rules.barricade_at(Vector2i(8, 6), "N")
        "Crossfire":
            enemy_fx["drone_hit_owner"] = 0
            enemy_fx["drone_hit_side"] = "N"
            ok = rules.impact(0, 5, 2, 0, ranged)["hp_damage"] == 4
        "Retaliation Circuit":
            foe["pos"] = Vector2i(9, 6)
            foe["range"] = 1
            foe["damage"] = 1
            ok = rules.try_enemy_drone_attack(5) and foe["hp"] < 20
        "Baffled Exhaust", "Feed Mechanism":
            info["heat"] = 4
            primary["rounds"] = 0
            rules.arm_action(0, "Vent", "")
            ok = info["heat"] == 1 if skill == "Baffled Exhaust" else primary["rounds"] == 1
        "Braced Mount":
            ok = rules.impact(0, 5, 3, 0, ranged)["hp_damage"] == 4
        "Quick Adaptation", "Vestigial Plates":
            rules.shift_form(0, "Jellyfish")
            ok = rules.free_step(0) == 1 if skill == "Quick Adaptation" else int(fx.get("barrier", 0)) == 2
        "Settled Form":
            primary["armour"] = 0
            rules.start_enemy_phase()
            ok = rules.impact(5, 0, 3, 0, ranged)["hp_damage"] == 2
        "Form Mastery":
            rules.shift_form(0, "Skunk")
            board.turn_number += 2
            rules.start_player_phase()
            ok = primary["range"] == int(primary["ranged_range"]) + 1
        "Bedside Cover":
            rules.finished_standard_move(0)
            rules.arm_action(0, skill, "")
            rules.submit(A)
            ok = rules.effects(1).get("barrier", 0) == 1
        "Break Through":
            rules.enter_hyde(0)
            rules.hit(0, 5, skill, 2, melee)
            ok = foe["pos"] == P + Vector2i(2, 0) and fx.has("Hyde Follow-through")
        "Trauma Ward":
            board.units[1]["armour"] = 0
            board.units[1]["hp"] = 3
            rules.hit(5, 1, skill, 1, ranged)
            ok = rules.effects(1).get("barrier", 0) == 2
        "Adrenal Rebound":
            rules.enter_hyde(0)
            rules.revert_hyde(0)
            ok = int(fx.get("barrier", 0)) == 2 and primary["ap"] == 2
        "Read Intent", "Quiet Mind", "Divided Attention":
            foe["reaction_available"] = true
            foe["reaction_type"] = "overwatch"
            rules.hit(0, 5, "Synaptic Prick", 2, ranged)
            match skill:
                "Read Intent": ok = foe["hp"] == 17
                "Quiet Mind": ok = int(fx.get("barrier", 0)) == 1
                "Divided Attention": ok = int(enemy_fx.get("slow", 0)) == 1
        "Empathic Echo":
            rules.arm_action(0, "Distort Aim", "")
            rules.submit(E)
            rules.hit(1, 5, skill, 2, ranged)
            ok = primary["hp"] == 6
        "Leverage", "Follow Through":
            foe["weight"] = 3 if skill == "Leverage" else 1
            if skill == "Follow Through":
                board.units[7]["pos"] = Vector2i(11, 9)
            rules.hit(0, 5, "Force Bolt", 2, ranged)
            ok = foe["pos"] == (Vector2i(10, 8) if skill == "Leverage" else Vector2i(11, 8))
        "Set the Angle":
            rules.force_move(0, 5, Vector2i(1, 0), 1)
            ok = rules.impact(0, 5, 2, 0, ranged)["hp_damage"] == 3
    require(ok, "%s / %s passive did not produce its expected result" % [origin, skill])
