extends Area2D

@export var parent: CharacterBody2D  

func _ready():
	if parent == null:
		parent = get_parent()
	add_to_group("hurtboxes")  
	connect("area_entered", _on_hitbox_entered)

func _on_hitbox_entered(hitbox: Area2D):
	if hitbox.is_in_group("hitboxes"):
		print("Hurtbox hit!")
		var damage = hitbox.damage if hitbox.has_method("damage") else 10
		parent.take_damage(damage) 
