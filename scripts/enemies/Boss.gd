extends CharacterBody2D

# ── sabitler ───────────────────────────────────────────────────────────────────
const MAX_HP              := 5
const PHASE_2_HP          := 2      # ≤2 HP → phase geçişi

const SPEED               := 55.0
const SPEED_P2            := 82.0   # faz 2: daha saldırgan
const GRAVITY             := 1200.0
const ATTACK_RANGE        := 100.0

# Telegraph süreleri (faz 2'de kısalıyor)
const TELEGRAPH_DUR       := 0.65
const TELEGRAPH_DUR_P2    := 0.35

# Saldırı süreleri — animasyon frame sayısına göre hesaplandı
const LIGHT_ATTACK_DUR    := 1.45   # 13 kare / 9 fps
const LIGHT_ATTACK_DUR_P2 := 1.45   # aynı animasyon, telegraph kısaltılarak hızlanır
const RESONANCE_SLAM_DUR  := 2.45   # 17 kare / 7 fps
const ECHO_ATTACK_DUR     := 1.45   # light_attack animasyonunu kullanır
const ECHO_DELAY          := 0.80
const LAST_BELL_DUR       := 2.50
const LAST_BELL_FREEZE    := 1.20   # animasyonun ~%48'inde slam vurur

const HURT_DUR            := 0.40
const PHASE_TRANSITION_DUR := 3.50

# Hasar değerleri
const LIGHT_DAMAGE        := 1
const RESONANCE_DAMAGE    := 2
const ECHO_DAMAGE         := 1
const LAST_BELL_DAMAGE    := 3

# Bekleme süreleri
const SPECIAL_COOLDOWN    := 8.0
const LAST_BELL_COOLDOWN  := 20.0

# AI sabitleri
const RETREAT_DIST        := 48.0   # bu mesafeden yakınsa geri çekil
const STRAFE_DUR          := 1.1    # yanlara kayma süresi
const STRAFE_CHANCE       := 0.40   # yürürken strafe ihtimali
const LIGHT_COMBO_LIMIT   := 2      # kaç light'tan sonra özel zorlanır
const LISTEN_DUR          := 1.4    # faz 2: "ses duyma" dondurması
const LISTEN_CHANCE       := 0.22   # faz 2: dondurma ihtimali (walk'ta)
const STAGGER_IMMUNITY    := 0.8    # hasar sonrası stagger immunite süresi
const TELEGRAPH_CANCEL_DIST := 260.0 # telegraph'ta oyuncu bu kadar uzaklaşırsa iptal

# Hit pause süreleri (real time)
const HIT_PAUSE_LIGHT     := 0.04
const HIT_PAUSE_HEAVY     := 0.08

# Kamera sarsma şiddeti / süresi
const SHAKE_LIGHT  := Vector2(3.5,  0.12)
const SHAKE_HEAVY  := Vector2(7.0,  0.25)
const SHAKE_SLAM   := Vector2(11.0, 0.40)

# Sprite sheet'ler
const SHEET_IDLE           := "res://assets/sprites/characters/boss/boss_idle.png"
const SHEET_WALK           := "res://assets/sprites/characters/boss/boss_walk.png"
const SHEET_LIGHT_ATTACK   := "res://assets/sprites/characters/boss/boss_light_attack.png"
const SHEET_SPECIAL_ATTACK := "res://assets/sprites/characters/boss/boss_special_attack.png"
const SHEET_DEATH          := "res://assets/sprites/characters/boss/boss_death.png"

# ── durum makinesi ─────────────────────────────────────────────────────────────
enum State {
	IDLE, WALK, TELEGRAPH,
	LIGHT_ATTACK,
	RESONANCE_SLAM,    # faz 1 özel — yavaş, ezici
	ECHO_ATTACK,       # faz 2 özel — gecikimli tekrar
	LAST_BELL,         # faz 2 ultimate — her şeyi durduran çan
	PHASE_TRANSITION,  # %50 HP sahnesi
	HURT, DEAD
}
var state : int = State.IDLE

# ── çalışma zamanı değişkenleri ────────────────────────────────────────────────
var hp                  : int   = MAX_HP
var phase               : int   = 1
var _player             : CharacterBody2D = null
var _facing_right       : bool  = false
var _state_timer        : float = 0.0
var _special_cooldown   : float = SPECIAL_COOLDOWN
var _last_bell_cooldown : float = LAST_BELL_COOLDOWN
var _hitbox_timer       : float = 0.0
var _hit_landed         : bool  = false
var _next_attack        : int   = State.LIGHT_ATTACK
var _echo_pending       : bool  = false

# AI durumu
var _aggression         : float = 0.0   # 0→1 arası, HP düştükçe artar
var _light_combo        : int   = 0     # ardışık light attack sayısı
var _strafe_timer       : float = 0.0   # strafe kalan süre
var _strafe_dir         : float = 1.0   # strafe yönü
var _listen_timer       : float = 0.0   # faz 2 dondurma kalan süre
var _retreating         : bool  = false # kısa geri çekilme
var _stagger_immunity   : float = 0.0   # stagger immunite sayacı

# ── node'lar ───────────────────────────────────────────────────────────────────
@onready var sprite      : AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox      : Area2D           = $AttackHitbox
@onready var slam_hitbox : Area2D           = $SlamHitbox
@onready var hurtbox     : Area2D           = $HurtBox

# ── başlangıç ──────────────────────────────────────────────────────────────────
func _ready() -> void:
	add_to_group("boss")
	_build_sprite_frames()
	hitbox.monitoring      = false
	slam_hitbox.monitoring = false
	hitbox.body_entered.connect(_on_attack_body_entered)
	slam_hitbox.body_entered.connect(_on_slam_body_entered)
	$DetectionZone.body_entered.connect(_on_detection_entered)
	$DetectionZone.body_exited.connect(_on_detection_exited)

func _build_sprite_frames() -> void:
	var sf := SpriteFrames.new()
	sf.remove_animation("default")
	_add_sheet(sf, "idle",           SHEET_IDLE,           3, 3, 187, 187,  7.0, true,  0, 9)
	_add_sheet(sf, "walk",           SHEET_WALK,           3, 3, 175, 175,  9.0, true,  0, 9)
	_add_sheet(sf, "light_attack",   SHEET_LIGHT_ATTACK,   4, 4, 156, 156,  9.0, false, 0, 13)
	_add_sheet(sf, "special_attack", SHEET_SPECIAL_ATTACK, 5, 4, 175, 175,  7.0, false, 0, 17)
	_add_sheet(sf, "death",          SHEET_DEATH,          4, 4, 187, 187,  8.0, false, 0, 13)
	sprite.sprite_frames = sf
	sprite.play("idle")

func _add_sheet(sf: SpriteFrames, anim: String, path: String,
				cols: int, _rows: int, fw: int, fh: int,
				fps: float, loop: bool, start: int = 0, count: int = -1) -> void:
	sf.add_animation(anim)
	sf.set_animation_speed(anim, fps)
	sf.set_animation_loop(anim, loop)
	var sheet := load(path) as Texture2D
	if sheet == null:
		return
	var total := (sheet.get_width() / fw) * (sheet.get_height() / fh)
	var end   := (start + count) if count > 0 else total
	for i in range(start, end):
		var at := AtlasTexture.new()
		at.atlas       = sheet
		at.region      = Rect2((i % cols) * fw, (i / cols) * fh, fw, fh)
		at.filter_clip = true
		sf.add_frame(anim, at)

# ── ana döngü ──────────────────────────────────────────────────────────────────
func _physics_process(delta: float) -> void:
	if state == State.DEAD or state == State.PHASE_TRANSITION:
		move_and_slide()
		return

	if not is_on_floor():
		velocity.y += GRAVITY * delta

	_tick_timers(delta)

	match state:
		State.IDLE:          _tick_idle(delta)
		State.WALK:          _tick_walk(delta)
		State.TELEGRAPH:     _tick_telegraph(delta)
		State.LIGHT_ATTACK:
			var dur := LIGHT_ATTACK_DUR_P2 if phase == 2 else LIGHT_ATTACK_DUR
			_tick_attack(delta, dur, LIGHT_DAMAGE)
		State.RESONANCE_SLAM: _tick_resonance_slam(delta)
		State.ECHO_ATTACK:    _tick_echo_attack(delta)
		State.LAST_BELL:      _tick_last_bell(delta)
		State.HURT:           _tick_hurt(delta)

	move_and_slide()

# ── zamanlayıcılar ─────────────────────────────────────────────────────────────
func _tick_timers(delta: float) -> void:
	_state_timer -= delta
	if _special_cooldown > 0.0:
		_special_cooldown -= delta
	if _last_bell_cooldown > 0.0:
		_last_bell_cooldown -= delta
	if _hitbox_timer > 0.0:
		_hitbox_timer -= delta
		if _hitbox_timer <= 0.0:
			hitbox.monitoring      = false
			slam_hitbox.monitoring = false
	if _strafe_timer > 0.0:
		_strafe_timer -= delta
	if _listen_timer > 0.0:
		_listen_timer -= delta
	if _stagger_immunity > 0.0:
		_stagger_immunity -= delta

# ── durum tick'leri ────────────────────────────────────────────────────────────
func _tick_idle(_delta: float) -> void:
	velocity.x = 0.0
	if sprite.animation != "idle":
		sprite.play("idle")
	if is_instance_valid(_player):
		_change_state(State.WALK)

func _tick_walk(delta: float) -> void:
	if not is_instance_valid(_player):
		_change_state(State.IDLE)
		return

	var dist := global_position.distance_to(_player.global_position)
	var base_spd := SPEED_P2 if phase == 2 else SPEED
	# Agresyon hızı: HP azaldıkça %30'a kadar hız artışı
	var spd := base_spd * (1.0 + _aggression * 0.30)

	# ── Faz 2: "duyma" dondurması ──────────────────────────────────────────────
	if phase == 2 and _listen_timer > 0.0:
		velocity.x = move_toward(velocity.x, 0.0, spd * 6.0 * delta)
		sprite.modulate = Color(0.8 + sin(Time.get_ticks_msec() * 0.008) * 0.2,
								0.8, 0.8)
		return
	else:
		if sprite.modulate != Color.WHITE:
			sprite.modulate = Color.WHITE

	# ── Saldırı aralığı ────────────────────────────────────────────────────────
	if dist <= ATTACK_RANGE:
		_strafe_timer  = 0.0
		_retreating    = false
		_decide_attack()
		_change_state(State.TELEGRAPH)
		return

	# ── Çok yakın: geri çekil ─────────────────────────────────────────────────
	if dist < RETREAT_DIST:
		_retreating = true
		var away : float = sign(global_position.x - _player.global_position.x)
		if away == 0.0:
			away = -1.0 if _facing_right else 1.0
		velocity.x = move_toward(velocity.x, away * spd * 0.8, spd * 6.0 * delta)
		_set_facing(not (away >= 0.0))
		if sprite.animation != "walk":
			sprite.play("walk")
		return

	_retreating = false

	# ── Strafe: saldırı öncesi yanlara kayma ──────────────────────────────────
	if _strafe_timer > 0.0:
		velocity.x = move_toward(velocity.x, _strafe_dir * spd * 0.6, spd * 6.0 * delta)
		_set_facing(_player.global_position.x >= global_position.x)
		if sprite.animation != "walk":
			sprite.play("walk")
		return

	# Faz 2: rastgele "duyma" dondurması başlat
	if phase == 2 and _listen_timer <= 0.0 and randf() < LISTEN_CHANCE * delta:
		_listen_timer = LISTEN_DUR
		velocity.x    = 0.0
		return

	# Yaklaşırken rastgele strafe başlat
	if _strafe_timer <= 0.0 and dist < 220.0 and randf() < STRAFE_CHANCE * delta:
		_strafe_timer = STRAFE_DUR
		_strafe_dir   = sign(_player.global_position.x - global_position.x) \
						* (1.0 if randf() > 0.5 else -1.0)

	# ── Normal yaklaşma ────────────────────────────────────────────────────────
	var dir : float = sign(_player.global_position.x - global_position.x)
	velocity.x = move_toward(velocity.x, dir * spd, spd * 8.0 * delta)
	_set_facing(dir >= 0.0)
	if sprite.animation != "walk":
		sprite.play("walk")

func _tick_telegraph(_delta: float) -> void:
	velocity.x = 0.0
	# Oyuncu çok uzaklaştıysa saldırıyı iptal et, tekrar kovala
	if is_instance_valid(_player):
		var dist := global_position.distance_to(_player.global_position)
		if dist > TELEGRAPH_CANCEL_DIST:
			sprite.modulate = Color.WHITE
			_light_combo = 0
			_change_state(State.WALK)
			return
	if _state_timer <= 0.0:
		sprite.modulate = Color.WHITE
		_change_state(_next_attack)

func _tick_attack(delta: float, dur: float, damage: int) -> void:
	velocity.x = move_toward(velocity.x, 0.0, SPEED * 8.0 * delta)
	var elapsed := dur - _state_timer
	if not _hit_landed and elapsed >= dur * 0.55:
		_hit_landed = true
		_open_hitbox(hitbox, 0.18, damage, SHAKE_LIGHT, HIT_PAUSE_LIGHT)
	if _state_timer <= 0.0:
		hitbox.monitoring = false
		_change_state(State.WALK if is_instance_valid(_player) else State.IDLE)

# ── Resonance Slam (faz 1 özel) ────────────────────────────────────────────────
func _tick_resonance_slam(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, SPEED * 8.0 * delta)
	var elapsed := RESONANCE_SLAM_DUR - _state_timer

	if not _hit_landed and elapsed >= RESONANCE_SLAM_DUR * 0.62:
		_hit_landed       = true
		_special_cooldown = SPECIAL_COOLDOWN
		EventBus.boss_sound_rupture.emit(0.8)
		_open_hitbox(slam_hitbox, 0.22, RESONANCE_DAMAGE, SHAKE_HEAVY, HIT_PAUSE_HEAVY)

	if _state_timer <= 0.0:
		slam_hitbox.monitoring = false
		_change_state(State.WALK if is_instance_valid(_player) else State.IDLE)

# ── Echo Attack (faz 2 özel) ───────────────────────────────────────────────────
func _tick_echo_attack(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, SPEED_P2 * 8.0 * delta)
	var elapsed := ECHO_ATTACK_DUR - _state_timer

	if not _hit_landed and elapsed >= ECHO_ATTACK_DUR * 0.55:
		_hit_landed       = true
		_special_cooldown = SPECIAL_COOLDOWN
		_echo_pending     = true
		_open_hitbox(hitbox, 0.15, ECHO_DAMAGE, SHAKE_LIGHT, HIT_PAUSE_LIGHT)

	if _state_timer <= 0.0:
		hitbox.monitoring = false
		if _echo_pending:
			_echo_pending = false
			get_tree().create_timer(ECHO_DELAY).timeout.connect(_fire_echo)
		_change_state(State.WALK if is_instance_valid(_player) else State.IDLE)

func _fire_echo() -> void:
	if not is_instance_valid(self) or state == State.DEAD:
		return
	EventBus.boss_sound_rupture.emit(0.3)
	_open_hitbox(hitbox, 0.15, ECHO_DAMAGE, SHAKE_LIGHT, HIT_PAUSE_LIGHT)

# ── Last Bell (faz 2 ultimate) ─────────────────────────────────────────────────
func _tick_last_bell(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, SPEED_P2 * 8.0 * delta)
	var elapsed := LAST_BELL_DUR - _state_timer

	if not _hit_landed and elapsed >= LAST_BELL_FREEZE:
		_hit_landed         = true
		_last_bell_cooldown = LAST_BELL_COOLDOWN
		EventBus.boss_sound_rupture.emit(1.5)
		_open_hitbox(slam_hitbox, 0.30, LAST_BELL_DAMAGE, SHAKE_SLAM, HIT_PAUSE_HEAVY)

	if _state_timer <= 0.0:
		slam_hitbox.monitoring = false
		_change_state(State.WALK if is_instance_valid(_player) else State.IDLE)

func _tick_hurt(delta: float) -> void:
	# Hasar yedikten sonra oyuncudan uzaklaş — nefes alma boşluğu yaratır
	if is_instance_valid(_player):
		var away : float = sign(global_position.x - _player.global_position.x)
		if away == 0.0: away = 1.0
		velocity.x = move_toward(velocity.x, away * (SPEED * 0.5), SPEED * 5.0 * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED * 8.0 * delta)
	if _state_timer <= 0.0:
		_change_state(State.WALK if is_instance_valid(_player) else State.IDLE)

# ── saldırı kararı ─────────────────────────────────────────────────────────────
func _decide_attack() -> void:
	# Agresyon arttıkça özel saldırı cooldown'u kısalır
	var effective_cd := _special_cooldown - (_aggression * 3.0)

	if phase == 1:
		# Çok fazla light attack yaptıysa veya cooldown dolduysa slam yap
		var force_slam := _light_combo >= LIGHT_COMBO_LIMIT or effective_cd <= 0.0
		if force_slam:
			_next_attack  = State.RESONANCE_SLAM
			_light_combo  = 0
		else:
			_next_attack  = State.LIGHT_ATTACK
			_light_combo += 1
	else:
		if _last_bell_cooldown <= 0.0:
			_next_attack = State.LAST_BELL
			_light_combo = 0
		elif effective_cd <= 0.0 or _light_combo >= LIGHT_COMBO_LIMIT:
			_next_attack = State.ECHO_ATTACK
			_light_combo = 0
		else:
			_next_attack  = State.LIGHT_ATTACK
			_light_combo += 1

# ── durum geçişi ───────────────────────────────────────────────────────────────
func _change_state(new_state: int) -> void:
	state       = new_state
	_hit_landed = false

	match new_state:
		State.IDLE:
			_state_timer = 0.0
			sprite.play("idle")
		State.WALK:
			_state_timer = 0.0
			if sprite.animation != "walk":
				sprite.play("walk")
		State.TELEGRAPH:
			var dur := TELEGRAPH_DUR_P2 if phase == 2 else TELEGRAPH_DUR
			_state_timer = dur
			sprite.play("idle")
			sprite.modulate = Color(1.0, 0.85, 0.15)
			if is_instance_valid(_player):
				_set_facing(_player.global_position.x >= global_position.x)
		State.LIGHT_ATTACK:
			_state_timer = LIGHT_ATTACK_DUR_P2 if phase == 2 else LIGHT_ATTACK_DUR
			sprite.play("light_attack")
		State.RESONANCE_SLAM:
			_state_timer = RESONANCE_SLAM_DUR
			sprite.play("special_attack")
		State.ECHO_ATTACK:
			_state_timer = ECHO_ATTACK_DUR
			sprite.play("light_attack")
		State.LAST_BELL:
			_state_timer = LAST_BELL_DUR
			sprite.play("special_attack")
			sprite.modulate = Color(0.9, 0.7, 1.0)
		State.PHASE_TRANSITION:
			hitbox.monitoring      = false
			slam_hitbox.monitoring = false
			_do_phase_transition()
		State.HURT:
			_state_timer = HURT_DUR
			sprite.play("idle")
			sprite.modulate = Color(1.0, 0.3, 0.3)
			get_tree().create_timer(HURT_DUR).timeout.connect(
				func(): if is_instance_valid(self) and state != State.DEAD:
					sprite.modulate = Color.WHITE
			)
		State.DEAD:
			_die()

# ── faz geçiş sahnesi ──────────────────────────────────────────────────────────
func _do_phase_transition() -> void:
	set_physics_process(false)
	velocity = Vector2.ZERO

	# Diz çöküyor — karanlık titreme
	sprite.play("idle")
	sprite.modulate = Color(0.15, 0.15, 0.15)
	await get_tree().create_timer(1.0).timeout
	if not is_instance_valid(self):
		return

	# Kulak mühürlerini koparıyor — kırmızı flash + ses kırılması + shake
	sprite.modulate = Color(0.9, 0.05, 0.05)
	EventBus.boss_sound_rupture.emit(2.0)
	EventBus.camera_shake.emit(14.0, 0.6)
	await get_tree().create_timer(1.5).timeout
	if not is_instance_valid(self):
		return

	# Faz 2 aktif
	phase = 2
	sprite.modulate = Color.WHITE
	EventBus.boss_phase_changed.emit(2)
	set_physics_process(true)
	_special_cooldown   = 0.0   # faz 2'de hemen özel saldırı
	_last_bell_cooldown = LAST_BELL_COOLDOWN
	_change_state(State.WALK if is_instance_valid(_player) else State.IDLE)

# ── hasar ve ölüm ──────────────────────────────────────────────────────────────
func take_damage(amount: int) -> void:
	if state == State.DEAD or state == State.PHASE_TRANSITION:
		return
	hp -= amount
	EventBus.boss_hit.emit(hp, MAX_HP)
	_aggression = 1.0 - (float(max(hp, 0)) / float(MAX_HP))
	if hp <= 0:
		_change_state(State.DEAD)
	elif phase == 1 and hp <= PHASE_2_HP:
		_change_state(State.PHASE_TRANSITION)
	elif _stagger_immunity > 0.0:
		# Hasar alındı ama stagger yok — poise koruması aktif
		sprite.modulate = Color(1.0, 0.6, 0.6)
		get_tree().create_timer(0.12).timeout.connect(
			func(): if is_instance_valid(self) and state != State.DEAD:
				sprite.modulate = Color.WHITE
		)
	else:
		_stagger_immunity = STAGGER_IMMUNITY
		_change_state(State.HURT)

func _die() -> void:
	set_physics_process(false)
	hitbox.monitoring = false
	hurtbox.set_deferred("monitoring", false)
	sprite.modulate = Color.WHITE
	sprite.play("death")
	EventBus.boss_died.emit()
	await sprite.animation_finished
	await get_tree().create_timer(0.8).timeout
	EventBus.show_dialogue.emit("Bell Keeper", "...do not let it hear you...")
	await get_tree().create_timer(2.5).timeout
	queue_free()

# ── yardımcılar ────────────────────────────────────────────────────────────────
func _set_facing(right: bool) -> void:
	if _facing_right == right:
		return
	_facing_right          = right
	sprite.flip_h          = right   # yeni sprite'lar sola bakıyor, sağa dönerken flip
	var sign_x             := 1 if right else -1
	hitbox.position.x      = abs(hitbox.position.x)      * sign_x
	slam_hitbox.position.x = abs(slam_hitbox.position.x) * sign_x

# body_entered sinyali: hitbox aktifken yeni giren bedenler için
func _on_attack_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		var dmg := ECHO_DAMAGE if state == State.ECHO_ATTACK else LIGHT_DAMAGE
		body.take_damage(dmg)

func _on_slam_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(LAST_BELL_DAMAGE if state == State.LAST_BELL else RESONANCE_DAMAGE)

# Hitbox açar + o anda içeride olan oyuncuyu direkt kontrol eder
# (body_entered sinyali önceden içeride olan bedenleri tetiklemez)
func _open_hitbox(box: Area2D, window: float, damage: int,
				  shake: Vector2, pause_dur: float) -> void:
	box.monitoring = true
	_hitbox_timer  = window
	# Direkt AABB kontrolü — sinyal mekanizmasını bypass eder
	if is_instance_valid(_player) and _player.has_method("take_damage"):
		var shape_half := Vector2(25.0, 19.0) if box == hitbox else Vector2(39.0, 24.0)
		var diff := _player.global_position - box.global_position
		if abs(diff.x) <= shape_half.x + 16.0 and abs(diff.y) <= shape_half.y + 26.0:
			_player.take_damage(damage)
			EventBus.camera_shake.emit(shake.x, shake.y)
			_hit_pause(pause_dur)

func _hit_pause(real_duration: float) -> void:
	Engine.time_scale = 0.05
	await get_tree().create_timer(real_duration, true, false, true).timeout
	Engine.time_scale = 1.0

func _on_detection_entered(body: Node2D) -> void:
	if body.is_in_group("player") and state != State.DEAD:
		_player = body as CharacterBody2D
		if state == State.IDLE:
			_change_state(State.WALK)

func _on_detection_exited(body: Node2D) -> void:
	if body == _player:
		_player = null
