extends Control

@onready var select_button : Button = $"MarginContainer/Vertical Box/Buttons/Restart"

func _ready():
	await get_tree().process_frame
	select_button.grab_focus()

func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
