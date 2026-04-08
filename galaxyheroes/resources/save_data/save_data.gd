class_name SaveData
extends Resource

# --- sounds and music --- #
@export var music_volume : float = 0.5
@export var sfx_volume : float = 0.5

# --- screen --- #
@export var resolution : Vector2i = Vector2i(1280, 720)
@export var full_screen : bool = true
@export var windowed : bool = false
@export var brightness : float = 50.0

# --- game --- #
@export var score : int
@export var hi_score : int = 0
@export var lifes : int = 3

# --- level --- #
@export var level_unlocked : int = 1
@export var current_level : int = 1

# --- upgrade --- #
@export var upgrade_life : int = 0
@export var upgrade_speed : int = 0
@export var upgrade_time_shield : int = 0
@export var weapon_selected : int = 0

# --- select character--- #
@export var selecter_character_id : int = 0
