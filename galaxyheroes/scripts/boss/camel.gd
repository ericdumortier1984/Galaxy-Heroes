class_name CamelBoss
extends Node2D

signal third_boss_entered
signal third_boss_defeated

# --- onready --- #
@onready var lower_shoot_marker : Array = $"Area2D/Lower Shoot Marker".get_children()
@onready var upper_shoot_marker : Array = $"Area2D/Upper Shoot Marker".get_children()


func _ready() -> void:
	set_third_boss_entry()


func _process(delta: float) -> void:
	pass

func set_third_boss_entry() -> void:
	#is_first_boss_entering = true
	
	var screen_size = get_viewport_rect().size
	var screen_target_postion = screen_size.x * 0.8
	
	var entry_tween = get_tree().create_tween()
	entry_tween.tween_property(
		self, "global_position:x", screen_target_postion, 5.0
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	entry_tween.finished.connect(set_third_boss_entry_finish)


func set_third_boss_entry_finish() -> void:
	third_boss_entered.emit()

func _on_area_2d_area_entered(area: Area2D) -> void:
	pass # Replace with function body.


func _on_shoot_pattern_timer_timeout() -> void:
	for marker in lower_shoot_marker:
		marker.start_shot_third_boss()
	for marker in upper_shoot_marker:
		marker.start_shot_third_boss()
