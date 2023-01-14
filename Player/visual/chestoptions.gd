extends "res://Player/visual/head/textureselect.gd"
func _on_switcher_selected(button):
	visual.frames=button.get_node("texture").frames
