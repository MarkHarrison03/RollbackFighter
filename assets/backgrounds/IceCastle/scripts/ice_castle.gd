extends Node2D

var serializer 

var rollbackManager

var game_started := false
var local_ready := false
var remote_ready := false

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
	
@rpc("any_peer", "call_local")
func ready_handshake():
	remote_ready = true

func start_game():
	InputManager.game_started = true
	InputManager.set_current_frame(0)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
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
	print("gamestate1", game_state)
	RollbackManager.add_gamestate_buffer(game_state)
		
