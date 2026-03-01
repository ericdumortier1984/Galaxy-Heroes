class_name BigAsteroid
extends Asteroid

# --- export --- #
@export var small_asteroid_scene : PackedScene 

# --- onready --- #
@onready var notifier : VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

func _ready() -> void:
	life = 1

func spawn_fragments():
	var array_direction = [
		Vector2(1, 1),
		Vector2(1, -1),
		Vector2(-1, -1),
		Vector2(-1, 1)
	]
	
	for direction in array_direction:
		var small_steroid = small_asteroid_scene.instantiate()
		small_steroid.global_position = global_position
		small_steroid.direction = direction.normalized()
		get_parent().add_child(small_steroid)
		
	GlobalSingleton.score += 20

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if is_explosion:
		return
	
	if area.is_in_group("PLAYER_BULLET"):
		take_damage(1)
		explode()

func _on_explosion_animation_finished() -> void:
	call_deferred("spawn_fragments")
	queue_free()
