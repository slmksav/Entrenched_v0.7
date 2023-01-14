extends Node2D
export(Color) var handcolor
func _ready():
	get_child(0).visual=get_parent()
