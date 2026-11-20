extends CharacterBody2D

const INITIAL_SPEED: float = 300.0
const MAX_SPEED: float = INITIAL_SPEED * 2.0
const PICKUP_SPEED_MULTIPLIER: float = 1.05

var SPEED: float = INITIAL_SPEED


func prepare_for_launch() -> void:
	# Keep the acquired speed when reusing the ball after a lost attempt.
	velocity = Vector2.ZERO

func accelerate() -> void:
	SPEED = minf(SPEED * PICKUP_SPEED_MULTIPLIER, MAX_SPEED)
	if not velocity.is_zero_approx():
		velocity = velocity.normalized() * SPEED

func launch() -> void:
	velocity = Vector2(randf_range(-1, 1), -1).normalized() * SPEED

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
