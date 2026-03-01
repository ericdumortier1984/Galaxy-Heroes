class_name ShootMarkerLevel2
extends Marker2D

# --- export --- #
@export var drone_scene : PackedScene
@export var shot_interval : float = 2.0

# --- onready --- #
@onready var fire_rate_timer : Timer = $"Fire Rate Timer"

# --- bool --- # 
var can_shoot : bool = false

func _ready() -> void:
	set_shoot_timer()

func _process(delta: float) -> void:
	pass

func set_shoot_timer():
	fire_rate_timer.wait_time = shot_interval

func start_shooting():
	print("START SHOOTING")
	can_shoot = true
	fire_rate_timer.start()

func stop_shooting():
	can_shoot = false
	fire_rate_timer.stop()

func spawn_drone():
	var drone_scene_instance = drone_scene.instantiate()
	get_tree().current_scene.add_child(drone_scene_instance)
	drone_scene_instance.global_position = global_position
	print("SPAWN DRONE")

func _on_fire_rate_timer_timeout() -> void:
	if not can_shoot:
		print("NO PUEDE DISPARAR")
		return
	if GlobalSingleton.game_state != GlobalSingleton.GameState.PLAYING:
		print("NO ESTA EN PLAYING")
		return
	
	print("GameState actual: ", GlobalSingleton.game_state)
	print("TIMER FUNCIONA")
	spawn_drone()
