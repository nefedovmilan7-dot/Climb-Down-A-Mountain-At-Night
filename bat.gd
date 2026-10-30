extends CharacterBody2D

@export var speed: float = 140.0
@export var stop_distance: float = 35.0
@export var follow_offset: Vector2 = Vector2(40, -30)


@export var float_speed: float = 3.0
@export var float_amplitude: float = 6.0


@export var text_cps: float = 25.0 

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var subtitle_container: PanelContainer = $PanelContainer
@onready var subtitle_label: Label = $PanelContainer/SubtitleLabel

var player: Node2D = null
var float_time: float = 0.0
var active_tween: Tween = null

func _ready() -> void:
	add_to_group("guide")
	animated_sprite.play("fly")
	

	player = get_tree().get_first_node_in_group("player")
	
	show_subtitle("Hey there! I'm Jimmy!")

func _physics_process(delta: float) -> void:
	if not player:
		player = get_tree().get_first_node_in_group("player")
		return

	float_time += delta * float_speed
	var vertical_bob = sin(float_time) * float_amplitude
	

	var target_pos = player.global_position + follow_offset + Vector2(0, vertical_bob)
	var distance = global_position.distance_to(target_pos)

	if distance > stop_distance:
		var direction = global_position.direction_to(target_pos)
		velocity = direction * speed
		

		if direction.x != 0:
			animated_sprite.flip_h = direction.x < 0
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed * delta * 3)

	move_and_slide()

func show_subtitle(text: String, duration: float = 3.0) -> void:
	if active_tween and active_tween.is_running():
		active_tween.kill()

	subtitle_label.text = text
	subtitle_label.visible_ratio = 0.0
	subtitle_container.visible = true

	var type_duration = float(text.length()) / text_cps

	active_tween = create_tween()
	active_tween.tween_property(subtitle_label, "visible_ratio", 1.0, type_duration)

	if duration > 0.0:
		await active_tween.finished
		await get_tree().create_timer(duration).timeout
		if subtitle_label.text == text:
			subtitle_container.visible = false

func speak_sequence(lines: Array[String]) -> void:
	for line in lines:
		await show_subtitle(line, 2.5)
