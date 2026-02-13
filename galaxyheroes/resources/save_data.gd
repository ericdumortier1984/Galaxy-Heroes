class_name SaveData
extends Resource

# --- sounds and music --- #
@export var music_volume : float = 0.5
@export var sfx_volume : float = 0.5

# --- screen --- #
@export var resolution : Vector2i = Vector2i(1280, 720)
@export var full_screen : bool = false
@export var windowed : bool = false
@export var brightness : float = 0.5

# --- game --- #
@export var score : int
@export var hi_score : int = 0

# --- level --- #
@export var level_unlocked : int = 1

# --- upgrade --- #
@export var damage_upgrade : int = 0
@export var fire_rate_upgrade : int = 0
@export var speed : int = 0

# --- select character--- #
@export var selecter_character_id : int = 0
