extends Node2D

@onready var connection_panel = $CanvasLayer/connection_panel
@onready var host_field = $CanvasLayer/connection_panel/GridContainer/HostField
@onready var port_field = $CanvasLayer/connection_panel/GridContainer/PortField
@onready var message = $CanvasLayer/messageLabel


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_network_peer_connected)
	multiplayer.peer_disconnected.connect( _on_network_peer_disconnected)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func _on_server_button_pressed() -> void:
	var peer = 	ENetMultiplayerPeer.new()
	#only allow one client to connect
	peer.create_server(int(port_field.text),1)
	multiplayer.multiplayer_peer = peer
	connection_panel.visible = false
	message.text = "Listening for client..."


func _on_client_button_pressed() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(host_field.text, int(port_field.text))
	multiplayer.multiplayer_peer = peer
	connection_panel.visible = false
	message.text = "Connecting..."
	
func _on_network_peer_connected(peer_id: int):
	message.text = "Connected!"
	get_tree().change_scene_to_file("res://assets/backgrounds/IceCastle/scripts/ice_castle.tscn")

	
func _on_network_peer_disconnected(peer_id: int):
	message.text = "Disconnected!"
	
func _on_server_disconnected(peer_id: int):
	_on_network_peer_disconnected(1)
	
