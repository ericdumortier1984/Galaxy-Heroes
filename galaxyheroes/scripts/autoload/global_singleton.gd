extends Node

enum GameState {
	DIALOGUING,
	PLAYING,
	WIN,
	GAME_OVER,
	PAUSED
}

enum PowerUp {
	LIFE,
	SHIELD,
	DOUBLE_SHOT,
	TRIPLE_SHOT,
	MISSILE,
	SPEED
}

signal state_changed(new_state)

var score : int = 0
var hi_score : int = 0
var lifes : int = 0
var missiles : int = 0
var selecter_character_id : int = 0
var game_state : GameState = GameState.PLAYING
var level_scenes : Array[String] = [
	"res://scenes/level/level_1.tscn",
	"res://scenes/level/level_2.tscn",
	"res://scenes/level/level_3.tscn"
]

func set_state(new_state : GameState) -> void:
	if game_state == new_state:
		return
	
	game_state = new_state
	state_changed.emit(game_state)
	
	match game_state:
		GameState.GAME_OVER:
			game_over()

func lose_life(amount: int = 1) -> void:
	lifes -= amount
	
	if lifes <= 0:
		lifes = 0
		set_state(GameState.GAME_OVER)

func load_next_level() -> void:
	var next_level : int = SaveSystem.data.level_unlocked
	
	if next_level - 1 < level_scenes.size():
		get_tree().change_scene_to_file(level_scenes[next_level - 1])
	else:
		get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")

func game_over() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/game_over.tscn")
	SaveSystem.update_hi_score(score)
