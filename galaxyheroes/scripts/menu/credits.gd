extends Control

@onready var select_button : Button = $Panel/MarginContainer/Back

func _ready():
	await get_tree().process_frame
	select_button.grab_focus()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")
