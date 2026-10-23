extends Node2D

@export var obstacle_scene: PackedScene
@export var spawn_ahead_distance: float = 1200.0
@export var spawn_spacing: float = 250.0

@onready var player: CharacterBody2D = get_node("../Player")

var next_spawn_y: float = 400.0

func _process(_delta: float) -> void:
	if not player:
		return
		
	while player.global_position.y + spawn_ahead_distance > next_spawn_y:
		spawn_obstacle_row()
		next_spawn_y += spawn_spacing

func spawn_obstacle_row() -> void:
	if not obstacle_scene:
		return
		
	var left_obstacle = obstacle_scene.instantiate() as Node2D
	left_obstacle.global_position = Vector2(randf_range(-260, -90), next_spawn_y)
	add_child(left_obstacle)
	
	var right_obstacle = obstacle_scene.instantiate() as Node2D
	right_obstacle.global_position = Vector2(randf_range(90, 260), next_spawn_y)
	add_child(right_obstacle)
