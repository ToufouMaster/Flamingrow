class_name Main
extends Node


@export var main_menu_scene: PackedScene
@export var game_scene: PackedScene
@export var radial_fade_scene: PackedScene

static var save_data := SaveData.new()


func _ready() -> void:
	Main.save_data.load_data()
	_open_main_menu(false, false, false)


## Level 0 -> New game
## Higher than 0 -> Practice run
##
## Optionally, you can load existing game data
func _switch_to_game(level: int, game_data: GameData = null) -> void:
	var game := game_scene.instantiate() as Game
	game.practice_finished.connect(_on_practice_finished)
	game.game_finished.connect(_on_game_finished)
	game.restarted.connect(_on_restarted)
	game.goal_reached.connect(_on_goal_reached)
	game.level_reached.connect(_on_level_reached)
	
	if level > 0:
		game.practice_level(level)
	
	if game_data:
		game.load_game_data(game_data)
	
	add_child(game)


func _fade_out_and_play(level: int = 0) -> void:
	var animation := radial_fade_scene.instantiate() as RadialFadeAnimation
	add_child(animation)
	animation.time_ms = 800
	animation.set_center(get_viewport().size / 2.0)
	animation.play(true)
	
	await animation.animation_finished
	
	remove_child(animation)
	if get_node_or_null("MainMenu"):
		remove_child(get_node("MainMenu"))
	
	($GameBGM as AudioStreamPlayer).play()
	_switch_to_game(level)


func start_practice(level: int) -> void:
	_fade_out_and_play(level)


func start_game() -> void:
	_fade_out_and_play()


func _on_practice_finished() -> void:
	call_deferred("_open_main_menu", true, true, false)


func _on_game_finished() -> void:
	call_deferred("_open_main_menu", true, false, true)


func _on_restarted(game_data: GameData) -> void:
	call_deferred("_switch_to_game", 0, game_data)


func _on_goal_reached() -> void:
	($GameBGM as AudioStreamPlayer).stop()


func _on_level_reached(level: int) -> void:
	($GameBGM as AudioStreamPlayer).play()
	if level > save_data.unlocked_levels:
		Main.save_data.unlocked_levels = level
		Main.save_data.save()


func _open_main_menu(skip_intro: bool, show_level_select: bool, show_thank_you: bool) -> void:
	($GameBGM as AudioStreamPlayer).stop()
	
	if get_node_or_null("Game"):
		remove_child(get_node("Game"))
	
	RenderingServer.set_default_clear_color(Game.day_color)
	
	var main_menu := main_menu_scene.instantiate() as MainMenu
	main_menu.level_button_pressed.connect(start_practice)
	main_menu.play_button_pressed.connect(start_game)
	if skip_intro:
		main_menu.skip_intro()
	if show_level_select:
		main_menu.show_level_select()
	if show_thank_you:
		main_menu.show_thank_you()
	add_child(main_menu)
