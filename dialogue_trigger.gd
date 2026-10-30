extends Area2D

@export var lines_to_say: Array[String] = [
	"Hey! Check this out!",
	"Be careful around here."
]

@export var trigger_once: bool = true
var has_triggered: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not has_triggered:
		if trigger_once:
			has_triggered = true
			
		var bat_guide = get_tree().get_first_node_in_group("guide")
		if bat_guide:
			bat_guide.speak_sequence(lines_to_say)
