extends Control

func _on_fire_rate_button_pressed() -> void:
	SaveSystem.data.fire_rate_upgrade += 1

func _on_damage_button_pressed() -> void:
	SaveSystem.data.damage_upgrade += 1

func _on_speed_button_pressed() -> void:
	SaveSystem.data.speed += 1

func _on_continue_pressed() -> void:
	SaveSystem.save_game()
	get_tree().change_scene_to_file("res://scenes/level/level_2.tscn")
