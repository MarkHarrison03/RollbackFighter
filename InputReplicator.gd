extends Node
class_name input_replicator

var predicted_input_by_frame := {}
var current_remote_input := {}
var real_input_by_frame := {}
const MAX_ROLLBACK_FRAMES = 12
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_last_predicted_input(input: Dictionary):
	predicted_input_by_frame[InputManager.current_frame] = input
	var min_frame = InputManager.current_frame - MAX_ROLLBACK_FRAMES
	for key in predicted_input_by_frame.keys():
		if key < min_frame:
			predicted_input_by_frame.erase(key)
			
func set_current_remote_input(input : Dictionary):
	current_remote_input = input

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print("prediction: " , predicted_input_by_frame)
	#print("current input: " , current_remote_input)
	pass

func get_prediction_input(frame: int) -> Dictionary:
	if not InputReplicator.predicted_input_by_frame.is_empty():
		var last_predicted = InputReplicator.predicted_input_by_frame.values()[-1]
		var predicted = last_predicted.duplicate()
		predicted["frame"] = frame
		return predicted
	elif not InputReplicator.current_remote_input.is_empty():
		var fallback = InputReplicator.current_remote_input.duplicate()
		fallback["frame"] = frame
		return fallback
	else:
		return {
			"left": false, "right": false,
			"jump": false, "crouch": false,
			"attack": false, "frame": frame
		}
