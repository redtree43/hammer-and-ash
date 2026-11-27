extends RefCounted
## Hand-authored pixel silhouettes on a 30 × 32 canvas. Polygon edges snap
## to pixels at rasterization. Coordinates run left to right and top to bottom.

const SIZE := Vector2i(30, 32)
const INK := Color("#111923")
const PlayerClasses = preload("res://scripts/player_classes.gd")

# Each palette has shadow, body, light, and the origin's identifying accent.
const PALETTES := {
    "WOLVERINE": ["#43272f", "#a7613e", "#eeb875", "#fae4b6"],
    "SCORPION": ["#442538", "#91445c", "#d58177", "#f1c878"],
    "STEEL SKIN": ["#374457", "#8293a4", "#cfe4e5", "#fcf5df"],
    "PSIONIC ARMOUR": ["#382b57", "#64578c", "#a799cb", "#92f4e3"],
    "TELEPATHY": ["#3c2a50", "#765271", "#bf87aa", "#f9b2ef"],
    "TELEKINESIS": ["#203a51", "#416983", "#81b0be", "#a5efff"],
    "EYE POWERS": ["#2f3b34", "#638465", "#aacc92", "#ff835b"],
    "HAWK WINGS": ["#45352f", "#89654d", "#d4ab77", "#fff0bf"],
    "DRONE COMMAND": ["#2d444d", "#557e86", "#a8cac1", "#7df6bb"],
    "ARTILLERY SUIT": ["#492d3d", "#9a5149", "#dc9566", "#ffce6f"],
    "HEALING": ["#345354", "#7faaa2", "#e3e5d0", "#8af2de"],
    "Frog": ["#344638", "#64835e", "#a9b979", "#dfdc88"],
    "Jellyfish": ["#493a37", "#89684c", "#c29b6e", "#cce3ad"],
    "Skunk": ["#342f47", "#625878", "#c3b9cc", "#b2e783"],
}

const HEAVY := ["STEEL SKIN", "PSIONIC ARMOUR", "DRONE COMMAND", "ARTILLERY SUIT", "Jellyfish"]
const COATS := ["TELEPATHY", "TELEKINESIS", "HEALING"]
const EXPOSED := ["STEEL SKIN", "TELEPATHY", "HEALING", "Frog"]

# Each layer selects a palette swatch followed by x/y pairs.
# The accessories cross the edges of the base silhouette so origins read at tile size.
const BACK := {
    "SCORPION": [[0, [20,21, 25,17, 25,11, 22,8, 22,4, 26,1, 29,3, 28,7, 26,8, 29,11, 29,18, 24,24]],
        [2, [24,4, 27,2, 28,4, 26,6]], [3, [24,3, 26,2, 25,5]], [1, [26,11, 28,12, 28,16, 26,18]]],
    "PSIONIC ARMOUR": [[3, [2,9, 5,12, 3,17, 3,22, 0,24, 0,15]],
        [3, [25,8, 29,12, 30,19, 27,23, 27,16]], [2, [1,12, 5,9, 4,13, 1,19]]],
    "TELEKINESIS": [[3, [0,13, 3,11, 4,13, 2,16]], [2, [25,7, 27,6, 29,9, 28,11, 26,10]],
        [3, [26,17, 28,15, 30,17, 29,20, 26,19]]],
    "HAWK WINGS": [[0, [0,3, 8,7, 12,17, 10,23, 5,20, 5,17, 3,15, 3,12, 1,10]],
        [0, [30,3, 22,7, 18,17, 20,23, 25,20, 25,17, 27,15, 27,12, 29,10]],
        [2, [1,5, 7,8, 10,14, 5,12, 2,9]], [2, [29,5, 23,8, 20,14, 25,12, 28,9]],
        [1, [4,12, 10,15, 10,20, 6,17]], [1, [26,12, 20,15, 20,20, 24,17]]],
    "DRONE COMMAND": [[0, [0,7, 2,6, 4,6, 5,4, 8,4, 9,7, 11,8, 10,11, 8,12, 4,12, 3,10, 0,10]],
        [2, [3,7, 7,5, 9,8, 7,10, 4,9]], [3, [5,8, 8,8, 8,10, 5,10]]],
    "ARTILLERY SUIT": [[0, [3,4, 8,1, 11,6, 12,13, 6,16, 2,10]],
        [2, [4,4, 8,2, 10,6, 5,8]], [3, [5,5, 7,4, 8,6, 6,7]],
        [0, [21,12, 21,4, 25,1, 29,4, 28,10, 26,15]], [2, [23,4, 25,2, 28,4, 27,7, 23,7]]],
    "Jellyfish": [[0, [17,10, 20,5, 25,4, 29,8, 30,15, 28,20, 24,22, 19,20]],
        [1, [20,8, 25,6, 28,10, 29,15, 26,19, 22,19, 19,16]],
        [2, [22,9, 26,9, 28,13, 26,16, 23,16, 22,13, 24,11, 25,12, 24,14, 26,14, 26,12, 24,10]]],
    "Skunk": [[0, [19,27, 21,21, 24,17, 24,10, 21,6, 22,2, 25,1, 29,5, 30,13, 27,22, 24,27]],
        [2, [24,3, 27,5, 28,9, 27,15, 25,20, 25,12, 23,7]]],
}

const FRONT := {
    "WOLVERINE": [[0, [9,4, 10,1, 14,5, 17,5, 20,1, 21,8, 19,12, 10,12]],
        [2, [10,5, 11,3, 14,7, 16,7, 19,4, 20,8, 18,11, 12,11]],
        [0, [10,8, 13,7, 15,8, 17,7, 20,8, 20,9, 17,9, 15,10, 13,9, 10,9]],
        [3, [11,8, 14,8, 13,9, 11,9]], [3, [17,8, 19,8, 19,9, 16,9]],
        [3, [2,19, 4,19, 3,26, 2,28]], [3, [5,20, 6,20, 5,27, 4,27]],
        [3, [24,19, 25,18, 27,25, 26,26]], [3, [27,18, 28,18, 29,24, 28,24]]],
    "SCORPION": [[0, [7,12, 13,13, 17,13, 23,11, 21,18, 16,21, 10,19]],
        [2, [9,13, 13,15, 18,15, 21,13, 20,16, 15,18, 11,17]],
        [2, [12,19, 16,20, 19,18, 18,21, 15,22]], [3, [12,8, 19,8, 18,10, 12,10]]],
    "STEEL SKIN": [[2, [5,13, 8,10, 13,11, 12,15, 7,16]], [2, [16,11, 22,10, 26,14, 22,17, 17,15]],
        [2, [12,17, 16,15, 20,17, 17,20, 13,20]], [3, [11,6, 18,5, 16,7, 11,8]],
        [1, [2,19, 6,17, 9,20, 8,23, 3,23]], [2, [3,19, 7,19, 7,21, 3,21]],
        [1, [22,20, 26,18, 28,20, 27,23, 22,24]], [2, [24,19, 28,19, 27,21, 23,21]]],
    "PSIONIC ARMOUR": [[2, [7,12, 10,10, 14,14, 12,16]], [2, [17,14, 21,10, 24,12, 20,16]],
        [3, [15,14, 18,17, 15,21, 12,17]], [0, [15,16, 16,17, 15,19, 14,17]],
        [3, [2,18, 5,16, 8,19, 6,24, 3,24]], [1, [3,19, 6,18, 7,20, 5,23, 4,23]]],
    "TELEPATHY": [[0, [8,9, 8,5, 11,2, 17,2, 21,6, 21,10, 18,9, 18,5, 12,5, 11,10]],
        [3, [9,7, 11,6, 11,9, 9,10]], [3, [18,6, 21,7, 20,10, 18,9]],
        [2, [14,5, 16,5, 16,7, 14,7]], [2, [9,13, 11,12, 14,16, 17,19, 15,24, 13,19]],
        [3, [15,14, 17,16, 15,18, 13,16]]],
    "TELEKINESIS": [[1, [8,9, 10,4, 13,2, 18,2, 21,6, 22,11, 19,12, 17,6, 13,6, 11,12]],
        [3, [12,8, 19,8, 18,10, 12,10]], [2, [11,13, 15,16, 19,13, 18,18, 14,20]],
        [2, [4,17, 7,16, 10,18, 8,21, 4,21]], [3, [4,18, 7,17, 8,19, 5,20]]],
    "EYE POWERS": [[0, [8,7, 12,5, 21,6, 21,11, 12,12, 9,10]],
        [3, [10,8, 15,7, 21,7, 20,9, 15,10, 11,10]], [2, [16,7, 19,7, 19,8, 16,8]],
        [1, [7,20, 12,16, 18,15, 25,14, 27,14, 27,16, 22,17, 19,19, 12,20, 9,23]],
        [2, [13,16, 25,14, 25,15, 15,18]], [0, [11,20, 23,17, 22,19, 13,22]]],
    "HAWK WINGS": [[2, [11,4, 15,3, 19,5, 20,8, 17,10, 12,9]],
        [0, [11,7, 15,6, 19,7, 18,9, 12,9]], [3, [15,8, 20,9, 18,11, 16,12, 16,9]],
        [2, [9,13, 13,15, 18,13, 17,17, 14,20, 11,17]], [3, [5,16, 7,16, 8,19, 6,20]]],
    "DRONE COMMAND": [[2, [8,5, 12,3, 18,3, 21,5, 21,8, 9,8]], [3, [11,7, 19,7, 19,9, 11,9]],
        [0, [7,15, 12,13, 16,17, 13,21, 6,21]], [2, [8,15, 12,14, 14,17, 11,19, 7,19]],
        [3, [9,16, 12,16, 12,18, 9,18]], [2, [19,14, 23,12, 25,15, 22,18]]],
    "ARTILLERY SUIT": [[2, [9,5, 12,3, 19,3, 21,6, 20,8, 10,8]], [3, [12,7, 19,7, 18,9, 12,9]],
        [0, [19,13, 23,11, 26,13, 30,17, 29,21, 26,23, 21,20]],
        [2, [21,13, 25,13, 28,17, 26,18, 22,16]], [3, [27,17, 29,17, 29,20, 27,20]],
        [3, [10,14, 12,13, 16,14, 16,16, 11,16]]],
    "HEALING": [[2, [9,5, 13,2, 18,3, 21,7, 10,7]], [3, [11,7, 19,7, 18,9, 12,9]],
        [0, [19,14, 24,13, 26,16, 26,22, 22,24, 18,22]], [2, [20,16, 24,16, 25,19, 24,22, 20,22]],
        [0, [22,16, 23,16, 23,22, 22,22]], [0, [20,18, 25,18, 25,20, 20,20]],
        [3, [5,15, 7,14, 8,19, 6,21, 5,19]]],
    "Frog": [[2, [11,4, 17,3, 21,6, 22,9, 19,11, 13,10, 9,8]], [3, [16,7, 20,7, 20,8, 16,8]],
        [1, [12,10, 17,9, 22,10, 20,13, 14,14, 10,12]], [2, [3,17, 7,16, 8,20, 5,24, 3,22]],
        [3, [2,21, 4,21, 4,24, 3,25]], [2, [21,15, 25,15, 27,18, 24,20, 21,18]]],
    "Jellyfish": [[2, [9,5, 11,4, 11,1, 13,1, 13,5, 17,5, 17,1, 19,1, 20,6, 21,10, 11,11]],
        [3, [10,8, 19,8, 18,10, 11,10]], [2, [5,15, 9,12, 12,14, 12,20, 8,23, 4,20]],
        [0, [6,17, 9,15, 10,17, 8,21, 6,20]]],
    "Skunk": [[2, [9,4, 12,2, 14,5, 16,5, 19,2, 21,6, 20,10, 17,13, 11,11, 9,8]],
        [0, [9,7, 13,6, 15,8, 17,6, 20,7, 20,9, 17,10, 13,10, 10,9]],
        [3, [12,7, 14,8, 12,9]], [3, [17,8, 19,7, 19,9]], [2, [14,12, 17,13, 16,20, 14,22, 13,17]]],
}

static var textures: Dictionary[String, Texture2D] = {}

static func variant(kit: String, build: Dictionary, form: String = "") -> String:
    var origin: int = int(build["origin"])
    if kit == "Alkhimik" and origin == 0:
        return form if not form.is_empty() else str(build["form"])
    var name: String = str(PlayerClasses.data(kit)["origins"][origin]["name"]).to_upper()
    return {"JAGUAR": "WOLVERINE", "JEKYLL / HYDE": "HEALING"}.get(name, name)

static func texture(key: String, scale: int = 1) -> Texture2D:
    if not textures.has(key):
        textures[key] = rasterize(key)
    if scale == 1:
        return textures[key]
    var scaled_key: String = "%s/%d" % [key, scale]
    if not textures.has(scaled_key):
        var portrait: Image = textures[key].get_image()
        portrait.resize(SIZE.x * scale, SIZE.y * scale, Image.INTERPOLATE_NEAREST)
        textures[scaled_key] = ImageTexture.create_from_image(portrait)
    return textures[scaled_key]

static func rasterize(key: String) -> ImageTexture:
    var image := Image.create_empty(SIZE.x, SIZE.y, false, Image.FORMAT_RGBA8)
    var palette: Array = PALETTES[key]
    var heavy: bool = key in HEAVY
    var coat: bool = key in COATS
    paint_layers(image, palette, BACK.get(key, []))
    # Torso, lower silhouette, and boxing of the gloves and boots.
    if heavy:
        polygon(image, INK, [2,13, 7,10, 10,10, 10,5, 12,3, 18,3, 22,6, 22,10, 27,12, 29,17,
            28,23, 24,24, 24,29, 26,29, 26,31, 17,31, 16,25, 14,25, 12,31, 4,31, 4,29, 7,28, 7,24, 2,23, 1,18])
        paint_layers(image, palette, [[1, [4,13, 9,11, 21,11, 26,13, 28,17, 25,21, 22,21, 21,26, 18,26, 16,23,
            13,24, 11,27, 8,27, 8,21, 4,22, 2,18]], [0, [8,20, 13,21, 17,22, 22,20, 21,28, 23,29, 18,30,
            17,26, 15,24, 13,25, 11,30, 6,30, 9,28]], [2, [5,13, 10,12, 12,14, 10,17, 5,17, 3,16]],
            [2, [20,12, 24,12, 27,15, 25,17, 20,16]], [2, [11,17, 18,16, 21,18, 19,20, 11,20]]])
    else:
        polygon(image, INK, [4,14, 8,11, 10,10, 9,6, 11,3, 18,3, 21,6, 21,10, 25,13, 27,18, 26,23,
            22,22, 22,27, 25,29, 25,31, 17,31, 15,25, 13,25, 12,29, 11,31, 4,31, 4,29, 7,27, 8,22, 4,23, 2,20])
        paint_layers(image, palette, [[1, [5,14, 10,11, 19,11, 24,13, 26,17, 25,21, 22,20, 20,24, 16,24, 13,24,
            10,23, 10,19, 7,20, 5,22, 3,20]], [0, [9,20, 14,20, 16,22, 21,20, 21,27, 23,29, 18,30, 15,24, 13,24,
            11,29, 6,30, 8,27]], [2, [5,14, 10,12, 12,14, 10,16, 5,17]], [2, [16,13, 21,12, 24,14, 22,16, 18,16]]])
    if coat:
        paint_layers(image, palette, [[1, [8,18, 13,17, 14,23, 12,27, 6,28]],
            [0, [16,19, 21,18, 24,27, 21,29, 16,26]], [2, [9,17, 12,17, 11,20, 9,24, 8,24]]])
    paint_layers(image, palette, [[0, [10,7, 12,4, 18,4, 20,6, 20,10, 18,13, 12,12]],
        [1, [11,6, 13,4, 17,4, 20,6, 19,10, 16,11, 12,10]], [2, [12,5, 17,4, 19,6, 16,7, 11,7]],
        [3, [12,8, 19,8, 18,9, 13,9]], [0, [9,22, 20,22, 20,24, 17,24, 14,23, 10,24]]])
    var reflected: Color = Color(palette[0]).lerp(Color(palette[1]), 0.52)
    var stitched: Color = Color(palette[1]).lerp(Color(palette[2]), 0.55)
    polygon(image, reflected, [9,25, 12,24, 11,27, 8,28, 8,27])
    polygon(image, reflected, [17,25, 20,25, 21,28, 19,29, 18,28])
    polygon(image, stitched, [9,26, 11,25, 11,26, 9,27])
    polygon(image, stitched, [17,26, 20,26, 20,27, 18,27])
    polygon(image, reflected, [10,20, 13,20, 16,21, 19,20, 20,21, 16,22, 12,21])
    polygon(image, stitched, [13,15, 16,14, 18,15, 17,17, 14,17])
    image.set_pixel(14, 22, Color(palette[2]))
    image.set_pixel(15, 22, reflected)
    if key in EXPOSED:
        var face: Color = Color(palette[2]) if key == "STEEL SKIN" else Color("#dbac8b")
        polygon(image, face, [11,7, 14,6, 18,6, 20,8, 18,11, 16,12, 12,11])
        polygon(image, Color(palette[0]), [13,8, 18,8, 18,9, 13,9])
        image.set_pixel(17, 10, Color(palette[0]))
    paint_layers(image, palette, FRONT[key])
    return ImageTexture.create_from_image(image)

static func paint_layers(image: Image, palette: Array, layers: Array) -> void:
    for layer in layers:
        polygon(image, Color(palette[layer[0]]), layer[1])

static func polygon(image: Image, color: Color, coordinates: Array) -> void:
    var shape := PackedVector2Array()
    for index in range(0, coordinates.size(), 2):
        shape.append(Vector2(coordinates[index], coordinates[index + 1]))
    for y in range(SIZE.y):
        for x in range(SIZE.x):
            if Geometry2D.is_point_in_polygon(Vector2(x + 0.5, y + 0.5), shape):
                image.set_pixel(x, y, color)
