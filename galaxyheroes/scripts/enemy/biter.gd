class_name Biter
extends Enemy

# --- export -- #
@export var amplitude : float = 0.0
@export var frequency : float = 0.0

# --- float ---#
var start_positionY : float

func _ready() -> void:
	super._ready()
	start_positionY = global_position.y
	disable_shot()

func _process(delta: float) -> void:
	if explosion or GlobalSingleton.game_state != GlobalSingleton.GameState.PLAYING:
		return
	
	set_biter_movement(delta)
	apply_biter_movement()
	set_enemy_out_screen()

func set_biter_movement(delta: float):
	global_position.x += direction.x * speed_enemy * delta

func apply_biter_movement():
	var time = Time.get_ticks_msec() / 1000.0
	global_position.y = start_positionY + sin(time * frequency) * amplitude

func disable_shot():
	if shoot_timer.is_inside_tree():
		shoot_timer.stop()
