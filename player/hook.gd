extends Node2D

func update_lines(radius):
	# Ugly hack to rotate Neck and Head correctly with inversed rotation
	var _rotation = $Sprite2D.rotation
	var offset = -$Sprite2D.offset/2
	if $Sprite2D.flip_v:
		offset.y -= offset.y
		offset.x -= offset.x*2
		_rotation -= deg_to_rad(-135)
	offset = offset.rotated(_rotation).rotated(deg_to_rad(-135)) #* _scale
	
	# Draw line
	$BorderLine2D.set_point_position(0, offset)
	$Line2D.set_point_position(0, offset)
	$BorderLine2D.set_point_position(1, radius * 1/scale)
	$Line2D.set_point_position(1, radius * 1/scale)
	#$Target.hide()

func get_hook_pos(ray: RayCast2D, _mouse_position: Vector2):
	var collider = ray.get_collider()
	if collider:
		if collider is Area2D && collider.collision_layer == 16:
			if collider.global_position.distance_to(ray.global_position) <= ray.target_position.y:
				return collider.global_position
		else:
			return ray.get_collision_point()

func set_hook_pos(ray: RayCast2D, hook_position):
	var collider = ray.get_collider()
	var angle = ray.get_collision_normal().angle()
	if collider is Area2D && collider.collision_layer == 16:
		angle = (ray.global_position - collider.global_position).angle()
	$Sprite2D.rotation = angle-PI
	$Sprite2D.flip_v = angle <= 0
	$Sprite2D.offset = Vector2(-12, 10)
	if $Sprite2D.flip_v:
		$Sprite2D.offset.y = -$Sprite2D.offset.y
	
	#$Sprite2D.flip_v = $Sprite2D.rotation_degrees > 180
	self.global_position = hook_position

func update(ray: RayCast2D, mouse_pos: Vector2):
	var pos = get_hook_pos(ray, mouse_pos)
	var target = get_parent().get_node("Target")
	target.play("Active")
	target.scale = Vector2.ONE*3
	if pos == null:
		target.play("Inactive")
		target.scale = Vector2.ONE*2
		var max_range = ray.global_position + ray.target_position.rotated(ray.rotation)
		pos = clamp(mouse_pos, -max_range, max_range)
		if max_range.x < 0:
			pos = clamp(mouse_pos, max_range, -max_range)
	target.global_position = pos
