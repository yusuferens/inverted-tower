extends Node2D

const TILE_PX := 16
const BASE    := "res://assets/sprites/tilesets/zone2_cave_ruins/"

var _map : TileMap

func _ready() -> void:
	var ts : TileSet = TileSet.new()
	ts.tile_size = Vector2i(TILE_PX, TILE_PX)
	for i in range(16):
		var src : TileSetAtlasSource = TileSetAtlasSource.new()
		var abs : String = ProjectSettings.globalize_path(BASE + "wang_%d.png" % i)
		var img : Image = Image.load_from_file(abs)
		var tex : ImageTexture = ImageTexture.create_from_image(img)
		src.texture = tex
		src.texture_region_size = Vector2i(TILE_PX, TILE_PX)
		src.create_tile(Vector2i(0, 0))
		ts.add_source(src, i)

	_map = TileMap.new()
	_map.tile_set = ts
	_map.z_index = -1
	add_child(_map)

	_fill(-54, 34, 189, 4)  # floor  (y≈544 px)
	_fill(11,  26,  22, 2)  # platform A (y≈416 px)
	_fill(40,  20,  15, 2)  # platform B (y≈320 px)

func _fill(c0 : int, r0 : int, w : int, h : int) -> void:
	var c1 : int = c0 + w - 1
	var r1 : int = r0 + h - 1
	for r : int in range(r0, r1 + 1):
		for c : int in range(c0, c1 + 1):
			_map.set_cell(0, Vector2i(c, r), _wang(c, r, c0, r0, c1, r1), Vector2i(0, 0))

func _wang(c : int, r : int, c0 : int, r0 : int, c1 : int, r1 : int) -> int:
	var nw : int = _inside(c - 1, r - 1, c0, r0, c1, r1)
	var ne : int = _inside(c + 1, r - 1, c0, r0, c1, r1)
	var sw : int = _inside(c - 1, r + 1, c0, r0, c1, r1)
	var se : int = _inside(c + 1, r + 1, c0, r0, c1, r1)
	return (nw << 3) | (ne << 2) | (sw << 1) | se

func _inside(c : int, r : int, c0 : int, r0 : int, c1 : int, r1 : int) -> int:
	return 1 if (c >= c0 and c <= c1 and r >= r0 and r <= r1) else 0
