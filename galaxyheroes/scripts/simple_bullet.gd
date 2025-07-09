class_name SimpleBullet
extends Area2D

@export var speed = 300

var direction = Vector2.ZERO

func _physics_process(delta):
	position += direction * speed * delta
	
	if not get_viewport_rect().has_point(global_position):
		queue_free()
		#print("bullet deleted")

func set_direction(new_direction):
	direction = new_direction.normalized() 

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		queue_free()
