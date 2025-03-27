extends Node

var last_input_recieved_time := 0.0
var current_frame := 0
var player_id : int
@export var opponent: CharacterBody2D
var current_prediction : Dictionary
var predict : bool
var game_started := false

var last_heartbeat_sendtime := 0
var last_heartbeat_recievedtime := 0
var input_timeout_ms := 200
var ping := 0
var heartbeat_timer := 0.0
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
		
		var now = Time.get_ticks_msec()
		heartbeat_timer += delta
		if heartbeat_timer >= 0.1:
			send_heartbeat.rpc_id(multiplayer.get_peers()[0], Time.get_ticks_msec())
			heartbeat_timer = 0.0
			

			predict = true
			predict_last_input()
		else:
			predict = false
			
@rpc("any_peer", "call_remote")
func send_heartbeat(sent_time: int):
	recieve_heartbeat_response.rpc_id(multiplayer.get_remote_sender_id(), sent_time)

@rpc("any_peer", "call_remote")
func recieve_heartbeat_response(sent_time: int):
	var now = Time.get_ticks_msec()
	ping = now - sent_time
	print("PING  RTT: ", ping, " ms")
	if ping > input_timeout_ms:
		if not predict:
			print("input timeout. Predicting", now-last_input_recieved_time, " ")
	last_heartbeat_recievedtime = now
	

func get_current_frame():
	return current_frame
	
func set_current_frame(frame: int):
	current_frame = frame
	
func flip_predict():
	predict = !predict

#func check_for_lag(input_buffer: Dictionary) -> bool:
	#if not input_buffer.has("frame"):
		#return false
	#
	##print("frame diff: ", current_frame - input_buffer["frame"])
	#if current_frame - input_buffer["frame"]  > INPUT_TIMEOUT_THRESHOLD: 
		#predict_last_input()
		#return true
	#else:
		#predict = false
		#return false
		## when latency is detected:
		## set sync frame to the input buffer of the previous frame. this is the last frame
		## where both players were in sync
		## predict inputs for opponent in the meantime, pretend they were always doing their thing
		## once inputs are recieved again, revert the game state of every object
		## except the player controller character to the sync frame and keep going
		#

func predict_last_input():
	if !opponent:
		if player_id == 1:
			opponent = get_node_or_null("/root/IceCastle/Knight")
		elif player_id == 2:
			opponent = get_node_or_null("/root/IceCastle/Samurai")
		
	if player_id == 1 and predict:
		opponent.movement_remote(current_prediction)
		
		
	
