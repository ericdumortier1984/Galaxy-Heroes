extends Control

# --- onready --- #
@onready var story_text : RichTextLabel = $Story
@onready var skip_text : Label = $Skip
@onready var story_timer : Timer = $Timer
@onready var background_music : AudioStreamPlayer = $AudioStreamPlayer

var speed : int = 6
var is_text_finish : bool = false
var upper_limit_screen : float = 20.0

func _ready() -> void:
	background_music.play()
	story_text.position.y = get_viewport_rect().size.y
	story_timer.start()
	show_skip_intro_label()

func _process(delta: float) -> void:
	if is_text_finish:
		return
	if story_text.position.y <= upper_limit_screen:
		return
	
	story_text.position.y -= speed * delta 

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and skip_text.visible:
		change_scene()

func change_scene() -> void:
	if is_text_finish:
		return
	is_text_finish = true
	get_tree().change_scene_to_file("res://scenes/level/level_1.tscn")

func show_skip_intro_label() -> void:
	await get_tree().create_timer(4.0).timeout
	skip_text.visible = true
	blink_skip_text()

func blink_skip_text() -> void: 
	while skip_text.visible:
		var blink_tween = create_tween()
		blink_tween.tween_property(skip_text, "modulate:a", 0.0, 0.5) 
		blink_tween.tween_property(skip_text, "modulate:a", 1.0, 0.5)
		await blink_tween.finished

func _on_timer_timeout() -> void:
	change_scene()
