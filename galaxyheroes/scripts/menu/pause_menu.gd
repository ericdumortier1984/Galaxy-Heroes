extends Control

@onready var pause_menu : Control = $"."
@onready var select_button : Button = $MarginContainer/ColorRect/VBoxContainer/Resume

# --- bool --- #
var is_paused : bool = false

func _process(_delta: float) -> void:
	if is_paused:
		return

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_menu"):
		set_pause()

func set_pause():
	is_paused = !is_paused
	get_tree().paused = is_paused
	pause_menu.visible = is_paused
	
	if is_paused:
		await get_tree().process_frame
		select_button.grab_focus()

func _on_resume_pressed() -> void:
	get_tree().paused = false
	visible = false
	
	if GlobalSingleton.game_state == GlobalSingleton.GameState.DIALOGUING:
		var balloon := get_tree().get_first_node_in_group("BALLOON")
		if balloon:
			balloon.regain_focus()

func _on_main_menu_pressed() -> void:
	UiSound.play_mouse_clic_sound()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
