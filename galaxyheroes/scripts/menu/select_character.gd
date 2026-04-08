extends Control

# --- onready --- #
@onready var character_ryo_button : Button =  $"Select Character Button Container/Character Ryo"
@onready var character_billy_button : Button = $"Select Character Button Container/Character Billy"
@onready var character_kimi_button : Button = $"Select Character Button Container/Character Kimi"

func _ready() -> void:
	await get_tree().process_frame
	Transition.fade_out()
	match SaveSystem.data.selecter_character_id:
		0 : character_ryo_button.grab_focus()
		1 : character_billy_button.grab_focus()
		2 : character_kimi_button.grab_focus()

func select_character(id : int):
	SaveSystem.data.selecter_character_id = id
	SaveSystem.save_game()
	get_tree().change_scene_to_file("res://scenes/menu/intro_story.tscn")

func _on_button_pressed() -> void:
	UiSound.play_mouse_clic_sound()
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")

func _on_character_ryo_pressed() -> void:
	var ui_voice_sound = UiSound.play_voice_sound()
	Transition.fade_in()
	await ui_voice_sound.finished
	select_character(0)

func _on_character_billy_pressed() -> void:
	var ui_voice_sound = UiSound.play_voice_sound()
	await ui_voice_sound.finished
	select_character(1)

func _on_character_kimi_pressed() -> void:
	var ui_voice_sound = UiSound.play_voice_sound()
	await ui_voice_sound.finished
	select_character(2)
