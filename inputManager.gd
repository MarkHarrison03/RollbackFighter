extends Node

var last_input_frame := 0
var current_frame := 0
var INPUT_TIMEOUT_THRESHOLD := 9
var player_id : int
@export var opponent: CharacterBody2D
var current_prediction : Dictionary
var predict : bool
var game_started := false
func _ready():
	predict = false
	if multiplayer.get_unique_id() == 1:
		player_id = 1
		opponent = get_node_or_null("/root/IceCastle/Knight")
	else:
		player_id = 2
		opponent = get_node_or_null("/root/IceCastle/Samurai")
		
		
	

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if game_started:
		current_frame += 1

func update_time():
	last_input_frame = current_frame

func get_current_frame():
	return current_frame
	
func set_current_frame(frame: int):
	current_frame = frame
	
func flip_predict():
	predict = !predict

func check_for_lag(input_buffer: Dictionary) -> bool:
	if not input_buffer.has("frame"):
		return false
	
	#print("frame diff: ", current_frame - input_buffer["frame"])
	if current_frame - input_buffer["frame"]  > INPUT_TIMEOUT_THRESHOLD: 
		predict_last_input()
		return true
	else:
		predict = false
		return false
		# when latency is detected:
		# set sync frame to the input buffer of the previous frame. this is the last frame
		# where both players were in sync
		# predict inputs for opponent in the meantime, pretend they were always doing their thing
		# once inputs are recieved again, revert the game state of every object
		# except the player controller character to the sync frame and keep going
		

func predict_last_input():
	if !opponent:
		if player_id == 1:
			opponent = get_node_or_null("/root/IceCastle/Knight")
		elif player_id == 2:
			opponent = get_node_or_null("/root/IceCastle/Samurai")
		
	if player_id == 1 and predict:
		opponent.movement_remote(current_prediction)
			
		
	
