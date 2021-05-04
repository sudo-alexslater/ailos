extends KinematicBody2D

# onready refs

onready var anim = $AnimationPlayer
onready var anim_tree = $AnimationTree
onready var anim_state = anim_tree.get('parameters/playback')
onready var network = get_node('/root/Networking')

# base constants

var BASE_MOVEMENT_SPEED = 200
var MOVEMENT_CAP = 100
var FRICTION = 300
var ACCELERATION = 500
var BASE_HEALTH = 100

# state vars

var input_vector = Vector2.ZERO
var input_move_vector = Vector2.ZERO
var velocity = Vector2.ZERO
var direction = 'down'
var health = BASE_HEALTH
var dead = false
var current_collisions = {
	interactables = [],
	attackables = []
}

# network vars

puppet var puppet_position = Vector2()
puppet var puppet_input_vector = Vector2()
puppet var puppet_state = {
	health = BASE_HEALTH,
	dead = false,
	direction = "down"
}

func _ready():
	set_meta("type", 'player')
	# name_tag.set_text(network.get_player_name(name))

func _physics_process(delta):
	if(!get_tree().network_peer || is_network_master()):
		# get input and update network
		handle_input()
		if(get_tree().network_peer):
			set_network_state()
	else: 
		receive_network_state()

	calculate_movement_set_anim(delta)
	set_animations()
	set_collisions()
	apply_movement()

func set_collisions():
	if(get_slide_count()):
		# reset arrays
		current_collisions.interactables = []

		# get collisions
		for n in range(0, get_slide_count() - 1):
			var collision = get_slide_collision(n)
			var collider = collision.get_collider()

			if(collider.has_meta('type') && collider.get_meta('type') == 'interactable'):
				current_collisions.interactables.push_back(collider)

func handle_input():
	input_vector = Vector2.ZERO
	input_vector.x = -int(Input.is_action_pressed("ui_left")) + int(Input.is_action_pressed("ui_right"))
	input_vector.y = -int(Input.is_action_pressed("ui_up")) + int(Input.is_action_pressed("ui_down"))
	input_vector = input_vector.normalized()
	input_move_vector = input_vector.normalized() * BASE_MOVEMENT_SPEED

	if(Input.is_action_just_pressed("ui_click_left")):
		handle_interact()

func handle_interact():
	for n in current_collisions.interactables:
		n.interact()

func calculate_movement_set_anim(delta):
	if input_vector == Vector2.ZERO:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	else: 
		velocity = velocity.move_toward(input_move_vector, ACCELERATION * delta)
		velocity = velocity.clamped(MOVEMENT_CAP)

func set_animations():
	if input_vector == Vector2.ZERO:
		anim_state.travel('idle')
	else: 
		anim_tree.set('parameters/idle/blend_position', input_vector)
		anim_tree.set('parameters/walk/blend_position', input_vector)
		anim_state.travel('walk')

func apply_movement():
	velocity = move_and_slide(velocity)

func receive_network_state():
	input_vector = puppet_input_vector
	position = puppet_position
	health = puppet_state.health
	dead = puppet_state.dead
	direction = puppet_state.direction

func set_network_state():
	rset_unreliable('puppet_position', position)
	rset_unreliable('puppet_input_vector', input_vector)
	rset_unreliable('puppet_state', {health = health, dead = dead, direction = direction})