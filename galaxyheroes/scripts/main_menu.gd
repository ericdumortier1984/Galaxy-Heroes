extends Control

@onready var select_button : Button = $MarginContainer/VBoxContainer/Start

func _ready():
	await get_tree().process_frame
	select_button.grab_focus()

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/select_character.tscn")

func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/options_menu.tscn")

func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/credits.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
