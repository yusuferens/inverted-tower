extends Node

var health := 5
var max_health := 5
var sanity := 100
var max_sanity := 100
var stamina := 100.0
var max_stamina := 100.0
var stamina_regen_rate := 12.0 # Slower regen
var _stamina_regen_delay := 0.0
var current_zone := 1
var checkpoint_position := Vector2.ZERO
var lore_scrolls_collected: Array[String] = []
var health_potions := 0

# Demo Intro variables
var intro_played := false
var has_weapon := false
var has_manuscript := false
var has_zone2_key := false

func _ready() -> void:
	EventBus.player_damaged.connect(_on_player_damaged)
	EventBus.player_died.connect(_on_player_died)
	# Emit initial UI state
	call_deferred("_emit_initial_ui_state")

func _emit_initial_ui_state() -> void:
	EventBus.health_changed.emit(health, max_health)
	EventBus.stamina_changed.emit(stamina, max_stamina)
	EventBus.potions_changed.emit(health_potions)

func _process(delta: float) -> void:
	if _stamina_regen_delay > 0.0:
		_stamina_regen_delay -= delta
	elif stamina < max_stamina:
		stamina = min(max_stamina, stamina + stamina_regen_rate * delta)
		EventBus.stamina_changed.emit(stamina, max_stamina)

func consume_stamina(amount: float) -> bool:
	if stamina >= amount:
		stamina -= amount
		_stamina_regen_delay = 1.2 # Delay before regen starts again
		EventBus.stamina_changed.emit(stamina, max_stamina)
		return true
	return false

func damage_player(amount: int) -> void:
	health = max(0, health - amount)
	EventBus.health_changed.emit(health, max_health)
	EventBus.player_damaged.emit(amount)
	if health <= 0:
		EventBus.player_died.emit()

func heal_player(amount: int) -> void:
	if health > 0 and health < max_health:
		health = min(max_health, health + amount)
		EventBus.health_changed.emit(health, max_health)
		# Ensure we still emit the original signal if it exists somewhere
		if EventBus.has_user_signal("player_healed"):
			EventBus.emit_signal("player_healed", amount)

func add_health_potion(amount: int) -> void:
	health_potions += amount
	EventBus.potions_changed.emit(health_potions)

func use_health_potion() -> void:
	if health_potions > 0 and health < max_health:
		health_potions -= 1
		heal_player(2)
		EventBus.potions_changed.emit(health_potions)


func drain_sanity(amount: int) -> void:
	sanity = max(0, sanity - amount)
	EventBus.sanity_changed.emit(sanity)
	if sanity <= 0:
		EventBus.sanity_depleted.emit()

func collect_scroll(scroll_id: String) -> void:
	if scroll_id not in lore_scrolls_collected:
		lore_scrolls_collected.append(scroll_id)
		EventBus.lore_collected.emit(scroll_id)

func set_checkpoint(pos: Vector2) -> void:
	checkpoint_position = pos
	EventBus.checkpoint_reached.emit(pos)

func _on_player_damaged(_amount: int) -> void:
	pass

func _on_player_died() -> void:
	await get_tree().create_timer(2.0).timeout
	health = max_health
	EventBus.player_respawned.emit(checkpoint_position)
