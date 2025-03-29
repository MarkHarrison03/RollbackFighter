extends Node
class_name input_replicator

var last_predicted_input := {}
var current_remote_input := {}
var real_input_by_frame := {}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_last_predicted_input(input: Dictionary):
	last_predicted_input = input
	
func set_current_remote_input(input : Dictionary):
	current_remote_input = input

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print("last predicted: " , last_predicted_input)
	print("current input: " , current_remote_input)
	pass
