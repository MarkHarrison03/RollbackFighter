extends Node

@export var player_id: int
@export var samurai: CharacterBody2D
var input_buffer = {}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if multiplayer.get_unique_id() == 1:
		player_id = 1
	else:
		player_id = 2
		
	if  !samurai:
		samurai = get_parent()
	#if player_id == multiplayer.get_unique_id():
		#set_process(true)
	#else:
		#set_process(false)
			#
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	send_inputs.rpc_id(multiplayer.get_peers()[0], get_input_state())
	process_inputs()
	
	
func get_input_state() -> Dictionary:
	return {
		"right" : Input.is_action_pressed("right"),
		"left": Input.is_action_pressed("left"),
		"jump": Input.is_action_pressed("jump"),
		"crouch": Input.is_action_pressed("crouch"),
		"attack": Input.is_action_pressed("attack"),
		
	}
@rpc("any_peer", "call_local")
func send_inputs(input_state: Dictionary):
	
	input_buffer = input_state 
	
func process_inputs():
	#print("LRI ", input_buffer)
	#print(player_id)
	#print(multiplayer.get_unique_id())
	#print(multiplayer.get_peers())
	
	samurai.movement_remote(input_buffer)
		
