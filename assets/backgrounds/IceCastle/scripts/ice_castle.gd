extends Node2D

var serializer 

var rollbackManager

var game_started := false
var local_ready := false
var remote_ready := false
var flipped := false
@onready var samurai = $Samurai
@onready var knight =  $Knight

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#var rollbackScript = load("res://RollbackManager.gd")
	#rollbackManager = rollbackScript.new()
	Engine.max_fps = 60	
	#var id = 1
	#
	#if multiplayer.get_unique_id() == 1:
		#id == 1
	#else:
		#id = multiplayer.get_peers()[0]
	local_ready = true
	ready_handshake.rpc_id(multiplayer.get_peers()[0])
	var script =  load("res://serializer.gd")
	InputManager.set_current_frame(0)
	serializer = script.new()
	knight = get_node("/root/IceCastle/Knight")
	samurai = get_node("/root/IceCastle/Samurai")
	
func assign_chars():
	knight = get_node("/root/IceCastle/Knight")
	samurai = get_node("/root/IceCastle/Samurai")
	
@rpc("any_peer", "call_local")
func ready_handshake():
	remote_ready = true

func flip_chars():
	if samurai.global_position.x > knight.global_position.x:
		if not flipped:
			samurai.scale.x *= -1
			knight.scale.x *= -1
			flipped = true
			samurai.flipped = true
			knight.flipped = true
	else:
		if flipped:
			samurai.scale.x *= -1
			knight.scale.x *= -1
			flipped = false		
			samurai.flipped = false
			knight.flipped = false	

	
func start_game():
	InputManager.game_started = true
	InputManager.set_current_frame(0)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if !knight or !samurai:
		assign_chars()
	flip_chars()
	#knight.face_opponent(samurai.global_position)
	#samurai.face_opponent(knight.global_position)
	if local_ready and remote_ready and not InputManager.game_started:
		start_game()
	if InputManager.game_started:
		save_gamestate_buffers()

	pass


# this function will be called every frame, and will save the current game state to a buffer. 
# the size of this buffer will be equal to the MAX_ROLLBACK_FRAMES, which is defaulted to 11.
# W
func save_gamestate_buffers():
	var player1 = $Samurai
	var player2 = $Knight
	serializer.add_players(player1, player2)
	var game_state = serializer.serialize()
	RollbackManager.add_gamestate_buffer(game_state)
		
