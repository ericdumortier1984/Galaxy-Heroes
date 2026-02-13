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
@export var my_area2d : Area2D
@export var speed := 80 
@export var respawn_time : float = 1.5
@export var safe_time : float = 1.0
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

# --- int --- #
var normal_speed : int
var bullet_size_count : int = 1

# --- float --- #
var fire_timer : float = 0.0

# --- state --- #
var fly_state : FlyState

func _ready() -> void:
	my_animated_ship.sprite_frames = ship_frames
	my_animated_ship.play("idle")
	normal_speed = speed
	shot_sound.bus = "SFX"
	explosion_sound.bus = "SFX"

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
	if explosion:
		return
	if (event.is_action_pressed("shoot_missile")):
		fire_missile()

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
				set_bullet_size(Vector2(0, -1))
				set_bullet_size(Vector2(0, 1))
			3 :
				set_bullet_size(Vector2(0, 0))
				set_bullet_size(Vector2(0, -2))
				set_bullet_size(Vector2(0, 2))
				
	flash_animation.play("Flash")
	shot_sound.play()

func fire_missile():
	if GlobalSingleton.missiles <= 0:
		return
		
	if missile_scene: 
		var new_missile = missile_scene.instantiate() 
		new_missile.position = bullet_position.global_position
		new_missile.set_direction(Vector2.RIGHT)
		get_parent().add_child(new_missile) 
		GlobalSingleton.missiles -= 1

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

func set_safe_time(safe_time : float):
	is_blinking = true
	var safe_time_elapsed : float = 0.0
	while safe_time_elapsed < safe_time:
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
		mat.set_shader_parameter("shield_color", self.shield_color)
	
	shield_sprite.show()
	my_area2d.set_deferred("monitoring", false)

	await get_tree().create_timer(shield_duration).timeout

	shield_sprite.hide()
	my_area2d.set_deferred("monitoring", true)

func set_powered_speed(duration: float = 5.0 , powered: int = 160):
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
	speed = normal_speed
	is_powered_speed = false

func respawn():
	await get_tree().create_timer(respawn_time).timeout
	global_position = Vector2(80, screen_limits.y / 2)
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
		GlobalSingleton.PowerUp.SHIELD:
			set_shield_time(5.0)
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
	
	if area.is_in_group("Enemy") or area.is_in_group("ENEMY_BULLET"):
		GlobalSingleton.lose_life()
		reset_power_up()
		set_explosion()

func _on_explosion_animation_finished() -> void:
	if GlobalSingleton.lifes > 0:
		respawn()
	else:
		queue_free()
