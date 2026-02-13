class_name Level1Boss
extends Node2D

signal boss_entered
signal boss_defeated

# --- export --- #
@export var max_life : int = 100
@export var boss_offset : float = 1.0
@export var thrust_animation : AnimatedSprite2D
@export var explosion_animation : AnimatedSprite2D

# --- onready ---# 
@onready var boss_animated_sprite : AnimatedSprite2D = $Area2D/AnimatedSprite2D
@onready var boss_health_bar : ProgressBar = $Area2D/ProgressBar
@onready var boss_hit_box : Area2D = $Area2D
@onready var shoot_marker : ShootMarkerBoss = $"Area2D/Shoot Marker"
@onready var pattern_change_time : Timer = $"Shoot Pattern Timer"
@onready var damage_sound : AudioStreamPlayer2D = $"Area2D/Explosion/Damage Sound"

var current_life : int
var pattern_index := 0
var is_boss_defeated : bool = false
var is_boss_entering : bool = false

func _ready() -> void:
	current_life = max_life
	boss_health_bar.max_value = max_life
	boss_health_bar.value = current_life
	set_boss_entry()

func set_boss_entry():
	is_boss_entering = true
	thrust_animation.play("Thrust on")
	var screen_size = get_viewport_rect().size
	var boss_width_size = boss_animated_sprite.sprite_frames.get_frame_texture("idle", 0).get_size().x
	var boss_position_target = screen_size.x * 0.8
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position:x", boss_position_target, 5.0 )\
	.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	tween.finished.connect(set_boss_entry_finish)

func get_intro_boss_dialogue_id(ship_id: int) -> String:
	match ship_id:
		0:
			return "ryo_intro_boss_level_1"
		1:
			return "billy_intro_boss_level_1"
		2:
			return "kimi_intro_boss_level_1"
		_:
			return "ryo_intro_boss_level_1"

func start_intro_boss_dialogue():
	var ship_id := SaveSystem.data.selecter_character_id
	var dialogue_id := get_intro_boss_dialogue_id(ship_id)

	GlobalSingleton.set_state(GlobalSingleton.GameState.DIALOGUING)
	DialogueManager.show_dialogue_balloon(
		load("res://dialogues/intro_boss_level_1_dialogue.dialogue"), dialogue_id)

func on_dialogue_ended(resource):
	GlobalSingleton.set_state(GlobalSingleton.GameState.PLAYING)

func set_boss_entry_finish():
	start_intro_boss_dialogue()
	DialogueManager.dialogue_ended.connect(on_dialogue_ended)
	is_boss_entering = false
		
	boss_hit_box.monitoring = true
	boss_entered.emit()
	shoot_marker.start()
	
	pattern_index = 0
	shoot_marker.set_shoot_pattern_id(pattern_index)
	pattern_change_time.start()

func take_damage(amount : int):
	if GlobalSingleton.game_state != GlobalSingleton.GameState.PLAYING:
		return
	if is_boss_defeated or is_boss_entering:
		return
	
	current_life -= amount
	explosion_animation.play("explosion")
	damage_sound.play()
	current_life = max(current_life, 0)
	boss_health_bar.value = current_life
	
	if current_life <= 0:
		boss_destroyed()

func boss_destroyed():
	is_boss_defeated = true
	boss_hit_box.set_deferred("monitoring", false)
	boss_defeated.emit()
	queue_free()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("PLAYER_BULLET") && !is_boss_entering:
		take_damage(area.damage)
		area.queue_free()

func _on_shoot_pattern_timer_timeout() -> void:
	if is_boss_defeated:
		return
		
	pattern_index = (pattern_index + 1) % 3
	shoot_marker.set_shoot_pattern_id(pattern_index)
