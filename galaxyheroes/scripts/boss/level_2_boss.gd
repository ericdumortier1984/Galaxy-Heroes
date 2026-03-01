class_name Level2Boss
extends Node2D

enum BossState { IDLE, OPEN, CLOSE }

signal boss_entered
signal boss_defeated

# --- export --- #
@export var max_life : int = 100
@export var boss_offset : float = 1.0
@export var explosion_animation : AnimatedSprite2D

# --- onready ---# 
@onready var boss_animated_sprite : AnimatedSprite2D = $Area2D/AnimatedSprite2D
@onready var boss_health_bar : ProgressBar = $Area2D/ProgressBar
@onready var boss_hit_box : Area2D = $Area2D
@onready var state_timer : Timer = $"State Timer"
@onready var damage_sound : AudioStreamPlayer2D = $"Area2D/Explosion/Explosion Sound"

# --- int --- #
var current_life : int
var pattern_index := 0

# --- bool --- # 
var is_boss_defeated : bool = false
var is_boss_entering : bool = false
var is_boss_dying : bool = false

# --- state --- #
var current_state : BossState = BossState.IDLE

func _ready() -> void:
	set_boss_bar_health()
	set_boss_entry()

func set_boss_bar_health() -> void:
	current_life = max_life
	boss_health_bar.max_value = max_life
	boss_health_bar.value = current_life

func set_boss_entry() -> void:
	is_boss_entering = true
	
	var screen_size = get_viewport_rect().size
	var boss_position_target = screen_size.x * 0.8
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position:x", boss_position_target, 5.0 )\
	.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	tween.finished.connect(set_boss_entry_finish)

func set_boss_entry_finish() -> void:
	is_boss_entering = false
	boss_hit_box.monitoring = true
	
	boss_entered.emit()
	set_boss_state()

func set_boss_state() -> void:
	change_boss_state(BossState.IDLE)
	state_timer.start()

func change_boss_state(new_state : BossState):
	current_state = new_state
	
	match current_state:
		BossState.IDLE:
			boss_animated_sprite.play("idle")
			state_timer.wait_time = 2.0
		
		BossState.OPEN:
			boss_animated_sprite.play("open")
			state_timer.wait_time = 1.0
		
		BossState.CLOSE:
			boss_animated_sprite.play("close")
			state_timer.wait_time = 5.0
	state_timer.start()

func take_damage(amount : int):
	if GlobalSingleton.game_state != GlobalSingleton.GameState.PLAYING:
		return
	if current_state != BossState.IDLE:
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

func boss_destroyed() -> void:
	if is_boss_dying:
		return
	
	is_boss_dying = true
	is_boss_defeated = true
	
	boss_hit_box.set_deferred("monitoring", false)
	
	await play_boss_destroying_animation()
	
	boss_defeated.emit()
	queue_free()

func play_boss_destroying_animation() -> void:
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

func start_shoot_marker() -> void:
	for boss_marker in get_tree().get_nodes_in_group("BOSS_MARKER"):
		boss_marker.start_shooting_drone()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("PLAYER_BULLET") && !is_boss_entering:
		take_damage(area.damage)
		area.queue_free()

func _on_state_timer_timeout() -> void:
	match current_state:
		BossState.IDLE:
			change_boss_state(BossState.CLOSE)
			start_shoot_marker()
		
		BossState.CLOSE:
			change_boss_state(BossState.OPEN)
		
		BossState.OPEN:
			change_boss_state(BossState.IDLE)
