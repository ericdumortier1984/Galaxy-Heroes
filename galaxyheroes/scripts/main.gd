extends Node2D

var pre_load_enemy = preload("res://scenes/enemy.tscn")

func _ready():
	randomize()

func _on_timer_timeout() -> void:
	var enemy = pre_load_enemy.instantiate()
	self.call_deferred("add_child", enemy)
	enemy.position.y = round(randi_range(0,648))
	#enemy.position = Vector2(1152 + 50, randi_range(0, 648))  # X fuera de la pantalla derecha
	enemy.add_to_group("enemy")
