extends CanvasLayer

func _process(delta: float) -> void:
	$HUD/MarginContainer/Score.text = "SCORE: " + str(GlobalSingleton.score)
	$HUD/MarginContainer/Lifes.text = "LIFES: " + str(GlobalSingleton.lifes)
	$HUD/MarginContainer2/Missiles.text = "MISSILES: " + str(GlobalSingleton.missiles)
	$"HUD/MarginContainer/Hi Score".text = "HI SCORE: " + str(SaveSystem.get_hi_score())
