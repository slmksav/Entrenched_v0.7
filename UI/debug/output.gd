extends Button
var valname:String
var value
var target
export(String) var savename
class_name output,"res://UI/debug/output.png"
signal needsfill
onready var console=get_parent().get_parent()
func _ready():
	get_parent().outputbyname[savename]=self
	console.connect("executed",self,"execd")
func _pressed():
	if console.selectedin==null:
		console.selectedout=self
	else:
		console.selectedin.setout(self)
		console.selectedin=null
		console.selectedout=null
func execd():
	value=null
