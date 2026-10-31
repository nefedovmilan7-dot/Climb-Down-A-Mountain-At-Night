class_name Coin
extends Area2D

# Shared count across all coins
static var total_coins: int = 0

func _ready() -> void:
	# Automatically connect the body entered signal
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Make sure your player node is added to the "Player" group in the inspector
	if body.is_in_group("Player"):
		total_coins += 1
		queue_free() # Deletes the coin upon pickup
