extends CharacterBody2D 

@export var speed = 400
@export var gravity = 1100
@export var jump_force = -900
@onready var samurai : AnimationPlayer = $AnimationPlayer
@onready var axis = Vector2.ZERO
@onready var crouching = false
@onready var is_crouch_starting = false
@onready var is_attacking = false


func get_input_axis():
	if is_on_floor() and not is_attacking:
		axis.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
		axis.y = int(Input.is_action_pressed("crouch")) - int(Input.is_action_pressed("jump"))

	return axis.normalized()
	
func _ready():
	samurai.active = true
	
func _physics_process(delta):
	print("attacking? ", is_attacking)
	print("Velocity x? " , velocity.x)
	print("disabled ", $Hitbox/CollisionShape2D.disabled)
	if not is_attacking:
		print(samurai.current_animation)
		axis = get_input_axis()
		velocity.y += gravity * delta
	horizontal_movement()
	move_and_slide()

	
func horizontal_movement():

	var horizontal_input = Input.get_action_strength("right") - Input.get_action_strength("left")
	
	if is_attacking:
		print("slowing.......")
		velocity.x = move_toward(velocity.x, 0, speed * 4 * get_physics_process_delta_time())
	elif is_on_floor() and !crouching:
		velocity.x = horizontal_input * speed

func _process(delta):
	if axis.x == 0 and axis.y == 0 and is_on_floor() and samurai.current_animation != "attack":
		print("CHANGING TO DILE")
		play_anim("Idle")		
	if crouching and is_on_floor() and !is_crouch_starting and samurai.current_animation != "attack":
		play_anim("crouch")
	if axis.x == -1 and is_on_floor() and samurai.current_animation != "attack":
		play_anim("backrun")
	elif axis.x == 1 and is_on_floor() and samurai.current_animation != "attack":
		play_anim("Run")


func _input(event):
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
		is_attacking = true
		play_anim("attack")
		print("heyattack")

func play_anim(anim_name : String):
	if samurai.current_animation != anim_name:
		print(samurai.current_animation)
		samurai.play(anim_name)
		if anim_name == "attack":
			await samurai.animation_finished
			is_attacking = false


func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "crouchStart":
		is_crouch_starting = false
		play_anim("crouch")
