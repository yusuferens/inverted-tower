@tool
extends Node2D

const TILESET_PATH := "res://assets/sprites/tilesets/zone1_surface_ruins/zone1_tileset.tres"
const WANG_BASE   := "res://assets/sprites/tilesets/zone1_surface_ruins/wang_%d.png"

func _ready() -> void:
	if not Engine.is_editor_hint():
		return
	call_deferred("_ensure_tileset")

func _ensure_tileset() -> void:
	var ts: TileSet
	if ResourceLoader.exists(TILESET_PATH):
		ts = load(TILESET_PATH)
	else:
		ts = _build_tileset()
		var err := ResourceSaver.save(ts, TILESET_PATH)
		if err == OK:
			print("[Zone1Setup] Tileset oluşturuldu: ", TILESET_PATH)
			EditorInterface.get_resource_filesystem().scan()
		else:
			push_error("[Zone1Setup] Tileset kaydedilemedi, hata: %d" % err)
			return

	var terrain      = get_node_or_null("Terrain") as TileMapLayer
	var bg_tiles     = get_node_or_null("BackgroundTiles") as TileMapLayer
	if terrain:
		terrain.tile_set = ts
	if bg_tiles:
		bg_tiles.tile_set = ts

func _build_tileset() -> TileSet:
	var ts := TileSet.new()
	ts.tile_size = Vector2i(16, 16)

	ts.add_physics_layer(0)
	ts.set_physics_layer_collision_layer(0, 2)
	ts.set_physics_layer_collision_mask(0, 0)

	var rect := PackedVector2Array([
		Vector2(-8, -8), Vector2(8, -8),
		Vector2(8,   8), Vector2(-8, 8)
	])

	for i in range(16):
		var tex := load(WANG_BASE % i) as Texture2D
		if tex == null:
			push_warning("[Zone1Setup] Yüklenemedi: " + WANG_BASE % i)
			continue

		var src := TileSetAtlasSource.new()
		src.texture = tex
		src.texture_region_size = Vector2i(16, 16)
		src.create_tile(Vector2i(0, 0))

		var td := src.get_tile_data(Vector2i(0, 0), 0)
		td.add_collision_polygon(0)
		td.set_collision_polygon_points(0, 0, rect)

		ts.add_source(src, i)

	return ts
