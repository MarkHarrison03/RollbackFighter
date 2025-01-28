extends CharacterBody2D 

@export var speed = 300
@export var gravity = 1100
@export var jump_force = -700
@onready var knight : AnimationPlayer = $AnimationPlayer
@onready var axis = Vector2.ZERO
@onready var crouching = false
@onready var health = 100
@onready var canMove = true
func get_input_axis():
	if is_on_floor():
		axis.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
		axis.y = int(Input.is_action_pressed("crouch")) - int(Input.is_action_pressed("jump"))

	return axis.normalized()
	
func _ready():
	knight.active = true
	
func _physics_process(delta):
	
	if health <= 0:
		canMove = false
		handle_death()
	print("health, ", health)
	print("current anim" , knight.current_animation)
	print ("can move? ", canMove)
	if canMove:
		axis = get_input_axis()
		velocity.y += gravity * delta
	horizontal_movement()
	move_and_slide()

	
func horizontal_movement():
	if canMove:
		var horizontal_input = Input.get_action_strength("right") - Input.get_action_strength("left")
		if is_on_floor() and !crouching:
			velocity.x = horizontal_input * speed

func _process(delta):
	if canMove:
		if axis.x == 0 and axis.y == 0 and is_on_floor():
			play_anim("Knight/Idle")		
		if crouching and is_on_floor():
			play_anim("Crouch")
		if axis.x == -1 and is_on_floor():
			play_anim("Knight/BackWalk")
		elif axis.x == 1 and is_on_floor():
			play_anim("Knight/Walk")


func _input(event):
	if canMove:
		if event.is_action_pressed("crouch") and is_on_floor():
			print("CROUCHING")
			axis.x = 0
			velocity.x = 0
			crouching = true
		if event.is_action_released("crouch"):
			crouching = false
		if event.is_action_pressed("jump") and is_on_floor():
			play_anim("NeutralJump")
			if knight.current_animation != "NeutralJump":
				play_anim("NeutralJump")
			velocity.y = jump_force		
func take_damage(damage : int):
	canMove = false
	velocity.x += 50
	await play_full_anim("hurt")
	canMove = true
	health -= damage
	
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

	
