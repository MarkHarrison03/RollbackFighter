extends RefCounted
class_name Serializer

var players = []
var time_left = 99
		
func serialize() -> PackedByteArray:
	
	var writer = StreamPeerBuffer.new()
	writer.put_32(InputManager.current_frame)
	#var buffer = PackedByteArray()
	#buffer.append(InputManager.current_frame)
	for p in players:
		writer.put_data(p.serialize_binary())
	return writer.get_data_array()
		
func deserialize(state: PackedByteArray) :
	var reader = StreamPeerBuffer.new()
	reader.data_array = state
	time_left = reader.get_8()
	for p in players:
		p.deserialize(reader)
		

	
	
func add_players(p1: CharacterBody2D, p2: CharacterBody2D):
	players = []
	players.append(p1)
	players.append(p2)
			
