class_name ShootMarkerBoss
extends Marker2D

# --- export --- #
@export var bullet_boss_scene : PackedScene
@export var fire_ball_scene : PackedScene
@export var fire_rate : float = 1.0
@export var flash_animation : AnimatedSprite2D
@export var fire_timer : Timer

# --- bool --- #
var can_shoot : bool = false

# --- int --- #
var current_pattern : int = 0

func start() -> void:
	can_shoot = true
	fire_timer.wait_time = fire_rate
	fire_timer.start()

func stop() -> void:
	can_shoot = false
	fire_timer.stop()

func set_shoot_pattern_id(id : int) -> void:
	current_pattern = id

func set_fire_rate(value : float) -> void: 
	fire_rate = value
	fire_timer.wait_time = fire_rate

func set_boss_fire_ball(direction : Vector2, offset := Vector2.ZERO):
	var fire_ball = fire_ball_scene.instantiate()
	fire_ball.global_position = global_position + offset
	fire_ball.set_direction(direction.normalized())
	get_tree().current_scene.add_child(fire_ball)
	flash_animation.play()

func set_boss_bullet(direction : Vector2) -> void:
	var boss_bullet = bullet_boss_scene.instantiate()
	boss_bullet.global_position = global_position
	boss_bullet.set_direction(direction.normalized())
	boss_bullet.set_parent(self)
	get_tree().current_scene.add_child(boss_bullet)

func set_shoot_pattern_straight() -> void:
	set_boss_bullet(Vector2.LEFT)

func set_shot_pattern_double() -> void:
	set_boss_bullet(Vector2.LEFT + Vector2.UP * 0.2)
	set_boss_bullet(Vector2.LEFT + Vector2.DOWN * 0.2)

func set_shot_pattern_fan() -> void:
	for angle in [-0.2, 0.0, 0.4,
				  -0.6, 0.2, 0.6,
				  -0.10, 0.4, 0.10]:
		set_boss_bullet(Vector2.LEFT.rotated(angle))

func set_shot_fire_line() -> void:
	var fire_ball_count := 5
	var fire_ball_spacing := 5
	var fire_ball_random_angle := randf_range(-0.5, 0.5)
	var direction := Vector2.LEFT.rotated(fire_ball_random_angle)
	
	for i in fire_ball_count:
		var fire_ball_spawn_offset :=  -direction * fire_ball_spacing * i
		set_boss_fire_ball(direction, fire_ball_spawn_offset)

func shoot_radial() -> void:
	var bullets := 25
	
	for i in bullets:
		var angle = (TAU / bullets) * i
		set_boss_bullet(Vector2.RIGHT.rotated(angle))

func set_fan_shot_fire_ball() -> void:
	var fire_ball_count := 8
	var total_angle := 0.8
	var angle_step := total_angle / (fire_ball_count - 1)
	var start_angle := -total_angle / 2
	
	for i in fire_ball_count:
		var angle := start_angle + (i * angle_step)
		var direction := Vector2.LEFT.rotated(angle)
		
		set_boss_fire_ball(direction, Vector2.ZERO)

func _on_fire_rate_timer_timeout() -> void:
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
		3:
			shoot_radial()
		4:
			set_shot_fire_line()
		5:
			set_fan_shot_fire_ball()
