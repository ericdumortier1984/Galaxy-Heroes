extends Node2D

# --- onready --- #
@onready var enemy_path_follow : PathFollow2D = $"Enemy Spawner/Enemy Path Follow"
@onready var upper_path_follow : PathFollow2D = $"Enemy Roof Spawner/Enemy Roof Path Follow"
@onready var lower_path_follow : PathFollow2D = $"Enemy Floor Spawner/Enemy Floor Path Follow"
@onready var music_background : AudioStreamPlayer = $"Settings/Music Background"
@onready var my_ship_spawn_position : Vector2 = Vector2(20, get_viewport_rect().size.y / 2)

# --- export --- #
@export var my_ship : Array[PackedScene]
@export var enemy : Array[PackedScene]
@export var turret : Array[PackedScene]
@export var power_up : Array[PackedScene]
@export var first_boss_scene : PackedScene
@export var second_boss_scene : PackedScene
@export var third_boss_scene : PackedScene
@export var final_boss_scene :  PackedScene
@export var score_first_boss_spawner : int 
@export var score_second_boss_spawner : int 
@export var score_third_boss_spawner : int 
@export var score_final_boss_spawner : int 
@export var boss_position_spawner : Vector2

# --- bool --- #
var is_first_boss_spawned : bool = false
var is_second_boss_spawned : bool = false
var is_third_boss_spawned : bool = false
var is_final_boss_spawned : bool = false
var is_first_boss_defeated : bool = false
var is_third_boss_defeated : bool = false

# --- int --- # 
var score_afer_level : int = 0
var score_after_first_boss : int = 0
var score_after_second_boss : int = 0
var score_after_third_boss : int = 0

func _ready() -> void:
	SaveSystem.load_game()
	GlobalSingleton.set_state(GlobalSingleton.GameState.PLAYING)
	score_afer_level = GlobalSingleton.score
	set_character()
	start_level_3_intro_dialogue()
	DialogueManager.dialogue_ended.connect(on_dialogue_ended)
	music_background.bus = "Music"

func _process(delta: float) -> void:
	parallax_behavior(delta)
	check_first_boss_spawn()
	check_second_boss_spawn()
	check_third_boss_spawn()
	check_final_boss_spawn()

func parallax_behavior(delta_time) -> void:
	get_node("Background/Background Parallax").scroll_base_offset -= Vector2(1, 0) * 8 * delta_time
	get_node("Background/Floor Background Parallax").scroll_base_offset -= Vector2(1, 0) * 8 * delta_time
	get_node("Background/Roof Background Parallax").scroll_base_offset -= Vector2(1, 0) * 8 * delta_time

func set_character():
	var my_ship_id := SaveSystem.data.selecter_character_id
	my_ship_id = clamp(my_ship_id, 0, my_ship.size() - 1)
	
	var my_selected_ship = my_ship[my_ship_id].instantiate()
	my_selected_ship.global_position = my_ship_spawn_position
	add_child(my_selected_ship)

func get_level_3_intro_dialogue(my_ship_id : int) -> String: 
	match my_ship_id:
		0:
			return "ryo_intro_level_3"
		1:
			return "billy_intro_level_3"
		2:
			return "kimi_intro_level_3"
		_:
			return "ryo_intro_level_3"

func start_level_3_intro_dialogue() -> void:
	var my_ship_id = SaveSystem.data.selecter_character_id
	var my_dialogue_id = get_level_3_intro_dialogue(my_ship_id)
	
	GlobalSingleton.set_state(GlobalSingleton.GameState.DIALOGUING)
	DialogueManager.show_dialogue_balloon(
		load("res://dialogues/level_3_intro_dialogue.dialogue"), my_dialogue_id
	)

func get_level_3_first_boss_intro_dialogue(my_ship_id : int) -> String: 
	match my_ship_id:
		0:
			return "ryo_level_3_intro_first_boss"
		1:
			return "billy_level_3_intro_first_boss"
		2:
			return "kimi_level_3_intro_first_boss"
		_:
			return "ryo_level_3_intro_first_boss"

func start_level_3_first_boss_intro_dialogue() -> void:
	var my_ship_id = SaveSystem.data.selecter_character_id
	var my_dialogue_id = get_level_3_first_boss_intro_dialogue(my_ship_id)
	
	GlobalSingleton.set_state(GlobalSingleton.GameState.DIALOGUING)
	DialogueManager.show_dialogue_balloon(
		load("res://dialogues/level_3_intro_first_boss_dialogue.dialogue"), my_dialogue_id
	)

func get_level_3_third_boss_intro_dialogue(my_ship_id : int) -> String: 
	match my_ship_id:
		0:
			return "ryo_level_3_third_intro_boss"
		1:
			return "billy_level_3_third_intro_boss"
		2:
			return "kimi_level_3_third_intro_boss"
		_:
			return "ryo_level_3_third_intro_boss"

func start_level_3_third_boss_intro_dialogue() -> void:
	var my_ship_id = SaveSystem.data.selecter_character_id
	var my_dialogue_id = get_level_3_third_boss_intro_dialogue(my_ship_id)
	
	GlobalSingleton.set_state(GlobalSingleton.GameState.DIALOGUING)
	DialogueManager.show_dialogue_balloon(
		load("res://dialogues/level_3_intro_third_boss_dialogue.dialogue"), my_dialogue_id
	)

func on_dialogue_ended(_resource):
	GlobalSingleton.set_state(GlobalSingleton.GameState.PLAYING)

func spawn_turret_path_follow(path_follow : PathFollow2D):
	if GlobalSingleton.game_state != GlobalSingleton.GameState.PLAYING:
		return
		
	var turret_random_index := randi_range(0, turret.size() - 1)
	var turret_1_instance = turret[turret_random_index].instantiate()
	path_follow.progress_ratio = randf()
	turret_1_instance.global_position = path_follow.global_position
	
	add_child(turret_1_instance)

func check_first_boss_spawn() -> void:
	if is_first_boss_spawned:
		return
		
	if GlobalSingleton.score >= score_afer_level + score_first_boss_spawner:
		spawn_first_boss()

func check_second_boss_spawn() -> void:
	if is_second_boss_spawned:
		return
		
	if GlobalSingleton.score >= score_after_first_boss + score_second_boss_spawner:
		spawn_second_boss()

func check_third_boss_spawn() -> void:
	if is_third_boss_spawned:
		return
		
	if GlobalSingleton.score >= score_after_second_boss + score_third_boss_spawner:
		spawn_third_boss()

func check_final_boss_spawn() -> void:
	if is_final_boss_spawned:
		return
		
	if GlobalSingleton.score >= score_after_second_boss + score_final_boss_spawner:
		spawn_final_boss()

func spawn_first_boss() -> void:
	is_first_boss_spawned = true
	var first_boss_instance = first_boss_scene.instantiate()
	first_boss_instance.global_position = boss_position_spawner
	add_child(first_boss_instance)
	first_boss_instance.first_boss_entered.connect(set_first_boss_entered)
	first_boss_instance.first_boss_defeated.connect(set_first_boss_defeated)

func spawn_second_boss() -> void:
	is_second_boss_spawned = true
	var second_boss_instance = second_boss_scene.instantiate()
	second_boss_instance.global_position = boss_position_spawner
	add_child(second_boss_instance)

func spawn_third_boss() -> void:
	is_third_boss_spawned = true
	var third_boss_instance = third_boss_scene.instantiate()
	third_boss_instance.global_position = boss_position_spawner
	add_child(third_boss_instance)
	third_boss_instance.third_boss_entered.connect(set_third_boss_entered)
	third_boss_instance.third_boss_defeated.connect(set_third_boss_defeated)

func spawn_final_boss() -> void:
	is_final_boss_spawned = true
	var final_boss_instance = final_boss_scene.instantiate()
	final_boss_instance.global_position = boss_position_spawner
	add_child(final_boss_instance)

func set_first_boss_entered() -> void:
	start_level_3_first_boss_intro_dialogue()

func set_third_boss_entered() -> void:
	start_level_3_third_boss_intro_dialogue()

func set_first_boss_defeated() -> void:
	is_first_boss_defeated = true
	score_after_first_boss = GlobalSingleton.score

func set_third_boss_defeated() -> void:
	is_third_boss_defeated = true
	score_after_third_boss = GlobalSingleton.score

func set_win_level():
	SaveSystem.data.level_unlocked = 4
	SaveSystem.save_game()
	SaveSystem.update_hi_score(GlobalSingleton.score)
	get_tree().change_scene_to_file("res://scenes/menu/upgrade_menu.tscn")

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

func _on_power_up_spawn_timer_timeout() -> void:
	if GlobalSingleton.game_state != GlobalSingleton.GameState.PLAYING:
		return
		
	var power_up_random_index := randi_range(0, power_up.size() - 1)
	var power_up_instance = power_up[power_up_random_index].instantiate()
	
	enemy_path_follow.progress_ratio = randf()
	power_up_instance.global_position = enemy_path_follow.global_position
	add_child(power_up_instance)

func _on_turret_spawn_timer_timeout() -> void:
	if GlobalSingleton.game_state != GlobalSingleton.GameState.PLAYING:
		return
	
	spawn_turret_path_follow(lower_path_follow)
