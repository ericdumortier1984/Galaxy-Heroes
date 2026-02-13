extends Node2D

# --- export ---  #
@export var enemy : Array[PackedScene]
@export var power_up_scene : Array[PackedScene]
@export var boss_scene : PackedScene
@export var my_ships : Array[PackedScene]
@export var boss_score_spawner : int = 500
@export var boss_spawn_point : Vector2

# --- onready --- #
@onready var enemy_path_follow = $"Enemy Spawner/PathFollow2D"

var boss_spawned : bool = false
var boss_instance = Level1Boss

func _ready() -> void:
	$"Setttings/Music Background".bus = "Music"
	start_intro_dialogue()
	DialogueManager.dialogue_ended.connect(on_dialogue_ended)
	set_character()
	GlobalSingleton.score = 0
	GlobalSingleton.lifes = 3
	GlobalSingleton.missiles = 0

func _process(delta: float) -> void:
	parallax_behavior(delta)
	enemy_path_follow.progress += 80 * delta
	check_boss_spawn()

func set_character():
	var my_ship_id := SaveSystem.data.selecter_character_id
	my_ship_id = clamp(my_ship_id, 0, my_ships.size() - 1)
	
	var my_selected_ship := my_ships[my_ship_id].instantiate()
	my_selected_ship.global_position = Vector2(80, get_viewport_rect().size.y / 2)
	add_child(my_selected_ship)

func parallax_behavior(delta_time) -> void:
	get_node("Background/Background Parallax").scroll_base_offset -= Vector2(1, 0) * 8 * delta_time
	get_node("Background/Stars Parallax").scroll_base_offset -= Vector2(1, 0) * 16 * delta_time
	get_node("Background/Planet 1 Parallax").scroll_base_offset -= Vector2(1, 0) * 24 * delta_time
	get_node("Background/Planet 2 Parallax").scroll_base_offset -= Vector2(1, 0) * 24 * delta_time

func check_boss_spawn():
	if boss_spawned:
		return
		
	if GlobalSingleton.score >= boss_score_spawner:
		boss_spawn()

func boss_spawn():
	boss_spawned = true
	boss_instance = boss_scene.instantiate()
	boss_instance.global_position = boss_spawn_point
	add_child(boss_instance)
	boss_instance.boss_defeated.connect(set_boss_defeated)

func set_boss_defeated():
	call_deferred("win_level")

func win_level():
	SaveSystem.data.level_unlocked = 2
	SaveSystem.save_game()
	SaveSystem.update_hi_score(GlobalSingleton.score)
	get_tree().change_scene_to_file("res://scenes/upgrade_menu.tscn")

func get_intro_dialogue_id(ship_id: int) -> String:
	match ship_id:
		0:
			return "ryo_intro"
		1:
			return "billy_intro"
		2:
			return "kimi_intro"
		_:
			return "ryo_intro"

func on_dialogue_ended(resource):
	GlobalSingleton.set_state(GlobalSingleton.GameState.PLAYING)

func start_intro_dialogue():
	var ship_id := SaveSystem.data.selecter_character_id
	var dialogue_id := get_intro_dialogue_id(ship_id)

	GlobalSingleton.set_state(GlobalSingleton.GameState.DIALOGUING)
	DialogueManager.show_dialogue_balloon(
		load("res://dialogues/intro_dialogue.dialogue"), dialogue_id)

func _on_timer_timeout() -> void:
	if GlobalSingleton.game_state != GlobalSingleton.GameState.PLAYING:
		return
	
	var random_index := randi_range(0, enemy.size() - 1)
	var enemies_instance = enemy[random_index].instantiate()
	enemies_instance.global_position = $"Enemy Spawner/PathFollow2D".global_position
	add_child(enemies_instance)

func _on_power_up_timer_timeout() -> void:
	if GlobalSingleton.game_state != GlobalSingleton.GameState.PLAYING:
		return
	
	var random_index := randi_range(0, power_up_scene.size() - 1) 
	var power_up_instance := power_up_scene[random_index].instantiate()
	power_up_instance.global_position = Vector2(
		get_viewport_rect().size.x + 40,
		randf_range(40, get_viewport_rect().size.y - 40)
	)
	add_child(power_up_instance)
