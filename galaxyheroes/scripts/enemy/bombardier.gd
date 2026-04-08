class_name Bombardier
extends Enemy

# --- onready --- #
@onready var exit_screen_notifier : VisibleOnScreenNotifier2D = $Area2D/VisibleOnScreenNotifier2D
@onready var drop_bomb_marker : BombardierMarker = $"Drop Bomb Marker"

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
	if drop_bomb_marker:
		drop_bomb_marker.stop_dropping()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
