extends Area2D

@export var target_floor: NodePath

func _ready() -> void:
	collision_mask = 1 # Player layer
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var floor_node = get_node_or_null(target_floor)
		if floor_node:
			floor_node.queue_free()
		queue_free()
