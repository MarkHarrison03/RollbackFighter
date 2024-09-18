extends CharacterBody2D

@export var speed = 100
@export var gravity = 200

func _physics_process(delta):
	velocity.y += gravity * delta
	horizontal_movement()
	move_and_slide()
	player_animations()

func horizontal_movement():
	
	var horizontal_input = Input.get_action_strength("right") - Input.get_action_strength("left")
	velocity.x = horizontal_input * speed
