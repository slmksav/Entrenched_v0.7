tool
extends "res://inventory/hotbar/slot.gd"
func setselect():
	if item!=null:
		$select/toup.visible=true
	else:
		$select/toup.visible=false
