class_name EnemyBullet
extends Area2D

# --- export --- #
@export var speed = 0

# --- onready --- #
@onready var notifier : VisibleOnScreenNotifier2D = $"Simple Enemy Bullet Exit Notification"

# --- vector --- #
var direction : Vector2 = Vector2.LEFT

# --- node --- #
var parent : Node = null

func _process(delta):
	global_position += direction * speed * delta
	
	if parent == null or not is_instance_valid(parent):
		queue_free()
		return

func set_direction(new_direction: Vector2):
	direction = new_direction.normalized()

func set_parent(enemy):
	parent = enemy

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("PLAYER_SHIP"):
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
