extends Node


var last_synced_frame := 0
const MAX_ALLOWED_DELTA := 12
var gamestate_buffer: Array = []
const MAX_ROLLBACK_FRAMES = 12

var sync_buffer
var sync_locked := false
var game : Node = null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print("game, " , sync_buffer)

	pass

func set_sync_frame(frame: int): 
	if sync_locked:
		return
	last_synced_frame = frame - 1
	sync_locked = true
	#print("raaaaagh, " , last_synced_frame, " ", frame)
	grab_synced_state()

func grab_synced_state():
	for state in gamestate_buffer:
		if state["frame"] == last_synced_frame:
			sync_buffer = state
			print("entire buffer", gamestate_buffer)
			print("state to be synced", state)
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
	
