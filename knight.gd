extends CharacterBody2D

@export var speed = 100
@export var gravity = 200
@onready var animationTree : AnimationTree = $AnimationTree

func _physics_process(delta):
	velocity.y += gravity * delta
	horizontal_movement()
	move_and_slide()
	update_animation_parameters()
func horizontal_movement():
	
	var horizontal_input = Input.get_action_strength("right") - Input.get_action_strength("left")
	velocity.x = horizontal_input * speed

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
