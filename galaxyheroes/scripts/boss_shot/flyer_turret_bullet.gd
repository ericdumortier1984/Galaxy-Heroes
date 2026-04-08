class_name FlyerTurretBullet
extends Area2D

# --- export --- #
@export var speed : int = 0

# --- onready --- #
@onready var animation_sprite : AnimatedSprite2D = $AnimateSprite2D
@onready var notifier : VisibleOnScreenNotifier2D = $"Exit Notifier"

# --- vector --- #
var direction : Vector2 = Vector2.LEFT

func _process(delta: float) -> void:
	move_flyer_turret_bullet(delta)

func set_direction(new_direction : Vector2) -> void:
	direction = new_direction.normalized()

func move_flyer_turret_bullet(delta : float) -> void:
	global_position += direction * speed * delta

func play_animation() -> void:
	animation_sprite.play("in_fire")

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("PLAYER_SHIP"):
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
