extends CanvasLayer

@onready var health_bar = $MarginContainer/VBoxContainer/HealthBar
@onready var stamina_bar = $MarginContainer/VBoxContainer/StaminaBar
@onready var potion_box = $MarginContainer/VBoxContainer/PotionBox
@onready var potion_count_label = $MarginContainer/VBoxContainer/PotionBox/PotionCount

func _ready() -> void:
	EventBus.health_changed.connect(_on_health_changed)
	EventBus.stamina_changed.connect(_on_stamina_changed)
	EventBus.potions_changed.connect(_on_potions_changed)

func _on_health_changed(current: int, max_val: int) -> void:
	health_bar.max_value = max_val
	health_bar.value = current

func _on_stamina_changed(current: float, max_val: float) -> void:
	stamina_bar.max_value = max_val
	stamina_bar.value = current

func _on_potions_changed(count: int) -> void:
	potion_count_label.text = "x " + str(count)
	if count > 0:
		potion_box.modulate.a = 1.0
	else:
		potion_box.modulate.a = 0.3


