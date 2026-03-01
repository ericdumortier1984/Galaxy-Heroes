extends Control

# --- onready --- #
@onready var select_button : Button = $MarginContainer/VBoxContainer/Start
@onready var continue_button : Button = $MarginContainer/VBoxContainer/Continue

func _ready():
	await get_tree().process_frame
	select_button.grab_focus()
	SaveSystem.load_game()
	set_continue_game()

func set_continue_game():
	if SaveSystem.data.level_unlocked > 1:
		continue_button.disabled = false
		continue_button.modulate = Color(1,1,1,1)
	else:
		continue_button.disabled = true
		continue_button.modulate = Color(1,1,1,0.4)

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/select_character.tscn")

func _on_load_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/continue_menu.tscn")

func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/options_menu.tscn")

func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/credits.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
