class_name BossMissileShot
extends Area2D

# --- export --- #
@export var speed : int = 0
@export var rotation_speed : float = 0.0

# --- onready --- #
@onready var notifier : VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

# --- vector --- #
var velocity : Vector2 
var direction : Vector2 = Vector2.LEFT

# --- player --- #
var player_ship : CharacterBody2D

func _ready() -> void:
	velocity = direction * speed
	player_ship = get_tree().get_first_node_in_group("PLAYER_SHIP")

func _process(delta: float) -> void:
	chase_player_ship(delta)

func set_direction(new_direction : Vector2) -> void:
	direction = new_direction.normalized()

func move_missile(delta : float) -> void:
	global_position += direction * speed * delta

func chase_player_ship(delta: float) -> void:
	var new_direction = (player_ship.global_position - global_position).normalized()
	var new_velocity = new_direction * speed
	
	velocity = velocity.lerp(new_velocity, 0.4 * delta)
	global_position += velocity * delta
	
	rotation = velocity.angle()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("PLAYER_SHIP"):
		queue_free()
