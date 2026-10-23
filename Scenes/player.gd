extends CharacterBody2D

const SPEED: float = 180.0
const GRAVITY: float = 900


@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		
	var direction := Input.get_axis("ui_left", "ui_right")

	if direction != 0:
		velocity.x = direction * SPEED
		# Flip the sprite depending on which way they are facing
		animated_sprite.flip_h = direction < 0
		animated_sprite.play("walk")
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		animated_sprite.play("idle")

	move_and_slide()
