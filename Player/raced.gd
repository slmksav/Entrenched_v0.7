extends Node2D
var handcolor:Color
func _ready():
	visualprefs.connect("loaded",self,"gotskin")
func gotskin():
	if visualprefs.preferences.has("heads"):
		handcolor=visualprefs.racebyhead[int(visualprefs.getpref("heads"))]
		for i in get_children():
			i.recolor()
