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
    test_revised_class_effects()
    test_iskra_rework()
    test_glaz_and_alkhimik_effects()
    test_class_room_clear()
    test_full_cover()
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
    var damage := 2 if name == "Darwinian" else (3 if name == "Drone Command" else 4)
    var reach := 1 if melee else (6 if kit == "Iskra" else 8)
    require(operative["basic_melee"] == melee and operative["damage"] == damage
        and operative["range"] == reach, name + " level 1 basic attack")
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
    require(campaign.deploy("southern/sweep", squad, gear), "deploy " + kit)
    board.deploy_hq_operation("southern/sweep")
    board.headquarters.hide()
    return lead

func stage() -> void:
    board.walls.clear()
    board.cover_edges.clear()
    board.destructible_edges.clear()
    board.hazards.clear()
    board.barrels.clear()
    board.high_ground_tiles.clear()
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
        "Rake":
            picks.assign([E, F, LAND])
            board.units[7]["pos"] = LAND
        "Split Focus":
            picks.assign([E, F])
        "Rosette Rush":
            picks.assign([E, E])
        "Throw":
            picks.assign([E, LAND])
        "Strike and Drop":
            picks.assign([E, LAND, Vector2i(9, 7)])
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
        "Gleaming Armour":
            picks.assign([G])
        "Empty the Shell", "Pressure Front", "Defence is the Best Offense", "Thundering Taunt", "Plastic Skin", "Emergency Cells":
            picks.clear()
        "Wingover", "Banking Turn":
            picks.assign([E, LAND])
        "Peregrine Dive":
            rules.state(0)["mark"] = 5
        "Raking Pass":
            board.units[6]["pos"] = Vector2i(10, 8)
            board.units[7]["pos"] = Vector2i(11, 9)
            picks.assign([G])
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
        "Recovery Winch":
            board.units[1]["pos"] = LAND
            picks.assign([LAND])
        "Shock Mine":
            picks.assign([LAND])
        "Breach Kit":
            stage_cover(board.edge_key(E, "E"), EDGE, "W", 1, 3)
            picks.assign([E, EDGE])
        "Mortar Cup", "Siege Salvo":
            rules.arm_action(0, "Anchor", "")
            board.units[7]["pos"] = Vector2i(12, 8)
            picks.assign([Vector2i(12, 8)])
        "Flak Curtain", "Incendiary Shell", "Walking Barrage":
            rules.arm_action(0, "Anchor", "")
            picks.assign([G])
        "Rolling Thunder":
            picks.assign([P, G])
        "Sweep Beam":
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
            board.units[6]["pos"] = Vector2i(10, 9)
        "Vector Pull":
            board.units[5]["pos"] = Vector2i(11, 6)
            picks.assign([Vector2i(11, 6)])
        "Hurl Debris":
            var edge: String = board.edge_key(EDGE, "S")
            board.destructible_edges[edge] = {"level": 1, "hp": 2, "max_hp": 2, "tile": EDGE, "face": "S"}
            board.cover_edges[EDGE] = {"S": 1}
            picks.assign([EDGE, EDGE_OTHER, G])
        "Wrecking Ball":
            picks.assign([E, Vector2i(12, 8)])
    if skill in ["Hurl Aside", "Rampage"]:
        rules.enter_hyde(0)
    var label := "%s / %s" % [origin, skill]
    var ap: int = board.units[0]["ap"]
    var starting_armour: int = board.units[0]["armour"]
    rules.arm_action(0, skill, option)
    for pick in picks:
        rules.submit(pick)
    require(int(board.units[0]["ap"]) < ap and rules.ability.is_empty(), label + " did not resolve: " + str(board.status_message))
    if rules.ability != "":
        rules.cancel()
    else:
        check_cost_and_limit(skill, option, ap, label)
        check_capstone(skill, label)
        if skill == "Rake":
            require(board.units[5]["hp"] == 16 and board.units[6]["hp"] == 16 and board.units[7]["hp"] == 16,
                label + " hits all three selected adjacent tiles")
        if skill == "Raking Pass":
            require(board.units[5]["hp"] == 16 and board.units[6]["hp"] == 16 and rules.pos(0) == G,
                label + " flies over and hits both enemies")
        if skill == "Strike and Drop":
            require(board.units[5]["hp"] == 17 and rules.pos(0) == LAND and rules.pos(5) == Vector2i(9, 7),
                label + " resolves both player-selected landing tiles")
        if skill == "Pressure Front":
            require(board.units[0]["armour"] == 0 and board.units[5]["hp"] == 20 - starting_armour
                and board.units[1]["hp"] == 2, label + " spends armour and damages enemies only")
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
            passed = hp == 12 and not foe["statuses"].has("burning")
        "The Void's Gaze":
            passed = hp == 14 and rules.effects(5).get("root", false)
        "Peregrine Dive":
            passed = hp == 15
        "Wingover":
            passed = hp == 20 - int(primary["damage"]) and foe["statuses"].has("bleeding") and rules.pos(0) == LAND
        "Emergency Rebuild":
            passed = rules.drone_live(0) and rules.drones[0]["hp"] == ceili(rules.drone_max_hp(0) * 0.5) and info["mission_uses"].has(skill)
        "Overclock Link":
            if rules.knows(0, "Guardian Chassis"):
                passed = rules.barricade_at(Vector2i(8, 6), "N") and rules.barricade_at(Vector2i(8, 6), "E")
            else:
                passed = hp == 16 and board.units[6]["hp"] == 17
        "Siege Salvo":
            passed = board.units[7]["hp"] == 14 and info["heat"] == 3
        "Rolling Thunder":
            passed = hp == 16 and board.units[7]["hp"] == 16 and info["heat"] == 2 and board.voluntary_movement_locked(0)
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
            if rules.knows(0, "Adrenal Rebound"):
                require(rules.effects(0).get("barrier", 0) == 2, name + " gains reversion armour on linked-room entry")
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
    rules.arm_action(0, "Designate Target", "")
    rules.submit(E)
    rules.hit(1, 5, "Other Needle hit", 1, {"melee": true})
    require(int(rules.effects(5).get("quarry_hits", 0)) == 3 and board.units[5]["hp"] == 19,
        "another Needle neither gets the damage bonus nor spends a use")
    rules.hit(0, 5, "Test hit", 1, {"ranged": true})
    require(int(rules.effects(5).get("quarry_hits", 0)) == 2 and board.units[5]["hp"] == 15,
        "active Needle deals the bonus plus Read the Opening after the allied hit")
    rules.arm_action(1, "Designate Target", "")
    rules.submit(E)
    require(int(rules.effects(5).get("quarry_hits", 0)) == 3, "second Needle refreshes to three")
    require(rules.state(1)["mark"] == 5 and rules.state(0)["mark"] == -1, "refreshed quarry belongs to the latest Needle")
    for strike in range(3):
        rules.hit(1, 5, "Test hit", 1, {"ranged": true})
    require(not rules.effects(5).has("quarry_hits") and not rules.effects(5).has("quarry_owner") and rules.state(1)["mark"] == -1,
        "refreshed mark clears its owner when its three hits are used")

func test_revised_class_effects() -> void:
    deploy("Scythe", select_build("Scythe", 0, 31))
    stage()
    for count in range(3):
        rules.opportunity(5, E, G)
    require(board.battle_stats[0]["reactions"] == 2, "Threatening Presence caps melee reactions at two")
    board.turn_number += 1
    rules.opportunity(5, E, G)
    require(board.battle_stats[0]["reactions"] == 3, "Threatening Presence resets each round")

    deploy("Scythe", select_build("Scythe", 1, 4))
    stage()
    var aim: Array[Vector2i] = [G]
    var cone: Dictionary = rules.plan_action(0, "Venom Jet", "", aim)
    require(cone.get("tiles", []).size() == 6, "Venom Jet previews six tiles")
    rules.arm_action(0, "Venom Jet", "")
    rules.submit(G)
    require(rules.effects(5).has("poison") and rules.effects(7).has("poison"), "Venom Jet applies Venom along the cone")

    deploy("Anvil", select_build("Anvil", 0, 0))
    stage()
    board.units[6]["pos"] = EDGE
    rules.arm_action(0, "Throw", "")
    rules.submit(E)
    rules.submit(EDGE)
    require(board.units[5]["hp"] == 18 and board.units[6]["hp"] == 18 and rules.pos(5) == E,
        "Throw collision damages both enemies and stops at the blocker")
    board.units[6]["pos"] = F
    var edge: String = board.edge_key(E, "E")
    stage_cover(edge, EDGE, "W", 2, 6)
    rules.arm_action(0, "Throw", "")
    rules.submit(E)
    rules.submit(EDGE)
    require(not board.destructible_edges.has(edge) and board.units[5]["hp"] == 16,
        "Throw destroys reinforced cover and damages the thrown enemy")

    deploy("Anvil", select_build("Anvil", 0, 16))
    stage()
    board.units[5]["armour"] = 5
    board.units[5]["max_armour"] = 5
    board.units[7]["pos"] = Vector2i(11, 9)
    rules.arm_action(0, "Colossal Combo", "")
    rules.submit(E)
    require(board.units[5]["max_armour"] == 3 and board.units[5]["hp"] == 11 and rules.pos(5) == G,
        "Colossal Combo shreds before its first hit and knocks back after its third")
    stage()
    board.units[7]["pos"] = Vector2i(11, 9)
    board.units[5]["pos"] = Vector2i(10, 7)
    edge = board.edge_key(E, "E")
    stage_cover(edge, EDGE, "W", 2, 6)
    rules.arm_action(0, "Linebreaker", "")
    rules.submit(Vector2i(12, 8))
    require(rules.pos(0) == Vector2i(12, 8) and board.destructible_edges[edge]["hp"] == 1,
        "Linebreaker travels four tiles and deals five structural damage")

    deploy("Anvil", select_build("Anvil", 1, 8))
    stage()
    rules.arm_action(0, "Defence is the Best Offense", "")
    require(rules.effects(0).get("barrier") == 2 and rules.impact(0, 5, 4, 0, {"melee": true})["hp_damage"] == 5,
        "Defence is the Best Offense grants temporary armour and bonus damage")
    require(rules.impact(5, 0, 6, 0, {"ranged": true})["cover"] == 1 and board.units[0]["max_armour"] == 4,
        "Mental Fortress adds one armour and low cover")
    board.finish_enemy_phase()
    require(not rules.effects(0).has("attack_boost") and not rules.effects(0).has("barrier"),
        "Defence is the Best Offense expires on the next player turn")
    var starter := CLASSES.default_build()
    starter["origin"] = 1
    deploy("Anvil", starter)
    stage()
    board.units[1]["pos"] = Vector2i(4, 8)
    rules.arm_action(0, "Lend Armour", "")
    rules.submit(Vector2i(4, 8))
    require(rules.effects(1).get("mantle") == 3 and board.units[0]["armour"] == 0,
        "Living Mantle unlocks the four-tile Lend Armour at Level 1")

    deploy("Needle", select_build("Needle", 0, 4))
    stage()
    rules.arm_action(0, "Corneal Lance", "")
    rules.submit(E)
    require(board.units[5]["statuses"].get("blinded") == 3, "Rangefinder makes Corneal Lance blind for three turns")
    for remaining in [2, 1, 0]:
        board.expire_blinded_for_team("enemy")
        require(board.units[5]["statuses"].get("blinded", 0) == remaining, "Blindness counts down each enemy phase")

    deploy("Needle", select_build("Needle", 0, 0))
    stage()
    stage_cover(board.edge_key(E, "E"), EDGE, "W", 2, 6)
    rules.arm_action(0, "Sweep Beam", "")
    rules.submit(EDGE)
    require(board.destructible_edges.is_empty(), "Rangefinder destroys cover in Sweep Beam's tiles")

    deploy("Needle", select_build("Needle", 1, 0))
    stage()
    require(not rules.effects(0).has("high_perch"), "High Perch is inactive on flat ground")
    board.high_ground_tiles.append(P)
    rules.start_player_phase()
    rules.hit(0, 5, "Talons", 4, {"melee": true, "review_basic": true})
    rules.hit(0, 5, "Talons", 4, {"melee": true, "review_basic": true})
    require(board.units[5]["hp"] == 10 and not rules.effects(0).has("high_perch"),
        "High Perch grants two damage to the first attack only")

func test_iskra_rework() -> void:
    test_assault_drone()
    test_guardian_drone()
    test_artillery()

func issue_action(skill: String, targets: Array[Vector2i], mode: String = "") -> void:
    rules.arm_action(0, skill, mode)
    for tile in targets:
        if rules.ability.is_empty():
            break
        rules.submit(tile)

func stage_drone_watch(watcher: int, tile: Vector2i, damage: int = 4) -> void:
    var enemy: Dictionary = board.units[watcher]
    enemy["ap"] = 2
    enemy["rounds"] = 2
    enemy["magazine_capacity"] = 3
    enemy["basic_melee"] = false
    enemy["kind"] = "ranged"
    enemy["range"] = 8
    enemy["damage"] = damage
    enemy["reaction_type"] = "overwatch"
    enemy["reaction_available"] = true
    enemy["overwatch_tiles"] = {tile: true}

func test_assault_drone() -> void:
    deploy("Iskra", select_build("Iskra", 0, 0))
    stage()
    var origin := Vector2i(8, 6)
    var flank := Vector2i(10, 7)
    stage_drone_watch(5, Vector2i(12, 8))
    issue_action("Pincer Run", [flank, E, F])
    require(rules.drones[0]["pos"] == flank and board.units[5]["hp"] == 17 and board.units[6]["hp"] == 18,
        "Assault Pincer Run repositions and chains to the selected second target")
    require(not board.units[5]["reaction_available"] and board.units[0]["ap"] == 2
        and not rules.unavailable(0, "Scout Run", "").is_empty(), "Pincer cancels flanked Overwatch and spends one AP and one order")
    board.finish_enemy_phase()
    require(not rules.unavailable(0, "Pincer Run", "").is_empty(), "Pincer Run retains its two-turn cooldown")
    board.units[0]["pos"] = Vector2i(3, 6)
    var edge: String = board.edge_key(Vector2i(11, 7), "E")
    stage_cover(edge, Vector2i(12, 7), "W", 1, 3)
    issue_action("Breach Kit", [Vector2i(11, 7), Vector2i(12, 7)], "Drone")
    require(not board.destructible_edges.has(edge) and rules.once(0, "Drone order", false),
        "Remote Breach works far from the operator and leaves the order available")
    issue_action("Scout Run", [flank, E])
    require(board.units[5]["hp"] == 15, "Scout Run fires at reach four without an operator range restriction")
    rules.drones[0]["hp"] = 3
    board.room_cleared = true
    board.next_mission_room()
    require(rules.drone_live(0) and rules.drones[0]["hp"] == 3, "Surviving Assault drone carries wounds into room 2")
    stage()
    rules.drones[0]["pos"] = origin
    stage_drone_watch(5, LAND, 12)
    var scout_picks: Array[Vector2i] = [LAND, E]
    var plan: Dictionary = rules.plan_action(0, "Scout Run", "", scout_picks)
    require(rules.expected_drone_overwatch(0, plan["drone_path"]) == 1, "Drone route preview reports the lethal Overwatch shot")
    issue_action("Scout Run", [LAND, E])
    require(not rules.drone_live(0) and board.units[5]["hp"] == 20 and board.units[5]["rounds"] == 1,
        "Overwatch destroys the drone before its Arc Bolt, spending watcher ammo")
    board.room_cleared = true
    board.next_mission_room()
    require(not rules.drone_live(0), "Assault drone loss carries into room 3")
    issue_action("Emergency Rebuild", [])
    require(rules.drone_live(0) and rules.drones[0]["hp"] == 3 and not rules.unavailable(0, "Scout Run", "").is_empty(),
        "Emergency Rebuild restores half of upgraded HP and defers orders to next turn")

func test_guardian_drone() -> void:
    deploy("Iskra", select_build("Iskra", 0, 17))
    stage()
    var start := Vector2i(8, 6)
    var protected_tile := Vector2i(7, 6)
    board.units[1]["pos"] = protected_tile
    issue_action("Shield Run", [start, Vector2i(8, 5), protected_tile])
    require(rules.effects(1).get("barrier", 0) == 2 and rules.barricade_at(protected_tile, "N"),
        "Guardian Hardpoint protects the selected ally behind Shield Run")
    board.units[5]["pos"] = Vector2i(7, 4)
    stage_drone_watch(5, protected_tile)
    require(board.attack_preview(5, 1)["reason"] == "Shield Run blocks this shot.", "Guardian cover blocks the protected angle")
    board.finish_enemy_phase()
    require(not rules.barricade_at(protected_tile, "N"), "Guardian cover expires on the next player turn")
    rules.state(0)["ready"]["Shield Run"] = 99
    issue_action("Overclock Link", [start, Vector2i(8, 5), Vector2i(9, 6), protected_tile, start])
    require(rules.barricade_at(start, "N") and rules.barricade_at(start, "E") and rules.state(0)["ready"]["Shield Run"] == board.turn_number + 2,
        "Guardian Overclock bypasses cooldown, projects distinct cover lines and resets cooldown")
    rules.damage_drone(0, 20)
    require(not rules.barricade_at(start, "N"), "Destroyed Guardian loses its cover immediately")
    for room in [1, 2]:
        board.room_cleared = true
        board.next_mission_room()
        require(board.mission_stage == room and not rules.drone_live(0), "Guardian loss persists across both linked rooms")

func test_artillery() -> void:
    deploy("Iskra", select_build("Iskra", 1, 0))
    stage()
    var centre := Vector2i(12, 8)
    var far := Vector2i(13, 8)
    var edge: String = board.edge_key(centre, "E")
    stage_cover(edge, far, "W", 2, 5)
    board.units[5]["pos"] = centre
    board.units[6]["pos"] = far
    board.units[0]["rounds"] = 0
    require(not rules.unavailable(0, "Breach Shell", "").is_empty(), "Heavy fire requires Anchor")
    issue_action("Anchor", [])
    var movement: Dictionary = board.reachable(P, 4, int(board.units[0]["id"]))
    require(board.voluntary_movement_locked(0) and movement.size() == 1, "Anchor locks out normal movement")
    issue_action("Breach Shell", [centre, far])
    require(not board.destructible_edges.has(edge) and board.units[5]["hp"] == 18 and board.units[6]["hp"] == 18,
        "Breach Shell destroys the edge and hits units on both sides")
    require(board.perform_attack(0, 5) and board.units[0]["rounds"] == 0 and board.units[5]["hp"] == 14,
        "Breach Follow-Up fires a legal basic shot even with zero charges")
    board.finish_enemy_phase()
    require(not board.voluntary_movement_locked(0) and rules.state(0)["heat"] == 1, "Artillery unanchors and cools at turn start")

    stage()
    board.units[0]["rounds"] = 1
    rules.state(0)["heat"] = 4
    issue_action("Anchor", [])
    require(not rules.unavailable(0, "Flak Curtain", "").is_empty() and board.perform_attack(0, 5)
        and rules.state(0)["heat"] == 4, "Maximum Heat bars heavy fire but leaves charge-fed basic shot available")
    stage()
    rules.state(0)["heat"] = 0
    var flak_aim: Array[Vector2i] = [centre]
    var flak: Dictionary = rules.plan_action(0, "Flak Curtain", "", flak_aim)
    require(flak["tiles"].size() == 18, "Flak Curtain previews six rows of three")
    var wall := Vector2i(11, 8)
    board.walls.append(wall)
    flak = rules.plan_action(0, "Flak Curtain", "", flak_aim)
    require(not far in flak["tiles"] and not wall in flak["tiles"], "Walls clip the flak lane")
    board.walls.clear()
    issue_action("Flak Curtain", [centre])
    var before: int = board.units[5]["hp"]
    require(before == 20, "Flak does not detonate merely because enemies occupy the lane")
    board.units[5]["pos"] = Vector2i(12, 6)
    board.apply_unit_position(5, Vector2i(12, 7))
    require(board.units[5]["hp"] == before - 3, "Flak detonates when an enemy enters")
    board.apply_unit_position(6, Vector2i(10, 7))
    require(rules.zones.is_empty() and board.units[6]["hp"] == 20, "Flak only fires once")

    deploy("Iskra", select_build("Iskra", 1, 31))
    stage()
    issue_action("Anchor", [])
    issue_action("Incendiary Shell", [G])
    require(board.hazards.has(EDGE) and board.hazards.has(G) and board.hazards.has(centre)
        and board.units[7]["hp"] == 18 and board.units[7]["statuses"].has("burning"), "Incendiary Shell ignites all three tiles, including an occupant")
    board.units[0]["armour"] = 0
    var watched: Dictionary = rules.impact(5, 0, 4, 0, {"ranged": true, "overwatch": true})
    rules.consume_hit(5, 0, watched)
    require(watched["hp_damage"] == 3 and rules.impact(5, 0, 4, 0, {"ranged": true, "overwatch": true})["hp_damage"] == 4,
        "Shock Mounts only reduces the first Overwatch hit in a round")

func test_glaz_and_alkhimik_effects() -> void:
    test_glaz_control()
    test_alkhimik_forms()

func test_glaz_control() -> void:
    deploy("Glaz", select_build("Glaz", 0, 2))
    stage()
    stage_drone_watch(5, P)
    rules.state(0)["ready"].clear()
    issue_action("Aphasia", [E])
    require(not board.apply_healing(5, 1, 3, "Test heal"), "Aphasia blocks healing")
    require(board.perform_attack(5, 0) and board.perform_attack(5, 0), "Aphasia still permits repeated basic attacks")

    stage()
    board.units[5]["basic_melee"] = true
    rules.hit(0, 5, "Synaptic Prick", 2, {"ranged": true, "review_basic": true})
    require(not rules.reaction_disabled(5), "Surface Thought waits for the player's choice")
    issue_action("Suppress Reaction", [E])
    require(rules.reaction_disabled(5) and rules.effects(5)["reaction_cancelled_by"][0] == board.turn_number,
        "Surface Thought removes and records a melee departure reaction")

    deploy("Glaz", select_build("Glaz", 0, 4))
    stage()
    board.units[5]["basic_melee"] = true
    issue_action("Panic Spike", [E])
    issue_action("Feedback Spike", [E])
    require(board.units[5]["hp"] == 14, "Feedback Spike gains damage from this Glaz's available reaction cancellation")
    deploy("Glaz", select_build("Glaz", 0, 4))
    stage()
    board.units[5]["kind"] = "ranged"
    board.units[5]["basic_melee"] = false
    issue_action("Panic Spike", [E])
    issue_action("Feedback Spike", [E])
    require(board.units[5]["hp"] == 16, "Feedback Spike stays at base damage when no reaction was available")

    deploy("Glaz", select_build("Glaz", 1, 0))
    stage()
    issue_action("Distort Aim", [E])
    board.side_to_play = "enemy"
    var hp: int = board.units[0]["hp"]
    rules.hit(5, 0, "Test attack", 4, {"ranged": true})
    require(board.units[0]["hp"] == hp - 2, "Distort Aim reduces the next direct hit")
    board.finish_enemy_phase()
    require(rules.free_step(0) == 1, "Residual Distortion survives the phase refresh")
    issue_action("Follow-up Step", [LAND])
    require(rules.pos(0) == LAND and board.units[0]["ap"] == 3, "Residual Distortion uses normal targeting without spending AP")

    stage()
    board.units[5]["basic_melee"] = true
    var finish := Vector2i(8, 6)
    board.units[6]["pos"] = Vector2i(8, 4)
    stage_drone_watch(6, finish)
    var melee_reactions: int = board.battle_stats[5]["reactions"]
    var ranged_reactions: int = board.battle_stats[6]["reactions"]
    issue_action("Safe Passage", [P, finish])
    require(rules.pos(0) == finish and board.battle_stats[5]["reactions"] == melee_reactions
        and board.battle_stats[6]["reactions"] == ranged_reactions + 1, "Safe Passage avoids departure strikes and still draws Overwatch")

    deploy("Glaz", select_build("Glaz", 1, 2))
    stage()
    board.units[5]["pos"] = Vector2i(11, 6)
    rules.state(0)["ready"].clear()
    require(rules.knows(0, "Lateral Slip"), "Telekinesis alternate branch remains selectable")
    deploy("Glaz", select_build("Glaz", 1, 0))
    stage()
    var initial := Vector2i(11, 6)
    board.units[5]["pos"] = initial
    issue_action("Vector Pull", [initial], "1 Tile")
    require(rules.pos(5) == Vector2i(10, 7), "Vector Pull can stop after one tile")

func test_alkhimik_forms() -> void:
    var build := select_build("Alkhimik", 0, 4)
    build["form"] = "Skunk"
    deploy("Alkhimik", build)
    stage()
    require(board.units[0]["damage"] == 2 and board.units[0]["range"] == 4, "Skunk uses its listed base damage and reach")
    issue_action("Musk Trail", [G])
    require(board.units[7]["hp"] == 20, "Musk Trail waits for enemy movement or phase start")
    rules.start_enemy_phase()
    require(board.units[7]["hp"] == 19 and board.units[7]["statuses"].has("blinded"), "Musk Trail damages and blinds an enemy starting inside")
    board.apply_unit_position(7, Vector2i(11, 7))
    board.apply_unit_position(7, G)
    require(board.units[7]["hp"] == 19, "Musk Trail affects each enemy once per cast")

    stage()
    rules.shift_form(0, "Jellyfish")
    issue_action("Passing Trait", [A])
    var shoved: int = rules.force_move(5, 1, Vector2i.LEFT, 2)
    require(shoved == 1 and rules.pos(1) == Vector2i(6, 8), "Jellyfish Passing Trait shortens the first shove by one tile")

    deploy("Alkhimik", select_build("Alkhimik", 1, 31))
    stage()
    rules.enter_hyde(0)
    board.units[6]["pos"] = EDGE
    issue_action("Hurl Aside", [E])
    require(board.units[5]["hp"] == 16 and board.units[6]["hp"] == 19 and rules.pos(5) == E,
        "Hurl Aside resolves collision damage to both units")

    stage()
    board.apply_status(0, "burning")
    issue_action("Reserve Dose", [P])
    rules.hit(0, 5, "Special", 1, {"melee": true})
    require(not board.units[0]["statuses"].has("burning") and rules.effects(0).has("reserve_dose"),
        "Reserve Dose cleanses Burn and waits for a basic attack in Hyde")
    var hp: int = board.units[5]["hp"]
    rules.hit(0, 5, "Rending Strike", 4, {"melee": true, "review_basic": true})
    require(board.units[5]["hp"] == hp - 5 and not rules.effects(0).has("reserve_dose"),
        "The next basic attack receives the Reserve Dose bonus once")

func test_class_room_clear() -> void:
    deploy("Glaz", select_build("Glaz", 1, 0))
    stage()
    board.side_to_play = "enemy"
    board.start_unit_movement(5, EDGE)
    board.advance_movement_task()
    require(rules.pos(5) == EDGE and board.movement_task.is_empty(), "Campaign enemy walking completes without player class state")
    board.side_to_play = "player"
    for index in range(6, board.units.size()):
        board.units[index]["hp"] = 0
    board.units[5]["hp"] = 1
    issue_action("Compression", [EDGE])
    require(board.room_cleared, "A class ability that defeats the final enemy clears the room immediately")

func test_full_cover() -> void:
    deploy("Needle", select_build("Needle", 0, 0))
    stage()
    var edge: String = board.edge_key(E, "W")
    stage_cover(edge, E, "W", 2, 5)
    var rounds: int = board.units[0]["rounds"]
    require(board.attack_preview(0, 5)["reason"] == "Full cover blocks this shot.", "Protected-side basic attack is blocked in preview")
    var shot := InputEventMouseButton.new()
    shot.button_index = MOUSE_BUTTON_LEFT
    shot.pressed = true
    shot.position = board.battlefield.ground * board.board_center(E)
    board._unhandled_input(shot)
    require(board.units[0]["ap"] == 2 and board.units[0]["rounds"] == rounds - 1
        and board.units[5]["hp"] == 20 and board.destructible_edges[edge]["hp"] == 5,
        "Clicking a protected target spends AP and ammo without damaging the unit or cover")
    require(board.attack_preview_from(0, 5, F)["valid"], "A flank has a legal shot on the same target")
    issue_action("Needle Beam", [E])
    require(board.units[0]["ap"] == 0 and board.units[5]["hp"] == 20, "Blocked Needle Beam spends its AP and armour piercing grants no bypass")
    rules.cancel()
    stage_drone_watch(5, P)
    var route: Array[Vector2i] = [P]
    var protected_hp: int = board.units[0]["hp"]
    require(board.expected_overwatch_shots(0, route) == 1 and board.trigger_reactions_to_step(0)
        and board.units[0]["hp"] == protected_hp,
        "Overwatch fires into full cover without damaging the operative")
    require(board.units[5]["rounds"] == 1 and board.units[5]["ap"] == 1, "Blocked Overwatch spends AP and ammo")
    rules.effects(5)["taunted_by"] = 0
    require(board.attack_preview(5, 1)["valid"], "Taunt leaves other targets available when full cover blocks the taunter")
    rules.effects(5).erase("taunted_by")
    require(board.attack_preview(0, 5, 1, 1, false)["valid"], "An explicit legacy cover-piercing attack opens the shot")
    board.damage_cover_edge(edge, 5, 0, "Test breach")
    require(board.attack_preview(0, 5)["valid"] and board.expected_overwatch_shots(0, route) == 1,
        "Breaking the edge opens the shot and the existing Overwatch lane")
    stage_cover(edge, E, "W", 1, 2)
    var half: Dictionary = board.attack_preview(0, 5)
    require(half["valid"] and half["cover"] == 1, "Half cover still permits fire and reduces damage")

    deploy("Scythe", select_build("Scythe", 0, 0))
    stage()
    stage_cover(edge, E, "W", 2, 5)
    require(board.basic_melee_plan(0, 5, false)["valid"], "Full cover still permits adjacent melee")

    deploy("Iskra", select_build("Iskra", 0, 0))
    stage()
    var drone: Vector2i = rules.drones[0]["pos"]
    var target := Vector2i(8, 5)
    board.units[5]["pos"] = target
    stage_cover(board.edge_key(drone, "N"), target, "S", 2, 5)
    var drone_picks: Array[Vector2i] = [drone, target]
    require(rules.plan_action(0, "Scout Run", "", drone_picks).get("warning", "") == "Full cover blocks this shot.",
        "Drone Arc Bolt warns that the target is protected")
    issue_action("Scout Run", [drone, target])
    require(board.units[0]["ap"] < 3 and board.units[5]["hp"] == 20, "Drone Arc Bolt spends the order without harming the target")
    stage_drone_watch(5, drone)
    var drone_hp: int = rules.drones[0]["hp"]
    require(rules.expected_drone_overwatch(0, [drone]) == 1 and rules.move_drone(0, [drone])
        and rules.drones[0]["hp"] == drone_hp and board.units[5]["rounds"] == 1 and board.units[5]["ap"] == 1,
        "Blocked Overwatch against the drone spends AP and ammo without harming it")

func stage_cover(edge: String, tile: Vector2i, face: String, level: int, hp: int) -> void:
    board.destructible_edges[edge] = {"level": level, "hp": hp, "max_hp": hp, "tile": tile, "face": face}
    board.cover_edges[tile] = {face: level}

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
            else:
                rules.hit(0, 5, skill, 2, melee)
            foe["basic_melee"] = true
            rules.opportunity(0, P, A)
            ok = board.battle_stats[5]["reactions"] == 0 and not fx.has("slipping_foe") and not fx.has("silent_landing_primed")
            rules.opportunity(0, P, A)
            ok = ok and board.battle_stats[5]["reactions"] == 1
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
            board.apply_status(0, "burning")
            board.apply_status(0, "irradiated")
            ok = primary["statuses"].size() == 2
            rules.finish_enemy_phase()
            ok = ok and primary["statuses"].is_empty() and info["room_uses"].has(skill)
            board.apply_status(0, "burning")
            rules.finish_enemy_phase()
            ok = ok and primary["statuses"].has("burning")
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
        "Shining Knight":
            info["heat"] = 3
            primary["armour"] = 0
            ok = rules.impact(5, 0, 3, 0, ranged)["hp_damage"] == 2
        "Long Mantle":
            board.units[1]["pos"] = Vector2i(3, 8)
            var pick: Array[Vector2i] = [Vector2i(3, 8)]
            ok = not rules.plan_action(0, "Lend Armour", "", pick).has("error")
        "Returning Mantle", "Returning Defence":
            rules.arm_action(0, "Lend Armour", "")
            rules.submit(A)
            if skill == "Returning Mantle":
                board.units[1]["armour"] = 0
                ok = true
                for shot in [Vector2i(6, 8), Vector2i(9, 8), Vector2i(7, 5), Vector2i(7, 11)]:
                    var attack: Dictionary = rules.impact(5, 1, 5, 0, {"ranged": true, "source": shot})
                    ok = ok and attack["cover"] == 1 and attack["hp_damage"] == 1
                ok = ok and rules.impact(5, 1, 5, 2, ranged)["cover"] == 2
            else:
                rules.start_player_phase()
                ok = int(fx.get("barrier", 0)) == 1 and not rules.effects(1).has("mantle")
        "Long Focus", "Long Lever":
            var without: Dictionary = primary["class_build"].duplicate(true)
            var level := 2 if skill == "Long Focus" else 6
            without["choices"][level] = 1 - int(without["choices"][level])
            var compare := CLASSES.base_attack(primary["kit_name"], without, info["form"],
                primary["ranged_damage"], primary["ranged_range"])
            ok = int(primary["range"]) == int(compare["range"]) + (2 if skill == "Long Focus" else 1)
        "Short-Sighted":
            ok = rules.impact(0, 5, 3, 0, ranged)["hp_damage"] == 5
            foe["pos"] = Vector2i(13, 8)
            ok = ok and rules.impact(0, 5, 3, 0, ranged)["hp_damage"] == 4
        "Steady Gaze":
            foe["pos"] = Vector2i(13, 8)
            ok = rules.impact(0, 5, 2, 0, ranged)["hp_damage"] == 5 \
                and rules.impact(0, 5, 2, 0, {"ranged": true})["hp_damage"] == 3
        "Fiery Gaze":
            rules.hit(0, 5, "Corneal Lance", 2, {"ranged": true})
            ok = not foe["statuses"].has("burning")
            rules.hit(0, 5, "Sightline", 2, ranged)
            ok = ok and foe["statuses"].has("burning")
        "Spread Your Wings":
            var pick: Array[Vector2i] = [Vector2i(14, 8)]
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
            rules.arm_action(0, "Pincer Run", "")
            rules.submit(Vector2i(8, 6))
            rules.submit(E)
            rules.submit(F)
            ok = foe["hp"] == 17 and board.units[6]["hp"] == 18
        "Guardian Chassis":
            rules.arm_action(0, "Shield Run", "")
            rules.submit(Vector2i(8, 6))
            rules.submit(Vector2i(8, 5))
            ok = rules.barricade_at(Vector2i(8, 6), "N") and rules.drones[0]["armour"] == 2
        "Hardpoint Upgrade":
            ok = rules.target_steps(0, "Pincer Run", "") == 3
        "Hardened Frame":
            ok = rules.drones[0]["hp"] == 6 and rules.drone_max_hp(0) == 6
        "Tandem Drive":
            rules.finished_standard_move(0, 1)
            rules.arm_action(0, "Tandem Move", "")
            rules.submit(LAND)
            ok = rules.drones[0]["pos"] == LAND and rules.once(0, "Drone order", false)
        "Cooling Fins", "Feed Mechanism":
            info["heat"] = 4
            primary["rounds"] = 0
            rules.arm_action(0, "Vent", "")
            ok = info["heat"] == 1 if skill == "Cooling Fins" else primary["rounds"] == 1
        "Quick-Lock":
            info["moved"] = 1
            rules.finished_standard_move(0, 1)
            rules.arm_action(0, "Anchor", "")
            ok = fx.get("anchored", false) and info["room_uses"].has("Quick-Lock")
        "Hot Breech":
            info["heat"] = 2
            rules.arm_action(0, "Anchor", "")
            rules.arm_action(0, "Walking Barrage", "")
            rules.submit(G)
            ok = foe["hp"] == 20 and board.units[7]["hp"] == 15 and info["heat"] == 4
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
            ok = primary["range"] == 5
        "Bedside Cover":
            rules.finished_standard_move(0, 1)
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
            stage_drone_watch(5, P)
            rules.hit(0, 5, "Synaptic Prick", 2, ranged)
            issue_action("Suppress Reaction", [E])
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
            issue_action("Impulse Push", [E])
            ok = foe["pos"] == (Vector2i(10, 8) if skill == "Leverage" else Vector2i(11, 8))
        "Set the Angle":
            rules.force_move(0, 5, Vector2i(1, 0), 1)
            ok = rules.impact(0, 5, 2, 0, ranged)["hp_damage"] == 3
    require(ok, "%s / %s passive did not produce its expected result" % [origin, skill])
