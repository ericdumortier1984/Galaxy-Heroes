class_name ShootMarkerTurret
extends Marker2D

# --- export --- # 
@export var bullet_scene : PackedScene

# --- shot pattern --- #
var pattern_index : int = 0
var rotation_pattern = [-65, 35, -65, 35]
var pattern_rotation : float = 0.0

func set_shoot_pattern_id(id : int) -> void:
	pattern_index = id
	pattern_rotation = deg_to_rad(rotation_pattern[id])

func fire_pattern(base_direction: Vector2):
	var turret_bullet = bullet_scene.instantiate()
	turret_bullet.global_position = global_position
	var turret_bullet_direction = base_direction.rotated(pattern_rotation)
	turret_bullet.set_direction(turret_bullet_direction)
	get_tree().current_scene.add_child(turret_bullet)
