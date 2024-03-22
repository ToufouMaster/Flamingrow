class_name LevelGoal
extends Node2D


signal player_reached_goal()


func _on_area_2d_body_entered(_body: Node2D) -> void:
	# The player reached the goal!
	player_reached_goal.emit()
	$AnimatedSprite2D.play("Activate")


func _on_animated_sprite_2d_animation_finished():
	$AnimatedSprite2D.play("Idle")
