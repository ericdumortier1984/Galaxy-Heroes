class_name FlyerTurretMarkerShot
extends Marker2D

# --- export --- #
@export var first_boss_bullet_scene : PackedScene
@export var shot_interval : float

# --- onready --- #
@onready var first_boss_shot_marker_timer : Timer = $"Fire rate timer"

# --- bool --- #
var can_shot : bool = false

# --- vector --- #
var first_boss_shot_direction : Vector2 

func _ready() -> void:
	first_boss_shot_marker_timer.wait_time = shot_interval

func start_shot_first_boss() -> void :
	if can_shot:
		return
	
	can_shot = true
	first_boss_shot_marker_timer.start()

func stop_shot_first_boss() -> void :
	can_shot = false
	first_boss_shot_marker_timer.stop()

func spawn_first_boss_bullet_instance(direction: Vector2) -> void:
	var first_bullet_boss_instance = first_boss_bullet_scene.instantiate()
	
	first_boss_shot_direction = direction.normalized()
	first_bullet_boss_instance.global_position = global_position
	first_bullet_boss_instance.set_direction(first_boss_shot_direction)
	
	get_tree().current_scene.add_child(first_bullet_boss_instance)

func _on_fire_rate_timer_timeout() -> void:
	if not can_shot:
		return
	if GlobalSingleton.game_state != GlobalSingleton.GameState.PLAYING:
		return
	
	spawn_first_boss_bullet_instance(Vector2.LEFT)
