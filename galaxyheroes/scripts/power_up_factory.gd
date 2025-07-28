class_name PowerUpFactory
extends Node

enum PowerUpType {
	HEALTH,
	TRIPLESHOT
}

@onready var health_scene = preload("res://scenes/power_up/health_power_up.tscn")
@onready var triple_shot_scene = preload("res://scenes/power_up/TripleShotPowerUp.tscn")

func create(power_up_type) -> Node2D:
	var scene : PackedScene
	match power_up_type:
		PowerUpType.HEALTH:
			scene = health_scene
		PowerUpType.TRIPLESHOT:
			scene = triple_shot_scene
		
	return scene.instantiate()
