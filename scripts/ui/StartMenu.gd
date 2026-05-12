extends Control

# Geçiş yapılacak asıl oyun sahnesi
const MAIN_GAME_SCENE = "res://scenes/zones/TowerEntrance.tscn"

@onready var start_button = $CenterContainer/VBoxContainer/StartButton
@onready var fade_rect = $FadeLayer/ColorRect
@onready var anim_player = $AnimationPlayer

func _ready() -> void:
	# Başlangıçta ekranın görünür olduğundan emin olalım
	fade_rect.modulate.a = 0.0
	start_button.grab_focus()
	
	# Buton tıklama sinyalini bağla
	start_button.pressed.connect(_on_start_pressed)

func _on_start_pressed() -> void:
	# Butona basıldığında etkileşimi keselim
	start_button.disabled = true
	
	# Basit bir Fade-Out (Kararma) efekti başlatalım
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 0.8)
	
	# Kararma bittiğinde sahneyi değiştir
	await tween.finished
	get_tree().change_scene_to_file(MAIN_GAME_SCENE)
