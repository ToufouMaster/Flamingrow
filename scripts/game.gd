class_name Game
extends Node


signal practice_finished()
signal game_finished()
signal restarted(game_data: GameData)
signal goal_reached()
signal level_reached(level: int)

@export var levels: Array[PackedScene]
@export var player_scene: PackedScene
@export var radial_fade_scene: PackedScene
@export var player_nodes_scene: PackedScene
@export var evening_color_tint: Color
@export var evening_color_sky: Color

@export var coin_score: int = 100
@export var bigmush_score: int = 1000
@export var smallmush_score: int = 1000

static var day_color: Color = Color("4bb8e3")
static var night_color_tint: Color = Color(0.5, 0.5, 0.5)
static var night_color_sky: Color = Color("080808")

var _level_node: Node = null
var _level_info: LevelInfo
var _game_data: GameData
var _score: int # Score for this level only; the total score is in the GameData
var _game_over: bool = false
var _end_of_level: bool = false
var _fade_out_playing: bool = false

@onready var speedrun_timer := %SpeedrunTimer as SpeedrunTimer


static func get_player() -> Player:
	return Engine.get_main_loop().get_first_node_in_group("Player")


func _ready() -> void:
	if not _game_data:
		_game_data = GameData.new()
	
	_update_score_label()
	_load_level()
	
	if _game_data.time_ms == 0:
		_play_fade_in()
	else:
		_play_respawn_fade_in()
		_start_game()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("quick_restart") and not _game_over:
		_restart()
	
	if Input.is_action_just_pressed("action") and _game_over and not _fade_out_playing:
		_play_fade_out()
	
	if Input.is_action_just_pressed("debug_quit"):
		practice_finished.emit()


func _restart() -> void:
	if is_queued_for_deletion():
		return
	_game_data.time_ms = speedrun_timer.timer.current_time_ms()
	get_parent().remove_child(self)
	queue_free()
	restarted.emit(_game_data)


func _play_next_level() -> void:
	level_reached.emit(_game_data.level)
	_game_data.time_ms = 0
	speedrun_timer.reset()
	_game_over = false
	
	_load_level()
	_play_fade_in()


func _load_level() -> void:
	if _level_node:
		remove_child(_level_node)
		_level_node.queue_free()
	
	_level_node = levels[_game_data.level - 1].instantiate()
	
	if _level_node.get_node_or_null("Evening"):
		var modulate := CanvasModulate.new()
		modulate.color = evening_color_tint
		_level_node.get_node("WorldLayer").add_child(modulate)
		
		RenderingServer.set_default_clear_color(evening_color_sky)
	elif _level_node.get_node_or_null("Night"):
		var modulate := CanvasModulate.new()
		modulate.color = Game.night_color_tint
		_level_node.get_node("WorldLayer").add_child(modulate)
		
		RenderingServer.set_default_clear_color(Game.night_color_sky)
	else:
		RenderingServer.set_default_clear_color(Game.day_color)
	
	# Get the level info
	_level_info = null
	for node in _level_node.get_children():
		if node is LevelInfo:
			_level_info = node
			break
	if not _level_info:
		print_debug("WARNING: level does not have a level info node!")
	
	# Respawn the player at the level's spawn point
	var player: Player = Game.get_player()
	if player:
		player.get_parent().remove_child(player)
		player.queue_free()
	
	player = player_scene.instantiate() as Player
	player.position = _level_node.get_node("WorldLayer/Spawn").position
	player.died.connect(_on_player_died)
	
	var player_nodes: Node = player_nodes_scene.instantiate()
	player_nodes.add_child(player)
	
	_level_node.get_node("WorldLayer").add_child(player_nodes)
	add_child(_level_node)
	player.get_node("Camera2D").make_current()
	
	# Connect the signals for collectibles being collected
	for node in _level_node.get_node("WorldLayer").get_children():
		if node is LevelGoal:
			(node as LevelGoal).player_reached_goal.connect(_on_player_reached_goal)
	for node in _level_node.get_node("ItemLayer").get_children():
		if node is Collectible:
			(node as Collectible).collected.connect(_on_collectible_collected)


func _play_fade_in() -> void:
	var animation := radial_fade_scene.instantiate() as RadialFadeAnimation
	$UILayer.add_child(animation)
	animation.time_ms = 400
	animation.distance = 200
	animation.delete_when_done = false
	animation.set_object_to_follow(Game.get_player())
	animation.play(false)
	animation.animation_finished.connect(_on_fade_in_finished)


func _on_fade_in_finished(animation: RadialFadeAnimation) -> void:
	var timer := Timer.new()
	timer.wait_time = 0.3
	add_child(timer)
	timer.start()
	await timer.timeout
	remove_child(timer)
	
	_start_game()
	
	# Play a 2nd fade in
	animation.time_ms = 800
	animation.distance = 2000
	animation.base_distance = 190
	animation.delete_when_done = true
	animation.animation_finished.disconnect(_on_fade_in_finished)
	animation.play(false)


func _play_respawn_fade_in() -> void:
	var animation := radial_fade_scene.instantiate() as RadialFadeAnimation
	$UILayer.add_child(animation)
	animation.time_ms = 950
	animation.distance = 1500
	animation.set_object_to_follow(Game.get_player())
	animation.play(false)


func _play_fade_out() -> void:
	_fade_out_playing = true
	var animation := radial_fade_scene.instantiate() as RadialFadeAnimation
	$UILayer.add_child(animation)
	animation.time_ms = 1500
	animation.distance = 1500
	animation.set_object_to_follow(Game.get_player())
	animation.play(true)
	animation.animation_finished.connect(_on_fade_out_finished)


func _on_fade_out_finished(_animation: RadialFadeAnimation) -> void:
	_fade_out_playing = false
	
	if _end_of_level:
		_end_of_level = false
		call_deferred("_play_next_level")
		return
	
	if _game_data.is_practice:
		practice_finished.emit()
	else:
		game_finished.emit()


func _play_death_fade_out() -> void:
	_fade_out_playing = true
	var animation := radial_fade_scene.instantiate() as RadialFadeAnimation
	$UILayer.add_child(animation)
	animation.time_ms = 800
	animation.distance = 1500
	animation.set_object_to_follow(Game.get_player())
	animation.play(true)
	animation.delete_when_done = false
	animation.animation_finished.connect(_on_death_fade_out_finished)


func _on_death_fade_out_finished(animation: RadialFadeAnimation) -> void:
	var timer := Timer.new()
	timer.wait_time = 1.0
	add_child(timer)
	timer.start()
	await timer.timeout
	remove_child(timer)
	
	animation.queue_free()
	_restart()


func _on_player_died() -> void:
	speedrun_timer.pause()
	_play_death_fade_out()


func _start_game() -> void:
	Game.get_player().locked_controls = false
	speedrun_timer.play(_game_data.time_ms)


func load_game_data(game_data: GameData) -> void:
	_game_data = game_data


func practice_level(level: int) -> void:
	_game_data = GameData.new()
	_game_data.level = level
	_game_data.is_practice = true


func _gain_score(score_to_gain: int) -> void:
	_score += score_to_gain
	_update_score_label()


func _update_score_label() -> void:
	(%ScoreLabel as Label).text = "Score: " + str(_score + _game_data.run_score)


func _on_collectible_collected(collectible_type: int) -> void:
	match collectible_type:
		1:
			($Coin as AudioStreamPlayer).play()
			_gain_score(coin_score)
		2:
			print_debug("You're using the now unused item, oops!")
		3:
			($Mushroom as AudioStreamPlayer).play()
			Game.get_player().grow()
			_gain_score(bigmush_score)
		4:
			($Shrimp as AudioStreamPlayer).play()
			Game.get_player().shrink()
			_gain_score(smallmush_score)


func _on_player_reached_goal() -> void:
	($Goal as AudioStreamPlayer).play()
	goal_reached.emit()
	speedrun_timer.pause()
	Game.get_player().locked_controls = true
	
	# Give score at end of level
	if _level_info:
		var time_ms: int = speedrun_timer.timer.current_time_ms()
		for i in _level_info.clear_times_ms.size():
			if time_ms <= _level_info.clear_times_ms[i]:
				_gain_score(_level_info.points_given[i])
				break
	_game_data.run_score += _score
	_score = 0
	
	if _game_data.is_practice:
		_game_over = true
		return
	
	_game_data.level += 1
	if (_game_data.level - 1) >= levels.size():
		# Finished all the levels!
		_game_over = true
		return
		
		# Let's reset to level 1 just in case to prevent crash
		#_current_level = 1
	
	_end_of_level = true
	_game_over = true
