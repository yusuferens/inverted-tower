extends Node2D

# Düştüğümüzde gideceğimiz yer
const NEXT_SCENE = "res://scenes/zones/Zone1_IsciMezari.tscn"

@onready var fall_area = $FallArea

func _ready() -> void:
	# Eğer oyuncu bu odaya giriyorsa, asıl intro henüz oynanmamış demektir
	GameState.intro_played = false
	
	# Boşluğa düşme tetikleyicisi
	fall_area.body_entered.connect(_on_fall_area_entered)

func _on_fall_area_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# Sahne geçişi yapalım, asıl odaya düştüğümüzde Player.gd otomatik intro yapacak
		get_tree().change_scene_to_file(NEXT_SCENE)
