extends Area2D

signal collected

@export var fall_speed: float = 160.0

const HALF_SIZE: float = 8.0

func _physics_process(delta: float) -> void:
	position.y += fall_speed * delta
	# Poll only during active play: the paddle may overlap an object while waiting.
	for body in get_overlapping_bodies():
		if body.is_in_group("paddle"):
			queue_free()
			collected.emit()
			return

	var object_top: float = get_global_transform_with_canvas().origin.y - HALF_SIZE
	if object_top > get_viewport_rect().end.y:
		queue_free()
