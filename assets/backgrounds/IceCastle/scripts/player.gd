extends Node

@export var player_id: int
@export var knight: CharacterBody2D
var input_buffer = {}
var input_history = {}
const MAX_ROLLBACK_FRAMES = 12

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if multiplayer.get_unique_id() == 1:
		player_id = 1
	else:
		player_id = 2
	if  !knight:
		knight = get_parent()
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
		input_history[frame] = input

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
func send_inputs(inputs: Array):
	#print("aaaaa", inputs)
	for input_state in inputs:
		#if not input_state.has("frame"):
			#return
		var frame = input_state["frame"]
		#print("aaa", input_state)d
		InputReplicator.real_input_by_frame[frame] = input_state
		for key in InputReplicator.real_input_by_frame.keys():
			if key < frame - MAX_ROLLBACK_FRAMES:
				InputReplicator.real_input_by_frame.erase(key)
		#print("bb", InputReplicator.real_input_by_frame)
		InputManager.current_prediction = input_state
		InputManager.predict = false
		InputManager.remote_frame = input_state["frame"]
		if frame > InputReplicator.current_remote_input.get("frame", -1):
			InputReplicator.set_current_remote_input(input_state)
	
func process_inputs():

	var frame = InputManager.get_current_frame()
	var remote_frame = 	InputReplicator.real_input_by_frame.keys().reduce(func(a, b): return max(a, b))

	if remote_frame < frame - MAX_ROLLBACK_FRAMES:
		var prediction = InputReplicator.get_prediction_input(frame)
		knight.movement_remote(prediction)
		InputReplicator.set_last_predicted_input(prediction)
	else:
		var real_input = InputReplicator.real_input_by_frame.get(remote_frame)
		# ✅ use input only if it matches the current frame
		knight.movement_remote(real_input)
		InputReplicator.set_current_remote_input(real_input)
