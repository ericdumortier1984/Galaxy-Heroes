class_name FinalBoss
extends Node2D

signal final_boss_entered
signal final_boss_defeated

# --- export --- #
@export var max_life : int = 100
@export var final_boss_offset : float = 1.0
@export var explosion_animation : AnimatedSprite2D
@export var is_almost_destroy : bool = false
@export var override_life : int = -1

# --- onready --- #
@onready var final_boss_animated : AnimatedSprite2D = $"Area2D/Final Boss Animate"
@onready var health_bar : ProgressBar = $"Area2D/Life Bar"
@onready var hit_box : Area2D =  $Area2D
@onready var final_hit_box : CollisionShape2D = $"Area2D/Hit Box 2"
@onready var damage_sound : AudioStreamPlayer2D = $"Area2D/Explosion/Explosion Sound"
@onready var shot_marker : Marker2D = $"Area2D/Shoot Marker"
@onready var shot_pattern_timer : Timer = $"Shot Pattern Timer"

# --- int --- #
var current_life : int
var shot_pattern_index = 0

# --- bool --- #
var is_final_boss_entering = false
var is_final_boss_dying = false
var is_final_boss_defeated = false

func _ready() -> void:
	set_final_boss_health()
	
	if is_almost_destroy:
		set_final_mode() 
	else:
		set_final_boss_entry()

func set_final_boss_health() -> void:
	current_life = max_life
	health_bar.max_value = max_life
	health_bar.value = current_life

func set_final_boss_entry() -> void:
	is_final_boss_entering = true
	
	var screen_size = get_viewport_rect().size
	var screen_position_target = screen_size.x * 0.8
	
	final_boss_animated.play("walk")
	var final_boss_entry_tween = get_tree().create_tween()
	final_boss_entry_tween.tween_property(
		self, "global_position:x", screen_position_target, 5.0
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	final_boss_entry_tween.finished.connect(set_final_boss_entry_finish)

func set_final_boss_entry_finish() -> void:
	is_final_boss_entering = false
	hit_box.monitoring = true
	final_hit_box.disabled = true
	
	final_boss_entered.emit()
	final_boss_animated.play("idle")
	
	shot_marker.start_shot()
	shot_pattern_index = 0
	shot_pattern_timer.start()

func take_damage(amount : int) -> void:
	if GlobalSingleton.game_state != GlobalSingleton.GameState.PLAYING:
		return
	if is_final_boss_entering or is_final_boss_dying or is_final_boss_defeated:
		return
		
	current_life -= amount
	current_life = max(current_life, 0)
	
	explosion_animation.play("explosion")
	damage_sound.play()
	health_bar.value = current_life
	
	if current_life <= 0:
		final_boss_destroyed()

func final_boss_destroyed() -> void:
	if is_final_boss_dying:
		return
	
	is_final_boss_dying = true
	is_final_boss_defeated = true
	
	shot_marker.stop_shot()
	
	hit_box.set_deferred("monitoring", false)
	final_hit_box.set_deferred("disabled", true)
	await  set_final_boss_dying_animation()
	final_boss_defeated.emit()
	queue_free()

func set_final_boss_dying_animation() -> void:
	Engine.time_scale = 0.5
	await get_tree().create_timer(0.4, true).timeout
	Engine.time_scale = 1.0
	
	damage_sound.play()
	explosion_animation.scale = Vector2(2, 2)
	explosion_animation.play("explosion")
	
	var explosion_tween = get_tree().create_tween()
	explosion_tween.tween_property(
		final_boss_animated, "modulate", Color(0.129, 0.129, 0.129, 1.0,), 0.3)
	explosion_tween.tween_property(
		final_boss_animated, "modulate", Color(0.129, 0.129, 0.129, 1.0), 0.2)
	
	await explosion_tween.finished

func set_final_mode() -> void:
	is_final_boss_entering = false
	hit_box.monitoring = true
	final_hit_box.disabled = false
	
	final_boss_animated.play("almost_destroy")
	shot_marker.stop_shot()
	health_bar.visible = false

func _on_area_2d_area_entered(area: Area2D) -> void:
	if is_final_boss_entering:
		return
		
	if area.is_in_group("PLAYER_BULLET"):
		take_damage(area.damage)
		area.queue_free()

func _on_shot_pattern_timer_timeout() -> void:
	if is_final_boss_defeated:
		return
		
	shot_pattern_index = (shot_pattern_index + 1) % 6
	shot_marker.set_shot_pattern_index(shot_pattern_index)
