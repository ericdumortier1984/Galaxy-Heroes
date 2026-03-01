class_name Drone01
extends Enemy

# --- export --- #
@export var rotation_speed : float = 0.0

# --- player --- #
var player_ship : CharacterBody2D

# --- vector --- #
var velocity : Vector2 

func _ready() -> void:
	super._ready()
	player_ship = get_tree().get_first_node_in_group("PLAYER_SHIP")
	disable_shot()

func _process(delta: float) -> void:
	if explosion or GlobalSingleton.game_state != GlobalSingleton.GameState.PLAYING:
		return
	
	if player_ship:
		chase_player_ship(delta)
		drone_rotate(delta)
	
	set_enemy_out_screen()

func chase_player_ship(delta: float) -> void:
	var new_direction = (player_ship.global_position - global_position).normalized()
	var new_velocity = new_direction * speed_enemy
	
	velocity = velocity.lerp(new_velocity, 0.4 * delta)
	global_position += velocity * delta

func drone_rotate(delta: float) -> void:
	rotation += rotation_speed * delta

func disable_shot():
	if shoot_timer.is_inside_tree():
		shoot_timer.stop()
