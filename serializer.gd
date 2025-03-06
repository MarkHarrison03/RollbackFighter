extends RefCounted
class_name Serializer

var players = []
var time_left = 99
		
func serialize() -> PackedByteArray:
	var buffer = PackedByteArray()
	buffer.append(time_left)
	for p in players:
		buffer.append_array(p.serialize_binary())
	return buffer
		
func deserialize(state: PackedByteArray) :
	var reader = StreamPeerBuffer.new()
	reader.data_array = state
	time_left = reader.get_8()
	for p in players:
		p.deserialize(reader)
		
func clearPlayers():
	players = []
	
	
func add_players(p1: CharacterBody2D, p2: CharacterBody2D):
	players.append(p1)
	players.append(p2)
			
