class_name FinalBullet
extends Area2D

#signal final_bullet_hit(boss)

# --- export --- #
@export var final_bullet_speed : int
@export var damage : int 

# --- onready --- #
@onready var exit_screen_notifier : VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

# --- vector --- #
var final_bullet_direction : Vector2 = Vector2.RIGHT

# --- target --- #
var final_bullet_target : Node2D

func _process(delta: float) -> void:
	#var target_direction = (final_bullet_target.global_position - global_position).normalized()
	#position += target_direction * final_bullet_speed * delta 
	position += final_bullet_direction * final_bullet_speed * delta 

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("ENEMIES"):
		queue_free()
	if area.is_in_group("BOSSES"):
		#final_bullet_hit.emit(area)
		queue_free()
