@tool
class_name Spikes
extends Node2D


@export var spikes_tile_scene: PackedScene

## Increase this value to create a longer row of spikes
@export var length: int = 1 : set = _set_length


func _ready() -> void:
	_update_spike_tiles()


func _set_length(value: int) -> void:
	length = value
	_update_spike_tiles()


func _update_spike_tiles() -> void:
	var number_existing_tiles: int = get_children().size()
	
	if number_existing_tiles < length:
		for i in range(number_existing_tiles, length):
			var new_tile := spikes_tile_scene.instantiate() as Node2D
			new_tile.position = Vector2(i * 16.0, 0.0)
			add_child(new_tile)
	elif number_existing_tiles > length:
		var children_to_remove: Array[Node] = []
		for i in range(length, number_existing_tiles):
			children_to_remove.append(get_child(i))
		for child in children_to_remove:
			remove_child(child)
