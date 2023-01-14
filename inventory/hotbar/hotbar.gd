extends HBoxContainer
export var tohand:NodePath
export(NodePath) var visual
export(int) var selectedindex
var selected:NinePatchRect
func vischange():
	visible=not globals.camera.get_node("UI/bottom/dialoguer").visible
func select(who:NinePatchRect):
	if globals.player!=null:
		if selected!=null:
			selected.selected=false
		selected=who
		who.selected=true


func _on_player_ready():
	visual = get_node(visual)
	globals.camera.get_node("UI/bottom/dialoguer").connect("visibility_changed",self,"vischange")
	get_node(tohand).get_node("spr").queue_free()
	select(get_child(selectedindex))


func _on_inventory_visibility_changed():
	if selected!=null:
		selected.get_node("select/toup").visible=globals.player.inventory.visible
