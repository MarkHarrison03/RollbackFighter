extends Node


var last_synced_frame := 0
const MAX_ALLOWED_DELTA := 12
var gamestate_buffer: Array = []
const MAX_ROLLBACK_FRAMES = 12

var sync_buffer
var sync_locked := false
var game : Node = null

var samurai := false
var knight := false
var opponent : CharacterBody2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print("game, " , sync_buffer)

	pass
func assign_opponent():
	if multiplayer.get_unique_id() == 1:
		knight = true
		opponent = get_node("/root/IceCastle/Knight")
	else:
		opponent = get_node("/root/IceCastle/Samurai")


func set_sync_frame(frame: int): 
	if sync_locked:
		return

	var min_frame = InputManager.get_current_frame() - MAX_ROLLBACK_FRAMES
	if frame < min_frame:
		return

	last_synced_frame = frame - 1
	sync_locked = true
	grab_synced_state()
	
func grab_synced_state():
	for state in gamestate_buffer:
		if state["frame"] == last_synced_frame:
			sync_buffer = state
			#print("entire buffer", gamestate_buffer)
			#print("state to be synced", state)
			return
func add_gamestate_buffer(state : PackedByteArray):
	var buffer := StreamPeerBuffer.new()
	buffer.put_32(InputManager.get_current_frame())
	buffer.put_data(state)
	var packed := buffer.get_data_array()
#	print("current IM frame: " , InputManager.get_current_frame())
	buffer.seek(0)  
	var state_frame = buffer.get_32()
	#print("current state frame: ", state_frame)
	#print(packed)
	gamestate_buffer.append({
		"frame": InputManager.get_current_frame(),
		"data": state  
	})
	
	if gamestate_buffer.size() > MAX_ROLLBACK_FRAMES:
		gamestate_buffer.pop_front()
	
func rollback():
	if sync_buffer == null:
		print("no sync")
		return	
		
	if opponent == null:
		assign_opponent()
	
	var buffer := StreamPeerBuffer.new()
	buffer.put_data(sync_buffer["data"])
	buffer.seek(4)
	var serializer := Serializer.new()
	serializer.deserialize(buffer.get_data_array())
	
	var cur_frame = InputManager.get_current_frame()

	var predicted_keys = InputReplicator.predicted_input_by_frame.keys()
	var real_keys = InputReplicator.real_input_by_frame.keys()

	var overlap_frames := []

	for key in predicted_keys:
		if real_keys.has(key):
			overlap_frames.append(key)

	print("Overlap frames: ", overlap_frames)
	for f in range(overlap_frames[0], overlap_frames[overlap_frames.size() - 1]):
		var remote_input = InputReplicator.real_input_by_frame.get(f)
		
		if remote_input == null:
			remote_input = InputReplicator.predicted_input_by_frame.get(f)
		opponent.movement_remote(remote_input)	
