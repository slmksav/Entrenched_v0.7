extends Control
var ontrade:bool=false
signal selectindex(item,index)
export(bool) var hasaction
enum actions{Buy,Sell}
export(actions) var action
var inventory:Inventory = load("res://inventory/inventory.gd").new()
export(Resource) var custom_inventory
onready var item_list = $ScrollContainer/ItemsVBox/
export(PackedScene) var item_node
var displaybyadded=[]
#excluded items will be items that wont be displayed on
#the visual inventory, but will remain in the inventory
#class, maybe because its in the hotbar or on the body,
#or maybe it cant be sold and you are trading.
var excludeditems:Array=[]
#this array contains all item containers in the order they
#were drawn, not in their inventory item order
var itemdisplay=[]
var currentdisplayidx:int
func _ready() -> void:
	visible=false
	if custom_inventory!=null:
		inventory=custom_inventory
	$action.connect("pressed",self,"action")
	match action:
		actions.Buy:
			$action.text="Buy"
		actions.Sell:
			$action.text="Sell"
	$action.visible=false
	display_items()
	inventory.connect("updated", self, "display_items")
func display_items():
	itemdisplay.resize(10)
	displaybyadded.resize(10)
	for child in item_list.get_children():
		(child as Node).queue_free()
	var added=0
	for i in inventory.items.size():
		if not excludeditems.has(inventory.items[i]):
			var itm = (item_node.instance() as Button)
			displaybyadded[added]=itm
			itemdisplay[i]=itm
			itm.connect("pressed", self, "item_clicked", [i,added])
			itm.display_item(inventory.items[i])
			item_list.add_child(itm)
			added+=1
	$dust.visible=not added>0
	$balance/balance.text=str(inventory.balance)
var selectindex:int
func item_clicked(index:int,bydisplay:int):
	globals.iprint(["selected item index",index,"display index",bydisplay],"inventory")
	if index<inventory.items.size():
		selectindex=index
		currentdisplayidx=bydisplay
		if ontrade and hasaction:
			$action.visible=true
			var container=itemdisplay[index] as Button
			$action/amount.max_value=inventory.items[index].amount
			$action.rect_position.y=container.rect_position.y+(container.rect_size.y/2)
		emit_signal("selectindex", inventory.items[index],index)
	else:
		print("wnknown inventory slot clicked")
func takeaction(target:Control):
	inventory.tradeout(target.inventory,selectindex,$action/amount.value)
	if inventory.items.size()<=selectindex:
		$action.visible=false
	target.display_items()
	display_items()
