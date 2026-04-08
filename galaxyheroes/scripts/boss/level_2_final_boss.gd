class_name Level2FinalBoss
extends Node2D

signal final_boss_entered
signal final_boss_defeated

# --- export --- #
@export var max_life : int = 100
@export var boss_offset : float = 1.0
@export var thrust_animation : AnimatedSprite2D
@export var explosion_animation : AnimatedSprite2D

# --- onready ---# 
@onready var boss_animated_sprite : AnimatedSprite2D = $Area2D/AnimatedSprite2D
@onready var boss_health_bar : ProgressBar = $Area2D/ProgressBar
@onready var boss_hit_box : Area2D = $Area2D
@onready var shoot_marker : Marker2D = $"Area2D/Shoot Marker"
@onready var pattern_change_time : Timer = $"Shoot Patter Timer"
@onready var damage_sound : AudioStreamPlayer2D = $"Area2D/Explosion/Explosion Sound"

# --- int --- #
var current_life : int
var pattern_index := 0

# --- bool --- # 
var is_final_boss_defeated : bool = false
var is_boss_entering : bool = false
var is_boss_dying : bool = false

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

func set_boss_entry_finish():
	is_boss_entering = false
	boss_hit_box.monitoring = true
	
	final_boss_entered.emit()
	
	shoot_marker.start()
	pattern_index = 0
	shoot_marker.set_shoot_pattern_id(pattern_index)
	pattern_change_time.start()

func update_aura() -> void:
	if boss_animated_sprite.material is ShaderMaterial:
		var mat := boss_animated_sprite.material as ShaderMaterial
		
		var life_amount_ratio := float(current_life) / float(max_life)
		var damage_amount_ratio := 1.0 - life_amount_ratio
		var boss_aura_thickness : float = lerp(0.015, 0.1, damage_amount_ratio)
		var boss_aura_intensity : float = lerp(1.5, 5.0, damage_amount_ratio)
		var boss_aura_speed : float = lerp(2.0, 10.0, damage_amount_ratio)
		mat.set_shader_parameter("aura_thickness", boss_aura_thickness)
		mat.set_shader_parameter("aura_intensity", boss_aura_intensity)
		mat.set_shader_parameter("aura_change_speed", boss_aura_speed)

func take_damage(amount : int):
	if GlobalSingleton.game_state != GlobalSingleton.GameState.PLAYING:
		return
	if is_final_boss_defeated or is_boss_entering or is_boss_dying:
		return
	
	current_life -= amount
	current_life = max(current_life, 0)
	
	explosion_animation.play("explosion")
	damage_sound.play()
	boss_health_bar.value = current_life
	
	if current_life <= 0:
		boss_destroyed()
		
	update_aura()

func boss_destroyed():
	if is_boss_dying:
		return
	
	is_boss_dying = true
	is_final_boss_defeated = true
	
	boss_hit_box.set_deferred("monitoring", false)
	shoot_marker.stop()
	pattern_change_time.stop()
	
	await play_boss_destroying_animation()
	
	final_boss_defeated.emit()
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

func _on_shoot_patter_timer_timeout() -> void:
	if is_final_boss_defeated:
		return
		
	pattern_index = (pattern_index + 1) % 6
	shoot_marker.set_shoot_pattern_id(pattern_index)
