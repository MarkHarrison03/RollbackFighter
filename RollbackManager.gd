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
	print("gamestateBuffer, " , gamestate_buffer)
	print("abc syncframe, " , sync_buffer)
	print("abc currentframe ", InputManager.current_frame)
	pass

func set_sync_frame(frame: int): 
	if sync_locked:
		return
	last_synced_frame = frame - 1
	sync_locked = true
	print("raaaaagh, " , last_synced_frame, " ", frame)
	grab_synced_state()

func grab_synced_state():
	print( )
	for state in gamestate_buffer:
		print("raaagh" , state)
		if state["frame"] == last_synced_frame:
			sync_buffer = state["data"]
			return
func add_gamestate_buffer(state : PackedByteArray):
	print("abc buffer")
	gamestate_buffer.append({
		"frame": InputManager.get_current_frame(),
		"data": state.duplicate()  #
	})
	
	if gamestate_buffer.size() > MAX_ROLLBACK_FRAMES:
		gamestate_buffer.pop_front()
	
