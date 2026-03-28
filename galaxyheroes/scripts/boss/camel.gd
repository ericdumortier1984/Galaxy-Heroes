class_name CamelBoss
extends Node2D

enum ThirdBossState { STAND, CROUCH }

signal third_boss_entered
signal third_boss_defeated

# --- export --- #
@export var max_life : int = 100
@export var third_boss_offset : float = 1.0
@export var explosion_animation : AnimatedSprite2D 

# --- onready --- #
@onready var missile_launcher_marker : MissileLauncherMarker = $"Area2D/Missile launcher"
@onready var animated_camel : AnimatedSprite2D = $Area2D/AnimatedSprite2D
@onready var health_bar : ProgressBar = $"Area2D/Life Bar"
@onready var hit_box : Area2D = $Area2D
@onready var damage_sound : AudioStreamPlayer2D = $"Area2D/Explosion/Explosion Sound"
@onready var third_boss_state_timer : Timer = $"State Timer"
@onready var missile_launcher_timer : Timer = $"Missile Pattern Timer"

# --- int --- #
var current_life : int

# --- bool --- #
var is_third_boss_entering = false
var is_third_boss_dying = false
var is_third_boss_defeated = false

# --- state --- #
var third_boss_current_state = ThirdBossState

func _ready() -> void:
	set_health()
	set_third_boss_entry()

func set_health() -> void:
	current_life = max_life
	health_bar.max_value = max_life
	health_bar.value = current_life

func set_third_boss_entry() -> void:
	is_third_boss_entering = true
	
	var screen_size = get_viewport_rect().size
	var screen_target_postion = screen_size.x * 0.8
	
	animated_camel.play("walk")
	var entry_tween = get_tree().create_tween()
	entry_tween.tween_property(
		self, "global_position:x", screen_target_postion, 5.0
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	entry_tween.finished.connect(set_third_boss_entry_finish)

func set_third_boss_entry_finish() -> void:
	is_third_boss_entering = false
	hit_box.monitoring = true
	
	animated_camel.play("idle")
	third_boss_entered.emit()
	missile_launcher_timer.start()
	
	set_initial_third_boss_state()

func set_initial_third_boss_state() -> void:
	change_boss_state(ThirdBossState.STAND)

func change_boss_state(new_state : ThirdBossState) -> void:
	third_boss_current_state = new_state
	
	match third_boss_current_state:
		
		ThirdBossState.STAND:
			animated_camel.play("idle")
			hit_box.monitoring = true
			third_boss_state_timer.wait_time = 2.0
		
		ThirdBossState.CROUCH:
			animated_camel.play("down")
			hit_box.monitoring = false
			third_boss_state_timer.wait_time = 2.0
		
	third_boss_state_timer.start()

func take_damage(amount : int) -> void:
	if GlobalSingleton.game_state != GlobalSingleton.GameState.PLAYING:
		return
	if is_third_boss_entering or is_third_boss_dying or is_third_boss_defeated:
		return
	
	current_life -= amount
	current_life = max(current_life, 0)
	
	explosion_animation.play("explosion")
	damage_sound.play()
	health_bar.value = current_life
	
	if current_life <= 0:
		third_boss_destroyed()

func third_boss_destroyed() -> void:
	if is_third_boss_dying:
		return
	
	is_third_boss_dying = true
	is_third_boss_defeated = true
	
	hit_box.set_deferred("monitoring", false)
	await  set_third_boss_dying_animation()
	third_boss_defeated.emit()
	queue_free()

func set_third_boss_dying_animation() -> void:
	Engine.time_scale = 0.5
	await get_tree().create_timer(0.4, true).timeout
	Engine.time_scale = 1.0
	
	damage_sound.play()
	explosion_animation.scale = Vector2(2, 2)
	explosion_animation.play("explosion")
	
	var explosion_tween = get_tree().create_tween()
	explosion_tween.tween_property(
		animated_camel, "modulate", Color(0.129, 0.129, 0.129, 1.0,), 0.3)
	explosion_tween.tween_property(
		animated_camel, "modulate", Color(0.129, 0.129, 0.129, 1.0), 0.2)
	
	await explosion_tween.finished

func _on_area_2d_area_entered(area: Area2D) -> void:
	if is_third_boss_entering:
		return
	if area.is_in_group("PLAYER_BULLET"):
		take_damage(area.damage)
		area.queue_free()

func _on_shoot_pattern_timer_timeout() -> void:
	missile_launcher_marker.start_shot_third_boss()

func _on_state_timer_timeout() -> void:
	match third_boss_current_state:
		ThirdBossState.STAND:
			change_boss_state(ThirdBossState.CROUCH)
			missile_launcher_marker.stop_shot_third_boss()
		
		ThirdBossState.CROUCH:
			change_boss_state(ThirdBossState.STAND)
