extends Node2D

# --- onready --- #
@onready var bullet_camera : Camera2D = $Settings/Camera2D
@onready var music_background : AudioStreamPlayer = $"Settings/Music Background"
@onready var final_boss_position : Vector2 = Vector2(get_viewport_rect().size.x * 0.8, 
get_viewport_rect().size.y * 0.58)

# --- export --- #
@export var my_ship : Array[PackedScene]
@export var final_bullet_scene : PackedScene
@export var final_boss_scene : PackedScene

# --- bool --- #
var is_final_bullet_shooted : bool = false
var is_final_dialogue : bool = false

# --- reference --- #
var my_selected_ship : Node2D

func _ready() -> void:
	SaveSystem.load_game()
	GlobalSingleton.set_state(GlobalSingleton.GameState.DIALOGUING)
	set_character()
	set_final_boss_character()
	start_final_scene_intro_dialogue()
	DialogueManager.dialogue_ended.connect(on_dialogue_ended)

func _process(delta: float) -> void:
	parallax_behavior(delta)

func _input(event: InputEvent) -> void:
	if GlobalSingleton.game_state != GlobalSingleton.GameState.PLAYING:
		return
	if is_final_bullet_shooted:
		return
	if event.is_action_pressed("shoot"):
		is_final_bullet_shooted = true
		var ship = get_tree().get_first_node_in_group("PLAYER_SHIP")
		ship.shoot_final_bullet()

func parallax_behavior(delta_time) -> void:
	get_node("Background/Background Parallax").scroll_base_offset -= Vector2(1, 0) * 8 * delta_time
	get_node("Background/Floor Background Parallax").scroll_base_offset -= Vector2(1, 0) * 8 * delta_time
	get_node("Background/Roof Background Parallax").scroll_base_offset -= Vector2(1, 0) * 8 * delta_time

func set_character() -> void:
	var my_ship_id := SaveSystem.data.selecter_character_id
	my_ship_id = clamp(my_ship_id, 0, my_ship.size() - 1)
	
	my_selected_ship = my_ship[my_ship_id].instantiate()
	my_selected_ship.global_position = GlobalSingleton.selected_character_final_position
	
	add_child(my_selected_ship)
	
	GlobalSingleton.set_state(GlobalSingleton.GameState.CINEMATIC)
	force_my_ship_position()

func force_my_ship_position() -> void:
	var target_position = Vector2(
		get_viewport_rect().size.x * 0.2,
		get_viewport_rect().size.y * 0.5
	)
	
	var tween = get_tree().create_tween()
	tween.tween_property(
		my_selected_ship,
		"global_position",
		target_position,
		1.2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	await tween.finished
	GlobalSingleton.set_state(GlobalSingleton.GameState.DIALOGUING)

func set_final_boss_character() -> void:
	var final_boss_instance = final_boss_scene.instantiate()
	final_boss_instance.global_position = final_boss_position
	final_boss_instance.is_almost_destroy = true
	final_boss_instance.override_life = -1
	add_child(final_boss_instance)
	final_boss_instance.final_boss_defeated.connect(on_final_boss_defeated)

func get_final_scene_intro_dialogue(my_ship_id : int) -> String: 
	match my_ship_id:
		0:
			return "ryo_final_scene_intro"
		1:
			return "billy_final_scene_intro"
		2:
			return "kimi_final_scene_intro"
		_:
			return "ryo_final_scene_intro"

func start_final_scene_intro_dialogue() -> void:
	var my_ship_id = SaveSystem.data.selecter_character_id
	var my_dialogue_id = get_final_scene_intro_dialogue(my_ship_id)
	
	GlobalSingleton.set_state(GlobalSingleton.GameState.DIALOGUING)
	DialogueManager.show_dialogue_balloon(
		load("res://dialogues/final_scene_intro_dialogue.dialogue"), my_dialogue_id
	)

func get_final_dialogue(my_ship_id : int) -> String:
	match my_ship_id:
		0:
			return "ryo_final_dialogue"
		1:
			return "billy_final_dialogue"
		2:
			return "kimi_final_dialogue"
		_:
			return "ryo_final_dialogue"

func start_final_dialogue() -> void:
	is_final_dialogue = true
	var my_ship_id = SaveSystem.data.selecter_character_id
	var my_dialogue_id = get_final_dialogue(my_ship_id)
	
	GlobalSingleton.set_state(GlobalSingleton.GameState.DIALOGUING)
	DialogueManager.show_dialogue_balloon(
		load("res://dialogues/final_scene_final_dialogue.dialogue"), my_dialogue_id
	)

func on_dialogue_ended(_resource):
	if is_final_dialogue:
		show_credits()
	else:
		GlobalSingleton.set_state(GlobalSingleton.GameState.PLAYING)

func set_final_bullet_camera(final_bullet) -> void:
	GlobalSingleton.set_state(GlobalSingleton.GameState.CINEMATIC)
	Engine.time_scale = 0.3
	
	bullet_camera.reparent(final_bullet)
	bullet_camera.position = Vector2.ZERO
	bullet_camera.zoom = Vector2(2.0, 2.0)
	bullet_camera.make_current()
	
	GlobalSingleton.set_state(GlobalSingleton.GameState.PLAYING)

func on_final_boss_defeated() -> void:
	GlobalSingleton.set_state(GlobalSingleton.GameState.DIALOGUING)
	start_final_dialogue()

func show_credits() -> void:
	await get_tree().create_timer(2.0).timeout
	Transition.change_scene("res://scenes/menu/credits.tscn")
