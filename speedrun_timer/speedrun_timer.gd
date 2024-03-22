@tool
class_name SpeedrunTimer
extends Control


@export var font_size: int = 24 : set = _set_font_size

var _playing: bool = false
var timer: CustomTimer = CustomTimer.new()


func _ready() -> void:
	# Initialize
	_set_font_size(font_size)


func play(time_ms: int = 0) -> void:
	timer.start_timer(time_ms)
	_playing = true


func resume() -> void:
	timer.resume_timer()
	_playing = true


func pause() -> void:
	_update_label()
	timer.pause_timer()
	_playing = false


func reset() -> void:
	timer.reset_timer()
	_update_label()
	_playing = false


func _process(_delta: float) -> void:
	if _playing:
		_update_label()


func _update_label() -> void:
	(%TimerLabel as Label).text = timer.formatted_time()


func _set_font_size(value: int) -> void:
	font_size = value
	var label := %TimerLabel as Label
	if label:
		label.add_theme_font_size_override("font_size", font_size)
