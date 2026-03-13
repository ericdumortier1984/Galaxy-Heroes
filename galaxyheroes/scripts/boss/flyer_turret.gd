class_name FlyerTurret
extends Node2D

enum FirstBossState { UP, CENTER, DOWN }

signal first_boss_entered
signal first_boss_defeated

# --- export --- #
@export var max_life : int = 100
@export var first_boss_offset : float = 1.0
@export var explosion_animation : AnimatedSprite2D

# --- onready --- #
@onready var first_boss_animated_sprite : AnimatedSprite2D = $Area2D/Fly
@onready var health_bar : ProgressBar = $"Area2D/Life Bar"
@onready var hit_box : Area2D =  $Area2D
@onready var damage_sound : AudioStreamPlayer2D = $"Area2D/Explosion/Exposion Sound"
@onready var first_boss_state_timer : Timer = $"State Timer"
@onready var shot_pattern_timer : Timer = $"Shot Pattern Timer"

# --- int --- #
var current_life : int
var pattern_index : int = 0

# --- bool --- #
var is_first_boss_entering : bool = false
var is_first_boss_defeated : bool = false
var is_first_boss_dying : bool = false

# --- fight_position --- #
var target_position : float
var position_up : float
var position_center : float
var position_down : float

# --- state --- #
var current_first_boss_state : FirstBossState

func _ready() -> void:
	set_health()
	set_first_boss_entry()

func _process(delta: float) -> void:
	if is_first_boss_entering or is_first_boss_dying or is_first_boss_defeated:
		return
	
	position.x += sin(Time.get_ticks_msec() * 0.002) * 0.5

func set_health() -> void:
	current_life = max_life
	health_bar.max_value = max_life
	health_bar.value = current_life

func set_first_boss_entry() -> void:
	is_first_boss_entering = true
	
	var screen_size = get_viewport_rect().size
	var screen_target_postion = screen_size.x * 0.8
	
	var entry_tween = get_tree().create_tween()
	entry_tween.tween_property(
		self, "global_position:x", screen_target_postion, 5.0
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	entry_tween.finished.connect(set_first_boss_entry_finish)

func set_first_boss_entry_finish() -> void:
	is_first_boss_entering = false
	hit_box.monitoring = true
	
	first_boss_entered.emit()
	set_fight_position()
	set_first_boss_state()
	shot_pattern_timer.start()

func take_damage(amount : int) -> void:
	if GlobalSingleton.game_state != GlobalSingleton.GameState.PLAYING:
		return
	if is_first_boss_entering or is_first_boss_dying or is_first_boss_defeated:
		return
	
	current_life -= amount
	current_life = max(current_life, 0)
	
	explosion_animation.play("explosion")
	damage_sound.play()
	health_bar.value = current_life
	
	if(current_life <= 0):
		first_boss_destroyed()

func first_boss_destroyed() -> void:
	if is_first_boss_dying:
		return
	
	is_first_boss_dying = true
	is_first_boss_defeated = true
	
	hit_box.set_deferred("monitoring", false)
	await  set_first_boss_dying_animation()
	first_boss_defeated.emit()
	queue_free()

func set_first_boss_dying_animation() -> void:
	Engine.time_scale = 0.5
	await get_tree().create_timer(0.4, true).timeout
	Engine.time_scale = 1.0
	
	damage_sound.play()
	explosion_animation.scale = Vector2(2, 2)
	explosion_animation.play("explosion")
	
	var explosion_tween = get_tree().create_tween()
	explosion_tween.tween_property(
		first_boss_animated_sprite, "modulate", Color(0.129, 0.129, 0.129, 1.0,), 0.3)
	explosion_tween.tween_property(
		first_boss_animated_sprite, "modulate", Color(0.129, 0.129, 0.129, 1.0), 0.2)
	
	await explosion_tween.finished

func set_fight_position() -> void:
	var screen_size = get_viewport_rect().size
	position_up = screen_size.y * 0.3
	position_center = screen_size.y * 0.5
	position_down = screen_size.y * 0.8

func set_first_boss_state() -> void:
	change_first_boss_state(FirstBossState.CENTER)

func change_first_boss_state(new_state : FirstBossState) -> void:
	current_first_boss_state = new_state
	
	match current_first_boss_state:
		FirstBossState.UP:
			target_position = position_up
			first_boss_state_timer.wait_time = 2.0
		FirstBossState.CENTER:
			target_position = position_center
			first_boss_state_timer.wait_time = 2.0
		FirstBossState.DOWN:
			target_position = position_down
			first_boss_state_timer.wait_time = 2.0
	
	set_first_boss_fight_movement_tween()
	first_boss_state_timer.start()

func set_first_boss_fight_movement_tween() -> void:
	var fight_movement_tween = get_tree().create_tween()
	fight_movement_tween.tween_property(
		self, "global_position:y", target_position, 1.2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _on_area_2d_area_entered(area: Area2D) -> void:
	if is_first_boss_entering:
		return
	if area.is_in_group("PLAYER_BULLET"):
		take_damage(area.damage)
		area.queue_free()

func _on_state_timer_timeout() -> void:
	var new_first_boss_state = current_first_boss_state
	
	while new_first_boss_state == current_first_boss_state:
		new_first_boss_state = randi() % 3
	
	change_first_boss_state(new_first_boss_state)

func _on_shot_pattern_timer_timeout() -> void:
	for marker in get_tree().get_nodes_in_group("BOSS_MARKER"):
		marker.start_shot_first_boss()
