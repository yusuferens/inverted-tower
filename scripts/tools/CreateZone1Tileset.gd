@tool
extends EditorScript

# Godot editöründe Script panelini açıp bu script'i "Run" (▶) ile çalıştır.
# Zone1 wang tile'larından zone1_tileset.tres dosyasını oluşturur.

func _run() -> void:
	var ts := TileSet.new()
	ts.tile_size = Vector2i(16, 16)

	# Terrain çarpışma katmanı (collision_layer 2)
	ts.add_physics_layer(0)
	ts.set_physics_layer_collision_layer(0, 2)
	ts.set_physics_layer_collision_mask(0, 0)

	# Tüm tile için tam kare çarpışma poligonu (16×16)
	var half := 8.0
	var rect := PackedVector2Array([
		Vector2(-half, -half), Vector2(half, -half),
		Vector2(half,  half),  Vector2(-half, half)
	])

	for i in range(16):
		var path := "res://assets/sprites/tilesets/zone1_surface_ruins/wang_%d.png" % i
		var tex := load(path) as Texture2D
		if tex == null:
			push_error("Texture yüklenemedi: " + path)
			continue

		var source := TileSetAtlasSource.new()
		source.texture = tex
		source.texture_region_size = Vector2i(16, 16)
		source.create_tile(Vector2i(0, 0))

		var td := source.get_tile_data(Vector2i(0, 0), 0)
		td.add_collision_polygon(0)
		td.set_collision_polygon_points(0, 0, rect)

		ts.add_source(source, i)
		print("  [%d/16] wang_%d eklendi" % [i + 1, i])

	var save_path := "res://assets/sprites/tilesets/zone1_surface_ruins/zone1_tileset.tres"
	var err := ResourceSaver.save(ts, save_path)
	if err == OK:
		print("Tileset kaydedildi: " + save_path)
		EditorInterface.get_resource_filesystem().scan()
	else:
		push_error("Tileset kaydedilemedi (hata kodu: %d)" % err)
