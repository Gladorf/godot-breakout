extends Node2D

const BRICK_SCENE = preload("res://brick.tscn")
const margin_x = 4
const margin_y = 8
const space_x = 8
const space_y = 8

@onready var bricks_container: Node2D = $BricksContainer

var brick_size: Vector2
var start_position: Vector2

func _ready() -> void:
	var brick = BRICK_SCENE.instantiate()
	var collision = brick.get_node("CollisionShape2D") as CollisionShape2D
	var shape = collision.shape as RectangleShape2D

	brick_size = shape.size
	start_position = Vector2(margin_x, margin_y) + brick_size / 2
	brick.free()

	spawn_row()
	spawn_row()

func spawn_row() -> void:
	for brick in bricks_container.get_children():
		brick.position.y += brick_size.y + space_y

	for i in range(5):
		var brick = BRICK_SCENE.instantiate()
		brick.position = start_position + Vector2(
			i * (brick_size.x + space_x), 0
		)
		bricks_container.add_child(brick)
