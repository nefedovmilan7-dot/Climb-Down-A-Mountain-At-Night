extends Control

@onready var master_slider: HSlider = $VBoxContainer/HBoxContainer/MasterSlider
@onready var music_slider: HSlider = $VBoxContainer/HBoxContainer2/MusicSlider
@onready var sfx_slider: HSlider = $VBoxContainer/HBoxContainer3/HSlider
@onready var fullscreen_check: CheckBox = $VBoxContainer/FullScreenCheckBox
@onready var back_button: Button = $VBoxContainer/BackButton

func _ready() -> void:
	var master_idx = AudioServer.get_bus_index("Master")
	if master_idx != -1 and master_slider:
		master_slider.value = db_to_linear(AudioServer.get_bus_volume_db(master_idx))
	
	var music_idx = AudioServer.get_bus_index("Music")
	if music_idx != -1 and music_slider:
		music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(music_idx))
		
	var sfx_idx = AudioServer.get_bus_index("SFX")
	if sfx_idx != -1 and sfx_slider:
		sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_idx))

	if fullscreen_check:
		fullscreen_check.button_pressed = (DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)
		fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	else:
		push_error("FullScreenCheckBox node was not found! Check node path.")

	# Connect button signals
	if master_slider: master_slider.value_changed.connect(_on_master_slider_changed)
	if music_slider: music_slider.value_changed.connect(_on_music_slider_changed)
	if sfx_slider: sfx_slider.value_changed.connect(_on_sfx_slider_changed)
	if back_button: back_button.pressed.connect(_on_back_pressed)

func _on_master_slider_changed(value: float) -> void:
	var bus_idx = AudioServer.get_bus_index("Master")
	if bus_idx != -1:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))

func _on_music_slider_changed(value: float) -> void:
	var bus_idx = AudioServer.get_bus_index("Music")
	if bus_idx != -1:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))

func _on_sfx_slider_changed(value: float) -> void:
	var bus_idx = AudioServer.get_bus_index("SFX")
	if bus_idx != -1:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))

func _on_fullscreen_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
