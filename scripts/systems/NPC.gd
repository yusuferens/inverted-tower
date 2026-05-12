extends Area2D

@export var npc_name := "Mysterious Figure"

func _ready() -> void:
	collision_layer = 32 # Interactable layer
	collision_mask = 1 # Detect player
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

var _player_in_range := false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = false

func _input(event: InputEvent) -> void:
	if _player_in_range and event.is_action_pressed("interact"):
		interact()

func interact() -> void:
	if not GameState.has_manuscript:
		if not GameState.has_weapon:
			EventBus.show_dialogue.emit(npc_name, "ψ ⍙⍚⍎ ⍛⍜⍞, ⍠⍡⍢ ⍣⍤⍥! ... [color=gray](Söylediklerini anlayamıyorsun, ama sana bir kılıç ve iksir uzatıyor)[/color]")
			GameState.has_weapon = true
			GameState.add_health_potion(1)
			EventBus.show_info.emit("KILIÇ VE CAN İKSİRİ KAZANDIN!")
		else:
			EventBus.show_dialogue.emit(npc_name, "ΔΘΛ ΞΦΠ... ⍦⍧⍨ ⍩⍪⍫, ⍬⍭⍮.")
	else:
		# Player understands the language
		if not GameState.has_zone2_key:
			EventBus.show_dialogue.emit(npc_name, "Artık kadim dili okuyabiliyorsun... Tarikat aşağıda. Bu anahtarı al ve onları durdur. [Bölge 2 Anahtarı Açıldı]")
			GameState.has_zone2_key = true
		else:
			EventBus.show_dialogue.emit(npc_name, "Acele et! Tersine Çevrilmiş Olan huzursuzlanıyor.")
