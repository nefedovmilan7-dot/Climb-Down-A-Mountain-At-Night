extends CharacterBody2D

@export_category("Pohyb bro bro bro")
@export var speed: float = 80.0
@export var gravity: float = 1500.0
@export var dash_speed: float = 1000.0  
@export var jump_velocity: float = -400.0  
@export var dash_cooldown_time: float = 2.0

@export_category("mrtev mrkev")
@export var fall_limit_y: float = 1000.0  
@export var max_lava_time: float = 5.0
@export var lava_drain_multiplier: float = 3.0

@export_category("lava")
@export var lava_gravity_multiplier_6: float = 0.267
@export var lava_max_fall_speed_6: float = 83.3
@export var lava_gravity_multiplier_7: float = 0.133
@export var lava_max_fall_speed_7: float = 40.0
@export var lava_jump_velocity: float = -80.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var tile_map_layer: TileMapLayer = get_parent().get_node("TileMapLayer")

var dash_cooldown: float = 0.0
var lava_timer: float = 0.0
var is_dead: bool = false

var red_overlay: ColorRect
var death_label: Label

func _ready() -> void:
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100
	add_child(canvas_layer)
	
	red_overlay = ColorRect.new()
	red_overlay.anchor_right = 1.0
	red_overlay.anchor_bottom = 1.0
	red_overlay.color = Color(1, 0, 0, 0)
	canvas_layer.add_child(red_overlay)
	
	death_label = Label.new()
	death_label.text = "YOU'RE DEAD\nPress SPACE to play again"
	death_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	death_label.add_theme_font_size_override("font_size", 32)
	death_label.visible = false  
	canvas_layer.add_child(death_label)

func _physics_process(delta: float) -> void:
	if is_dead:
		if Input.is_action_just_pressed("ui_accept"):
			get_tree().reload_current_scene()
		return

	if dash_cooldown > 0:
		dash_cooldown -= delta

	var lava_id = get_lava_type()
	var touching_lava = (lava_id != -1)

	if not is_on_floor():
		if touching_lava:
			match lava_id:
				6: 
					velocity.y += (gravity * lava_gravity_multiplier_6) * delta
					velocity.y = min(velocity.y, lava_max_fall_speed_6)
				7: 
					velocity.y += (gravity * lava_gravity_multiplier_7) * delta
					velocity.y = min(velocity.y, lava_max_fall_speed_7)
		else:
			velocity.y += gravity * delta
		
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			velocity.y = jump_velocity
		elif touching_lava:
			velocity.y = lava_jump_velocity

	var direction := Input.get_axis("ui_left", "ui_right")
	
	if Input.is_action_just_pressed("dash") and dash_cooldown <= 0 and not touching_lava:
		dash_cooldown = dash_cooldown_time
		var dash_dir = direction
		if dash_dir == 0:
			dash_dir = -1 if animated_sprite.flip_h else 1
		velocity.x = dash_dir * dash_speed  

	elif abs(velocity.x) > speed:
		velocity.x = move_toward(velocity.x, 0, 50)

	elif direction != 0:
		velocity.x = direction * speed
		animated_sprite.flip_h = direction < 0
		animated_sprite.play("walk")
		
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		animated_sprite.play("idle")

	move_and_slide()
	
	if global_position.y > fall_limit_y:
		trigger_death("Hráč spadl z mapy!")
		return
	
	if touching_lava:
		lava_timer += delta
		red_overlay.color.a = clamp(lava_timer / max_lava_time, 0.0, 1.0)
		
		if lava_timer >= max_lava_time:
			trigger_death("Hráč uhořel v lávě!")
	else:
		if lava_timer > 0:
			lava_timer = max(0.0, lava_timer - delta * lava_drain_multiplier)
			red_overlay.color.a = clamp(lava_timer / max_lava_time, 0.0, 1.0)

func trigger_death(reason: String) -> void:
	is_dead = true
	print(reason)
	red_overlay.color.a = 1.0       
	
	var viewport_size = get_viewport_rect().size
	var random_x = randf_range(50.0, max(50.0, viewport_size.x - 350.0))
	var random_y = randf_range(50.0, max(50.0, viewport_size.y - 120.0))
	death_label.position = Vector2(random_x, random_y)
	
	death_label.visible = true       
	velocity = Vector2.ZERO          

func get_lava_type() -> int:
	var body_points = [
		global_position,                     
		global_position + Vector2(0, 16),  
		global_position + Vector2(-8, 0),  
		global_position + Vector2(8, 0)    
	]
	
	for point in body_points:
		var tile_pos = tile_map_layer.local_to_map(tile_map_layer.to_local(point))
		var source_id = tile_map_layer.get_cell_source_id(tile_pos)
		
		if source_id in [6, 7]:
			return source_id
			
	return -1
