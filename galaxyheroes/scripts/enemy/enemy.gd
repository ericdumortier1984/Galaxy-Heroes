class_name Enemy
extends Node2D

# --- export --- #
@export var speed_enemy : int = 60
@export var max_life : int = 0

# --- ready --- #
@onready var explosion_sound : AudioStreamPlayer2D = $"Explosion/Explosion Sound"
@onready var thrust_animation : AnimatedSprite2D = get_node_or_null("Area2D/Thrust")
@onready var flash_animation : AnimatedSprite2D = get_node_or_null("Flash 1")
@onready var fly_animation : AnimatedSprite2D = get_node_or_null("Area2D/Fly")

# --- vector --- #
var direction = Vector2.ZERO

# --- int --- #
var current_life : int

# --- float --- #
var hit_flash_time : float = 0.08

# --- bool --- # 
var is_shooting : bool = false
var is_spawning : bool = false
var explosion : bool = false
var spawned_by_boss : bool = false

func _ready():
	if GlobalSingleton.game_state != GlobalSingleton.GameState.PLAYING:
		return
	
	set_health()
	set_animations()
	check_boss()

func _process(_delta: float) -> void:
	if explosion or GlobalSingleton.game_state != GlobalSingleton.GameState.PLAYING:
		return

func set_direction(new_direction: Vector2):
	direction = new_direction.normalized()

func set_health():
	current_life = max_life

func take_damage(amount : int) -> void:
	current_life -= amount
	current_life = max(current_life, 0)
	flash_hit()

func flash_hit():
	modulate = Color(1,0.3,0.3)
	await get_tree().create_timer(hit_flash_time).timeout
	modulate = Color(1,1,1)

func set_explosion():
	if current_life <= 0:
		is_shooting = false
		explosion = true
		
		$Area2D.queue_free()
		$Explosion.play("explosion")
		explosion_sound.play()
		GlobalSingleton.score  += 100

func _on_shoot_timer_timeout():
	shoot()

func shoot():
	if flash_animation:
		flash_animation.play("Flash")

func set_animations():
	if fly_animation:
		$Area2D/Fly.play("fly")
	if thrust_animation:
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

func set_boss_entered():
	is_spawning = false
	direction = Vector2.ZERO

func set_final_boss_entered():
	is_spawning = false
	direction = Vector2.ZERO

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area is WeaponDrone:
		return
	
	if area.is_in_group("PLAYER_BULLET"):
		if thrust_animation:
			thrust_animation.stop()
		take_damage(area.damage)
		set_explosion()
