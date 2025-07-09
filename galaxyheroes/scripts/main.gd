extends Node2D

var pre_load_enemy = preload("res://scenes/enemy.tscn")

func _ready():
	randomize()

func _on_timer_timeout() -> void:
	
	var enemy = pre_load_enemy.instantiate()
	self.call_deferred("add_child", enemy)
	enemy.position.y = round(randi_range(0,648))
	enemy.add_to_group("enemy")
