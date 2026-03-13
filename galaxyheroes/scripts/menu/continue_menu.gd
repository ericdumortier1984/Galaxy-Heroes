extends Control

# --- onready --- #
@onready var select_button : Button = $"MarginContainer/Selector/Level 1"

func _ready() -> void:
	await get_tree().process_frame
	select_button.grab_focus()

func _on_level_1_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level/level_1.tscn")

func _on_level_2_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level/level_2.tscn")

func _on_level_3_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level/level_3.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")
