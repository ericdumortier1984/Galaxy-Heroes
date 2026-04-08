extends Node2D

# --- onready --- #
@onready var enemy_path_follow : PathFollow2D = $"Enemy Spawner/Enemy Path Follow"
@onready var upper_path_follow : PathFollow2D = $"Drone Upper Spawner/Upper Path Follow"
@onready var lower_path_follow : PathFollow2D = $"Drone Lower Spawner/Lower Path Follow"
@onready var music_background : AudioStreamPlayer = $"Settings/Music Background"
@onready var my_ship_spawn_position : Vector2 = Vector2(20, get_viewport_rect().size.y / 2)

# --- export --- #
@export var my_ship : Array[PackedScene]
@export var enemy : Array[PackedScene]
@export var power_up : Array[PackedScene]
@export var drone_1_scene : PackedScene
@export var boss_scene : PackedScene
@export var final_boss_scene :  PackedScene
@export var score_boss_spawner : int = 2500
@export var score_final_boss_spawner : int = 4500
@export var boss_position_spawner : Vector2
@export var final_boss_position_spawner : Vector2

# --- bool --- #
var boss_spawned : bool = false
var final_boss_spawned : bool = false
var boss_defeated : bool = false
var level_completed : bool = false

# --- int --- # 
var level_start_score : int = 0
var score_after_boss : int = 0

func _ready() -> void:
	await get_tree().process_frame
	Transition.fade_out()
	SaveSystem.load_game()
	GlobalSingleton.load_game_state()
	GlobalSingleton.set_state(GlobalSingleton.GameState.PLAYING)
	level_start_score = GlobalSingleton.score
	start_level_2_intro_dialogue()
	DialogueManager.dialogue_ended.connect(on_dialogue_ended)
	set_character()
	music_background.bus = "Music"

func _process(delta: float) -> void:
	parallax_behavior(delta)
	check_boss_spawn()
	check_final_boss_spawn()

func get_level_score() -> int:
	if not boss_defeated:
		return min(GlobalSingleton.score - level_start_score, score_boss_spawner)
	
	return score_boss_spawner + (GlobalSingleton.score - score_after_boss)

func set_character():
	var my_ship_id := SaveSystem.data.selecter_character_id
	my_ship_id = clamp(my_ship_id, 0, my_ship.size() - 1)
	
	var my_selected_ship = my_ship[my_ship_id].instantiate()
	my_selected_ship.global_position = my_ship_spawn_position
	add_child(my_selected_ship)

func parallax_behavior(delta_time) -> void:
	get_node("Background/Background Parallax").scroll_base_offset -= Vector2(1, 0) * 8 * delta_time
	get_node("Background/Star Parallax").scroll_base_offset -= Vector2(1, 0) * 16 * delta_time
	get_node("Background/Earth Parallax").scroll_base_offset -= Vector2(1, 0) * 1 * delta_time

func get_intro_dialogue_id(my_ship_id: int) -> String:
	match my_ship_id:
		0:
			return "ryo_intro"
		1:
			return "billy_intro"
		2:
			return "kimi_intro"
		_:
			return "ryo_intro"

func start_level_2_intro_dialogue():
	var my_ship_id = SaveSystem.data.selecter_character_id
	var dialogue_id = get_intro_dialogue_id(my_ship_id)
	
	GlobalSingleton.set_state(GlobalSingleton.GameState.DIALOGUING)
	DialogueManager.show_dialogue_balloon(
		load("res://dialogues/level_2_intro_dialogue.dialogue"), dialogue_id
	)

func start_level_2_boss_intro_dialogue():
	var my_ship_id = SaveSystem.data.selecter_character_id
	var dialogue_id = get_intro_level_2_boss_dialogue(my_ship_id)
	
	GlobalSingleton.set_state(GlobalSingleton.GameState.DIALOGUING)
	DialogueManager.show_dialogue_balloon(
		load("res://dialogues/intro_dialogue_boss_level_2.dialogue"), dialogue_id
	)

func get_intro_level_2_boss_dialogue(ship_id : int) -> String:
	match ship_id:
		0:
			return "ryo_intro_boss_level_2"
		1:
			return "billy_intro_boss_level_2"
		2:
			return "kimi_intro_boss_level_2"
		_:
			return "ryo_intro_boss_level_2"

func start_level_2_final_boss_intro_dialogue():
	var my_ship_id = SaveSystem.data.selecter_character_id
	var dialogue_id = get_intro_final_boss_level_2_dialogue(my_ship_id)
	
	GlobalSingleton.set_state(GlobalSingleton.GameState.DIALOGUING)
	DialogueManager.show_dialogue_balloon(
		load("res://dialogues/intro_dialogue_final_boss_level_2.dialogue"), dialogue_id
	)

func get_intro_final_boss_level_2_dialogue(ship_id : int) -> String:
	match ship_id:
		0:
			return "ryo_intro_final_boss_level_2"
		1:
			return "billy_intro_final_boss_level_2"
		2:
			return "kimi_intro_final_boss_level_2"
		_:
			return "ryo_intro__final_boss_level_2"

func on_dialogue_ended(_resource):
	GlobalSingleton.set_state(GlobalSingleton.GameState.PLAYING)

func spawn_drone_path_follow(path_follow : PathFollow2D):
	if GlobalSingleton.game_state != GlobalSingleton.GameState.PLAYING:
		return
		
	var drone_1_instance = drone_1_scene.instantiate()
	path_follow.progress_ratio = randf()
	drone_1_instance.global_position = path_follow.global_position
	
	add_child(drone_1_instance)

func check_boss_spawn():
	if boss_spawned:
		return
	
	if get_level_score() >= score_boss_spawner:
		spawn_boss()

func set_boss_entered():
	start_level_2_boss_intro_dialogue()

func set_final_boss_entered():
	start_level_2_final_boss_intro_dialogue()

func set_boss_defeated():
	boss_defeated = true
	score_after_boss = GlobalSingleton.score

func spawn_boss():
	boss_spawned = true
	var boss_scene_instance = boss_scene.instantiate()
	boss_scene_instance.global_position = boss_position_spawner
	add_child(boss_scene_instance)
	boss_scene_instance.boss_entered.connect(set_boss_entered)
	boss_scene_instance.boss_defeated.connect(set_boss_defeated)

func check_final_boss_spawn():
	if final_boss_spawned:
		return
	if not boss_defeated:
		return
	
	if get_level_score() >= score_boss_spawner + score_final_boss_spawner:
		spawn_final_boss()

func spawn_final_boss():
	final_boss_spawned = true
	var final_boss_instance = final_boss_scene.instantiate()
	final_boss_instance.global_position = final_boss_position_spawner
	add_child(final_boss_instance)
	final_boss_instance.final_boss_entered.connect(set_final_boss_entered)
	final_boss_instance.final_boss_defeated.connect(set_final_boss_defeated)

func show_level_completed(): 
	var texture_win_label = load("res://images/UI/text/Level_2_completed.png")
	var sprite_win_label = Sprite2D.new()
	sprite_win_label.texture = texture_win_label
	sprite_win_label.centered = true
	sprite_win_label.modulate.a = 0.0
	sprite_win_label.position = get_viewport_rect().size / 2
	add_child(sprite_win_label)
	
	var tween = create_tween()
	tween.tween_property(sprite_win_label, "modulate:a", 1.0, 1.0)
	await tween.finished
	
	await get_tree().create_timer(2.5).timeout
	
	var tween_out = create_tween()
	tween_out.tween_property(sprite_win_label, "modulate:a", 0.0, 0.0)
	await tween_out.finished
	
	sprite_win_label.queue_free()

func set_win_level():
	GlobalSingleton.complete_level(2)
	SaveSystem.update_hi_score(GlobalSingleton.score)
	Transition.change_scene("res://scenes/menu/upgrade_menu.tscn")

func win_level():
	GlobalSingleton.set_state(GlobalSingleton.GameState.WIN)
	await show_level_completed()
	set_win_level()

func set_final_boss_defeated():
	call_deferred("win_level")

func _on_enemy_spawn_timer_timeout() -> void:
	if GlobalSingleton.game_state != GlobalSingleton.GameState.PLAYING:
		return
		
	var enemy_random_index := randi_range(0, enemy.size() - 1)
	var enemy_instance = enemy[enemy_random_index].instantiate()
	
	enemy_path_follow.progress_ratio = randf()
	enemy_instance.global_position = enemy_path_follow.global_position
	add_child(enemy_instance)
	
	spawn_drone_path_follow(upper_path_follow)
	spawn_drone_path_follow(lower_path_follow)

func _on_power_up_spawn_timer_timeout() -> void:
	if GlobalSingleton.game_state != GlobalSingleton.GameState.PLAYING:
		return
		
	var power_up_random_index := randi_range(0, power_up.size() - 1)
	var power_up_instance = power_up[power_up_random_index].instantiate()
	
	enemy_path_follow.progress_ratio = randf()
	power_up_instance.global_position = enemy_path_follow.global_position
	add_child(power_up_instance)
