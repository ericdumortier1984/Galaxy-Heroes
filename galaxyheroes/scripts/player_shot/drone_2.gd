class_name WeaponDrone
extends Area2D

signal drone_process_finish

# --- export --- #
@export var drone_bullet_scene : PackedScene
@export var distance_to_player : Vector2 = Vector2(0, 0)
@export var fire_rate : float = 0.0
@export var drone_speed : float = 0.0

# --- reference --- #
var player_reference : Node2D
var fire_rate_timer : float = 0.0

func _process(delta: float) -> void:
	follow_player_ship(delta)
	set_fire_rate_timer(delta)

func follow_player_ship(delta : float) -> void:
	var player_position = player_reference.position + distance_to_player
	global_position = global_position.lerp(player_position, drone_speed * delta)

func drone_shot() -> void:
	var drone_bullet_instance = drone_bullet_scene.instantiate()
	drone_bullet_instance.global_position = global_position
	drone_bullet_instance.set_direction(Vector2.RIGHT)
	get_parent().add_child(drone_bullet_instance)

func set_fire_rate_timer(delta : float) -> void:
	fire_rate_timer -= delta
	if fire_rate_timer <= 0:
		drone_shot()
		fire_rate_timer = fire_rate

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("ENEMIES"):
		emit_signal("drone_process_finish")
		queue_free()
	if area.is_in_group("BOSSES"):
		emit_signal("drone_process_finish")
		queue_free()

func _exit_tree():
	emit_signal("drone_process_finish")
