class_name Enemy
extends Node2D

# --- export --- #
@export var speed_enemy : int = 60

# --- ready --- #
@onready var enemy_out_position : float = get_viewport_rect().size.x
@onready var explosion : bool = false
@onready var shoot_timer : Timer = Timer.new()
@onready var boss_level_1 : Node 
@onready var explosion_sound : AudioStreamPlayer2D = $"Explosion/Explosion Sound"

# --- preload --- #
var pre_load_enemy_bullet = preload("res://scenes/simple_enemy_bullet.tscn")

# --- vector --- #
var direction = Vector2.ZERO

# --- bool --- # 
var is_shooting : bool = false
var is_spawning : bool = false

func _ready():
	if GlobalSingleton.game_state != GlobalSingleton.GameState.PLAYING:
		return
	
	$Area2D/Fly.play("fly")
	direction = Vector2.LEFT
	shoot_timer.wait_time = 1.0
	shoot_timer.one_shot = false
	shoot_timer.autostart = true
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	add_child(shoot_timer)
	
	boss_level_1 = get_tree().get_first_node_in_group("BOSSES")
	if boss_level_1:
		boss_level_1.boss_entered.connect(set_boss_entered)
		$".".queue_free()

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
	var enemy_bullet = pre_load_enemy_bullet.instantiate()
	enemy_bullet.position = $"Shoot Point".global_position

	var my_ship = get_tree().get_first_node_in_group("PLAYER_SHIP")
	if my_ship:
		var my_ship_direction = (my_ship.global_position - global_position).normalized()
		enemy_bullet.set_direction(my_ship_direction)
		enemy_bullet.set_direction(Vector2.LEFT)

	get_parent().add_child(enemy_bullet)

func set_direction(new_direction: Vector2):
	direction = new_direction.normalized()

func set_enemy_out_screen():
	if global_position.x <= -50:
		queue_free()

func set_boss_entered():
	is_spawning = false
	direction = Vector2.ZERO
	shoot_timer.stop()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("PLAYER_BULLET"):
		set_explosion()
		GlobalSingleton.score  += 100

func _on_explosion_animation_finished() -> void:
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
