extends StaticBody2D

signal destroyed

func destroy() -> void:
	# A queued brick still exists until the end of the frame: count it only once.
	if is_queued_for_deletion():
		return
	queue_free()
	destroyed.emit()
