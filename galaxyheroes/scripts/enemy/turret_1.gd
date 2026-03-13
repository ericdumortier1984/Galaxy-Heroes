class_name Turret01
extends Enemy

# --- onready --- #
@onready var shoot_pattern_timer : Timer = $"Shoot Pattern Timer"
@onready var visible_exit_screen_notification : VisibleOnScreenNotifier2D =  $"Area2D/Turret Exit Notifier"
@onready var shoot_markers = [
	$"Area2D/Shoot Point",
	$"Area2D/Shoot Point2",
	$"Area2D/Shoot Point3"
	]

# --- int --- #
var pattern_index : int

# --- array shot direction --- #
var base_directions = [
	Vector2.LEFT,
	Vector2.UP,
	Vector2.RIGHT,
]

func _ready() -> void:
	super._ready()
	pattern_index = 0
	shoot_pattern_timer.start()
	direction = Vector2.LEFT

func _process(delta: float) -> void:
	if explosion or GlobalSingleton.game_state != GlobalSingleton.GameState.PLAYING:
		return
	
	set_movement(delta)

func set_movement(delta : float) -> void:
	global_position += direction * speed_enemy * delta

func _on_turret_exit_notifier_screen_exited() -> void:
	queue_free()

func _on_shoot_pattern_timer_timeout() -> void:
	pattern_index = (pattern_index + 1) % 4
	for i in shoot_markers.size():
		var marker = shoot_markers[i]
		if not is_instance_valid(marker):
			continue
			
		marker.set_shoot_pattern_id(pattern_index)
		marker.fire_pattern(base_directions[i])
