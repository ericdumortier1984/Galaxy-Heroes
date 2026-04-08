class_name Level1Boss
extends Node2D

enum FirstLevelBossState { FORWARD, ORIGINAL, BACK }

signal boss_entered
signal boss_defeated

# --- export --- #
@export var max_life : int = 1
@export var boss_offset : float = 1.0
@export var thrust_animation : AnimatedSprite2D
@export var explosion_animation : AnimatedSprite2D

# --- onready ---# 
@onready var boss_animated_sprite : AnimatedSprite2D = $Area2D/AnimatedSprite2D
@onready var boss_health_bar : ProgressBar = $Area2D/ProgressBar
@onready var boss_hit_box : Area2D = $Area2D
@onready var shoot_marker : ShootMarkerBoss = $"Area2D/Shoot Marker"
@onready var pattern_change_time : Timer = $"Shoot Pattern Timer"
@onready var position_change_timer : Timer = $"Position State Timer"
@onready var damage_sound : AudioStreamPlayer2D = $"Area2D/Explosion/Damage Sound"

# --- int --- #
var current_life : int
var pattern_index : int = 0

# --- bool --- # 
var is_boss_defeated : bool = false
var is_boss_entering : bool = false
var is_boss_dying : bool = false

# --- fight_position --- #
var target_position : float
var position_forward : float
var position_original : float
var position_back : float

# --- state --- #
var current_first_level_boss_state : FirstLevelBossState

func _ready() -> void:
	set_boss_bar_health()
	set_boss_entry()

func set_boss_bar_health():
	current_life = max_life
	boss_health_bar.max_value = max_life
	boss_health_bar.value = current_life

func set_boss_entry():
	is_boss_entering = true
	
	var screen_size = get_viewport_rect().size
	var boss_position_target = screen_size.x * 0.8
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position:x", boss_position_target, 5.0 )\
	.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	tween.finished.connect(set_boss_entry_finish)
	thrust_animation.stop()

func set_boss_entry_finish():
	is_boss_entering = false
	boss_hit_box.monitoring = true
	
	boss_entered.emit()
	
	shoot_marker.start()
	pattern_index = 0
	shoot_marker.set_shoot_pattern_id(pattern_index)
	pattern_change_time.start()
	set_fight_position()
	set_first_level_boss_state()

func set_fight_position() -> void:
	var screen_size = get_viewport_rect().size
	position_forward = screen_size.x * 0.6
	position_original = screen_size.x * 1.0
	position_back = screen_size.x * 0.8

func set_first_level_boss_state() -> void:
	change_first_level_boss_state(FirstLevelBossState.ORIGINAL)

func change_first_level_boss_state(new_state : FirstLevelBossState) -> void:
	current_first_level_boss_state = new_state
	
	match current_first_level_boss_state:
		FirstLevelBossState.FORWARD:
			target_position = position_forward
			position_change_timer.wait_time = 2.0
		FirstLevelBossState.ORIGINAL:
			target_position = position_original
			position_change_timer.wait_time = 2.0
		FirstLevelBossState.BACK:
			target_position = position_back
			position_change_timer.wait_time = 2.0
	
	set_first_level_boss_fight_movement_tween()
	position_change_timer.start()

func set_first_level_boss_fight_movement_tween() -> void:
	var fight_movement_tween = get_tree().create_tween()
	fight_movement_tween.tween_property(
		self, "global_position:x", target_position, 2.5
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	thrust_animation.play()

func take_damage(amount : int) -> void:
	if GlobalSingleton.game_state != GlobalSingleton.GameState.PLAYING:
		return
	if is_boss_defeated or is_boss_entering or is_boss_dying:
		return
	
	current_life -= amount
	current_life = max(current_life, 0)
	
	explosion_animation.play("explosion")
	damage_sound.play()
	boss_health_bar.value = current_life
	
	if current_life <= 0:
		boss_destroyed()

func boss_destroyed():
	if is_boss_dying:
		return
	
	is_boss_dying = true
	is_boss_defeated = true
	
	boss_hit_box.set_deferred("monitoring", false)
	shoot_marker.stop()
	pattern_change_time.stop()
	
	await play_boss_destroying_animation()
	
	boss_defeated.emit()
	queue_free()

func play_boss_destroying_animation():
	Engine.time_scale = 0.5
	await get_tree().create_timer(0.4, true).timeout
	Engine.time_scale = 1.0
	
	damage_sound.play()
	
	explosion_animation.scale = Vector2(2, 2)
	explosion_animation.play("explosion")
	
	var tween = get_tree().create_tween()
	
	tween.tween_property(boss_animated_sprite, "modulate", Color(0.129, 0.129, 0.129, 1.0), 0.3)
	tween.tween_property(boss_animated_sprite, "modulate", Color(0.129, 0.129, 0.129, 1.0), 0.2)
	
	await tween.finished

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("PLAYER_BULLET") && !is_boss_entering:
		take_damage(area.damage)
		area.queue_free()

func _on_shoot_pattern_timer_timeout() -> void:
	if is_boss_defeated:
		return
		
	pattern_index = (pattern_index + 1) % 4
	shoot_marker.set_shoot_pattern_id(pattern_index)

func _on_position_state_timer_timeout() -> void:
	var new_first_level_boss_state = current_first_level_boss_state
	
	while new_first_level_boss_state == current_first_level_boss_state:
		new_first_level_boss_state = (randi() % 3) as FirstLevelBossState
	
	change_first_level_boss_state(new_first_level_boss_state)
