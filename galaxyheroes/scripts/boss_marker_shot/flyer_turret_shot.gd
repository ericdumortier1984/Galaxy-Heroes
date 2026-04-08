class_name FlyerTurretMarkerShot
extends Marker2D

# --- export --- #
@export var bullet_scene : PackedScene
@export var shot_interval : float

# --- onready --- #
@onready var flyer_turret_shot_marker_timer : Timer = $"Fire rate timer"
@onready var fire_flash_animation : AnimatedSprite2D = $"../Flash"

# --- bool --- #
var can_shot : bool = false

# --- vector --- #
var flyer_turret_shot_direction : Vector2 

func _ready() -> void:
	flyer_turret_shot_marker_timer.wait_time = shot_interval

func start_shot_first_boss() -> void :
	if can_shot:
		return
	
	can_shot = true
	flyer_turret_shot_marker_timer.start()

func stop_shot_first_boss() -> void :
	can_shot = false
	flyer_turret_shot_marker_timer.stop()

func spawn_flyer_turret_bullet_instance(direction: Vector2) -> void:
	var bullet_boss_instance = bullet_scene.instantiate()
	
	flyer_turret_shot_direction = direction.normalized()
	bullet_boss_instance.global_position = global_position
	bullet_boss_instance.set_direction(flyer_turret_shot_direction)
	
	get_tree().current_scene.add_child(bullet_boss_instance)
	bullet_boss_instance.play_animation()

func _on_fire_rate_timer_timeout() -> void:
	if not can_shot:
		return
	if GlobalSingleton.game_state != GlobalSingleton.GameState.PLAYING:
		return
	
	fire_flash_animation.play("fire_flash")
	spawn_flyer_turret_bullet_instance(Vector2.LEFT)
