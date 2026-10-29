extends CharacterBody2D

const SPEED: float = 180.0
const GRAVITY: float = 900
const DASHSPEED: float = 1200.0  
const JUMP_VELOCITY: float = -400.0 
const FALL_LIMIT_Y: float = 1000.0 

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
					velocity.y += (GRAVITY * 0.267) * delta
					velocity.y = min(velocity.y, 83.3)
				7: 
					velocity.y += (GRAVITY * 0.133) * delta
					velocity.y = min(velocity.y, 40.0)
		else:
			velocity.y += GRAVITY * delta
		
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		elif touching_lava:
			velocity.y = -80.0

	var direction := Input.get_axis("ui_left", "ui_right")
	
	if Input.is_action_just_pressed("dash") and dash_cooldown <= 0 and not touching_lava:
		dash_cooldown = 7.0 
		var dash_dir = direction
		if dash_dir == 0:
			dash_dir = -1 if animated_sprite.flip_h else 1
		velocity.x = dash_dir * DASHSPEED 

	elif abs(velocity.x) > SPEED:
		velocity.x = move_toward(velocity.x, 0, 50)

	elif direction != 0:
		velocity.x = direction * SPEED
		animated_sprite.flip_h = direction < 0
		animated_sprite.play("walk")
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		animated_sprite.play("idle")

	move_and_slide()
	
	if global_position.y > FALL_LIMIT_Y:
		trigger_death("Hráč spadl z mapy!")
		return
	
	if touching_lava:
		lava_timer += delta
		red_overlay.color.a = clamp(lava_timer / 5.0, 0.0, 1.0)
		
		if lava_timer >= 5.0:
			trigger_death("Hráč uhořel v lávě!")
	else:
		if lava_timer > 0:
			lava_timer = max(0.0, lava_timer - delta * 3.0)
			red_overlay.color.a = clamp(lava_timer / 5.0, 0.0, 1.0)

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
