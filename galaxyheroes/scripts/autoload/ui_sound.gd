extends Node

# --- onready --- #
@onready var mouse_clic_sound : AudioStreamPlayer = $"Mouse Clic Sound"
@onready var voice_sound : AudioStreamPlayer = $"Voice Sound"

func play_mouse_clic_sound() -> void:
	mouse_clic_sound.play()

func play_voice_sound() -> AudioStreamPlayer:
	voice_sound.play()
	return voice_sound
