class_name LaserShot
extends Area2D

# --- export --- #
@export var speed : int = 0

# --- onready --- #
@onready var notifier : VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var raycast : RayCast2D = $"Laser Raycast"
@onready var line_2d : Line2D = $"Laser Raycast/Laser"
@onready var laser_particle : GPUParticles2D = $"Laser Raycast/Laser  Beam Particle"

# --- vector --- #
var direction : Vector2 = Vector2.ZERO

# --- bool ---#
var is_laser : bool = true

# --- node --- #
var parent : Node = null

func _process(delta : float) -> void:
	if not is_laser:
		return
	
	if parent == null or not is_instance_valid(parent):
		queue_free()
		return
	
	global_position += direction * speed * delta
	
	set_laser_beam_particle()

func set_laser_beam_particle():
	var laser_start_pos = line_2d.points[1]
	
	laser_particle.position = laser_start_pos

func set_direction(dir: Vector2) -> void:
	direction = dir.normalized()
	rotation = direction.angle()

func set_parent(enemy):
	parent = enemy

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("PLAYER_SHIP"):
		queue_free()
