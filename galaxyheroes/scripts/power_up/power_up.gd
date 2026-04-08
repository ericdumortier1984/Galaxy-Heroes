class_name PowerUp
extends Area2D

# --- export --- #
@export var power_up_type := GlobalSingleton.PowerUp.TRIPLE_SHOT
@export var speed : float = 0.0
@export var amplitude : float =  5.0
@export var is_moving : bool = true
@export var timing : float = 0.0
@export var bubble_color : Color
@export var pick_up_particle_scene : PackedScene

# --- onready --- #
@onready var bubble : Sprite2D = $Bubble

func _ready() -> void:
	if bubble.material:
		bubble.material = bubble.material.duplicate()
	set_color_bubble()

func _process(delta: float) -> void:
	set_movement(delta)
	
	if position.x <= -50:
		queue_free()

func set_movement(delta: float) -> void:
	timing += delta / 2
	position.x -= speed * delta
	
	if is_moving:
		position.y += sin(timing * speed) * amplitude * delta

func set_color_bubble():
	if bubble.material is ShaderMaterial:
		var shader_material := bubble.material as ShaderMaterial
		shader_material.set_shader_parameter("bubble_color", bubble_color)

func spawn_pick_up_effect():
	if pick_up_particle_scene == null:
		return
	
	var pick_up_particle = pick_up_particle_scene.instantiate()
	pick_up_particle.global_position = global_position
	
	get_tree().current_scene.add_child(pick_up_particle)
	if pick_up_particle.has_method("play_effect_pick_up"):
		pick_up_particle.play_effect_pick_up(bubble_color)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("PLAYER_SHIP"):
		return
	
	body.get_power_up(power_up_type)
	spawn_pick_up_effect()
	queue_free()
