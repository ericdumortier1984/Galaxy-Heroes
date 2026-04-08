class_name MyShip
extends CharacterBody2D

enum FlyState { IDLE, UP, DOWN }

# --- ready --- #
@onready var screen_limits = get_viewport_rect().size
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var shield_sprite : Sprite2D = $Shield
@onready var explosion : bool = false

# --- export --- #
@export var bullet_scene : PackedScene
@export var missile_scene : PackedScene
@export var bomb_scene : PackedScene
@export var drone_weapon_scene : PackedScene
@export var bullet_rain_scene : PackedScene
@export var my_area2d : Area2D
@export var speed : int = 80
@export var respawn_time : float = 1.5
@export var safe_time : float = 2.0
@export var fire_rate : float = 0.18
@export var shield_color : Color
@export var blinking_time : float = 0.15
@export var shot_sound : AudioStreamPlayer2D
@export var explosion_sound : AudioStreamPlayer2D
@export var bullet_position : Node2D
@export var flash_animation : AnimatedSprite2D
@export var explosion_animation : AnimatedSprite2D
@export var thrust_animation : AnimatedSprite2D
@export var ship_frames : SpriteFrames
@export var my_animated_ship : AnimatedSprite2D

# --- bool --- #
var is_blinking : bool = false
var is_powered_speed : bool = false
var can_autofire : bool = true
var is_special_weapon : bool = false

# --- int --- #
var normal_speed : int
var bullet_size_count : int = 1

# --- float --- #
var fire_timer : float = 0.0
var normal_safe_time : float

# --- state --- #
var fly_state : FlyState

# --- reference --- #
var current_weapon_drone : WeaponDrone = null

func _ready() -> void:
	my_animated_ship.sprite_frames = ship_frames
	my_animated_ship.play("idle")
	
	GlobalSingleton.load_upgrades()
	normal_speed = speed
	speed = normal_speed + GlobalSingleton.upgrade_speed
	
	normal_safe_time = safe_time
	safe_time = normal_safe_time + GlobalSingleton.upgrade_time_shield

func _physics_process(delta):
	if GlobalSingleton.game_state != GlobalSingleton.GameState.PLAYING:
		return
	
	set_auto_fire(delta)
	player_movement()
	set_limit_screen()

func player_movement():
	if explosion:
		velocity = Vector2.ZERO
		return
		
	var motion: Vector2 = Input.get_vector("speed_down", "speed_up", "move_up", "move_down")
	velocity = motion * speed
	
	if motion.x > 0:
		play_thrust_anim()
	else:
		stop_thrust_anim()
	if motion.y > 0:
		set_fly_state(FlyState.DOWN)
	elif motion.y < 0:
		set_fly_state(FlyState.UP)
	else:
		set_fly_state(FlyState.IDLE)
	move_and_slide()

func _input(event):
	if GlobalSingleton.game_state != GlobalSingleton.GameState.PLAYING:
		return
	if explosion:
		return
	if (event.is_action_pressed("shoot_missile")):
		fire_missile()
	if (event.is_action_pressed("shoot_special")) and not is_special_weapon:
		set_upgrade_weapon()

func set_fly_state(new_state: FlyState):
	if fly_state == new_state:
		return
		
	fly_state = new_state
	
	match fly_state:
		FlyState.IDLE:
			my_animated_ship.play("idle")
		FlyState.UP:
			my_animated_ship.play("fly_up")
		FlyState.DOWN:
			my_animated_ship.play("fly_down")

func set_auto_fire(delta: float):
	if explosion:
		return
	if not can_autofire:
		return
		
	fire_timer -= delta
	
	if Input.is_action_pressed("shoot") and fire_timer <= 0.0:
		shoot()
		fire_timer = fire_rate

func set_bullet_size(offset : Vector2):
	if bullet_scene: 
		var newBullet = bullet_scene.instantiate() 
		newBullet.position = bullet_position.global_position + offset
		newBullet.set_direction(Vector2.RIGHT)
		get_parent().add_child(newBullet) 

func shoot(): 
	if bullet_scene: 
		match bullet_size_count:
			1 : 
				set_bullet_size(Vector2(0, 0))
			2 :
				set_bullet_size(Vector2(0, -0.8))
				set_bullet_size(Vector2(0, 0.8))
			3 :
				set_bullet_size(Vector2(0, 0))
				set_bullet_size(Vector2(0, -1.8))
				set_bullet_size(Vector2(0, 1.8))
				
	flash_animation.play("Flash")
	shot_sound.play()

func set_upgrade_weapon() -> void:
	match SaveSystem.data.weapon_selected:
		GlobalSingleton.ExtraWeapon.BOMB:
			fire_bomb()
		GlobalSingleton.ExtraWeapon.DRONE:
			set_drone()
		GlobalSingleton.ExtraWeapon.BULLET_RAIN:
			call_rain()

func fire_bomb() -> void:
	if not GlobalSingleton.consume_special_weapon_bar(25):
		return
	
	is_special_weapon = true
	var bomb_instance = bomb_scene.instantiate()
	bomb_instance.position = bullet_position.global_position
	get_parent().add_child(bomb_instance)
	bomb_instance.bomb_process_finish.connect(stop_special_weapon)

func set_drone() -> void:
	if not GlobalSingleton.consume_special_weapon_bar(25):
		return
	if current_weapon_drone != null:
		return
	
	is_special_weapon = true
	var drone_weapon_instance : WeaponDrone = drone_weapon_scene.instantiate()
	drone_weapon_instance.player_reference = self
	get_parent().add_child(drone_weapon_instance)
	current_weapon_drone = drone_weapon_instance
	drone_weapon_instance.drone_process_finish.connect(stop_special_weapon)

func call_rain() -> void:
	if not GlobalSingleton.consume_special_weapon_bar(25):
		return
	
	is_special_weapon = true
	var bullet_rain_instance = bullet_rain_scene.instantiate()
	get_parent().add_child(bullet_rain_instance)
	bullet_rain_instance.rain_process_finish.connect(stop_special_weapon)

func stop_special_weapon() -> void:
	is_special_weapon = false

func fire_missile():
	if GlobalSingleton.missiles <= 0:
		return
		
	if missile_scene: 
		var new_missile = missile_scene.instantiate() 
		new_missile.position = bullet_position.global_position
		new_missile.set_direction(Vector2.RIGHT)
		get_parent().add_child(new_missile) 
		GlobalSingleton.missiles -= 1

func shoot_final_bullet() -> void:
	can_autofire = false
	var final_bullet = get_parent().final_bullet_scene.instantiate()
	final_bullet.global_position = bullet_position.global_position
	final_bullet.final_bullet_direction = Vector2.RIGHT
	get_parent().add_child(final_bullet)
	get_parent().set_final_bullet_camera(final_bullet)

func set_limit_screen():
	global_position.x = clamp(global_position.x, 10, screen_limits.x - 10)
	global_position.y = clamp(global_position.y, 10, screen_limits.y - 10)

func set_explosion():
	if explosion:
		return
	
	explosion = true
	my_area2d.set_deferred("monitoring", false)
	stop_thrust_anim()
	my_animated_ship.hide()
	play_explosion_anim()
	if current_weapon_drone:
		current_weapon_drone.queue_free()

func set_safe_time(duration : float):
	is_blinking = true
	var safe_time_elapsed : float = 0.0
	while safe_time_elapsed < duration:
		my_animated_ship.visible = not my_animated_ship.visible
		my_area2d.set_deferred("monitoring", false)
		
		await get_tree().create_timer(blinking_time).timeout
		safe_time_elapsed += blinking_time
	
	my_animated_ship.visible = true
	is_blinking = false
	my_area2d.set_deferred("monitoring", true)

func set_shield_time(shield_duration : float):
	if shield_sprite.material is ShaderMaterial:
		var mat := shield_sprite.material as ShaderMaterial
		mat.set_shader_parameter("shield_color", shield_color)
	
	shield_sprite.show()
	my_area2d.set_deferred("monitoring", false)

	await get_tree().create_timer(shield_duration).timeout

	shield_sprite.hide()
	my_area2d.set_deferred("monitoring", true)

func set_powered_speed(duration: float = 5.0 , powered: int = 85):
	if is_powered_speed:
		return
	
	is_powered_speed = true
	speed = normal_speed + powered
	
	await get_tree().create_timer(duration).timeout
	
	speed = normal_speed
	is_powered_speed = false

func reset_power_up():
	bullet_size_count = 1
	GlobalSingleton.missiles = 0
	speed = normal_speed + GlobalSingleton.upgrade_speed
	is_powered_speed = false

func respawn():
	await get_tree().create_timer(respawn_time).timeout
	global_position = Vector2(20, screen_limits.y / 2)
	explosion = false
	stop_explosion_anim()
	my_area2d.set_deferred("monitoring", true)
	my_animated_ship.show()
	set_safe_time(1.0)

func play_explosion_anim():
	explosion_animation.show()
	explosion_animation.frame = 0
	explosion_animation.play("explosion")
	explosion_sound.play()

func play_thrust_anim():
	if not thrust_animation.is_playing():
		thrust_animation.show()
		thrust_animation.play("Thrust on")

func stop_thrust_anim():
	thrust_animation.stop()
	thrust_animation.hide()

func stop_explosion_anim():
	explosion_animation.stop()
	explosion_animation.hide()
	explosion_animation.frame = 0

func get_power_up(type : GlobalSingleton.PowerUp) -> void:
	match type:
		GlobalSingleton.PowerUp.LIFE:
			GlobalSingleton.lifes += 1
			SaveSystem.data.lifes = GlobalSingleton.lifes
			SaveSystem.save_game()
		GlobalSingleton.PowerUp.SHIELD:
			set_shield_time(safe_time)
		GlobalSingleton.PowerUp.DOUBLE_SHOT:
			bullet_size_count = max(bullet_size_count, 2)
		GlobalSingleton.PowerUp.TRIPLE_SHOT:
			bullet_size_count = max(bullet_size_count, 3)
		GlobalSingleton.PowerUp.MISSILE:
			GlobalSingleton.missiles += 3
		GlobalSingleton.PowerUp.SPEED:
			set_powered_speed()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if explosion:
		return
	
	if area.is_in_group("ENEMIES") or area.is_in_group("ENEMY_BULLET"):
		GlobalSingleton.lose_life()
		reset_power_up()
		set_explosion()

func _on_explosion_animation_finished() -> void:
	if GlobalSingleton.lifes > 0:
		respawn()
	else:
		queue_free()
