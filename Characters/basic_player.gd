extends KinematicBody2D

onready var anim = $AnimationPlayer
onready var anim_tree = $AnimationTree
onready var anim_state = anim_tree.get('parameters/playback')

var BASE_MOVEMENT_SPEED = 200
var MOVEMENT_CAP = 100
var FRICTION = 300
var ACCELERATION = 500

var input_vector = Vector2.ZERO
var input_move_vector = Vector2.ZERO
var velocity = Vector2.ZERO
var direction = 'down'

func _ready():
	pass

func _physics_process(delta):
	input_vector = Vector2.ZERO
	input_vector.x = -int(Input.is_action_pressed("ui_left")) + int(Input.is_action_pressed("ui_right"))
	input_vector.y = -int(Input.is_action_pressed("ui_up")) + int(Input.is_action_pressed("ui_down"))
	input_vector = input_vector.normalized()
	input_move_vector = input_vector.normalized() * BASE_MOVEMENT_SPEED

	if input_vector == Vector2.ZERO:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		anim_state.travel('idle')
	else: 
		velocity = velocity.move_toward(input_move_vector, ACCELERATION * delta)
		velocity = velocity.clamped(MOVEMENT_CAP)
		print(input_vector)
		anim_tree.set('parameters/idle/blend_position', input_vector)
		anim_tree.set('parameters/walk/blend_position', input_vector)
		anim_state.travel('walk')

	velocity = move_and_slide(velocity)
