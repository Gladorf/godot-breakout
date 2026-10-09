extends CharacterBody2D

var SPEED = 300

func _ready():
	velocity = Vector2(randf_range(-1,1),-1).normalized() * SPEED

func _physics_process(delta):
	var collision = move_and_collide(velocity*delta)
	if collision:
		velocity = velocity.bounce(collision.get_normal())
		var collider = collision.get_collider()
		if collider.has_method("destroy"):
			collider.destroy()
		if collider.is_class("CharacterBody2D") and collision.get_normal().y < 0.0:
			var position_collision_x = collision.get_position().x
			# global_position to be sure to retrieve position in the same coordinate than the collision
			var position_paddle_x = collider.global_position.x
			
			var paddle_size_x = collider.get_node("CollisionShape2D").shape.size.x
			var direction_x = (position_collision_x - position_paddle_x) / (paddle_size_x / 2)
			
			velocity = Vector2(direction_x, -1).normalized() * SPEED
			
			print(direction_x)
