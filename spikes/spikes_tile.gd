class_name SpikesTile
extends Node2D


signal player_hit_spikes()


func _on_area_2d_body_entered(body: Node2D) -> void:
	(body as Player).die()
