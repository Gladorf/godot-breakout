extends Node2D

const BRICK_SCENE = preload("res://brick.tscn")
const FALLING_OBJECT_SCENE = preload("res://falling_object.tscn")
const POINTS_PER_BRICK: int = 100
const margin_x = 4
const margin_y = 8
const space_x = 8
const space_y = 8

enum State { WAITING, PLAYING, PAUSED, FINISHED }

@onready var bricks_container: Node2D = $Gameplay/BricksContainer
# Future objects and gameplay timers belong under ActivePlay and inherit its process mode.
@onready var active_play: Node2D = $Gameplay/ActivePlay
@onready var falling_objects: Node2D = $Gameplay/ActivePlay/FallingObjects
@onready var paddle = $Gameplay/Paddle
@onready var ball = $Gameplay/ActivePlay/Ball
@onready var state_message: Label = $Overlay/StateMessage
@onready var life_orbs: HBoxContainer = $Overlay/HUD/LifeOrbs
@onready var score_value: Label = $Overlay/HUD/Score/Value
@onready var best_score_value: Label = $Overlay/HUD/BestScore/Value
@onready var end_screen: CenterContainer = $Overlay/EndScreen
@onready var end_message: Label = $Overlay/EndScreen/Panel/Content/Message
@onready var final_score: Label = $Overlay/EndScreen/Panel/Content/FinalScore
@onready var replay_button: Button = $Overlay/EndScreen/Panel/Content/Replay

var state: State = State.WAITING
var state_before_pause: State = State.WAITING
var lives_remaining: int = 3
var score: int = 0

var brick_size: Vector2
var start_position: Vector2
var brick_limit_y: float

func _ready() -> void:
	var brick = BRICK_SCENE.instantiate()
	var collision = brick.get_node("CollisionShape2D") as CollisionShape2D
	var shape = collision.shape as RectangleShape2D

	brick_size = shape.size
	start_position = Vector2(margin_x, margin_y) + brick_size / 2
	brick.free()

	var paddle_half_height: float = paddle.get_node("CollisionShape2D").shape.size.y / 2.0
	brick_limit_y = paddle.global_position.y - paddle_half_height - 3 * (brick_size.y + space_y)
	for wall in [$Gameplay/VerticalWall1, $Gameplay/VerticalWall2]:
		wall.get_node("LimitMark").global_position.y = brick_limit_y
	replay_button.pressed.connect(_on_replay_pressed)

	spawn_row()
	spawn_row()
	spawn_row()
	spawn_row()

	paddle.moved.connect(_on_paddle_moved)
	_wait_for_launch()
	_update_hud()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if state == State.PAUSED:
			state = state_before_pause
			get_tree().paused = false
			_update_message()
		elif state != State.FINISHED:
			state_before_pause = state
			state = State.PAUSED
			get_tree().paused = true
			_update_message()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("launch") and state == State.WAITING:
		_place_ball_on_paddle()
		state = State.PLAYING
		active_play.process_mode = Node.PROCESS_MODE_INHERIT
		ball.launch()
		_update_message()
		get_viewport().set_input_as_handled()

func _physics_process(_delta: float) -> void:
	if state != State.PLAYING:
		return
	_check_end_conditions()
	if state == State.FINISHED:
		return
	var radius: float = ball.get_node("CollisionShape2D").shape.radius
	var ball_top: float = ball.get_global_transform_with_canvas().origin.y - radius
	if ball_top > get_viewport_rect().end.y:
		lives_remaining -= 1
		_update_hud()
		if lives_remaining > 0:
			_wait_for_launch()
		else:
			_finish_game("Game Over")

func _check_end_conditions() -> void:
	var has_bricks := false
	for brick in bricks_container.get_children():
		# queue_free() takes effect at the end of the frame.
		if brick.is_queued_for_deletion():
			continue
		has_bricks = true
		if brick.global_position.y + brick_size.y / 2.0 >= brick_limit_y:
			_finish_game("Game Over")
			return
	if has_bricks:
		return
	for falling_object in falling_objects.get_children():
		if not falling_object.is_queued_for_deletion():
			return
	_finish_game("Level cleared")

func _finish_game(message: String) -> void:
	if state == State.FINISHED:
		return
	state = State.FINISHED
	active_play.process_mode = Node.PROCESS_MODE_DISABLED
	$Gameplay.process_mode = Node.PROCESS_MODE_DISABLED
	_update_message()
	end_message.text = message
	final_score.text = "Score final : %d" % score
	end_screen.show()
	replay_button.grab_focus()

func _on_replay_pressed() -> void:
	get_tree().reload_current_scene()

func _wait_for_launch() -> void:
	state = State.WAITING
	active_play.process_mode = Node.PROCESS_MODE_DISABLED
	ball.prepare_for_launch()
	_place_ball_on_paddle()
	_update_message()

func _on_paddle_moved() -> void:
	if state == State.WAITING:
		_place_ball_on_paddle()

func _place_ball_on_paddle() -> void:
	var paddle_half_height: float = paddle.get_node("CollisionShape2D").shape.size.y / 2.0
	var ball_radius: float = ball.get_node("CollisionShape2D").shape.radius
	ball.global_position = paddle.global_position - Vector2(0, paddle_half_height + ball_radius)

func _update_message() -> void:
	match state:
		State.WAITING:
			state_message.text = "press space bar to start"
		State.PAUSED:
			state_message.text = "Paused — press Esc to resume"
		State.FINISHED:
			state_message.text = ""
		_:
			state_message.text = ""

func _on_brick_destroyed(at_position: Vector2) -> void:
	score += POINTS_PER_BRICK
	SessionScore.best_score = maxi(SessionScore.best_score, score)
	_update_hud()
	var falling_object = FALLING_OBJECT_SCENE.instantiate()
	falling_object.collected.connect(_on_object_collected)
	falling_objects.add_child(falling_object)
	falling_object.global_position = at_position

func _on_object_collected() -> void:
	if state != State.PLAYING:
		return
	ball.accelerate()
	spawn_row()
	_check_end_conditions()

func _update_hud() -> void:
	for i in range(life_orbs.get_child_count()):
		life_orbs.get_child(i).visible = i < lives_remaining
	score_value.text = str(score)
	best_score_value.text = str(SessionScore.best_score)

func spawn_row() -> void:
	for brick in bricks_container.get_children():
		brick.position.y += brick_size.y + space_y

	for i in range(5):
		var brick = BRICK_SCENE.instantiate()
		brick.position = start_position + Vector2(
			i * (brick_size.x + space_x), 0
		)
		brick.destroyed.connect(_on_brick_destroyed)
		bricks_container.add_child(brick)
