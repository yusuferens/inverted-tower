extends Node2D

const NEXT_SCENE = "res://scenes/zones/Zone1_IsciMezari.tscn"

func _ready() -> void:
	var fall_area = get_node_or_null("FallArea")
	if fall_area:
		fall_area.body_entered.connect(_on_fall_area_entered)

func _on_fall_area_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# Asıl zindana düştüğü an intro'yu tekrar açıyoruz
		GameState.intro_played = false
		get_tree().change_scene_to_file(NEXT_SCENE)
