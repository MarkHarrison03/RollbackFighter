extends Node

var last_input_recieved_time := 0.0
var current_frame := 0
var remote_frame := 0
var player_id : int
@export var opponent: CharacterBody2D
var current_prediction : Dictionary
var predict : bool
var game_started := false

var last_heartbeat_sendtime := 0
var last_heartbeat_recievedtime := 0
const input_timeout_ms := 200
const MAX_FRAME_DELTA := 2
const FRAME_TIME := 1.0/60.0
var rollbackManager
var ping := 0
var heartbeat_timer := 0.0
const MAX_ROLLBACK_FRAMES = 12
var frame_delta := 0

var last_predicted_input := {}

func _ready():
	#var script =  load("res://RollbackManager.gd")
	#rollbackManager = script.new()
	predict = false
	if multiplayer.get_unique_id() == 1:
		player_id = 1
		opponent = get_node_or_null("/root/IceCastle/Knight")
	else:
		player_id = 2
		opponent = get_node_or_null("/root/IceCastle/Samurai")
		
		
	

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	if abs(current_frame - remote_frame) > 12:
		
		#print("UNSYNCED")
		#when the unsync is detected, we want to set the last frame to the sync frame
		RollbackManager.set_sync_frame(current_frame)
		
	else:
	#	print("NO MORE LATENCY", randi())
		if RollbackManager.sync_locked:
			for frame in InputReplicator.real_input_by_frame.keys():
				if InputReplicator.predicted_input_by_frame.has(frame) and InputReplicator.real_input_by_frame.has(frame):
					var predicted = InputReplicator.predicted_input_by_frame[frame]
					
					var actual = InputReplicator.real_input_by_frame[frame]
					if predicted != actual:
						print("sync frame", RollbackManager.last_synced_frame)
						print("mismatch at frame ", frame)
						RollbackManager.rollback()
						
				RollbackManager.sync_locked =false
		
		RollbackManager.sync_locked = false
		InputReplicator.predicted_input_by_frame.clear()
		
		#print(InputReplicator.real_input_by_frame)
		#print("new input recieved, " , )
		#then we predict 
		#then when an input is recieved again, we compare the actual input with the predicted input
		#if its the same, continue as normal
		#if its different, return to sync state and re-execute frames until the frame numbers match again (execute 12+ inputs in one frame?  )
#	print("current : ", current_frame, " remote : ", remote_frame)
	if game_started:
		current_frame += 1
		
		frame_delta = remote_frame - current_frame
		if frame_delta > MAX_FRAME_DELTA:
			# we are behind
			current_frame += 1
		elif frame_delta < -MAX_FRAME_DELTA:
			# we're ahead
			await get_tree().create_timer(FRAME_TIME).timeout
		var now = Time.get_ticks_msec()
		heartbeat_timer += delta
		if heartbeat_timer >= 0.1:
			send_heartbeat.rpc_id(multiplayer.get_peers()[0], Time.get_ticks_msec())
			heartbeat_timer = 0.0
			
#
			#predict = true

		#else:
			#predict = false
			
@rpc("any_peer", "call_remote")
func send_heartbeat(sent_time: int):
	recieve_heartbeat_response.rpc_id(multiplayer.get_remote_sender_id(), sent_time)

@rpc("any_peer", "call_remote")
func recieve_heartbeat_response(sent_time: int):
	var now = Time.get_ticks_msec()
	ping = now - sent_time
	
	#print("PING  RTT: ", ping, " ms")
	#if ping > input_timeout_ms:
		#if not predict:
		#	print("input timeout. Predicting", now-last_input_recieved_time, " ")
			#predict_last_input()
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
	print("PREDICTING!")
	if !opponent:
		if player_id == 1:
			opponent = get_node_or_null("/root/IceCastle/Knight")
		elif player_id == 2:
			opponent = get_node_or_null("/root/IceCastle/Samurai")
		
	if player_id == 1:
	#	print("PING -- PREDICTING", current_prediction)
		InputReplicator.add_last_predicted_input(current_prediction)
		opponent.movement_remote(current_prediction)
		
		
		
	
