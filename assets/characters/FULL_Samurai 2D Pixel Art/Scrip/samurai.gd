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
@onready var health = 100
@onready var canMove = true

@onready var health_bar : ProgressBar
var is_playing_full_anim := false
@onready var hitbox = $KnightHitbox
@onready var hurtbox = $Hurtbox
@onready var sprite = $AnimatedSprite2D
var flipped = false
var remote_is_blocking = false

func get_input_axis():
	if is_on_floor() and not is_attacking:
		axis.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
		axis.y = int(Input.is_action_pressed("crouch")) - int(Input.is_action_pressed("jump"))

	return axis.normalized()
	
func _ready():
	samurai.active = true
	health_bar = get_node("/root/IceCastle/UI/SamuraiHealthbar")

	if multiplayer.get_unique_id() != 1:
		controlling = false
		
	
func _physics_process(delta):
	if health <= 0:
		canMove = false
		handle_death()
		
	if canMove:
		axis = get_input_axis()
		velocity.y += gravity * delta
	if controlling:
		horizontal_movement()
		if not is_playing_full_anim:
			move_and_slide()
		
	

func horizontal_movement():
	if canMove:

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
		var remotePos = input_dictionary.get("pos")
		var right_input = int(input_dictionary.get("right", false))
		var left_input = int(input_dictionary.get("left", false))
		var jump_input = int(input_dictionary.get("jump", false))
		var crouch_input = int(input_dictionary.get("crouch", false))
		var attack_input = int(input_dictionary.get("attack", false))
		if flipped:
				if left_input == 1:
					remote_is_blocking = true
				else:
					remote_is_blocking = false
		else:
				if right_input == 1:
					remote_is_blocking = true
				else:
					remote_is_blocking = false
		if remotePos != samurai.position:
			samurai.position = remotePos
		if canMove:
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
		if not is_playing_full_anim:
			move_and_slide()
		
func jump():
	if samurai.current_animation != "jump":
				play_anim("jump")
	velocity.y = jump_force		

func play_anims():
			if is_playing_full_anim or is_attacking or !canMove:
				return
			
			if axis.x == 0 and axis.y == 0 and is_on_floor() and not crouching and not is_attacking:
				play_anim("Idle")		
			if crouching and is_on_floor() and not is_attacking:
				play_anim("crouch")
			if axis.x == -1 and is_on_floor() and not is_attacking:
				play_anim("backrun")
			elif axis.x == 1 and is_on_floor() and not is_attacking:
				play_anim("Run")
				
				
func _input(event):
	if !controlling or !canMove:
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
		
func take_damage(damage : int):
	if is_playing_full_anim:
		return 
	if flipped:
		if Input.is_action_pressed("right"):
			is_playing_full_anim=true
			await play_full_anim("block")
			is_playing_full_anim = false
			return
	else:
		if Input.is_action_pressed("left"):
			is_playing_full_anim=true
			await play_full_anim("block")
			is_playing_full_anim = false
			return
	is_playing_full_anim = true
	velocity.x += 50
	await play_full_anim("hurt")
	is_playing_full_anim = false
	canMove = true
	health -= damage
	update_health_bar()
	move_and_slide()

func update_health_bar():
	if health_bar:
		health_bar.value = health

func handle_death():
		samurai.play("death")
		await samurai.animation_finished

		get_tree().quit()
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
		
func play_full_anim(anim_name : String):
	if samurai.current_animation != anim_name:
		samurai.play(anim_name)
		await samurai.animation_finished
		
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


#func face_opponent(opponent_position: Vector2):
	#hitbox = $SamuraiHitbox
#
	#var facing_left = opponent_position.x < global_position.x
	#sprite.flip_h = facing_left
	#
	#var hitbox_pos = hitbox.position
	#hitbox_pos.x = abs(hitbox_pos.x) * (-1 if facing_left else 1)
	#hitbox.position = hitbox_pos
#
	#var hurtbox_pos = hurtbox.position
	#hurtbox_pos.x = abs(hurtbox_pos.x) * (-1 if facing_left else 1)
	#hurtbox.position = hurtbox_pos
