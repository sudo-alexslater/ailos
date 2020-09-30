extends KinematicBody2D

# base player vars
var BASE_MOVEMENT_WEIGHT = .003
var BASE_MOVEMENT_SPEED = 16*16
var BASE_BOOST_SPEED = 1000 # fast thrust
var BASE_SHIELD_DISTANCE = 32
var BASE_WEAPON_DISTANCE = 20

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

# onready vars
onready var body = $Sprite
onready var shield = $Shield
onready var weapon = $Weapon
onready var local_mouse_pos = get_local_mouse_position()
onready var camera = $PlayerCamera

# network vars
puppet var puppet_position = Vector2()
puppet var puppet_mouse_vector = Vector2()
puppet var puppet_shield_vector = Vector2()

func _physics_process(_delta):
	update_state()
	if(is_network_master()):
		handle_input()
		update_objects()
	else:
		update_network_variables()
	
	calculate_movement()
	apply_movement()
	
func update_network_variables():
	position = puppet_position
	weapon.position = puppet_mouse_vector.normalized() * BASE_WEAPON_DISTANCE
	weapon.rotation = puppet_mouse_vector.angle() + PI/2
	shield.position = puppet_mouse_vector.normalized() * BASE_SHIELD_DISTANCE
	shield.rotation = puppet_mouse_vector.angle() + PI/2

func handle_input():
	# update network position
	rset_unreliable('puppet_position', position)
	rset_unreliable('puppet_mouse_vector', local_mouse_pos)

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
		input_move_vector = local_mouse_pos.normalized() * BASE_BOOST_SPEED
		boosting = true

	if(Input.is_action_pressed("ui_click_right")):
		show_shield()

	if(Input.is_action_just_released("ui_click_right")):
		hide_shield()

func show_shield():
	shield.position = local_mouse_pos.normalized() * BASE_SHIELD_DISTANCE
	shield.rotation = local_mouse_pos.angle() + PI/2 # flip 90 deg
	weapon.hide()
	shield.show()
	shielding = true

func hide_shield():
	shielding = false
	weapon.show()
	shield.hide()

func calculate_movement():
	# interpolate velocity towards desired using move weight
	if(input_move_vector == Vector2.ZERO):
		input_move_vector = velocity.linear_interpolate(input_move_vector, t_amount_deceleration)
	velocity = velocity.linear_interpolate(input_move_vector, t_amount_boost if boosting else t_amount)

	velocity = move_and_slide(velocity)

func update_objects():
	weapon.position = local_mouse_pos.normalized() * BASE_WEAPON_DISTANCE
	weapon.rotation = local_mouse_pos.angle() + PI/2

func update_state():
	local_mouse_pos = get_local_mouse_position()
	boosting = false

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
