class_name SimpleBullet
extends Area2D

# --- export --- #
@export var speed = 0
@export var damage = 0

# --- Vector2 --- #
var direction = Vector2.ZERO

func _physics_process(delta):
	position += direction * speed * delta

func set_direction(new_direction):
	direction = new_direction.normalized() 

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemy"):
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
