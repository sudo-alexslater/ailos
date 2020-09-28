extends KinematicBody2D

# base player vars
var BASE_MOVEMENT_WEIGHT = .003
var BASE_MOVEMENT_SPEED = 16*16
var BASE_BOOST_SPEED = 1000 # fast thrust
var BASE_SHIELD_DISTANCE = 32

# movement vars
var speed_multiplier = 2
var input_velocity = Vector2.ZERO
var velocity = Vector2.ZERO
var input_move_vector = Vector2.ZERO
var t_amount = .1
var t_amount_deceleration = .2
var t_amount_boost = 1

# state vars
var boosting = false
var shielding = false

onready var body = $Sprite
onready var shield = $Shield

func _physics_process(_delta):
	handle_input()
	calculate_movement()
	apply_movement()
	update_state()
	
func handle_input():
	# get input and set vector with movement speed
	input_velocity = Vector2.ZERO
	input_velocity.x = -int(Input.is_action_pressed("ui_left")) + int(Input.is_action_pressed("ui_right"))
	input_velocity.y = -int(Input.is_action_pressed("ui_up")) + int(Input.is_action_pressed("ui_down"))
	input_move_vector = input_velocity.normalized() * BASE_MOVEMENT_SPEED

	# flip scale to reflect direction of travel
	if(input_velocity.x != 0): 
		body.scale.x = sign(input_velocity.x)  * abs(body.scale.x)
	
	# if boosting
	if(Input.is_action_just_pressed("ui_click_left")):
		input_move_vector = get_local_mouse_position().normalized() * BASE_BOOST_SPEED
		boosting = true

	if(Input.is_action_pressed("ui_click_right")):
		shield.position = get_local_mouse_position().normalized() * BASE_SHIELD_DISTANCE
		shield.show()
		shielding = true
	
func calculate_movement():
	# interpolate velocity towards desired using move weight
	if(input_move_vector == Vector2.ZERO):
		input_move_vector = velocity.linear_interpolate(input_move_vector, t_amount_deceleration)
	velocity = velocity.linear_interpolate(input_move_vector, t_amount_boost if boosting else t_amount)

	velocity = move_and_slide(velocity)

func update_state():
	boosting = false
	if(Input.is_action_just_released("ui_click_right")):
		shielding = false
		shield.hide()

func apply_movement():
	# with bounce logic
	var mas_vel = move_and_slide(velocity)
	if(get_slide_count()):
		var collision = get_slide_collision(get_slide_count() - 1)
		velocity = velocity.bounce(collision.normal)
	else:
		velocity = mas_vel

# getters
func get_move_weight():
	return BASE_MOVEMENT_WEIGHT
