extends CanvasLayer

@onready var panel = $Control/Panel
@onready var speaker_label = $Control/Panel/VBoxContainer/SpeakerLabel
@onready var text_label = $Control/Panel/VBoxContainer/TextLabel
@onready var info_label = $Control/InfoLabel
@onready var timer = $Timer
@onready var info_timer = $InfoTimer

func _ready() -> void:
	panel.hide()
	info_label.hide()
	EventBus.show_dialogue.connect(_on_show_dialogue)
	EventBus.hide_dialogue.connect(_on_hide_dialogue)
	EventBus.show_info.connect(_on_show_info)

func _on_show_dialogue(speaker: String, text: String) -> void:
	speaker_label.text = "[color=yellow]" + speaker + "[/color]"
	text_label.text = text
	panel.show()
	timer.start(3.5) # Auto hide after 3.5 seconds

func _on_hide_dialogue() -> void:
	panel.hide()

func _on_show_info(text: String) -> void:
	info_label.text = "[center][b]" + text + "[/b][/center]"
	info_label.show()
	info_timer.start(2.5)

func _on_timer_timeout() -> void:
	_on_hide_dialogue()

func _on_info_timer_timeout() -> void:
	info_label.hide()
