extends CharacterBody2D

# ── constants ──────────────────────────────────────────────────────────────────
const SPEED          := 160.0
const JUMP_VELOCITY  := -520.0
const GRAVITY        := 1200.0
const DODGE_SPEED    := 480.0
const DODGE_DURATION := 0.22
const IFRAMES_DUR    := 0.50
const ATTACK_DUR     := 0.45

# spritesheetler
const SHEET_IDLE  := "res://assets/sprites/characters/player/idleman.png"       # 240×240, 3×3, 80×80
const SHEET_SWORD := "res://assets/sprites/characters/player/malemainsword.png" # 324×324, 4×4, 81×81
const SHEET_WALK  := "res://assets/sprites/characters/player/malewalksword.png" # 324×324, 4×4, 81×81
const SHEET_JUMP  := "res://assets/sprites/characters/player/malejump.png"      # 340×340, 4×4, 85×85

# ── state ──────────────────────────────────────────────────────────────────────
var _facing_right  := true
var _is_dodging    := false
var _is_attacking  := false
var _is_hurt       := false
var _is_dead       := false
var _iframe_timer  := 0.0
var _dodge_timer   := 0.0
var _attack_timer  := 0.0
var _intro_state   := 0

# ── nodes ──────────────────────────────────────────────────────────────────────
@onready var sprite        : AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_hitbox : Area2D           = $AttackHitbox
@onready var hurt_box      : Area2D           = $HurtBox
@onready var interact_box  : Area2D           = $InteractBox

# ── init ───────────────────────────────────────────────────────────────────────
func _ready() -> void:
	add_to_group("player")
	_build_sprite_frames()
	attack_hitbox.body_entered.connect(_on_attack_body_entered)
	hurt_box.area_entered.connect(_on_hurt_area_entered)
	EventBus.player_died.connect(_on_player_died)
	EventBus.player_respawned.connect(_on_player_respawned)
	if not GameState.intro_played:
		call_deferred("_start_intro")
	else:
		call_deferred("_init_checkpoint")

func _start_intro() -> void:
	_intro_state = 1
	global_position.y -= 400
	velocity = Vector2.ZERO

func _init_checkpoint() -> void:
	GameState.set_checkpoint(global_position)

func _build_sprite_frames() -> void:
	var sf := SpriteFrames.new()
	sf.remove_animation("default")

	var idle  := load(SHEET_IDLE)  as Texture2D
	var sword := load(SHEET_SWORD) as Texture2D
	var walk  := load(SHEET_WALK)  as Texture2D
	var jump  := load(SHEET_JUMP)  as Texture2D

	# idle   → idleman.png 9 kare, 80×80
	_add_sheet(sf, "idle",   idle,  3, 3,  80, 80,  8.0, true,  0, 9)
	# walk   → malewalksword 13 kare
	_add_sheet(sf, "walk",   walk,  4, 4,  81, 81, 10.0, true,  0, 13)
	# jump   → malejump 15 kare (son kare boş)
	_add_sheet(sf, "jump",   jump,  4, 4,  85, 85, 12.0, false, 0, 15)
	# attack → malemainsword 13 kare (Z tuşu)
	_add_sheet(sf, "attack", sword, 4, 4,  81, 81, 10.0, false, 0, 13)
	# dodge  → hızlandırılmış walk 13 kare
	_add_sheet(sf, "dodge",  walk,  4, 4,  81, 81, 22.0, false, 0, 13)

	sprite.sprite_frames = sf
	sprite.play("idle")

func _add_sheet(sf: SpriteFrames, anim: String, sheet: Texture2D,
				cols: int, _rows: int, fw: int, fh: int,
				fps: float, loop: bool, start: int = 0, count: int = -1) -> void:
	sf.add_animation(anim)
	sf.set_animation_speed(anim, fps)
	sf.set_animation_loop(anim, loop)
	if sheet == null:
		return
	var total_in_sheet := (sheet.get_width() / fw) * (sheet.get_height() / fh)
	var end := (start + count) if count > 0 else total_in_sheet
	for i in range(start, end):
		var at := AtlasTexture.new()
		at.atlas       = sheet
		at.region      = Rect2((i % cols) * fw, (i / cols) * fh, fw, fh)
		at.filter_clip = true
		sf.add_frame(anim, at)

# ── physics ────────────────────────────────────────────────────────────────────
func _physics_process(delta: float) -> void:
	if _is_dead:
		return

	_tick_timers(delta)

	if not is_on_floor():
		velocity.y += GRAVITY * delta

	if _intro_state > 0:
		move_and_slide()
		if _intro_state == 1 and is_on_floor():
			_intro_state = 2
			GameState.intro_played = true
			_play("idle")
			var cam = get_node_or_null("PlayerCamera")
			if cam and cam.has_method("shake"):
				cam.shake(0.6, 8.0)
			_iframe_timer = 1.5
			sprite.modulate = Color(0.6, 0.6, 0.6)
			await get_tree().create_timer(1.5).timeout
			sprite.modulate = Color.WHITE
			_intro_state = 0
			call_deferred("_init_checkpoint")
		elif _intro_state == 1:
			_play("jump")
		return

	if _is_dodging:
		velocity.x = DODGE_SPEED * (1.0 if _facing_right else -1.0)
		move_and_slide()
		return

	if not _is_attacking and not _is_hurt:
		_handle_move(delta)
		_handle_jump()
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED * 8.0 * delta)

	_handle_attack()
	_handle_dodge()
	_handle_interact()
	move_and_slide()
	_update_anim()

# ── input handlers ─────────────────────────────────────────────────────────────
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_H: 
			GameState.use_health_potion()
func _handle_move(delta: float) -> void:
	var dir : float = Input.get_axis("move_left", "move_right")
	if dir != 0.0:
		velocity.x = move_toward(velocity.x, dir * SPEED, SPEED * 12.0 * delta)
		_set_facing(dir > 0.0)
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED * 10.0 * delta)

func _handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		if GameState.consume_stamina(15.0):
			velocity.y = JUMP_VELOCITY

func _handle_attack() -> void:
	if not GameState.has_weapon:
		return
	if Input.is_action_just_pressed("attack") and not _is_attacking and not _is_dodging:
		_is_attacking = true
		_attack_timer = ATTACK_DUR
		attack_hitbox.monitoring = true
		sprite.play("attack")

func _handle_interact() -> void:
	if Input.is_action_just_pressed("interact"):
		if interact_box == null: return
		var areas = interact_box.get_overlapping_areas()
		for a in areas:
			if a.has_method("interact"):
				a.interact()
				return
		var bodies = interact_box.get_overlapping_bodies()
		for b in bodies:
			if b.has_method("interact"):
				b.interact()
				return

func _handle_dodge() -> void:
	if Input.is_action_just_pressed("dodge") and is_on_floor() and not _is_dodging and not _is_attacking:
		if GameState.consume_stamina(30.0):
			_is_dodging  = true
			_dodge_timer = DODGE_DURATION
			_iframe_timer = IFRAMES_DUR
			_play("dodge")

# ── timers ─────────────────────────────────────────────────────────────────────
func _tick_timers(delta: float) -> void:
	if _attack_timer > 0.0:
		_attack_timer -= delta
		if _attack_timer <= 0.0:
			_is_attacking = false
			attack_hitbox.monitoring = false

	if _dodge_timer > 0.0:
		_dodge_timer -= delta
		if _dodge_timer <= 0.0:
			_is_dodging = false

	if _iframe_timer > 0.0:
		_iframe_timer -= delta

# ── animation ──────────────────────────────────────────────────────────────────
func _update_anim() -> void:
	if _is_attacking or _is_hurt or _is_dodging:
		return
	if not is_on_floor():
		_play("jump")
	elif abs(velocity.x) > 20.0:
		_play("walk")
	else:
		_play("idle")

func _play(anim: String) -> void:
	if sprite.animation != anim:
		sprite.play(anim)

func _set_facing(right: bool) -> void:
	if _facing_right == right:
		return
	_facing_right = right
	sprite.flip_h = not right
	attack_hitbox.position.x = abs(attack_hitbox.position.x) * (1 if right else -1)

# ── damage ─────────────────────────────────────────────────────────────────────
func take_damage(amount: int) -> void:
	if _iframe_timer > 0.0 or _is_dead:
		return
	_iframe_timer = IFRAMES_DUR
	_is_hurt = true
	GameState.damage_player(amount)
	sprite.modulate = Color(1, 0.3, 0.3)
	await get_tree().create_timer(0.35).timeout
	sprite.modulate = Color.WHITE
	if not _is_dead:
		_is_hurt = false

func _on_player_died() -> void:
	_is_dead = true
	set_physics_process(false)
	sprite.play("idle") # Stop other animations
	
	var canvas = CanvasLayer.new()
	canvas.layer = 100
	add_child(canvas)
	
	var btn = Button.new()
	btn.text = "RETRY"
	btn.custom_minimum_size = Vector2(200, 80)
	btn.add_theme_font_size_override("font_size", 32)
	btn.set_anchors_preset(Control.PRESET_CENTER)
	canvas.add_child(btn)
	btn.pressed.connect(func(): get_tree().reload_current_scene())

func _on_player_respawned(pos: Vector2) -> void:
	_is_dead = false
	_is_hurt = false
	_iframe_timer = IFRAMES_DUR
	global_position = pos
	set_physics_process(true)
	sprite.modulate = Color.WHITE

# ── signal callbacks ───────────────────────────────────────────────────────────
func _on_attack_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(1)

func _on_hurt_area_entered(_area: Area2D) -> void:
	take_damage(1)
