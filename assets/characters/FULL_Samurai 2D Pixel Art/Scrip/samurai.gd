extends CharacterBody2D 

@export var speed = 400
@export var gravity = 1100
@export var jump_force = -900
@onready var samurai : AnimationPlayer = $AnimationPlayer
@onready var axis = Vector2.ZERO
@onready var crouching = false
@onready var is_crouch_starting = false
@onready var is_attacking = false
@onready var controlling = true

func get_input_axis():
	if is_on_floor() and not is_attacking:
		axis.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
		axis.y = int(Input.is_action_pressed("crouch")) - int(Input.is_action_pressed("jump"))

	return axis.normalized()
	
func _ready():
	samurai.active = true
	
	if multiplayer.get_unique_id() != 1:
		controlling = false
		
	
func _physics_process(delta):
	print(is_attacking)
	if not is_attacking:
		axis = get_input_axis()
		velocity.y += gravity * delta
	if controlling:
		horizontal_movement()
		move_and_slide()
		
	

func horizontal_movement():

	var horizontal_input = Input.get_action_strength("right") - Input.get_action_strength("left")
	
	if is_attacking:
		velocity.x = move_toward(velocity.x, 0, speed * 4 * get_physics_process_delta_time())
	elif is_on_floor() and !crouching:
		velocity.x = horizontal_input * speed

#func horizontal_movement_remote (right_input : float, left_input: float):
	#var horizontal_input = Input.get_action_strength("right") - Input.get_action_strength("left")
	#
	#if is_attacking:
		#velocity.x = move_toward(velocity.x, 0, speed * 4 * get_physics_process_delta_time())
	#elif is_on_floor() and !crouching:
		#velocity.x = horizontal_input * speed
		#
func _process(delta):

	if !controlling:
		return	
	play_anims()
	#if axis.x == 0 and axis.y == 0 and is_on_floor() and samurai.current_animation != "attack":
		#print("switching idle now -------")
		#play_anim("Idle")		
	#if crouching and is_on_floor() and !is_crouch_starting and samurai.current_animation != "attack":
		#play_anim("crouch")
	#if axis.x == -1 and is_on_floor() and samurai.current_animation != "attack":
		#play_anim("backrun")
	#elif axis.x == 1 and is_on_floor() and samurai.current_animation != "attack":
		#play_anim("Run")


func movement_remote (input_dictionary : Dictionary):
		if controlling:
			return
		var right_input = int(input_dictionary.get("right", false))
		var left_input = int(input_dictionary.get("left", false))
		var jump_input = int(input_dictionary.get("jump", false))
		var crouch_input = int(input_dictionary.get("crouch", false))
		var attack_input = int(input_dictionary.get("attack", false))
	
	#if canMove:
		var horizontal_input = right_input - left_input
		if is_attacking:
			velocity.x = move_toward(velocity.x, 0, speed * 4 * get_physics_process_delta_time())
		elif is_on_floor() and !crouching:

			velocity.x = horizontal_input * speed
			axis.x = right_input - left_input
			axis.y = crouch_input - jump_input

		if is_on_floor() and jump_input == 1:
			jump()
		
		if attack_input == 1 and is_on_floor():
			attack()
		if(crouch_input == 1 and is_on_floor()):
			play_anim("Crouch")
			axis.x = 0
			velocity.x = 0
			crouching = true
		else:	
			crouching = false
			

		play_anims()
		move_and_slide()
		
func jump():
	if samurai.current_animation != "jump":
				play_anim("jump")
	velocity.y = jump_force		

func play_anims():
			if axis.x == 0 and axis.y == 0 and is_on_floor() and not crouching and not is_attacking:
				play_anim("Idle")		
			if crouching and is_on_floor() and not is_attacking:
				play_anim("crouch")
			if axis.x == -1 and is_on_floor() and not is_attacking:
				play_anim("backrun")
			elif axis.x == 1 and is_on_floor() and not is_attacking:
				play_anim("Run")
				
				
func _input(event):
	if !controlling:
		return
		
	if event.is_action_pressed("crouch") and is_on_floor():
		axis.x = 0
		velocity.x = 0
		crouching = true
		is_crouch_starting = true
		play_anim("crouchStart")
	if event.is_action_released("crouch"):
		crouching = false

	if event.is_action_pressed("jump") and is_on_floor():
		play_anim("jump")
		if samurai.current_animation != "jump":
			play_anim("jump")
		velocity.y = jump_force		
	if event.is_action_pressed("attack") and is_on_floor():
		attack()

func attack():
		is_attacking = true
		play_anim("attack")
 
func play_anim(anim_name : String):
	if samurai.current_animation != anim_name:
		samurai.play(anim_name)
		if anim_name == "attack":
			await samurai.animation_finished
			is_attacking = false


func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "crouchStart":
		is_crouch_starting = false
		play_anim("crouch")
