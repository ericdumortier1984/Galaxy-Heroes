class_name CyclopMarker
extends Marker2D

# --- export --- #
@export var laser_scene : PackedScene
@export var shot_interval : float = 0.5

# --- onready --- #
@onready var fire_rate_timer : Timer = $"Fire Rate Timer"

# --- bool --- # 
var can_shoot : bool = false

# --- Array --- #
var active_lasers : Array = []

func _ready() -> void:
	set_shoot_timer()
	start_shooting()

func set_shoot_timer() -> void:
	fire_rate_timer.wait_time = shot_interval

func start_shooting() -> void:
	can_shoot = true
	fire_rate_timer.start()

func stop_shooting() -> void:
	can_shoot = false
	fire_rate_timer.stop()
	for laser in active_lasers:
		if is_instance_valid(laser):
			laser.queue_free()
			
	active_lasers.clear()

func spawn_laser_shot() -> void:
	var laser_instance = laser_scene.instantiate()
	get_tree().current_scene.add_child(laser_instance)
	laser_instance.global_position = global_position
	laser_instance.set_direction(Vector2.LEFT)
	laser_instance.set_parent(get_parent())
	active_lasers.append(laser_instance)

func _on_fire_rate_timer_timeout() -> void:
	if not can_shoot:
		return
	if GlobalSingleton.game_state != GlobalSingleton.GameState.PLAYING:
		return
	
	spawn_laser_shot()
