extends Camera2D

var _shake_time      := 0.0
var _shake_intensity := 0.0

func _ready() -> void:
	EventBus.camera_shake.connect(shake)

func _process(delta: float) -> void:
	if _shake_time > 0.0:
		_shake_time -= delta
		offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * _shake_intensity
	else:
		offset = Vector2.ZERO

func shake(intensity: float, duration: float) -> void:
	_shake_time      = max(_shake_time, duration)
	_shake_intensity = max(_shake_intensity, intensity)
