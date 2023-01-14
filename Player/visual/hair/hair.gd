extends "res://Player/visual/head/textureselect.gd"


func _on_switcher_selected(button):
	visual.get_node("chest/head").sethair(button.get_node("texture").frames)
