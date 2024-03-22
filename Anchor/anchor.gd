@tool
extends Node2D

## Increase this value to create a larger magnetized Anchor
@export var radius: float = 50.0 : set = _set_radius


func _ready():
	$AnimationPlayer.play("anchor_magnet")
	update()

func _set_radius(value: float) -> void:
	radius = value
	update()

func update():
	$Area2D/CollisionShape2D.shape = CircleShape2D.new()
	$Area2D/CollisionShape2D.shape.radius = radius
	$ShaderSprite.texture = GradientTexture2D.new()
	$ShaderSprite.texture.gradient = Gradient.new()
	$ShaderSprite.texture.gradient.offsets = [1]
	$ShaderSprite.texture.gradient.colors = [Color.WHITE]
	$ShaderSprite.texture.width = radius*2
	$ShaderSprite.texture.height = radius*2
