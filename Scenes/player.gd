extends CharacterBody2D

const SPEED: float = 180.0
const GRAVITY: float = 900
const JUMP_VELOCITY: float = -400.0 
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		
	# Zpracování skoku (používá "ui_accept" což je standardně Mezerník nebo Enter)
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("ui_left", "ui_right")

	if direction != 0:
		velocity.x = direction * SPEED
		animated_sprite.flip_h = direction < 0
		animated_sprite.play("walk")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		animated_sprite.play("idle")

	move_and_slide()
