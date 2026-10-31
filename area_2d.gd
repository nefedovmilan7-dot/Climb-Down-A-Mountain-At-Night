extends Area2D

# Allows you to pick main_menu.tscn directly from the Inspector
@export_file("*.tscn") var target_scene: String = "res://main_menu.tscn"

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		var error = get_tree().change_scene_to_file(target_scene)
		if error != OK:
			print("Error loading scene: ", target_scene)
