extends VBoxContainer

var selected:NinePatchRect=null
var chest: Sprite
func _on_new_player(new_player: Entity):
	chest = globals.player.get_node("visual/chest")
	globals.disconnect("new_player", self, "_on_new_player")
	globals.player.inventory.connect("visibility_changed", self, "visibility")


func noitem(item:Armor):
	globals.player.unset_armor(item)
	chest.unset_armor(item)


func visibility():
	if not globals.player.inventory.ontrade:
		get_parent().visible=globals.player.inventory.visible


func select(who:NinePatchRect):
	if selected!=null:
		selected.get_node("select").visible = false
	selected=who
	who.selected=true
func _on_inventory_selectindex(item:Item,_index):
	if "chest" in item:
		globals.iprint(["equiping",item])
		if item.chest!=null:
			$body.changeitem(item)
		if item.helmet!=null:
			$head.changeitem(item)
		chest.set_armor(item)
		globals.player.set_armor(item)
		globals.player.inventory.display_items()



func _on_player_ready():
	globals.connect("new_player", self, "_on_new_player")
	get_parent().visible=false
	for child in get_children():
		child.connect("removeditem",self,"noitem")
