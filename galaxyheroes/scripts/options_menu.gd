extends Control

@onready var select_one_button : Button = $MarginContainer/Video
@onready var select_two_button : Button = $MarginContainer/Audio
@onready var select_three_button : Button = $"MarginContainer/Key Controller"
@onready var select_four_button : Button = $MarginContainer/Back

# --- panels --- #
@onready var audio_panel : Control = $"MarginContainer/Audio Panel"
@onready var video_panel : Control = $"MarginContainer/Video Panel"
@onready var key_controller_panel : Control = $"MarginContainer/Key Controller Panel"

# --- buttons --- #
@onready var audio_button : Button = $MarginContainer/Audio
@onready var video_button : Button = $MarginContainer/Video
@onready var key_controller_button : Button = $"MarginContainer/Key Controller"

# --- sliders --- #
@onready var music_slider : Slider = $"MarginContainer/Audio Panel/VBoxContainer/Music Slider"
@onready var sfx_slider : Slider = $"MarginContainer/Audio Panel/VBoxContainer/SFX Slider"
@onready var brightness_slider : Slider = $"MarginContainer/Video Panel/VBoxContainer/HSlider"

func _ready() -> void:
	await get_tree().process_frame
	show_audio_panel()
	music_slider.value = SaveSystem.data.music_volume
	sfx_slider.value = SaveSystem.data.sfx_volume
	brightness_slider.value = SaveSystem.data.brightness

func show_audio_panel():
	audio_panel.visible = true
	video_panel.visible = false
	key_controller_panel.visible = false
	video_button.visible = true
	video_button.text = "VIDEO"
	audio_button.visible = false
	key_controller_button.visible = false
	
	await get_tree().process_frame
	music_slider.grab_focus()

func show_video_panel():
	audio_panel.visible = false
	key_controller_panel.visible = false
	video_panel.visible = true
	audio_button.visible = true
	audio_button.text = "AUDIO"
	video_button.visible = false
	key_controller_button.visible = true
	key_controller_button.text = "INPUT"
	
	await get_tree().process_frame
	brightness_slider.grab_focus()

func show_key_controller_panel():
	audio_panel.visible = false
	key_controller_panel.visible = true
	video_panel.visible = false
	video_button.text = "VIDEO"
	audio_button.visible = true
	audio_button.text = "AUDIO"
	video_button.visible = false
	key_controller_button.visible = false
	
	await get_tree().process_frame
	$MarginContainer/Back.grab_focus()

# --- sliders --- #
func _on_h_slider_value_changed(value: float) -> void:
	SaveSystem.data.music_volume = value
	SaveSystem.apply_settings()
	SaveSystem.save_game()

func _on_sfx_slider_value_changed(value: float) -> void:
	SaveSystem.data.sfx_volume = value
	SaveSystem.apply_settings()
	SaveSystem.save_game()

func _on_brightness_slider_value_changed(value: float) -> void:
	SaveSystem.data.brightness = value
	SaveSystem.apply_settings()
	SaveSystem.save_game()

# --- buttons pressed --- #
func _on_video_pressed() -> void:
	show_video_panel()

func _on_audio_pressed() -> void:
	show_audio_panel()

func _on_key_controller_pressed() -> void:
	show_key_controller_panel()

func _on_back_pressed() -> void:
	SaveSystem.save_game()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
