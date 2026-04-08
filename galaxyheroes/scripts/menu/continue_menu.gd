extends Control

# --- onready --- #
@onready var level_1_button : Button = $"MarginContainer/Selector/Level 1"
@onready var level_2_button : Button = $"MarginContainer/Selector/Level 2"
@onready var level_3_button : Button = $"MarginContainer/Selector/Level 3"

func _ready() -> void:
	await get_tree().process_frame
	
	update_level_buttons()
	set_focus_to_active_level()

func set_focus_to_active_level():
	var unlocked := SaveSystem.data.level_unlocked
	var total_levels := GlobalSingleton.level_scenes.size()
	
	if unlocked > total_levels:
		level_1_button.grab_focus()
		return
	
	match unlocked:
		1:
			level_1_button.grab_focus()
		2:
			level_2_button.grab_focus()
		3:
			level_3_button.grab_focus()

func update_level_buttons():
	var unlocked := SaveSystem.data.level_unlocked
	var total_levels := GlobalSingleton.level_scenes.size()
	
	level_1_button.disabled = unlocked != 1
	level_2_button.disabled = unlocked != 2
	level_3_button.disabled = unlocked != 3
	
	if unlocked > total_levels:
		level_1_button.disabled = false
		level_2_button.disabled = false
		level_3_button.disabled = false
		return

func load_level(level: int):
	var unlocked := SaveSystem.data.level_unlocked
	var total_levels := GlobalSingleton.level_scenes.size()
	if unlocked > total_levels or level == unlocked:
		SaveSystem.data.current_level = level
		SaveSystem.save_game()
		get_tree().change_scene_to_file(GlobalSingleton.level_scenes[level - 1])

func _on_level_1_button_pressed() -> void:
	UiSound.play_mouse_clic_sound()
	load_level(1)
	GlobalSingleton.load_game_state()

func _on_level_2_button_pressed() -> void:
	UiSound.play_mouse_clic_sound()
	load_level(2)
	GlobalSingleton.load_game_state()

func _on_level_3_pressed() -> void:
	UiSound.play_mouse_clic_sound()
	load_level(3)
	GlobalSingleton.load_game_state()

func _on_back_pressed() -> void:
	UiSound.play_mouse_clic_sound()
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")
