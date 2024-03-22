@tool
extends Node2D

## The power of the velocity applied to the player
@export var power: float = 100 : set = _set_power
## Change this value to modulate the size of the Wind
@export var size: Vector2 = Vector2(50, 50) : set = _set_size

func _ready():
	_update_wind_effect()

func _set_power(value: float) -> void:
	power = value
	_update_wind_effect()

func _set_size(value: Vector2) -> void:
	size = value
	_update_wind_effect()

func _update_wind_effect():
	$Area2D/CollisionShape2D.shape = RectangleShape2D.new()
	$SubViewport.size = size
	$SubViewport/GPUParticles2D.position = size/2
	$SubViewport/GPUParticles2D.amount = max(size.x, size.y)
	$SubViewport/GPUParticles2D.process_material.initial_velocity_min = power
	$SubViewport/GPUParticles2D.process_material.initial_velocity_max = power
	$SubViewport/GPUParticles2D.process_material.scale_min = 1 + (power/500)
	$SubViewport/GPUParticles2D.process_material.scale_max = 1 + (power/500)
	$SubViewport/GPUParticles2D.process_material.emission_box_extents = Vector3(size.x/2, size.y/2, 0)
	$Area2D/CollisionShape2D.shape.size = size

func _on_area_2d_body_entered(player):
	if self not in player.wind_forces:
		player.wind_forces.append(self)

func _on_area_2d_body_exited(player):
	if self in player.wind_forces:
		player.wind_forces.erase(self)

func get_wind_velocity():
	return Vector2.RIGHT.rotated(rotation) * power
