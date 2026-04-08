class_name EnemyBullet
extends Area2D

# --- export --- #
@export var speed : int = 0
@export var speed_rotation : float = 0.0
@export var glow_color : Color

# --- onready --- #
@onready var sprite: Sprite2D = $Sprite2D
@onready var notifier : VisibleOnScreenNotifier2D = $"Exit Notifier"

# --- vector --- #
var direction : Vector2 = Vector2.LEFT

# --- node --- #
var parent : Node = null

func _ready() -> void:
	set_bright_color_material()

func _process(delta):
	global_position += direction * speed * delta
	set_bullet_rotation(delta)
	
	if parent == null or not is_instance_valid(parent):
		queue_free()
		return

func set_direction(new_direction: Vector2):
	direction = new_direction.normalized()

func set_bullet_rotation(delta : float) -> void:
	rotation += speed_rotation * delta

func set_parent(enemy):
	parent = enemy

func set_bright_color_material() -> void:
	if sprite.material is ShaderMaterial:
		var mat := sprite.material as ShaderMaterial
		mat.set_shader_parameter("glow_color", glow_color)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("PLAYER_SHIP"):
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
