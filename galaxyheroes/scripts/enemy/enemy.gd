class_name Enemy
extends Node2D

# --- export --- #
@export var enemy_shot : PackedScene
@export var speed_enemy : int = 60
@export var shot_burst_timer : float = 0.1

# --- ready --- #
@onready var shoot_timer : Timer = Timer.new()
@onready var boss_level_1 : Node 
@onready var explosion_sound : AudioStreamPlayer2D = $"Explosion/Explosion Sound"
@onready var thrust_animation : AnimatedSprite2D = get_node_or_null("Area2D/Thrust")
@onready var flash_animation : AnimatedSprite2D = get_node_or_null("Flash 1")

# --- vector --- #
var direction = Vector2.ZERO

# --- bool --- # 
var is_shooting : bool = false
var is_spawning : bool = false
var explosion : bool = false
var spawned_by_boss : bool = false

func _ready():
	if GlobalSingleton.game_state != GlobalSingleton.GameState.PLAYING:
		return
	
	set_animations()
	set_bullet_movement()
	set_shot_timer()
	check_boss()

func _process(delta: float) -> void:
	if explosion or GlobalSingleton.game_state != GlobalSingleton.GameState.PLAYING:
		return
	
	global_position += direction * speed_enemy * delta
	set_enemy_out_screen()

func set_explosion():
	is_shooting = false
	explosion = true
	
	shoot_timer.stop()
	
	$Area2D.queue_free()
	$Explosion.play("explosion")
	explosion_sound.play()

func _on_shoot_timer_timeout():
	shoot()

func shoot():
	is_shooting = true
	var spawn_shot_points = [$"Shoot Point", $"Shoot Point2"]
	
	for point in spawn_shot_points:
		var enemy_bullet = enemy_shot.instantiate()
		add_child(enemy_bullet)
		enemy_bullet.global_position = point.global_position
		enemy_bullet.set_direction(Vector2.LEFT)
	
	if flash_animation:
		flash_animation.play("Flash")

func set_shot_timer():
	shoot_timer.wait_time = shot_burst_timer
	shoot_timer.one_shot = false
	shoot_timer.autostart = true
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	add_child(shoot_timer)

func set_direction(new_direction: Vector2):
	direction = new_direction.normalized()

func set_bullet_movement():
	direction = Vector2.LEFT

func set_animations():
	$Area2D/Fly.play("fly")
	if flash_animation:
		thrust_animation.play("Thrust on")

func check_boss():
	if spawned_by_boss:
		return
	
	var boss = get_tree().get_first_node_in_group("BOSSES")
	
	if boss:
		if boss.has_signal("boss_entered"):
			boss.boss_entered.connect(set_boss_entered)
		
		if boss.has_signal("final_boss_entered"):
			boss.final_boss_entered.connect(set_final_boss_entered)
		
		$".".queue_free()

func set_enemy_out_screen():
	if global_position.x <= -50:
		queue_free()

func set_boss_entered():
	is_spawning = false
	direction = Vector2.ZERO
	shoot_timer.stop()

func set_final_boss_entered():
	is_spawning = false
	direction = Vector2.ZERO
	shoot_timer.stop()

func delete_laser_shot():
	for child in get_children():
		if child is LaserShot:
			child.queue_free()

func delete_burst_shot():
	for child in get_children():
		if child is GunnerShot:
			child.queue_free()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("PLAYER_BULLET"):
		if thrust_animation:
			thrust_animation.stop()
		set_explosion()
		delete_laser_shot()
		delete_burst_shot()
		GlobalSingleton.score  += 100

func _on_explosion_animation_finished() -> void:
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
