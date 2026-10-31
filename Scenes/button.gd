extends Button

func _ready() -> void:
	# Connect the button's pressed signal
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	# Make sure this matches the exact folder path to your main menu scene file
	var scene_path = "res://scenes/main_menu.tscn"
	
	var error = get_tree().change_scene_to_file(scene_path)
	if error != OK:
		print("Error: Could not load scene at path: ", scene_path)
