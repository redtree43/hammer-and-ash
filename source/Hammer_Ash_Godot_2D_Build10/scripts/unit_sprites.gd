extends RefCounted
## Original 13 x 12 pixel sprites. Each dot is transparent.
## s/m/h are the shadow, midtone and highlight for each uniform or body.

const SPRITES: Dictionary = {
    "Scythe": [
        "....###......",
        "...#hhm#.....",
        "...#hva#.....",
        "....#ss#.....",
        "..##mmm##.##.",
        ".#hhmssms#ah#",
        ".#msmmsh#mha#",
        ".#s#hmm##a#..",
        "...#smmm#....",
        "..#mm#sm#....",
        ".#sm#.#mm#...",
        ".###...###...",
    ],
    "Anvil": [
        "....#####....",
        "...#hhmms#...",
        "...#hvvms#...",
        "..##mmmms##..",
        ".#hhmssmshh#.",
        "#hhmhhhmshms#",
        "#hmhvvvhm#ms#",
        "#hmhmmmhms#s#",
        ".#mmsms##s##.",
        "..#mm#.#sm#..",
        "..#ms#.#ms#..",
        ".#####.#####.",
    ],
    "Needle": [
        "....####.....",
        "...#hhms#....",
        "...#hvat###..",
        "....#smm#####",
        "..##sh#vmmm#.",
        ".#ssmh##s##..",
        ".#smmh#s#....",
        "..#mmss#.....",
        "..#mssm#.....",
        ".#mm##mm#....",
        ".#ms#.#ms#...",
        ".####.####...",
    ],
    "Iskra": [
        "..##.#####...",
        ".#aa#hhmms#..",
        ".#am#hvavs#..",
        ".#mm##tss#...",
        ".#m#hmas#..#.",
        ".#m#hmmss##a#",
        ".#s##mssh#av#",
        "..#.#mmsm#h#.",
        "...#shmm###..",
        "...#mm#sm#...",
        "..#ms#.#ms#..",
        "..####.####..",
    ],
    "Alkhimik": [
        "....#####....",
        "...#hhhms#...",
        "...#tvvts#...",
        "...#hmhss#...",
        "..##mhmh####.",
        ".#hmhmhms#va#",
        ".#mhhvhhm#va#",
        ".#smhvmhm#s#.",
        "..#mmhmmm##..",
        "...#ssmss#...",
        "...#hs#hs#...",
        "..####.####..",
    ],
    "hound": [
        ".............",
        ".............",
        ".........#...",
        "........#m#..",
        ".#.....#smm#.",
        "#m#...#hmav##",
        ".#m###mmhhss#",
        "..#hhmmms###.",
        "..#hssmms#...",
        "...#ms#ms#...",
        "..#ss#.#s#...",
        "...###.###...",
    ],
    "rifle": [
        "....####.....",
        "...#hhmm#....",
        "...#mmms#....",
        "....#tts#....",
        "..##mmmm#....",
        ".#hmmssm#####",
        ".#msmhm#vms#.",
        ".#smms##s##..",
        "..##msms#....",
        "...#mmss#....",
        "..#ms##ms#...",
        "..####.###...",
    ],
    "veteran": [
        "....#####....",
        "...#hhmms#...",
        "...#mhhms#...",
        "...#tavts#...",
        "..##smsms##..",
        ".#hhmmhshms#.",
        ".#mshmm#ms###",
        ".#sms##vms#..",
        "..##m#####...",
        "...#msmms#...",
        "..#ms##ms#...",
        "..####.####..",
    ],
    "bodyguard": [
        "....####.....",
        "...#hhms#....",
        "...#savs#....",
        "....#tts#....",
        "..##ssss##...",
        ".#hmhsshms#..",
        ".#smsshshms#.",
        ".#shmm##sss#.",
        "..#smm#s#.#..",
        "...#ssms#....",
        "..#ss##ss#...",
        "..####.####..",
    ],
    "elite": [
        "....#####....",
        "...#hhmms#...",
        "..#hmsmmsm#..",
        "..#hvvvvms#..",
        ".##smmssmm##.",
        "#hhhmmhhmmms#",
        "#hmssmssmshs#",
        ".#hms###mms#.",
        "..##mmhmm##..",
        "..#mms#sms#..",
        "..#mms#sms#..",
        ".#####.#####.",
    ],
    "biotechnician": [
        ".....####....",
        "....#hhhms#..",
        "....#tavts#..",
        "...##hhms##..",
        "..#hmmhhhms#.",
        ".#hhmmhmhmss#",
        ".#hm#hmmh#a#.",
        ".#hm#mhmm#a#.",
        "..###hhmm###.",
        "....#hmsm#...",
        "...#ms#ms#...",
        "...###.###...",
    ],
    "orlov": [
        "...########..",
        "..#hhhhmmmm#.",
        "...#aaaass#..",
        "....#ttvs#...",
        "....#tts#....",
        "..##mhhmm##..",
        ".#ahhmmssha#.",
        ".#shmamhmms#.",
        ".#smmmsmmss#.",
        "..#msmmmm##..",
        "...#ms#ms#...",
        "..####.####..",
    ],
    "robot": [
        "..#..#####...",
        ".#h##hmmms#..",
        "..###avavs#..",
        ".##s##sss###.",
        "#hhmhhmmshms#",
        "#mshmavvmshs#",
        "#ms#msmsm#ms#",
        "#hs#hmmms#hs#",
        ".##.#sss#.##.",
        "..#hm#.#hm#..",
        "..#ms#.#ms#..",
        ".#####.#####.",
    ],
    "commander": [
        "...#######...",
        "..#hhahhmms#.",
        "...#aaaams#..",
        "...#tavts#...",
        "..##smmss###.",
        ".#ahhmmshha#.",
        ".#smhamsmhh#.",
        ".#smamm#vms#.",
        "..#msmm###s#.",
        "..#msmmss##..",
        "..#ms##ms#...",
        ".#####.####..",
    ],
}

const MATERIAL_COLORS: Dictionary = {
    "Scythe": ["#213945", "#5e8189", "#b8d3be"],
    "Anvil": ["#1e3344", "#597187", "#b8d0db"],
    "Needle": ["#2c3d32", "#6c805e", "#c1cf96"],
    "Iskra": ["#3c3839", "#806a56", "#ddaf72"],
    "Alkhimik": ["#374e59", "#8ba8ae", "#f0eee0"],
    "hound": ["#392c46", "#764670", "#d398ad"],
    "rifle": ["#3f3531", "#7e6850", "#bdbc8e"],
    "veteran": ["#403235", "#855758", "#d19889"],
    "bodyguard": ["#272936", "#535665", "#bac1cc"],
    "elite": ["#302b3e", "#655568", "#bd9db9"],
    "biotechnician": ["#484945", "#89927c", "#eee5c0"],
    "orlov": ["#3f332e", "#78543d", "#a5a377"],
    "robot": ["#343240", "#796477", "#d8b4bb"],
    "commander": ["#433039", "#76586c", "#c7a2ac"],
}

const DETAILS: Dictionary = {
    "#": "#111820",
    "a": "#f6cf77",
    "t": "#e3af83",
    "v": "#d5f3f2",
}

static func create_textures() -> Dictionary[String, Texture2D]:
    var textures: Dictionary[String, Texture2D] = {}
    for role in SPRITES:
        var rows: Array = SPRITES[role]
        var colors: Array = MATERIAL_COLORS[role]
        var palette: Dictionary = DETAILS.duplicate()
        palette["s"] = colors[0]
        palette["m"] = colors[1]
        palette["h"] = colors[2]
        var image: Image = Image.create_empty(rows[0].length(), rows.size(), false, Image.FORMAT_RGBA8)
        for y in range(rows.size()):
            var row: String = rows[y]
            for x in range(row.length()):
                if row[x] != ".":
                    image.set_pixel(x, y, Color(palette[row[x]]))
        image.resize(image.get_width() * 2, image.get_height() * 2, Image.INTERPOLATE_NEAREST)
        textures[role] = ImageTexture.create_from_image(image)
    return textures

static func role_for(unit: Dictionary) -> String:
    if unit["team"] == "player":
        return str(unit["name"])
    if bool(unit.get("prototype_robot", false)):
        return "robot"
    if bool(unit.get("mission_target", false)):
        return "orlov"
    match unit.get("kind", ""):
        "horde":
            return "hound"
        "support":
            return "biotechnician"
        "boss":
            return "commander"
    if unit["letter"] == "X":
        return "elite"
    if str(unit["name"]).begins_with("Orlov Bodyguard "):
        return "bodyguard"
    return "veteran" if int(unit["max_armour"]) >= 2 else "rifle"
