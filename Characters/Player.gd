extends KinematicBody2D

# base player vars
var BASE_MOVEMENT_WEIGHT = .003
var BASE_MOVEMENT_SPEED = 16*16
var BASE_BOOST_SPEED = 1000 # fast thrust
var BASE_SHIELD_DISTANCE = 32
var BASE_WEAPON_DISTANCE = 20
var BASE_DAMAGE = 100

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
var health = 100
var dead = false

# onready vars

onready var body = $Sprite
onready var shield = $Shield
onready var weapon = $Weapon
onready var local_mouse_pos = get_local_mouse_position()
onready var camera = $PlayerCamera
onready var name_tag = $NameTag
onready var network = get_node('/root/Networking')

# network vars

puppet var puppet_position = Vector2()
puppet var puppet_mouse_vector = Vector2()
puppet var puppet_shield_vector = Vector2()
puppet var puppet_state = {health = 100, shielding = false, dead = false}

func _ready():
	set_meta("type", 'player')
	name_tag.set_text(network.get_player_name(name))

func _physics_process(_delta):
	update_state()
	if(!get_tree().network_peer || is_network_master()):
		if(!dead):
			handle_input()
			# update network with our state
			set_network_state()
	else:
		recieve_network_state()
		
	update_objects()
	calculate_movement()
	apply_movement()

func killed():
	network.player_killed(int(name))
	
	
remote func take_damage(dealt):
	health -= dealt
	print('hit for ', dealt)

func recieve_network_state():
	health = puppet_state.health
	shielding = puppet_state.shielding
	position = puppet_position
	local_mouse_pos = puppet_mouse_vector
	dead = puppet_state.dead

func set_network_state():
	if(get_tree().network_peer):
		rset_unreliable('puppet_position', position)
		rset_unreliable('puppet_mouse_vector', local_mouse_pos)
		rset('puppet_state', {health = health, shielding = shielding, dead = dead})	
		
func handle_input():
	local_mouse_pos = get_local_mouse_position()
	
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
		shielding = true

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
	if(shielding):
		show_shield()
	else:
		hide_shield()

	weapon.position = local_mouse_pos.normalized() * BASE_WEAPON_DISTANCE
	weapon.rotation = local_mouse_pos.angle() + PI/2
	shield.position = local_mouse_pos.normalized() * BASE_SHIELD_DISTANCE
	shield.rotation = local_mouse_pos.angle() + PI/2

func update_state():
	if(!dead && health <= 0):
		dead = true
		killed()
	boosting = false
	shielding = false

func apply_movement():
	# with bounce logic
	var mas_vel = move_and_slide(velocity)
	if(get_slide_count()):
		for n in range(0,get_slide_count() - 1):
			var collision = get_slide_collision(n)
			var collider = collision.get_collider()

			if(collider.has_meta('type') && collider.get_meta('type') == 'player'):
				print('hit player')
				rpc_id(int(collider.name), 'take_damage', BASE_DAMAGE)

		var collision = get_slide_collision(get_slide_count() - 1)
		velocity = velocity.bounce(collision.normal)
	else:
		velocity = mas_vel

# getters
func get_move_weight():
	return BASE_MOVEMENT_WEIGHT
