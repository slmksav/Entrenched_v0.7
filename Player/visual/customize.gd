extends Control

export(bool) var reportreqdata
func _ready():
	visualprefs.fetch()
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_DISABLED,SceneTree.STRETCH_ASPECT_EXPAND,Vector2(1,1))

func _on_userpref_pressed():
	visualprefs.fetch()

func _on_back_pressed():
	visualprefs.update()
	UserData.connect("update_player_data",self,"updatedata")
func updatedata(_data,request_data):
	#in http OK=200 is like OK=0 in godot.
	if request_data["response_code"]==200:
		if reportreqdata:
			print(request_data)
		var tomenu=get_tree().change_scene("res://MainMenu.tscn")
		if tomenu!=OK:
			globals.iprint(["error getting back!",tomenu],"default",true)
	else:
		globals.iprint(["error updating player data!",request_data["response_code"],"network"],true)
