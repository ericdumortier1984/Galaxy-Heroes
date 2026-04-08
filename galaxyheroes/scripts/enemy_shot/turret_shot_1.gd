class_name TurretShot01 
extends Area2D

# --- export --- #
@export var speed : int = 0

# --- onready --- #
@onready var screen_notifier : VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

# --- vector --- #
var direction : Vector2 

func _process(delta: float) -> void:
	move_turret_bullet(delta)

func set_direction(new_direction : Vector2) -> void:
	direction = new_direction.normalized()
	rotation = direction.angle()

func move_turret_bullet(delta : float) -> void:
	global_position += direction * speed * delta

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("PLAYER_SHIP"):
		queue_free()
