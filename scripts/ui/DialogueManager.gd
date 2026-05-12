extends CanvasLayer

@onready var panel = $Panel
@onready var name_label = $Panel/NameLabel
@onready var text_label = $Panel/TextLabel
@onready var type_timer = $TypeTimer

var target_text := ""
var displayed_text := ""
var char_index := 0
var is_active := false

func _ready() -> void:
	panel.hide()
	EventBus.show_dialogue.connect(_on_show_dialogue)
	EventBus.hide_dialogue.connect(_on_hide_dialogue)
	type_timer.timeout.connect(_on_type_timer_timeout)

func _process(_delta: float) -> void:
	if not is_active:
		return
	
	if Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("attack"):
		if char_index < target_text.length():
			# Skip typing
			char_index = target_text.length()
			text_label.text = target_text
			type_timer.stop()
		else:
			# Close dialogue
			EventBus.hide_dialogue.emit()

func _on_show_dialogue(speaker: String, text: String) -> void:
	is_active = true
	panel.show()
	name_label.text = speaker
	
	if not GameState.has_manuscript:
		target_text = scramble_text(text)
	else:
		target_text = text
		
	displayed_text = ""
	char_index = 0
	text_label.text = ""
	type_timer.start()

func _on_hide_dialogue() -> void:
	is_active = false
	panel.hide()
	type_timer.stop()

func scramble_text(text: String) -> String:
	var symbols = ["#", "@", "%", "&", "$", "!", "?", "*", "+", "="]
	var scrambled = ""
	for i in range(text.length()):
		if text[i] == " ":
			scrambled += " "
		else:
			scrambled += symbols[randi() % symbols.size()]
	return scrambled

func _on_type_timer_timeout() -> void:
	if char_index < target_text.length():
		displayed_text += target_text[char_index]
		text_label.text = displayed_text
		char_index += 1
	else:
		type_timer.stop()
