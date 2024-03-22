@tool
class_name Collectible
extends Node2D


signal collected(collectible_type: int)

## 1 is coin; 2 is star; 3 is big mushroom; 4 is small mushroom; (don't use other values)
@export var collectible_type: int = 1

var _time: float = 0.0

@onready var sprite := $Sprite as Node2D


func _process(delta: float) -> void:
	if collectible_type > 2:
		sprite.rotation = 0.25 * sin(_time * delta)
		_time += 2.0


func _on_area_2d_body_entered(_body: Node2D) -> void:
	collected.emit(collectible_type)
	queue_free()
