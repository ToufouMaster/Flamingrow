class_name LevelSelectAnimation
extends Node


@export var level_select: Control

var _length1: int = 20
var _length2: int = 8
var _length_wiggle: int = 12
var _wiggle_speed: float = 4.0

var _playing: bool = false
var _frame: int = 0

var _already_open: bool = false
var _playing_wiggle: bool = false


func play_open() -> void:
	if _playing:
		return
	
	if _already_open:
		_playing_wiggle = true
		_frame = 0
		return
	
	_playing = true
	_frame = 0
	
	level_select.anchor_right = level_select.anchor_left
	level_select.show()


func _process(_delta: float) -> void:
	if not _playing:
		if _playing_wiggle:
			_play_wiggle()
		return
	
	if _frame <= _length1:
		level_select.anchor_right = level_select.anchor_left + (0.45 * (_frame / float(_length1)))
	
	if _frame > _length1:
		level_select.anchor_right = 0.95 + 0.02 * sin(_wiggle_speed * _frame / (2.0 * PI))
	
	if _frame >= _length1 + _length2:
		_playing = false
		level_select.anchor_right = 0.95
		_already_open = true
		return
	
	_frame += 1


func _play_wiggle() -> void:
	level_select.anchor_right = 0.95 + 0.02 * sin(_wiggle_speed * _frame / (2.0 * PI))
	
	if _frame >= _length_wiggle:
		_playing_wiggle = false
		level_select.anchor_right = 0.95
		return
	
	_frame += 1
