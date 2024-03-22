class_name MainMenu
extends Node


signal level_button_pressed(level: int)
signal play_button_pressed()

@export var level_buttons: Array[TextureButton]

var _thanks: bool = false
var _thanks_timer: int = 0

@onready var level_select_animation := $LevelSelectAnimation as LevelSelectAnimation


func _ready() -> void:
	var number_of_levels: int = level_buttons.size()
	var i = number_of_levels
	while i > Main.save_data.unlocked_levels:
		level_buttons[i - 1].disabled = true
		#level_buttons[i - 1].get_node("Disabled").show()
		i -= 1
	
	$UI/Options/TextureRect/MarginContainer/VBoxContainer/Master/MasterSlider.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
	$UI/Options/TextureRect/MarginContainer/VBoxContainer/Music/MusicSlider.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))
	$UI/Options/TextureRect/MarginContainer/VBoxContainer/SFX/SFXSlider.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Sfx"))


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("action"):
		$UI/Credits.hide()
		
		if _thanks and Time.get_ticks_msec() - _thanks_timer > 1000:
			$UI/Thanks.hide()


func _on_practice_button_pressed() -> void:
	#if $UI/LevelSelect.visible:
	#	$AnimationPlayer.play("CloseLevels")
	#else:
	#	$AnimationPlayer.play("OpenLevels")
	($SFX as AudioStreamPlayer).play()
	level_select_animation.play_open()


func _on_play_button_pressed() -> void:
	($SFX as AudioStreamPlayer).play()
	play_button_pressed.emit()


func skip_intro() -> void:
	($Sprite2D as Sprite2D).frame = 5
	($UI/StartButton as Control).hide()
	($UI as Control).modulate = Color.WHITE


func show_level_select() -> void:
	(%LevelSelect as Control).show()
	($LevelSelectAnimation as LevelSelectAnimation)._already_open = true


func show_thank_you() -> void:
	($UI/Thanks as Control).show()
	_thanks = true
	_thanks_timer = Time.get_ticks_msec()


func _on_level_1_pressed() -> void:
	($SFX as AudioStreamPlayer).play()
	level_button_pressed.emit(1)


func _on_level_2_pressed() -> void:
	($SFX as AudioStreamPlayer).play()
	level_button_pressed.emit(2)


func _on_level_3_pressed() -> void:
	($SFX as AudioStreamPlayer).play()
	level_button_pressed.emit(3)


func _on_level_4_pressed() -> void:
	($SFX as AudioStreamPlayer).play()
	level_button_pressed.emit(4)


func _on_level_5_pressed() -> void:
	($SFX as AudioStreamPlayer).play()
	level_button_pressed.emit(5)


func _on_level_6_pressed() -> void:
	($SFX as AudioStreamPlayer).play()
	level_button_pressed.emit(6)


func _on_level_7_pressed() -> void:
	($SFX as AudioStreamPlayer).play()
	level_button_pressed.emit(7)


func _on_level_8_pressed() -> void:
	($SFX as AudioStreamPlayer).play()
	level_button_pressed.emit(8)


func _on_level_9_pressed() -> void:
	($SFX as AudioStreamPlayer).play()
	level_button_pressed.emit(9)


func _on_level_10_pressed() -> void:
	($SFX as AudioStreamPlayer).play()
	level_button_pressed.emit(10)


func _on_start_button_pressed():
	$AnimationPlayer.play("OpenMenu")


func _on_credits_button_pressed() -> void:
	$UI/Credits.show()


func _on_master_slider_value_changed(value):
	var bus_idx = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_idx, value)
	AudioServer.set_bus_mute(bus_idx, value == -30)


func _on_music_slider_value_changed(value):
	var bus_idx = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(bus_idx, value)
	AudioServer.set_bus_mute(bus_idx, value == -30)


func _on_sfx_slider_value_changed(value):
	var bus_idx = AudioServer.get_bus_index("Sfx")
	AudioServer.set_bus_volume_db(bus_idx, value)
	AudioServer.set_bus_mute(bus_idx, value == -30)


func _on_option_button_pressed():
	($UI/Options as Control).show()


func _on_texture_button_pressed():
	($UI/Options as Control).hide()
