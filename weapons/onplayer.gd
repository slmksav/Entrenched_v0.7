extends Node
var recieve=true
class_name weaponcontrol,"res://weapons/onplayerclass.png"
func _ready():
	get_parent().connect("visibility_changed",self,"vischange")
func vischange():
	recieve=get_parent().visible
