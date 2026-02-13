class_name ShootMarkerBoss
extends Marker2D

# --- export --- #
@export var bullet_boss_scene : PackedScene
@export var fire_rate : float = 2.0

# --- onready --- #
@onready var fire_timer : Timer = $"Fire Rate Timer"

# --- bool --- #
var can_shoot : bool = false

# --- int --- #
var current_pattern : int = 0

func start():
	can_shoot = true
	fire_timer.wait_time = fire_rate
	fire_timer.start()

func stop():
	can_shoot = false
	fire_timer.stop()

func set_shoot_pattern_id(id : int):
	current_pattern = id

func set_boss_bullet(direction : Vector2):
	var boss_bullet = bullet_boss_scene.instantiate()
	boss_bullet.global_position = global_position
	boss_bullet.set_direction(direction.normalized())
	get_tree().current_scene.add_child(boss_bullet)

func set_shoot_pattern_straight():
	set_boss_bullet(Vector2.LEFT)

func set_shot_pattern_double():
	set_boss_bullet(Vector2.LEFT + Vector2.UP * 0.2)
	set_boss_bullet(Vector2.LEFT + Vector2.DOWN * 0.2)

func set_shot_pattern_fan():
	for angle in [-0.2, 0.0, 0.4,
				  -0.4, 0.1, 0.4,
				  -0.6, 0.2, 0.6,
				  -0.8, 0.3, 0.8,
				  -0.10, 0.4, 0.10]:
		set_boss_bullet(Vector2.LEFT.rotated(angle))

func _on_shoot_marker_timer_timeout() -> void:
	if not can_shoot:
		return
	if GlobalSingleton.game_state != GlobalSingleton.GameState.PLAYING:
		return
	
	match current_pattern:
		0:
			set_shoot_pattern_straight()
		1:
			set_shot_pattern_double()
		2:
			set_shot_pattern_fan()
