extends CanvasLayer

@onready var animation_player = $AnimationPlayer

func fade_in() -> void:
	animation_player.play("fade_in")
	await animation_player.animation_finished

func fade_out() -> void:
	animation_player.play("fade_out")
	await animation_player.animation_finished

func change_scene(path : String) -> void:
	await fade_in()
	get_tree().change_scene_to_file(path)
	await get_tree().process_frame 
	await fade_out()
