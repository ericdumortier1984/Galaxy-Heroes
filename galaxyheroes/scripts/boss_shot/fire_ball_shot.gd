class_name FireBallShot
extends Area2D

# --- export --- #
@export var speed : int = 0
@export var rotation_speed : float = 0.0

# --- onready --- #
@onready var notifier : VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

# --- vector --- #
var direction : Vector2 = Vector2.LEFT

func _process(delta: float) -> void:
	move_fire_ball(delta)
	set_fire_ball_rotation(delta)

func set_direction(new_direction : Vector2) -> void:
	direction = new_direction.normalized()

func move_fire_ball(delta : float) -> void:
	global_position += direction * speed * delta

func set_fire_ball_rotation(delta : float) -> void:
	rotation += rotation_speed * delta

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("PLAYER_SHIP"):
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
