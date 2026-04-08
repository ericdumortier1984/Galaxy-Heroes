class_name ShootMarkerTurret
extends Marker2D

# --- export --- # 
@export var bullet_scene : PackedScene

func fire_pattern():
	var turret_bullet = bullet_scene.instantiate()
	turret_bullet.global_position = global_position
	
	var player = get_tree().get_first_node_in_group("PLAYER_SHIP")
	if player:
		var marker_aim_direction = (player.global_position - global_position).normalized()
		turret_bullet.set_direction(marker_aim_direction)
		
	get_tree().current_scene.add_child(turret_bullet)
