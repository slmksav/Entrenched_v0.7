tool
extends "res://inventory/hotbar/slot.gd"
export(PackedScene) var hand
onready var representation:onhandrep=hand.instance()

func setselect():
	representation.visible=selected
func _ready():
	addhand()
	setselect()
	$select/toup.visible=false
func _on_slot_removeditem(item):
	representation.queue_free()
	addhand()
func _on_slot_addeditem(item:onhanditem):
	if representation!=null:
		representation.queue_free()
	representation=item.onhand.instance() as onhandrep
	if representation.onplayer!=null:
		var node=Node.new()
		node.set_script(representation.onplayer)
		representation.add_child(node)
	representation.user=globals.player
	representation.visual=globals.player.get_node("visual")
	get_parent().get_node(get_parent().tohand).add_child(representation)
func addhand():
	representation=hand.instance()
	get_parent().get_node(get_parent().tohand).add_child(representation)
