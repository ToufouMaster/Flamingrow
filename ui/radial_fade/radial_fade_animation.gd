class_name RadialFadeAnimation
extends Control


signal animation_finished(this: RadialFadeAnimation)

## How long the animation takes, in milliseconds
@export var time_ms: int = 1500

## How far away the animation starts/ends from, in pixels
@export var distance: int = 1000

var delete_when_done: bool = true
var base_distance: int = 0
var _playing: bool = false
var _fade_out: bool = false
var _start_time_ms: int = 0
var _object_to_follow: Node2D = null

@onready var shader: ShaderMaterial = $ColorRect.material


func set_center(center: Vector2) -> void:
	shader.set_shader_parameter("center", center)


## Optionally, make this follow a specific object
## In that case, the circle's center will be dealt with automatically
func set_object_to_follow(object: Node2D) -> void:
	_object_to_follow = object
	_update_center()


## fade_out: true -> fadeout; false -> fadein
func play(fade_out: bool) -> void:
	_playing = true
	_fade_out = fade_out
	_start_time_ms = Time.get_ticks_msec()
	_update_center()
	if fade_out:
		shader.set_shader_parameter("time", distance)
	else:
		shader.set_shader_parameter("time", base_distance)


func _process(_delta: float) -> void:
	if not _playing:
		return
	
	var time_spent: int = Time.get_ticks_msec() - _start_time_ms
	if time_spent >= time_ms:
		_playing = false
		if _fade_out:
			shader.set_shader_parameter("time", 0)
		else:
			shader.set_shader_parameter("time", base_distance + distance)
		animation_finished.emit(self)
		if delete_when_done:
			queue_free()
		return
	
	_update_center()
	
	if _fade_out:
		shader.set_shader_parameter("time", distance * (1.0 - (time_spent / float(time_ms))))
	else:
		shader.set_shader_parameter("time", base_distance + distance * ((time_spent / float(time_ms))))


func _update_center() -> void:
	if not _object_to_follow:
		return
	var cam: Camera2D = get_viewport().get_camera_2d()
	shader.set_shader_parameter("center", get_viewport().size / 2.0 + (cam.offset * cam.zoom + cam.global_position - _object_to_follow.global_position) * Vector2(1.0, -1.0) )
