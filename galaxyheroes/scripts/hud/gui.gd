extends CanvasLayer

# --- onready --- #
@onready var special_weapon_label : Label = $HUD/MarginContainer3/Label
@onready var special_weapon_bar : ProgressBar = $"HUD/MarginContainer3/Special Bar"

func _process(_delta: float) -> void:
	$HUD/MarginContainer/Score.text = "SCORE: " + str(GlobalSingleton.score)
	$HUD/MarginContainer/Lifes.text = "LIFES: " + str(GlobalSingleton.lifes)
	$HUD/MarginContainer2/Missiles.text = "MISSILES: " + str(GlobalSingleton.missiles)
	$"HUD/MarginContainer/Hi Score".text = "HI SCORE: " + str(SaveSystem.get_hi_score())
	
	update_special_weapon_ui()

func update_special_weapon_ui() -> void:
	var special_weapon = SaveSystem.data.weapon_selected
	
	if special_weapon == GlobalSingleton.ExtraWeapon.NONE:
		special_weapon_label.text = "SPECIAL: NONE"
		special_weapon_bar.visible = true
		return
	
	special_weapon_label.text = "SPECIAL: " + GlobalSingleton.get_special_weapon_name()
	special_weapon_bar.visible = true
	special_weapon_bar.max_value = GlobalSingleton.max_special_bar
	special_weapon_bar.value = GlobalSingleton.special_bar_value
