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

func _process(delta : float) -> void:
	if not is_laser:
		return
	
	if raycast.is_colliding():
		var area = raycast.get_collider()
	
	set_laser_beam_particle()

func set_laser_beam_particle():
	var laser_start_pos = line_2d.points[1]
	var laser_end_pos = line_2d.points[0]
	
	laser_particle.position = laser_start_pos

func set_direction(dir: Vector2) -> void:
	direction = dir.normalized()
	rotation = direction.angle()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("PLAYER_SHIP"):
		queue_free()
