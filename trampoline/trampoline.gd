class_name Trampoline
extends Node2D


## How far up the player goes (e.g. 100 is very little, 1000 is a lot)
@export var bounce_strength: float = 500.0


func _on_area_2d_body_entered(body: Node2D) -> void:
	# The player hit the trampoline. Send them flying!
	($SFX as AudioStreamPlayer).play()
	var player_character := body as Player
	player_character.velocity.y = -bounce_strength * player_character.scale.y
	$AnimatedSprite2D.play("jump")


func _on_animated_sprite_2d_animation_finished():
	$AnimatedSprite2D.play("default")
