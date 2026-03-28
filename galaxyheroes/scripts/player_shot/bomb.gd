class_name Bomb
extends Area2D

signal bomb_process_finish

# --- export --- #
@export var damage : int = 0
@export var shot_velocity : Vector2 = Vector2.ZERO
@export var shot_gravity : Vector2 = Vector2(0,0)

# --- onready --- #
@onready var screen_notifier : VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

func _process(delta: float) -> void:
	shot_velocity += shot_gravity * delta
	position += shot_velocity * delta

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("ENEMIES"):
		emit_signal("bomb_process_finish")
		queue_free()
	if area.is_in_group("BOSSES"):
		emit_signal("bomb_process_finish")
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	emit_signal("bomb_process_finish")
	queue_free()
