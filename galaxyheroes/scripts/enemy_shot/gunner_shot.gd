class_name GunnerShot
extends Area2D

# --- export --- #
@export var speed : int = 0

# --- onready --- #
@onready var notifier : VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

# --- vector --- #
var direction : Vector2 = Vector2.LEFT

func _process(delta: float) -> void:
	position += direction * speed * delta

func set_direction(dir: Vector2) -> void:
	direction = dir.normalized()
	rotation = direction.angle()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("PLAYER_SHIP"):
		queue_free()
