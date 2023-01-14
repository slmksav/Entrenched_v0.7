extends Node2D
#the elements in this array will be enabled or
#disabled depending on user settings.
export(Array,String) var ispreference
func _ready():
	visualprefs.connect("loaded",self,"onload")
func onload():
	for i in ispreference:
		if visualprefs.preferences.has(i):
			get_parent().get_parent().get_parent().player_cosmetics[i]=math.strtobool(visualprefs.getpref(i))
