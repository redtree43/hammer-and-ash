extends RefCounted

enum Tier { LOW, MID, HIGH, MINI_BOSS, BOSS }
const TIER_NAMES := ["Low", "Mid", "High", "Mini-boss", "Boss"]
const TIER_XP := [1, 2, 3, 5, 8]

static func tier(unit: Dictionary) -> int:
    if unit.has("tier"):
        return unit["tier"]
    # Legacy encounter kits predate the authored roster.
    match unit.get("kind", ""):
        "horde": return Tier.LOW
        "boss": return Tier.BOSS
    return Tier.MID

static func kill_xp(unit: Dictionary) -> int:
    return 0 if unit.get("summoned", false) else TIER_XP[tier(unit)]

# Prototype tuning. Each operation mixes an anchor, escorts and specialist support.
const ENCOUNTERS := {
    "cordon": [
        ["Rifleman", "Rifleman", "Collectivist Drone", "Assault Operative", "Marksman", "Collectivist Drone"],
        ["Rifleman", "Rifleman", "Captain", "Grenadier", "Pravda Man", "Hammer"]],
    "foundry": [
        ["Collectivist Drone", "Collectivist Drone", "Man of Steel", "Matryoshka", "Collectivist Drone", "Rifleman"],
        ["Combine", "Nevalyashka", "Collectivist Drone", "Marksman", "Pravda Man", "Red Star"]],
    "choir": [
        ["Kulak", "Kulak", "Kulak", "Clergy", "Kapitalist", "Rifleman"],
        ["Noble", "Individualist", "Kulak", "Kulak", "Clergy", "Sickle"]],
    "vanguard": [
        ["Proletariat", "Rifleman", "Siberian", "Collectivist Drone"],
        ["New Soviet Man", "New Soviet Woman", "Kulak", "Rifleman"],
        ["Vanguard", "Grenadier", "Matryoshka", "Assault Operative", "Rifleman"]]
}
const POSTS := [Vector2i(14, 3), Vector2i(16, 6), Vector2i(14, 8), Vector2i(19, 4), Vector2i(17, 9), Vector2i(14, 12)]
const COLORS := {"KGB": Color("#dbab65"), "Robots": Color("#83c7d4"), "Abominations": Color("#ce91b0"), "Supers": Color("#f0816c")}

static func profile(enemy_tier: int, family: String, hp: int, armour: int, damage: int, reach: int, move: int,
        weapon: String, ai: String, sprite: String, signature: String, hint: String) -> Dictionary:
    var kind := ai if ai in ["support", "horde"] else "ranged"
    return {"tier": enemy_tier, "family": family, "team": "enemy", "kind": kind, "hp": hp, "max_hp": hp,
        "armour": armour, "max_armour": armour, "damage": damage, "range": reach, "move": move,
        "ap": 2, "max_ap": 2, "basic_attack": weapon, "ai_profile": ai, "sprite": sprite,
        "trait": signature, "hint": hint, "ai_role": kind, "ai_traits": {}}

static var profiles := {
    "Rifleman": profile(Tier.LOW, "KGB", 6, 1, 2, 6, 4, "Service rifle", "balanced", "rifle", "line",
        "Uses cover and overlapping fire. Break sightlines."),
    "Assault Operative": profile(Tier.LOW, "KGB", 6, 1, 3, 3, 5, "Breach shotgun", "aggressive", "bodyguard", "close",
        "Hits harder at adjacent range. Keep a gap."),
    "Marksman": profile(Tier.LOW, "KGB", 5, 0, 4, 9, 3, "Long rifle", "defensive", "veteran", "sniper",
        "Loses 2 damage within three tiles. Close under cover."),
    "Grenadier": profile(Tier.LOW, "KGB", 6, 1, 2, 5, 4, "Blast grenade", "balanced", "bodyguard", "blast",
        "Splash hits everyone one square around impact for 1. Spread out."),
    "Captain": profile(Tier.MID, "KGB", 8, 2, 3, 6, 4, "Officer rifle", "balanced", "orlov", "command",
        "Nearby allies gain 1 attack damage within three tiles. Separate the formation."),
    "Pravda Man": profile(Tier.MID, "KGB", 6, 1, 1, 4, 4, "Broadcast pistol", "support", "biotechnician", "broadcast",
        "Inspires a nearby ally for +1 on its next attack. Isolate the broadcaster."),
    "Collectivist Drone": profile(Tier.LOW, "Robots", 3, 1, 1, 1, 5, "Contact prod", "horde", "drone", "swarm",
        "Cheap melee screen. Use area attacks on clustered drones."),
    "Man of Steel": profile(Tier.MID, "Robots", 8, 5, 3, 5, 2, "Foundry cannon", "defensive", "steel", "anchor",
        "Slow gun platform with thick armour. Concentrate damage before refresh."),
    "Matryoshka": profile(Tier.HIGH, "Robots", 6, 2, 2, 4, 3, "Shell gun", "balanced", "doll", "nest",
        "Breaking its armour or killing it releases one drone. Budget a follow-up."),
    "Nevalyashka": profile(Tier.HIGH, "Robots", 6, 2, 2, 1, 4, "Pendulum ram", "horde", "tumbler", "ballast",
        "Weighted base resists ordinary pushes. Kite or focus fire."),
    "Combine": profile(Tier.HIGH, "Robots", 8, 3, 3, 1, 3, "Harvester reel", "horde", "combine", "blast",
        "Reel clips adjacent units around its victim. Leave space."),
    "Kulak": profile(Tier.LOW, "Abominations", 3, 0, 2, 1, 5, "Grafting claws", "horde", "hound", "swarm",
        "Fast unarmoured pack fighter. Thin the pack with area damage."),
    "Kapitalist": profile(Tier.MID, "Abominations", 7, 0, 2, 1, 4, "Blood dividend", "horde", "Arachnid", "leech",
        "Recovers 2 HP when its attack draws blood. Protect wounded allies."),
    "Noble": profile(Tier.HIGH, "Abominations", 6, 0, 2, 5, 4, "Barbed quill", "defensive", "Blink", "bleeding",
        "Quills cause Bleeding. Break line of sight."),
    "Clergy": profile(Tier.MID, "Abominations", 6, 0, 1, 4, 4, "Choir shriek", "support", "Blink", "choir",
        "Choir of Flesh restores 3 HP to a nearby ally of any family. Cut it off from the pack."),
    "Individualist": profile(Tier.HIGH, "Abominations", 7, 0, 2, 4, 5, "Solitary howl", "aggressive", "Wolverine", "alone",
        "Deals 2 extra damage beyond three tiles from allies. Push it toward its pack."),
    "Hammer": profile(Tier.MID, "Supers", 10, 2, 4, 1, 3, "Forge hammer", "horde", "Anvil", "push",
        "Knocks its victim back. Avoid fighting beside walls and hazards."),
    "Sickle": profile(Tier.MID, "Supers", 7, 1, 2, 6, 5, "Returning sickle", "aggressive", "Arachnid", "bleeding",
        "Ranged blade inflicts Bleeding. Deny its firing lane."),
    "Proletariat": profile(Tier.HIGH, "Supers", 9, 2, 2, 5, 4, "Sickle throw", "aggressive", "elite", "combo",
        "Throws at range. Adjacent hammer strikes gain 2 damage and push."),
    "Red Star": profile(Tier.MID, "Supers", 7, 1, 3, 6, 4, "Corona bolt", "balanced", "Blink", "burning",
        "Energy bolts inflict Burning. Break sightlines."),
    "Siberian": profile(Tier.HIGH, "Supers", 9, 1, 2, 4, 4, "Winter pulse", "balanced", "Anvil", "shocked",
        "Cold shock reduces next AP refresh. Avoid exposing a key operative."),
    "New Soviet Man": profile(Tier.HIGH, "Supers", 10, 2, 3, 1, 5, "Exemplar fist", "horde", "Wolverine", "formation",
        "Gains 1 damage near an ally. Displace his escort."),
    "New Soviet Woman": profile(Tier.HIGH, "Supers", 8, 2, 2, 5, 4, "Resonance wave", "balanced", "commander", "command",
        "Amplifies nearby allied attacks by 1. Break the formation."),
    "Vanguard": profile(Tier.MID, "Supers", 7, 1, 3, 1, 6, "Vanguard thrust", "horde", "elite", "push",
        "Fast shock trooper. Guard isolated operatives and stay clear of walls.")
}

static func create(label: String, pos: Vector2i) -> Dictionary:
    var unit: Dictionary = profiles[label].duplicate(true)
    unit.merge({"name": label, "pos": pos, "id": -1, "letter": label.left(1)})
    return unit
