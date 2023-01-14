extends ProgressBar

func _on_slot_addeditem(item:Armor):
	item.parentinventory.connect("updated",self,"invupdate")
	visible=true
	max_value=item.maxhp
	value=item.hp
func _ready():
	visible=false
func invupdate():
	if get_parent().item!=null:
		value=get_parent().item.hp
func _on_slot_removeditem(item,_who):
	visible=false
	item.parentinventory.disconnect("updated",self,"invupdate")
