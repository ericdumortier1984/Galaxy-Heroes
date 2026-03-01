class_name ShootMarkerLevel2
extends Marker2D

# --- export --- #
@export var bullet_boss_scene : PackedScene
@export var drone_scene : PackedScene
@export var shot_interval : float = 0.5

# --- onready --- #
@onready var fire_rate_timer : Timer = $"Fire Rate Timer"

# --- bool --- # 
var can_shoot : bool = false

func _ready() -> void:
	set_shoot_timer()

func set_shoot_timer():
	fire_rate_timer.wait_time = shot_interval

func start_shooting_drone() -> void:
	can_shoot = true
	fire_rate_timer.start()

func stop_shooting() -> void:
	can_shoot = false
	fire_rate_timer.stop()

func spawn_drone() -> void:
	var drone_scene_instance = drone_scene.instantiate()
	drone_scene_instance.spawned_by_boss = true
	get_tree().current_scene.add_child(drone_scene_instance)
	drone_scene_instance.global_position = global_position

func spawn_boss_bullet() -> void:
	var bullet_boss_instance = bullet_boss_scene.instantiate()
	get_tree().current_scene.add_child(bullet_boss_instance)
	bullet_boss_instance.global_position = global_position

func _on_fire_rate_timer_timeout() -> void:
	if not can_shoot:
		return
	if GlobalSingleton.game_state != GlobalSingleton.GameState.PLAYING:
		return
	
	spawn_drone()
