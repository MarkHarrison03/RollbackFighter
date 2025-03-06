extends Node2D

var serializer 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var script =  load("res://serializer.gd")
	var player1 = $Samurai
	var player2 = $Knight
	serializer = script.new()
	
	serializer.add_players(player1, player2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print(serializer.serialize())
	pass
