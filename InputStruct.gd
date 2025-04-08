extends RefCounted

class_name InputStruct

var _id: int
var _left: bool
var _right: bool
var _up: bool
var _down: bool

func set_id (id : int) -> void:
		_id = id
func set_left (left : bool) -> void:
		_left = left
func set_right (right : bool) -> void:
		_right = right
func set_up (up: bool) -> void:
		_up = up
func set_down (down: bool) -> void:
		_down = down

func _to_string() -> String:
	var string : String = "ID:" + str(_id)  + "\nLeft: " + str(_left) + "\nRight: " + str(_right) + "\nUp: " + str(_up) + "\nDown: " + str(_down)
	return string
	
func _inherit_inputs(inputs: InputStruct):
	set_id(inputs._id + 1)
	if inputs._left:
		set_left(true)
	if inputs._right:
		set_right(true)
	if inputs._down:
		set_down(true)
	if inputs._up:
		set_up(true)
		
func _to_dictionary():
	var input_data = {
		"id": _id,
		"left":_left,
		"right": _right,
		"up": _up,
		"down": _down
	}
	return input_data
	
