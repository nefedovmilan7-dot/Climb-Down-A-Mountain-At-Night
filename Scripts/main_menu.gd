extends Control

@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var play_button: Button = $VBoxContainer/PlayButton
@onready var settings_button: Button = $VBoxContainer/SettingsButton
@onready var quit_button: Button = $VBoxContainer/QuitButtton

var is_shaking: bool = false
var shake_intensity: float = 0.0
var original_title_position: Vector2

func _ready() -> void:
	title_label.pivot_offset = title_label.size / 2.0
	title_label.scale = Vector2.ZERO
	
	var buttons = [play_button, settings_button, quit_button]
	for btn in buttons:
		btn.pivot_offset = btn.size / 2.0
		btn.modulate.a = 0.0
		btn.scale = Vector2(0.8, 0.8)
	
	play_button.pressed.connect(_on_play_button_pressed)
	settings_button.pressed.connect(_on_settings_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	
	play_shake_intro()

func _process(_delta: float) -> void:
	if is_shaking:
		var random_x = randf_range(-shake_intensity, shake_intensity)
		var random_y = randf_range(-shake_intensity, shake_intensity)
		title_label.position = original_title_position + Vector2(random_x, random_y)

func play_shake_intro() -> void:
	await get_tree().process_frame
	title_label.pivot_offset = title_label.size / 2.0
	original_title_position = title_label.position
	
	var tween = create_tween()
	
	is_shaking = true
	shake_intensity = 1.0
	
	tween.tween_property(title_label, "scale", Vector2(1.2, 1.2), 1.0)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN)
		
	tween.tween_callback(func():
		is_shaking = false
		title_label.position = original_title_position
	)
	
	tween.tween_interval(0.15)
	
	tween.tween_property(title_label, "scale", Vector2(1.0, 1.0), 0.3)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
		
	var buttons = [play_button, settings_button, quit_button]
	for btn in buttons:
		btn.pivot_offset = btn.size / 2.0
		tween.tween_property(btn, "modulate:a", 1.0, 0.25)
		tween.parallel().tween_property(btn, "scale", Vector2(1.0, 1.0), 0.25)\
			.set_trans(Tween.TRANS_BACK)\
			.set_ease(Tween.EASE_OUT)
		tween.tween_interval(0.12)

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://intro_cutscene.tscn")


func _on_settings_button_pressed() -> void:
	get_tree().change_scene_to_file("res://settings_menu.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
