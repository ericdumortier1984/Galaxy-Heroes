class_name Bomb
extends Area2D

signal bomb_process_finish

# --- export --- #
@export var life_time : float = 0.0
@export var damage : int = 0
@export var shot_velocity : Vector2 = Vector2.ZERO
@export var shot_gravity : Vector2 = Vector2.ZERO

# --- onready --- #
@onready var exposion_animation : AnimatedSprite2D = $Explosion
@onready var screen_notifier : VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

# --- float --- #
var time_elapsed : float = 0.0

# --- bool --- #
var has_explode : bool = false

func _process(delta: float) -> void:
	set_bomb_life_time(delta)
	shot_velocity += shot_gravity * delta
	position += shot_velocity * delta

func set_bomb_life_time(delta : float) -> void:
	time_elapsed += delta
	
	if time_elapsed >= life_time:
		explode_bomb_by_time()

func explode_bomb_by_time() -> void:
	has_explode = true
	emit_signal("bomb_process_finish")
	show_explosion()
	exposion_animation.visible = true
	exposion_animation.play("explosion")
	apply_damage()
	await get_tree().create_timer(0.2).timeout
	queue_free()

func apply_damage() -> void:
	for area in get_tree().get_nodes_in_group("ENEMIES"):
		if area.global_position.distance_to(global_position) <= 220:
			var enemy = area.get_parent()
			if enemy.has_method("take_damage"):
				enemy.take_damage(damage)
	
	for boss in get_tree().get_nodes_in_group("BOSSES"):
		if boss.global_position.distance_to(global_position) <= 220:
			var boss_node = boss.get_parent()
			if boss_node.has_method("take_damage"):
				boss_node.take_damage(damage)

func _draw():
	if has_explode:
		draw_circle(Vector2.ZERO, 220, Color(1.0, 0.059, 0.0, 0.302))

func show_explosion():
	queue_redraw()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("ENEMIES"):
		explode_bomb_by_time()
	if area.is_in_group("BOSSES"):
		explode_bomb_by_time()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	emit_signal("bomb_process_finish")
	queue_free()
