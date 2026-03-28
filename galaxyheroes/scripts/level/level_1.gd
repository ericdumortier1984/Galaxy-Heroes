extends Node2D

# --- export ---  #
@export var enemy : Array[PackedScene]
@export var upper_asteroid : Array[PackedScene]
@export var lower_asteroid : Array[PackedScene]
@export var power_up_scene : Array[PackedScene]
@export var boss_scene : PackedScene
@export var my_ships : Array[PackedScene]
@export var boss_score_spawner : int = 1500
@export var boss_spawn_point : Vector2

# --- onready --- #
@onready var my_ship_spawn_position : Vector2 = Vector2(20, get_viewport_rect().size.y / 2)
@onready var enemy_path_follow = $"Enemy Spawner/PathFollow2D"
@onready var uppper_asteroid_path_follow = $"Upper Asteroid Spawner/Upper Asteroid Path Follow"
@onready var lower_asteroid_path_follow = $"Lower Asteroid Spawner/Lower Asteroid Path Follow"

# --- bool --- #
var boss_spawned : bool = false
var boss_instance = Level1Boss
var level_completed : bool = false

# --- int --- # 
var level_start_score : int = 0

func _ready() -> void:
	await get_tree().process_frame
	Transition.fade_out()
	GlobalSingleton.load_game_state()
	level_start_score = GlobalSingleton.score
	start_intro_dialogue()
	DialogueManager.dialogue_ended.connect(on_dialogue_ended)
	set_character()

func _process(delta: float) -> void:
	parallax_behavior(delta)
	check_boss_spawn()

func get_level_score() -> int:
	return GlobalSingleton.score - level_start_score

func set_character():
	var my_ship_id := SaveSystem.data.selecter_character_id
	my_ship_id = clamp(my_ship_id, 0, my_ships.size() - 1)
	
	var my_selected_ship := my_ships[my_ship_id].instantiate()
	my_selected_ship.global_position = my_ship_spawn_position
	add_child(my_selected_ship)

func parallax_behavior(delta_time) -> void:
	get_node("Background/Background Parallax").scroll_base_offset -= Vector2(1, 0) * 8 * delta_time
	get_node("Background/Stars Parallax").scroll_base_offset -= Vector2(1, 0) * 16 * delta_time

func check_boss_spawn():
	if boss_spawned:
		return
		
	#if GlobalSingleton.score >= boss_score_spawner:
	if get_level_score() >= boss_score_spawner:
		boss_spawn()

func boss_spawn():
	boss_spawned = true
	boss_instance = boss_scene.instantiate()
	boss_instance.global_position = boss_spawn_point
	add_child(boss_instance)
	
	boss_instance.boss_entered.connect(set_boss_entered)
	boss_instance.boss_defeated.connect(set_boss_defeated)

func set_boss_entered():
	start_intro_boss_dialogue()

func set_boss_defeated():
	call_deferred("win_level")

func show_level_completed(): 
	var texture_win_label = load("res://images/UI/text/Level_completed.png")
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
	#SaveSystem.data.level_unlocked = 2
	#SaveSystem.save_game()
	GlobalSingleton.complete_level(1)
	SaveSystem.update_hi_score(GlobalSingleton.score)
	Transition.change_scene("res://scenes/menu/upgrade_menu.tscn")

func win_level():
	GlobalSingleton.set_state(GlobalSingleton.GameState.WIN)
	await show_level_completed()
	set_win_level()

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

func get_intro_boss_dialogue_id(ship_id: int) -> String:
	match ship_id:
		0:
			return "ryo_intro_boss_level_1"
		1:
			return "billy_intro_boss_level_1"
		2:
			return "kimi_intro_boss_level_1"
		_:
			return "ryo_intro_boss_level_1"

func start_intro_dialogue():
	var ship_id := SaveSystem.data.selecter_character_id
	var dialogue_id := get_intro_dialogue_id(ship_id)

	GlobalSingleton.set_state(GlobalSingleton.GameState.DIALOGUING)
	DialogueManager.show_dialogue_balloon(
		load("res://dialogues/intro_dialogue.dialogue"), dialogue_id)

func start_intro_boss_dialogue(): 
	var ship_id := SaveSystem.data.selecter_character_id
	var dialogue_id := get_intro_boss_dialogue_id(ship_id)

	GlobalSingleton.set_state(GlobalSingleton.GameState.DIALOGUING)
	DialogueManager.show_dialogue_balloon(
		load("res://dialogues/intro_boss_level_1_dialogue.dialogue"), dialogue_id)

func on_dialogue_ended(_resource):
	GlobalSingleton.set_state(GlobalSingleton.GameState.PLAYING)

func spawn_asteroid_from_path(path_follow: PathFollow2D, dir: Vector2):
	var index := randi_range(0, upper_asteroid.size() - 1)
	var asteroid_instance = upper_asteroid[index].instantiate()
	
	path_follow.progress_ratio = randf()
	asteroid_instance.global_position = path_follow.global_position
	asteroid_instance.direction = dir
	
	add_child(asteroid_instance)

func _on_timer_timeout() -> void:
	if GlobalSingleton.game_state != GlobalSingleton.GameState.PLAYING:
		return
	
	var random_index := randi_range(0, enemy.size() - 1)
	var enemies_instance = enemy[random_index].instantiate()
	
	enemy_path_follow.progress_ratio = randf()
	enemies_instance.global_position = $"Enemy Spawner/PathFollow2D".global_position
	add_child(enemies_instance)
	
	spawn_asteroid_from_path(uppper_asteroid_path_follow, Vector2(-1, 1).normalized())
	spawn_asteroid_from_path(lower_asteroid_path_follow, Vector2(-1, -1).normalized())

func _on_power_up_timer_timeout() -> void:
	if GlobalSingleton.game_state != GlobalSingleton.GameState.PLAYING:
		return
	
	var random_index := randi_range(0, power_up_scene.size() - 1) 
	var power_up_instance := power_up_scene[random_index].instantiate()
	power_up_instance.global_position = enemy_path_follow.global_position
	add_child(power_up_instance)
