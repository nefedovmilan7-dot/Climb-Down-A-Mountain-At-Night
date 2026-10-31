extends Control

@onready var coin_label: Label = $PanelContainer/HBoxContainer/CoinLabel
@onready var coin_sprite: AnimatedSprite2D = $PanelContainer/HBoxContainer/AnimatedSprite2D

func _ready() -> void:
	# Plays the spinning animation if configured
	if coin_sprite and coin_sprite.sprite_frames:
		coin_sprite.play()

func _process(_delta: float) -> void:
	# Updates the counter text to show current coins
	coin_label.text = str(Coin.total_coins)
