class_name FinalBossShotMarker
extends Marker2D

# --- export --- #
@export var final_boss_bullet_scene : PackedScene
@export var final_boss_fire_rate : float

# --- onready --- #
@onready var final_boss_fire_rate_timer : Timer = $"Fire Rate Timer"

# --- bool --- #
var is_final_boss_can_shoot : bool = false

# --- int --- #
var current_shot_pattern_index : int = 0

func start_shot() -> void:
	is_final_boss_can_shoot = true
	final_boss_fire_rate_timer.wait_time = final_boss_fire_rate
	final_boss_fire_rate_timer.start()

func stop_shot() -> void:
	is_final_boss_can_shoot = false
	final_boss_fire_rate_timer.stop()

func set_shot_pattern_index(pattern_id : int) -> void:
	current_shot_pattern_index = pattern_id

func shoot(direction : Vector2) -> void:
	var final_boss_bullet = final_boss_bullet_scene.instantiate()
	final_boss_bullet.global_position = global_position
	final_boss_bullet.set_direction(direction.normalized())
	final_boss_bullet.set_parent(self)
	get_tree().current_scene.add_child(final_boss_bullet)

func shoot_cone() -> void:
	for angle in [-0.5, -0.25, 0, 0.25, 0.5]:
		shoot(Vector2.LEFT.rotated(angle))

func shoot_radial() -> void:
	var bullets := 25
	
	for i in bullets:
		var angle = (TAU / bullets) * i
		shoot(Vector2.RIGHT.rotated(angle))

func _on_fire_rate_timer_timeout() -> void:
	if not is_final_boss_can_shoot:
		return
	if GlobalSingleton.game_state != GlobalSingleton.GameState.PLAYING:
		return
	
	match current_shot_pattern_index:
		0:
			shoot_cone()
		1:
			shoot_radial()
