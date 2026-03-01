class_name SmallAsteroid
extends Asteroid

# --- onready --- #
@onready var notifier : VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

func _ready() -> void:
	life = 1

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("PLAYER_BULLET"):
		take_damage(1)
		$Sprite2D.visible = false
		$".".set_deferred("monitoring", false)
		GlobalSingleton.score += 20

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _on_explosion_animation_finished() -> void:
	queue_free()
