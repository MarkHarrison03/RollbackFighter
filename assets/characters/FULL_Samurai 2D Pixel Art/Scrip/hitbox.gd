extends Area2D

func _ready():
	add_to_group("hitboxes")
	
func _on_area_entered(area : Area2D):
	print("AREA ",area)
