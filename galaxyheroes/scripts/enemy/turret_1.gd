class_name Turret01
extends Enemy

# --- export --- #
@export var cannon_rotation_speed : float = 0.0
@export var cannon_rotation_offset : float = 0.0
@export var cannon_min_angle_ : float = -180.0
@export var cannon_max_angle : float = 180.0

# --- onready --- #
@onready var cannon_turret : Node2D = $Area2D/Cannons
@onready var shoot_pattern_timer : Timer = $"Shoot Pattern Timer"
@onready var visible_exit_screen_notification : VisibleOnScreenNotifier2D =  $"Area2D/Turret Exit Notifier"
@onready var shoot_markers = [
	$"Area2D/Cannons/Shoot Point",
	$"Area2D/Cannons/Shoot Point2",
	$"Area2D/Cannons/Shoot Point3"
	]

# --- reference --- #
var player_reference : CharacterBody2D

# --- float --- #
var min_angle : float
var max_angle : float

func _ready() -> void:
	super._ready()
	shoot_pattern_timer.start()
	direction = Vector2.LEFT
	player_reference = get_tree().get_first_node_in_group("PLAYER_SHIP")
	set_deg_to_rad()

func _process(delta: float) -> void:
	if explosion or GlobalSingleton.game_state != GlobalSingleton.GameState.PLAYING:
		return
	
	set_movement(delta)
	set_cannon_rotation(delta)

func set_deg_to_rad() -> void:
	min_angle = deg_to_rad(cannon_min_angle_)
	max_angle = deg_to_rad(cannon_max_angle)

func set_movement(delta : float) -> void:
	global_position += direction * speed_enemy * delta

func set_cannon_rotation(delta : float) -> void:
	if not player_reference:
		return
		
	var target_direction = player_reference.global_position - cannon_turret.global_position
	var target_angle = target_direction.angle()
	target_angle = clamp(target_angle, min_angle, max_angle)
	
	cannon_turret.rotation = lerp_angle(
		cannon_turret.rotation,
		target_angle + cannon_rotation_offset,
		cannon_rotation_speed * delta
	)

func _on_turret_exit_notifier_screen_exited() -> void:
	queue_free()

func _on_shoot_pattern_timer_timeout() -> void:
	for i in shoot_markers.size():
		var marker = shoot_markers[i]
		if not is_instance_valid(marker):
			continue
			
		marker.fire_pattern()
