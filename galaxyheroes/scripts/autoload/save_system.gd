extends Node

var data : SaveData

func _ready() -> void:
	await get_tree().process_frame
	load_game()
	apply_settings()

func apply_settings():
	_apply_audio()
	_apply_video()

func _apply_audio():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),
	linear_to_db(data.music_volume / 100.0))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"),
	linear_to_db(data.sfx_volume / 100.0))

func _apply_video():
	if BrightnessLayer == null:
		return
	BrightnessLayer.set_brightness(data.brightness)
	
	if data.full_screen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN) 
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(data.resolution)

func save_game():
	if data == null:
		data = SaveData.new()
	
	ResourceSaver.save(data, "user://save.tres")

func load_game():
	if ResourceLoader.exists("user://save.tres"):
		data = ResourceLoader.load("user://save.tres") as SaveData
	else:
		data = SaveData.new()
		save_game()

func update_hi_score(final_score : int) -> void:
	if data == null:
		data = SaveData.new()
	
	if final_score > data.hi_score:
		data.hi_score = final_score
		save_game()

func get_hi_score() -> int:
	if data == null:
		load_game()
	return data.hi_score
