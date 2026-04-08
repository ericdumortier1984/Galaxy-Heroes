class_name BulletRain
extends Area2D

signal rain_process_finish

# --- export --- #
@export var bullet_scene : PackedScene
@export var rain_timer : float = 0.0
@export var rain_fire_rate : float = 0.0
@export var rain_speed : float = 0.0
@export var rain_width : float = 0.0

# --- onready --- #
@onready var screen_notifier : VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

# --- timer --- #
var timer : float = 0.0
var fire_rate_timer : float = 0.0

# --- position --- #
var screen_size : Vector2

func _ready() -> void:
	screen_size = get_viewport_rect().size

func _process(delta: float) -> void:
	set_fire_rate_timer(delta)
	set_fire_rain_timer(delta)

func set_fire_rate_timer(delta : float) -> void:
	fire_rate_timer -= delta
	if fire_rate_timer <= 0.0:
		spawn_bullet_rain()
		fire_rate_timer = rain_fire_rate

func set_fire_rain_timer(delta : float) -> void:
	timer += delta
	if timer >= rain_timer:
		emit_signal("rain_process_finish")
		queue_free()

func spawn_bullet_rain() -> void:
	#var x_pos = randf_range(0, screen_size.x)
	var y_pos = -20
	var center_x = screen_size.x / 2
	var x_pos = randf_range(center_x - rain_width, center_x + rain_width)
	
	var rain_bullet_instance = bullet_scene.instantiate()
	rain_bullet_instance.global_position = Vector2(x_pos, y_pos)
	#rain_bullet_instance.set_direction(Vector2(randf_range(-0.1, 0.1), 1))
	var direction = Vector2(randf_range(0.3, 0.7), 1).normalized()
	rain_bullet_instance.set_direction(direction)
	rain_bullet_instance.speed = rain_speed
	get_parent().add_child(rain_bullet_instance)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("ENEMIES"):
		queue_free()
	if area.is_in_group("BOSSES"):
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
