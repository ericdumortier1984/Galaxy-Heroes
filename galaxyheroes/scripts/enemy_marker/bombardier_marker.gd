class_name BombardierMarker
extends Marker2D

# --- export --- #
@export var bomb_scene : PackedScene
@export var drop_bomb_interval : float = 0.5

# --- onready --- #
@onready var drop_bomb_rate_timer : Timer = $"Drop Bomb rate Timer"

# --- bool --- # 
var can_drop_bomb : bool = false

# --- Array --- #
var active_bomb : Array = []

func _ready() -> void:
	set_drop_bomb_timer()
	start_dropping()

func set_drop_bomb_timer() -> void:
	drop_bomb_rate_timer.wait_time = drop_bomb_interval

func start_dropping() -> void:
	can_drop_bomb = true
	drop_bomb_rate_timer.start()

func stop_dropping() -> void:
	can_drop_bomb = false
	drop_bomb_rate_timer.stop()
	for bomb in active_bomb:
		if is_instance_valid(bomb):
			bomb.queue_free()
			
	active_bomb.clear()

func spawn_bomb() -> void:
	var bomb_instance = bomb_scene.instantiate()
	get_tree().current_scene.add_child(bomb_instance)
	bomb_instance.global_position = global_position
	active_bomb.append(bomb_instance)

func _on_drop_bomb_rate_timer_timeout() -> void:
	if not can_drop_bomb:
		return
	if GlobalSingleton.game_state != GlobalSingleton.GameState.PLAYING:
		return
	
	spawn_bomb()
