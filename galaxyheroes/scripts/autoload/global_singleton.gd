extends Node

enum GameState {
	DIALOGUING,
	PLAYING,
	WIN,
	GAME_OVER,
	PAUSED, 
	CINEMATIC
}

enum PowerUp {
	LIFE,
	SHIELD,
	DOUBLE_SHOT,
	TRIPLE_SHOT,
	MISSILE,
	SPEED
}

enum ExtraWeapon {
	NONE,
	BOMB,
	DRONE,
	BULLET_RAIN
}

# --- game_state --- #
signal state_changed(new_state)
var game_state : GameState = GameState.PLAYING

# --- score --- "
var score : int = 0
var hi_score : int = 0

# --- upgrade --- #
var upgrades_applied : bool = false
var upgrade_life : int = 0
var upgrade_speed : int = 0
var upgrade_time_shield : int = 0
var special_bar_value : float = 100.0
var max_special_bar : float = 100.0
var consume_time_special_bar : float = 0.10

# --- character --- #
var selecter_character_id : int = 0
var selected_character_final_position : Vector2
var lifes : int = 0
var missiles : int = 0

# --- scenes --- #
var level_scenes : Array[String] = [
	"res://scenes/level/level_1.tscn",
	"res://scenes/level/level_2.tscn",
	"res://scenes/level/level_3.tscn"
]

func start_new_game():
	missiles = 0
	score = 0
	
	load_upgrades()
	lifes = 3 
	
	SaveSystem.data.lifes = lifes
	SaveSystem.data.current_level = 1
	SaveSystem.save_game()

func set_state(new_state : GameState) -> void:
	if game_state == new_state:
		return
	
	game_state = new_state
	state_changed.emit(game_state)
	
	match game_state:
		GameState.GAME_OVER:
			game_over()

func load_game_state():
	load_upgrades()
	lifes = max(1, SaveSystem.data.lifes)

func lose_life(amount: int = 1) -> void:
	lifes -= amount
	
	SaveSystem.data.lifes = lifes
	SaveSystem.save_game()
	
	if lifes <= 0:
		lifes = 0
		set_state(GameState.GAME_OVER)

func apply_life_upgrade():
	if upgrades_applied:
		return
	
	lifes += upgrade_life
	upgrades_applied = true

func load_upgrades():
	upgrade_speed = SaveSystem.data.upgrade_speed
	upgrade_life = SaveSystem.data.upgrade_life
	upgrade_time_shield = SaveSystem.data.upgrade_time_shield

func get_special_weapon_name() -> String:
	match SaveSystem.data.weapon_selected:
		ExtraWeapon.BOMB:
			return "BOMB"
		ExtraWeapon.DRONE:
			return "DRONE"
		ExtraWeapon.BULLET_RAIN:
			return "BULLET RAIN"
		_: 
			return "NONE"

func consume_special_weapon_bar(amount : float) -> bool:
	if special_bar_value <= 0:
		return false
	
	special_bar_value -= amount
	return true

func complete_level(current_level: int) -> void:
	var next_level := current_level + 1
	
	if SaveSystem.data.level_unlocked < next_level:
		SaveSystem.data.level_unlocked = next_level
	#SaveSystem.data.current_level = next_level
	
	if next_level > level_scenes.size():
		SaveSystem.data.current_level = 1
	else:
		SaveSystem.data.current_level = next_level
	
	SaveSystem.data.lifes = lifes
	SaveSystem.save_game()

func load_next_level() -> void:
	var next_level : int = SaveSystem.data.current_level
	
	if next_level - 1 < level_scenes.size():
		get_tree().change_scene_to_file(level_scenes[next_level - 1])
	else:
		get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")

func game_over() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/game_over.tscn")
	SaveSystem.update_hi_score(score)
	SaveSystem.save_game()
