extends CharacterBody2D 

@export var speed = 300
@export var gravity = 1100
@export var jump_force = -800
@onready var knight : AnimationPlayer = $AnimationPlayer
@onready var axis = Vector2.ZERO

func get_input_axis():
	if is_on_floor():
		axis.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
		axis.y = int(Input.is_action_pressed("crouch")) - int(Input.is_action_pressed("jump"))

	return axis.normalized()
	
func _ready():
	knight.active = true
	
func _physics_process(delta):

	axis = get_input_axis()
	velocity.y += gravity * delta
	horizontal_movement()
	move_and_slide()
	if is_on_floor() and axis.x == 0:
		play_anim("Knight/Idle")
	
func horizontal_movement():
	
	var horizontal_input = Input.get_action_strength("right") - Input.get_action_strength("left")
	if is_on_floor():
		velocity.x = horizontal_input * speed

func _input(event):
	if axis.y == 1:
		play_anim("Crouch")
	if axis.x == -1:
		play_anim("Knight/BackWalk")
	elif axis.x == 1:
		play_anim("Knight/Walk")
	if event.is_action_pressed("jump") and is_on_floor():
		play_anim("NeutralJump")
		if knight.current_animation != "NeutralJump":
			play_anim("NeutralJump")
		velocity.y = jump_force		

func play_anim(anim_name : String):
	if knight.current_animation != anim_name:
		knight.play(anim_name)
