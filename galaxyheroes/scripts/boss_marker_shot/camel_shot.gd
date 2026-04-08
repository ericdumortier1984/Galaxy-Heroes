class_name MissileLauncherMarker
extends Marker2D

# --- export --- #
@export var missile_scene : PackedScene
@export var missile_launch_interval : float

# --- onready --- #
@onready var missile_launcher_timer : Timer = $"Fire Rate Timer"
@onready var flash_animation : AnimatedSprite2D = $"../Flash"
@onready var sprite_animation : AnimatedSprite2D = $"../AnimatedSprite2D"

# --- bool --- #
var can_shot : bool = false

# --- vector --- #
var missile_direction : Vector2 

func _ready() -> void:
	missile_launcher_timer.wait_time = missile_launch_interval

func start_shot_third_boss() -> void :
	if can_shot:
		return
	
	can_shot = true
	missile_launcher_timer.start()

func stop_shot_third_boss() -> void :
	can_shot = false
	missile_launcher_timer.stop()

func spawn_missile_instance(direction: Vector2) -> void:
	var missile_instance = missile_scene.instantiate()
	
	if sprite_animation.animation == "idle":
		missile_direction = direction.normalized()
		missile_instance.global_position = global_position
		missile_instance.set_direction(missile_direction)
		
		get_tree().current_scene.add_child(missile_instance)
		flash_animation.play("fire_flash")

func _on_fire_rate_timer_timeout() -> void:
	if not can_shot:
		return
	if GlobalSingleton.game_state != GlobalSingleton.GameState.PLAYING:
		return
		
	spawn_missile_instance(Vector2.LEFT)
