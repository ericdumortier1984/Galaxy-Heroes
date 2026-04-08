extends Control

# ---  onready --- #
@onready var first_option_button : Button = $"Skill Upgrades Container/Life Margin Container/Upgrade Life/Life Button"
@onready var continue_button : Button = $"Continue Margin Container/Continue"

# --- bool --- #
var skill_selected : bool = false
var weapon_selected : bool = false

func _ready() -> void:
	first_option_button.grab_focus()
	continue_button.disabled = true

func _on_life_button_pressed() -> void:
	if skill_selected:
		return
	UiSound.play_mouse_clic_sound()
	skill_selected = true
	SaveSystem.data.upgrade_life += 1
	GlobalSingleton.upgrade_life = SaveSystem.data.upgrade_life
	GlobalSingleton.lifes += 1
	SaveSystem.data.lifes = GlobalSingleton.lifes
	disable_skill_buttons()
	check_upgrade_selected()
	$"Skill Upgrades Container/Life Margin Container/Upgrade Life/Life Button".modulate = Color.AQUA

func _on_speed_button_pressed() -> void:
	if skill_selected:
		return
	UiSound.play_mouse_clic_sound()
	skill_selected = true
	SaveSystem.data.upgrade_speed += 5
	disable_skill_buttons()
	check_upgrade_selected()
	$"Skill Upgrades Container/Speed Margin Container/Upgrade Speed/Speed Button".modulate = Color.AQUA

func _on_time_shield_button_pressed() -> void:
	if skill_selected:
		return
	UiSound.play_mouse_clic_sound()
	skill_selected = true
	SaveSystem.data.upgrade_time_shield += 5
	disable_skill_buttons()
	check_upgrade_selected()
	$"Skill Upgrades Container/Shield Margin Container/Upgrade Shield Timer/Time Shield Button".modulate = Color.AQUA

func _on_bomb_button_pressed() -> void:
	if weapon_selected:
		return
	UiSound.play_mouse_clic_sound()
	weapon_selected = true
	GlobalSingleton.special_bar_value = GlobalSingleton.max_special_bar
	SaveSystem.data.weapon_selected = GlobalSingleton.ExtraWeapon.BOMB
	disable_weapon_buttons()
	check_upgrade_selected()
	$"Weapon Upgrade Container/Bomb Margin Container/Add Bomb/Bomb Button".modulate = Color.AQUA

func _on_drone_button_pressed() -> void:
	if weapon_selected:
		return
	UiSound.play_mouse_clic_sound()
	weapon_selected = true
	GlobalSingleton.special_bar_value = GlobalSingleton.max_special_bar
	SaveSystem.data.weapon_selected = GlobalSingleton.ExtraWeapon.DRONE
	disable_weapon_buttons()
	check_upgrade_selected()
	$"Weapon Upgrade Container/Drone Margin Container/Add Drone/Drone Button".modulate = Color.AQUA

func _on_rain_button_pressed() -> void:
	if weapon_selected:
		return
	UiSound.play_mouse_clic_sound()
	weapon_selected = true
	GlobalSingleton.special_bar_value = GlobalSingleton.max_special_bar
	SaveSystem.data.weapon_selected = GlobalSingleton.ExtraWeapon.BULLET_RAIN
	disable_weapon_buttons()
	check_upgrade_selected()
	$"Weapon Upgrade Container/Rain Margin Container/Add Rain/Rain Button".modulate = Color.AQUA

func disable_skill_buttons() -> void:
	$"Skill Upgrades Container/Life Margin Container/Upgrade Life/Life Button".disabled = true
	$"Skill Upgrades Container/Speed Margin Container/Upgrade Speed/Speed Button".disabled = true
	$"Skill Upgrades Container/Shield Margin Container/Upgrade Shield Timer/Time Shield Button".disabled = true

func disable_weapon_buttons() -> void:
	$"Weapon Upgrade Container/Bomb Margin Container/Add Bomb/Bomb Button".disabled = true
	$"Weapon Upgrade Container/Drone Margin Container/Add Drone/Drone Button".disabled = true
	$"Weapon Upgrade Container/Rain Margin Container/Add Rain/Rain Button".disabled = true

func check_upgrade_selected() -> void:
	if skill_selected and weapon_selected:
		continue_button.disabled = false
		continue_button.modulate = Color.AQUA

func _on_continue_pressed() -> void:
	UiSound.play_mouse_clic_sound()
	SaveSystem.save_game()
	GlobalSingleton.load_next_level()
