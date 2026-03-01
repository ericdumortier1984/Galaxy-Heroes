class_name Asteroid
extends Area2D

# --- export --- #
@export var speed : int = 0
@export var life : int = 0
@export var damage : int = 0
@export var asteroid_rotation : float = 0.0

# --- onready --- #
@onready var explosion_animation : AnimatedSprite2D = $Explosion
@onready var explosion_sound : AudioStreamPlayer2D = $"Explosion/Explosion Sound"

# --- vector --- #
var direction : Vector2

# --- bool --- #
var is_explosion : bool = false

func _process(delta: float) -> void:
	position += direction * speed * delta
	rotation += asteroid_rotation * delta

func take_damage(amount : int):
	if is_explosion:
		return
	
	life -= amount
	if life <= 0:
		explode()

func explode():
	is_explosion = true
	explosion_animation.play("explosion")
	explosion_sound.play()
