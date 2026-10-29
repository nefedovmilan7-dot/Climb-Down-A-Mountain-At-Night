extends CharacterBody2D


@export var move_speed: float = 180.0
@export var automatic_descent_speed: float = 100.0

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * move_speed
	velocity.y = automatic_descent_speed + (Input.get_axis("ui_up", "ui_down") * 50.0)
	
	move_and_slide()
