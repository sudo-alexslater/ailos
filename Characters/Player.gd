extends KinematicBody2D

var BASE_MOVEMENT_WEIGHT = .3
var BASE_MOVEMENT_SPEED = 16*8
var speed_multiplier = 2
var input_velocity = Vector2.ZERO
var velocity = Vector2.ZERO
var move_direction = Vector2.ZERO

onready var body = $Sprite

func _physics_process(delta):
	_handle_input()
	_apply_movement()

func _handle_input():
	input_velocity = Vector2.ZERO
	input_velocity.x = -int(Input.is_action_pressed("ui_left")) + int(Input.is_action_pressed("ui_right"))
	input_velocity.y = -int(Input.is_action_pressed("ui_up")) + int(Input.is_action_pressed("ui_down"))
	move_direction = input_velocity.normalized() * BASE_MOVEMENT_SPEED
	
	if input_velocity.x != 0: 
		body.scale.x = sign(input_velocity.x)  * abs(body.scale.x)

func _apply_movement():
	velocity = velocity.linear_interpolate(move_direction, _get_move_weight())
	velocity = move_and_slide(velocity)

func _get_move_weight():
	return 0.3
