extends CharacterBody2D

@export var MAX_SPEED = 300
@export var ACCELERATION = 1500
@export var FRICTION = 1200

@onready var axis = Vector2.ZERO

@onready var animatedSprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var animationTree : AnimationTree = $AnimationTree

var animationLocked = false;

func _ready():
	animationTree.active = true

func _physics_process(delta):
	move(delta)
	
func get_input_axis():
	axis.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	print(axis.x)
	axis.y = int(Input.is_action_pressed("crouch")) - int(Input.is_action_pressed("jump"))
	return axis.normalized()
##function to move character every frame if needed

func move(delta):
	
	axis = get_input_axis()
	
	if axis == Vector2.ZERO:
		apply_friction(FRICTION * delta)
		
	else:
		apply_movement(axis * ACCELERATION * delta)
	move_and_slide()
	update_animation_parameters()
	
func apply_friction(amount):
	if velocity.length() > amount:
		velocity -= velocity.normalized() * amount
	else:
		velocity = Vector2.ZERO
		
func apply_movement(accel):
	velocity += accel
	velocity = velocity.limit_length((MAX_SPEED))


func update_animation_parameters():
	print(animationTree["parameters/conditions/idle"]) 
	print(animationTree["parameters/conditions/is_walking"])
		
	if velocity == Vector2.ZERO:
		print("notmoving")
		animationTree["parameters/conditions/idle"] = true
		animationTree["parameters/conditions/is_walking"] = false
		animationTree["parameters/conditions/is_backwalk"] = false

	else:
		if axis.x == 1:
			animationTree["parameters/conditions/idle"] = false
			animationTree["parameters/conditions/is_backwalk"] = false
			animationTree["parameters/conditions/is_walking"] = true
		elif axis.x == -1:
			animationTree["parameters/conditions/idle"] = false
			animationTree["parameters/conditions/is_walking"] = false
			animationTree["parameters/conditions/is_backwalk"] = true
	
