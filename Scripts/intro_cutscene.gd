extends Control

@onready var fade_overlay: ColorRect = $FadeOverlay
@onready var loading_spinner: Control = $LoadingSpinner
@onready var loading_label: Label = $LoadingLabel

@export_file("*.tscn") var next_level_path: String = "res://Scenes/main_game.tscn"
@export var spin_speed: float = 5.0

var _loading_in_progress: bool = false
var _is_loaded: bool = false
var _dot_step: int = 0

func _ready() -> void:
	fade_overlay.modulate.a = 1.0
	var intro_fade = create_tween()
	intro_fade.tween_property(fade_overlay, "modulate:a", 0.0, 1.5)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT)
	
	var err = ResourceLoader.load_threaded_request(next_level_path)
	if err != OK:
		push_error("Failed to request threaded load! Error code: ", err)
	
	_loading_in_progress = true
	_animate_loading_label()

func _process(delta: float) -> void:
	if loading_spinner:
		loading_spinner.rotation += spin_speed * delta

	if _loading_in_progress and not _is_loaded:
		var status = ResourceLoader.load_threaded_get_status(next_level_path)
		
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			_is_loaded = true
			_loading_in_progress = false
			loading_label.modulate.a = 1.0
			loading_label.text = "Done!"
			
			var finish_timer = get_tree().create_timer(0.6)
			await finish_timer.timeout
			finish_cutscene()
			
		elif status == ResourceLoader.THREAD_LOAD_FAILED:
			push_error("Failed to load scene: " + next_level_path)
			_loading_in_progress = false

func _animate_loading_label() -> void:
	if not _loading_in_progress or _is_loaded:
		return
		
	var texts = ["Loading", "Loading.", "Loading..", "Loading..."]
	loading_label.text = texts[_dot_step]
	_dot_step = (_dot_step + 1) % texts.size()
	
	loading_label.modulate.a = 0.0
	var t = create_tween()
	t.tween_property(loading_label, "modulate:a", 1.0, 0.3)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
	t.tween_interval(0.3)
	t.tween_property(loading_label, "modulate:a", 0.0, 0.3)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN)
	t.tween_callback(_animate_loading_label)

func finish_cutscene() -> void:
	var exit_tween = create_tween()
	exit_tween.tween_property(fade_overlay, "modulate:a", 1.0, 1.0)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_IN)
		
	await exit_tween.finished
	
	var loaded_scene = ResourceLoader.load_threaded_get(next_level_path) as PackedScene
	if loaded_scene:
		get_tree().change_scene_to_packed(loaded_scene)
	else:
		get_tree().change_scene_to_file(next_level_path)
