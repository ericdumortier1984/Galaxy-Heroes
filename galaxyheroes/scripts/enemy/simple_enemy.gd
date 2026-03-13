class_name SimpleEnemy
extends Enemy

# --- onready --- #
@onready var exit_screen_notifier : VisibleOnScreenNotifier2D = $Area2D/VisibleOnScreenNotifier2D
@onready var shoot_marker : SimpleEnemyMarker = $"Shoot Point"

func _ready() -> void:
	super._ready()
	direction = Vector2.LEFT

func _process(delta: float) -> void:
	if explosion or GlobalSingleton.game_state != GlobalSingleton.GameState.PLAYING:
		return
	
	set_movement(delta)

func set_movement(delta : float) -> void:
	global_position.x += direction.x * speed_enemy * delta

func set_explosion():
	super.set_explosion()
	if shoot_marker:
		shoot_marker.stop_shooting()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
