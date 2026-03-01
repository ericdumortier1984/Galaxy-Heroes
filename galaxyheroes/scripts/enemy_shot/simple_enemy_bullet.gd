class_name EnemyBullet
extends Area2D

# --- export --- #
@export var speed = 0

# --- vector --- #
var direction : Vector2 = Vector2.LEFT

func _physics_process(delta):
	global_position += direction * speed * delta
	if not get_viewport_rect().has_point(global_position):
		queue_free() # de otra manera la bala enemiga no se destruia

func set_direction(new_direction: Vector2):
	direction = new_direction.normalized()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("PLAYER_SHIP"):
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
