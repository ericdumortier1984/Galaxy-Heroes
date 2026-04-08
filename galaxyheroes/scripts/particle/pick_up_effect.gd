extends Node2D

# --- onready --- #
@onready var pick_up_sprite : Sprite2D = $Sprite2D
@onready var pick_up_sound : AudioStreamPlayer2D = $"Pick Up Sound"

func play_effect_pick_up(color : Color):
	if pick_up_sprite.material is ShaderMaterial:
		pick_up_sprite.material.set_shader_parameter("bubble_color", color)
	
	var tween := create_tween()
	tween.tween_property(pick_up_sprite, "scale", Vector2.ONE * 0.5, 0.5)\
	.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	tween.parallel().tween_property(pick_up_sprite, "self_modulate", color, 0.5)
	
	pick_up_sound.play()
	tween.finished.connect(queue_free)
