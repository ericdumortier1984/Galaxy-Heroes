class_name Enemy
extends Node2D

var pre_load_enemy_bullet = preload("res://scenes/simple_enemy_bullet.tscn")
var direction = Vector2.ZERO

func _ready():
	var shoot_timer = Timer.new()
	shoot_timer.wait_time = 1.0
	shoot_timer.one_shot = false
	shoot_timer.autostart = true
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	add_child(shoot_timer)

func _on_shoot_timer_timeout():
	shoot()

func shoot():
	if pre_load_enemy_bullet:
		var bullet = pre_load_enemy_bullet.instantiate()
		bullet.position = $Sprite2D/EnemyShootPoint.global_position

		var player = get_tree().get_first_node_in_group("my_ship")
		if player:
			#var dir = (player.global_position - global_position).normalized()
			#bullet.set_direction(dir)
			bullet.set_direction(Vector2.LEFT)

		get_parent().add_child(bullet)

func set_direction(new_direction: Vector2):
	direction = new_direction.normalized()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("simple_bullet"):
		queue_free()
