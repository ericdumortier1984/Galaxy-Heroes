class_name SimpleEnemyMarker
extends Marker2D

# --- export --- #
@export var bullet_scene : PackedScene
@export var shot_interval : float = 1.0

# --- onready --- #
@onready var fire_rate_timer : Timer = $"Fire Rate Timer"

# --- bool --- # 
var can_shoot : bool = false

# --- Array --- #
var active_bullet : Array = []

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
	for bullet in active_bullet:
		if is_instance_valid(bullet):
			bullet.queue_free()
			
	active_bullet.clear()

func spawn_simple_shot() -> void:
	var simple_shot_instance = bullet_scene.instantiate()
	get_tree().current_scene.add_child(simple_shot_instance)
	simple_shot_instance.global_position = global_position
	simple_shot_instance.set_direction(Vector2.LEFT)
	simple_shot_instance.set_parent(get_parent())
	active_bullet.append(simple_shot_instance)

func _on_fire_rate_timer_timeout() -> void:
	if not can_shoot:
		return
	if GlobalSingleton.game_state != GlobalSingleton.GameState.PLAYING:
		return
	
	spawn_simple_shot()
