extends CharacterBody2D 

@export var speed = 400
@export var gravity = 1100
@export var jump_force = -900
@onready var samurai : AnimationPlayer = $AnimationPlayer
@onready var axis = Vector2.ZERO
@onready var crouching = false
@onready var is_crouch_starting = false

func get_input_axis():
	if is_on_floor():
		axis.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
		axis.y = int(Input.is_action_pressed("crouch")) - int(Input.is_action_pressed("jump"))

	return axis.normalized()
	
func _ready():
	samurai.active = true
	
func _physics_process(delta):
	print(samurai.current_animation)
	axis = get_input_axis()
	velocity.y += gravity * delta
	horizontal_movement()
	move_and_slide()

	
func horizontal_movement():

	var horizontal_input = Input.get_action_strength("right") - Input.get_action_strength("left")
	if is_on_floor() and !crouching:
		velocity.x = horizontal_input * speed

func _process(delta):

	if axis.x == 0 and axis.y == 0 and is_on_floor():
		play_anim("Idle")		
	if crouching and is_on_floor() and !is_crouch_starting:
		play_anim("crouch")
	if axis.x == -1 and is_on_floor():
		play_anim("backrun")
	elif axis.x == 1 and is_on_floor():
		play_anim("Run")


func _input(event):
	if event.is_action_pressed("crouch") and is_on_floor():
		scale.x += 0.1
		scale.y += 0.1
		axis.x = 0
		velocity.x = 0
		crouching = true
		is_crouch_starting = true
		play_anim("crouchStart")
	if event.is_action_released("crouch"):
		scale.x -= 0.1
		scale.y -= 0.1


		crouching = false
	if event.is_action_pressed("jump") and is_on_floor():
		play_anim("jump")
		if samurai.current_animation != "jump":
			play_anim("jump")
		velocity.y = jump_force		

func play_anim(anim_name : String):
	if samurai.current_animation != anim_name:
		samurai.play(anim_name)


func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "crouchStart":
		is_crouch_starting = false
		play_anim("crouch")
