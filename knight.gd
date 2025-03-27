extends CharacterBody2D 

@export var speed = 300
@export var gravity = 1100
@export var jump_force = -700
@onready var knight : AnimationPlayer = $AnimationPlayer
@onready var axis = Vector2.ZERO
@onready var crouching = false
@onready var health = 100
@onready var controlling = true
@onready var canMove = true
@onready var jumping = false
func get_input_axis():
	if is_on_floor() and multiplayer.get_unique_id() != 1:
		axis.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
		axis.y = int(Input.is_action_pressed("crouch")) - int(Input.is_action_pressed("jump"))

	return axis.normalized()
	
func _ready():
	knight.active = true
	if multiplayer.get_unique_id() == 1:
		controlling = false

func _physics_process(delta):
	if health <= 0:
		canMove = false
		handle_death()
	#if knight.current_animation == 'NeutralJump':
		#jumping = true
	#else:
		#jumping = false
	if canMove:
		axis = get_input_axis()
		velocity.y += gravity * delta
	if controlling:
		print("moving 1 k")
		horizontal_movement()
		move_and_slide()

	
func horizontal_movement():
	if canMove:
		var horizontal_input = Input.get_action_strength("right") - Input.get_action_strength("left")
		if is_on_floor() and !crouching:
			velocity.x = horizontal_input * speed


func movement_remote (input_dictionary : Dictionary):
	print("moving 2 k")

	if controlling:
		return
	print("moving 222 k")

	var right_input = int(input_dictionary.get("right", false))
	var left_input = int(input_dictionary.get("left", false))
	var jump_input = int(input_dictionary.get("jump", false))
	var crouch_input = int(input_dictionary.get("crouch", false))
	var attack_input = int(input_dictionary.get("attack", false))
	axis.x = right_input - left_input
	axis.y = crouch_input - jump_input
	
	if canMove:
		if is_on_floor() and jump_input == 1:
			#jumping = true
			jump()
			
		#else:
			#jumping = false	
		var horizontal_input = right_input - left_input
		
		if is_on_floor() and !crouching:
			
			velocity.x = horizontal_input * speed
				



		if(crouch_input == 1 and is_on_floor()):
			play_anim("Crouch")
	
			axis.x = 0
			velocity.x = 0
			crouching = true
		else:	
			crouching = false
		play_anims()
	move_and_slide()
func _process(delta):
	play_anims()
	
func play_anims():

		if canMove and not jumping:

			if axis.x == 0 and axis.y == 0 and is_on_floor() and not crouching and not jumping:
				play_anim("Knight/Idle")		
			if crouching and is_on_floor() and knight.current_animation != 'NeutralJump':
				play_anim("Crouch")
			if axis.x == -1 and is_on_floor() and knight.current_animation != 'NeutralJump':

				play_anim("Knight/BackWalk")
			elif axis.x == 1 and is_on_floor() and  knight.current_animation != 'NeutralJump':
				play_anim("Knight/Walk")
				

func _input(event):
	if !controlling:
		return
	if canMove:
		if event.is_action_pressed("crouch") and is_on_floor():
			axis.x = 0
			velocity.x = 0
			crouching = true
		if event.is_action_released("crouch"):
			crouching = false
		if event.is_action("jump") and is_on_floor():
		#	jumping = true
			jump()
		#else:
		#	jumping = false
			
func jump():

			if knight.current_animation != "NeutralJump":
				play_anim("NeutralJump")

			velocity.y = jump_force		
		#	jumping = false
func take_damage(damage : int):
	velocity.x += 50
	await play_full_anim("hurt")
	canMove = true
	health -= damage
	move_and_slide()
	
func play_anim(anim_name : String):
	if knight.current_animation != anim_name:
		knight.play(anim_name)
		
func play_full_anim(anim_name : String):
	if knight.current_animation != anim_name:
		knight.play(anim_name)
		await knight.animation_finished

func handle_death():
		knight.play("death")
		await knight.animation_finished
		queue_free()

func serialize_binary() -> PackedByteArray:
	var buffer = PackedByteArray()
	buffer.append(health)
	buffer.append_array(serialize_position())
	return buffer
	
func serialize_position() -> PackedByteArray:
	var pos_buffer = PackedByteArray()
	pos_buffer.append(position.x)
	pos_buffer.append(position.y)
	return pos_buffer
