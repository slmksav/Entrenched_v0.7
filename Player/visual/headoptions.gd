extends "res://Player/visual/head/textureselect.gd"
func _on_switcher_selected(button):
	if button!=null:
		visual.get_node("chest/head").setframes(button.get_index()-1,button.get_node("texture").frames)
		visual.get_node("hand/spr").docolor(visualprefs.racebyhead[button.get_index()-1])
