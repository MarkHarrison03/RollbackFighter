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
	if multiplayer.get_peers().size() > 0:
		send_inputs.rpc_id(multiplayer.get_peers()[0], get_input_state())
	process_inputs()
	
func get_input_state() -> Dictionary:
	return {
		"right" : Input.is_action_pressed("right"),
		"left": Input.is_action_pressed("left"),
		"jump": Input.is_action_pressed("jump"),
		"crouch": Input.is_action_pressed("crouch"),
		"attack": Input.is_action_pressed("attack"),
		"frame": InputManager.get_current_frame()
		
	}
@rpc("any_peer", "call_local")
func send_inputs(input_state: Dictionary):
	print("current remote frame " , input_state)
	if not input_state.has("frame"):
		return
	input_buffer = input_state 

	#InputManager.last_input_received_time = Time.get_ticks_msec()
	InputManager.current_prediction = input_state
	InputManager.predict = false
	InputManager.remote_frame = input_state["frame"]
	
	
func process_inputs():
	if not input_buffer.has("frame"):
		return
	#InputManager.check_for_lag(input_buffer)
	samurai.movement_remote(input_buffer)
		
