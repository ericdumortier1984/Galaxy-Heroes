extends Marker2D

# --- onready --- #
@onready var third_boss_fire_rate_timer : Timer = $"Fire Rate Timer"

# --- bool --- #
var can_shot : bool = false

func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	pass

func start_shot_third_boss() -> void :
	if can_shot:
		return
	
	can_shot = true
	third_boss_fire_rate_timer.start()
