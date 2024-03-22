class_name Player
extends CharacterBody2D


signal died()

const SPEED = 300.0
const HOOK_SPEED = 100.0
const JUMP_VELOCITY = 400.0

@onready var hook_node = get_node("../Hook")

var hooked = false
var hook_pos = null
var current_rope_length = null

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var extra_velocity = Vector2.ZERO
var wind_forces = []

## When true, the player cannot do anything
var locked_controls: bool = true

var _dead: bool = false
var _scale: int


func _process(delta):
	#WIP_update_music_filter(delta)
	update_camera(delta)
	update_ray()

func WIP_update_music_filter(delta):
	var new_volume = float((min(max(abs(velocity.x) - _speed() + 0.5, 0), 1) -1) * 30)
	
	var bus_idx = AudioServer.get_bus_index("Music")
	var old_volume = AudioServer.get_bus_effect(bus_idx, 0).volume_db
	
	var volume_speed_change = delta
	if old_volume > new_volume:
		volume_speed_change /= 5
	
	AudioServer.get_bus_effect(bus_idx, 0).volume_db = lerp(old_volume, new_volume, volume_speed_change)

func update_camera(delta):
	var new_zoom = min(_speed() / (velocity.length() + extra_velocity.length()) * 0.5, 2.0)
	var camera_speed_change = delta
	if $Camera2D.zoom.x > new_zoom:
		camera_speed_change /= 5
	$Camera2D.zoom = Vector2.ONE * max(lerp($Camera2D.zoom.x, new_zoom, camera_speed_change), 1.0)

func update_ray():
	var mouse_position = get_global_mouse_position()
	$HookRay.look_at(mouse_position)
	$HookRay.rotation -= PI/2
	hook_node.update($HookRay, mouse_position)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	
	
	if velocity.x + extra_velocity.x < 0:
		$Sprite.flip_h = true
	if velocity.x + extra_velocity.x > 0:
		$Sprite.flip_h = false
	else:
		$Sprite.flip_h = $Sprite.flip_h 
	
	if is_on_floor():
		if $Sprite.animation == "Fall":
			$Sprite.play("Idle")
		
		if abs(velocity.x + extra_velocity.x) > 1:
			$Sprite.play("Walk")
		else:
			$Sprite.play("Idle")
		
		extra_velocity.x = extra_velocity.x * 0.01
		if Input.is_action_just_pressed("jump") and not locked_controls:
			($Jump as AudioStreamPlayer).play()
			velocity.y = -JUMP_VELOCITY * scale.y
			$Sprite.play("Jump")
	else:
		if $Sprite.animation != "Jump":
			$Sprite.play("Fall")
	
	if is_on_wall():
		extra_velocity.x = lerp(extra_velocity.x, 0.0, delta)
	
	if hooked:
		$Sprite.play("Hook")
		var swing_vel = swing(delta)
		velocity = Vector2.ZERO
		if swing_vel:
			velocity += swing_vel
		if Input.is_action_pressed("secondary_action"):
			var hook_pos_ = hook_node.global_position
			var difference = hook_pos_ - global_position
			var angle = difference.angle()
			if difference.length() > 10:
				var motion = Vector2.RIGHT.rotated(angle)
				var old_vel = velocity
				velocity = motion*_hook_speed()
				move_and_slide()
				velocity = old_vel
		velocity.x += get_horizontal_movespeed()/_hook_speed()
		velocity += get_all_wind_velocity(delta)
		move_and_slide()
		return
	
	velocity.x = 0
	velocity.x = get_horizontal_movespeed()
	
	var wind_velocity = get_all_wind_velocity(delta)
	extra_velocity.y += wind_velocity.y
	if not is_on_floor():
		extra_velocity.x += wind_velocity.x
	
	velocity.x = clamp(velocity.x + extra_velocity.x, -_speed()+extra_velocity.x, _speed()+extra_velocity.x)
	velocity.y += extra_velocity.y
	extra_velocity.y = move_toward(extra_velocity.y, 0, gravity)

	move_and_slide()

func get_horizontal_movespeed():
	var direction = Input.get_axis("move_left", "move_right")
	var vel = 0
	if direction and not locked_controls:
		vel = direction * _speed()
	else:
		velocity.x = move_toward(velocity.x, 0, _speed())
	return vel

func _input(_event):
	if locked_controls:
		return
	
	if Input.is_action_just_pressed("action"):
		hook_pos = hook_node.get_hook_pos($HookRay, get_global_mouse_position())
		if hook_pos == null: return
		($Hook as AudioStreamPlayer).play()
		hooked = true
		hook_node.set_hook_pos($HookRay, hook_pos)
		current_rope_length = global_position.distance_to(hook_pos)
	if Input.is_action_just_released("action"):
		if hooked:
			var extra_swing = swing(1)
			if extra_swing: extra_velocity = extra_swing/2
		hooked = false
		hook_node.hide()
			

func swing(_delta):
	var radius = global_position - hook_pos # points away from center
	
	var radius_offset = Vector2(6, -10)
	if $Sprite.flip_h: radius_offset.x = -6
	hook_node.update_lines(radius+radius_offset)
	hook_node.show()
	
	var vel = velocity
	if velocity.length() < 0.01 or radius.length() < 10: return
	var angle = acos(radius.dot(vel) / (radius.length() * vel.length()))
	var rad_vel = cos(angle) * vel.length()
	vel += radius.normalized() * -rad_vel
	return vel

func die():
	if _dead:
		return
	
	($Death as AudioStreamPlayer).play()
	_dead = true
	died.emit()
	locked_controls = true
	$Sprite.modulate = Color(1.0, 0.5, 0.5)
	hook_node.get_node("Line2D").modulate = Color(1.0, 0.5, 0.5)
	hook_node.get_node("Sprite2D").modulate = Color(1.0, 0.5, 0.5)

func get_all_wind_velocity(delta):
	var value = Vector2.ZERO
	for wind in wind_forces:
		value += wind.get_wind_velocity()*delta
	return value

func _on_sprite_animation_finished():
	if $Sprite.animation == "Jump":
		$Sprite.play("Fall")


func grow() -> void:
	_scale += 1
	_update_scale()


func shrink() -> void:
	_scale -= 1
	_update_scale()


func _update_scale() -> void:
	scale = Vector2.ONE * (1.4 ** _scale)
	hook_node.scale = scale


func _speed() -> float:
	return SPEED * scale.y


func _hook_speed() -> float:
	return HOOK_SPEED * (scale.y ** 0.5)
