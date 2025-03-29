extends Node

@export var player_id: int
@export var samurai: CharacterBody2D
var input_buffer = {}
var input_history = {}
const MAX_ROLLBACK_FRAMES = 12

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
		var input = get_input_state()
		var frame = input["frame"]
		
		for key in input_history.keys():
			if key < frame - MAX_ROLLBACK_FRAMES:
				input_history.erase(key)
		
		var inputs_to_send := []
		for i in range(frame - (MAX_ROLLBACK_FRAMES - 1), frame + 1):
			if input_history.has(i):
				inputs_to_send.append(input_history[i])
		send_inputs.rpc_id(multiplayer.get_peers()[0], inputs_to_send)
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
func send_inputs(inputs: Dictionary):
	
	for input_state in inputs:
		if not input_state.has("frame"):
			return
		var frame = input_state["frame"]
		InputReplicator.real_input_by_frame[frame] = input_state
		InputManager.current_prediction = input_state
		InputManager.predict = false
		InputManager.remote_frame = input_state["frame"]
		if frame > InputReplicator.current_remote_input.get("frame", -1):
			InputReplicator.set_current_remote_input(input_state)
	#input_buffer = input_state 
	#InputReplicator.set_current_remote_input(input_state)

	#InputManager.last_input_received_time = Time.get_ticks_msec()

	
	
func process_inputs():
	if not input_buffer.has("frame"):
		return
	#InputManager.check_for_lag(input_buffer)
	samurai.movement_remote(input_buffer)
		
