extends CharacterBody2D

func _ready():
	velocity = Vector2(randf_range(-100,100),-300)

func _physics_process(delta):
	var collision = move_and_collide(velocity*delta)
	if collision:
		velocity = velocity.bounce(collision.get_normal())
		var collider = collision.get_collider()
		if collider.has_method("destroy"):
			collider.destroy()
