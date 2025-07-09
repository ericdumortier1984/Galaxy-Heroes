class_name MyShip
extends CharacterBody2D

const SCREEN_WIDTH = 1152
const SCREEN_HEIGHT = 648 

@export var bullet_scene: PackedScene
@export var speed = 160 

func _physics_process(delta):
	var motion = Vector2()
	if (Input.is_action_pressed("move_up")):
		motion.y -= 1
	if (Input.is_action_pressed("move_down")):
		motion.y += 1
	if (Input.is_action_pressed("speed_down")):
		motion.x -= 1
	if (Input.is_action_pressed("speed_up")):
		motion.x += 1
	
	motion = motion.normalized() * speed * delta
	velocity = motion / delta
	move_and_slide()
	
	var pos = global_position
	pos.x = clamp(pos.x, 0, SCREEN_WIDTH)
	pos.y = clamp(pos.y, 0, SCREEN_HEIGHT)
	global_position = pos
	
func _input(event):
	if(event.is_action_pressed("shoot")):
		shoot()
	
func shoot(): 
	if bullet_scene: 
		var newBullet = bullet_scene.instantiate() 
		newBullet.position = Vector2(global_position.x + 35.0, global_position.y)
		newBullet.set_direction(Vector2.RIGHT)
		get_parent().add_child(newBullet) 

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		queue_free()
	if area.is_in_group("enemy_bullet"):
		queue_free()
