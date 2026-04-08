extends CanvasLayer

# --- onready --- #
@onready var brightness_color_rect : ColorRect = $Brightness

func set_brightness(value : float) -> void:
	brightness_color_rect.modulate.a = 1.0 - (value / 100.0)
	#brightness_color_rect.modulate.a = clamp(1.0 - (value / 100.0), 0.0, 1.0)
	#var normalized = (value - 50.0) / 50.0
	#brightness_color_rect.modulate.a = (1.0 - normalized) * 0.6
