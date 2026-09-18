extends CharacterBody2D

func _physics_process(_delta):
	var direction = Input.get_axis("move_left", "move_right")
	velocity = Vector2(direction * 300, 0)
	move_and_slide()
