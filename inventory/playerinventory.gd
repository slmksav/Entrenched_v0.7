extends "res://inventory/inventory_display.gd"

export(NodePath) var totrade
onready var hotbar = get_parent().get_parent().get_parent().get_node("bottom/list")
#where excluded items are gonna be saved when trading
var normalexcluded: Array = []


func action():
	takeaction(get_node(totrade))

func _ready():
	smartinput.waitfor(self,"inventory",1)
	smartinput.waitfor(self,"inventorymove",1)


func newinput(event):
	if globals.player!=null and globals.player.setui and event.is_action_pressed("inventory") and not ontrade:
		visible=not visible
		return true
	if visible and event.is_action_pressed("inventorymove") and selectindex!=null and inventory.items[selectindex] is onhanditem:
		var node:NinePatchRect
		var exec=true
		if hotbar.selected==null:
			for i in hotbar.get_child_count():
				if hotbar.get_child(i).item==null:
					node=hotbar.get_child(i)
					break
				if i==hotbar.get_child_count():
					exec=false
		else:
			if hotbar.selected.item!=null:
				#make the item go to the inventory
				hotbar.selected.get_node("select/toup")._pressed()
			node=hotbar.selected
		if exec:
			var newitem:Item=inventory.items[selectindex]
			globals.iprint(["moving item",newitem,newitem.name],"inventory")
			node.changeitem(newitem)
			display_items()
		return true

func _on_back_pressed():
	ontrade=false
	visible=false
	get_node(totrade).ontrade=false
	get_node(totrade).closetrade()

