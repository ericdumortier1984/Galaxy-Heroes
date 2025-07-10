class_name EnemyBullet
extends Area2D

@export var speed = 0
var direction = Vector2.LEFT

func _physics_process(delta):
	position += direction * speed * delta

	if not get_viewport_rect().has_point(global_position):
		queue_free()

func set_direction(new_direction: Vector2):
	direction = new_direction.normalized()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("my_ship"):
		queue_free()
