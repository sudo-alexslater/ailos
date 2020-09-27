extends KinematicBody2D

var BASE_MOVEMENT_WEIGHT = .003;
var BASE_MOVEMENT_SPEED = 16*32
var speed_multiplier = 2
var input_velocity = Vector2.ZERO
var velocity = Vector2.ZERO
var move_vector = Vector2.ZERO
var acceleration_amount = 2000;
var friction_amount = 2000;

onready var body = $Sprite

func _physics_process(_delta):
	handle_input()
	calculate_movement()
	velocity = move_and_slide(velocity)

func handle_input():
	input_velocity = Vector2.ZERO
	input_velocity.x = -int(Input.is_action_pressed("ui_left")) + int(Input.is_action_pressed("ui_right"))
	input_velocity.y = -int(Input.is_action_pressed("ui_up")) + int(Input.is_action_pressed("ui_down"))
	move_vector = input_velocity.normalized() * BASE_MOVEMENT_SPEED

	
	if input_velocity.x != 0: 
		body.scale.x = sign(input_velocity.x)  * abs(body.scale.x)

func calculate_movement():
	velocity = velocity.linear_interpolate(move_vector, get_move_weight())
	if(input_velocity == Vector2.ZERO):
		apply_friction(friction_amount)

func get_move_weight():
	return BASE_MOVEMENT_WEIGHT * (1/10)

func apply_friction(amount):
	velocity.length -= amount;
