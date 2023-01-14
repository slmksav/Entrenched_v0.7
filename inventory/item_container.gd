extends Control
var item:Item
func display_item(newitem:Item):
	item=newitem
	$HBox/Icon.texture = item.icon
	$HBox/Name.text = item.name
	$HBox/Amount.text = "x" + str(item.amount)
	$HBox/Weight.text = str(item.weight)
	rect_size.x=$HBox.rect_size.x
	rect_size.y=$HBox/Icon.rect_size.y
	
	$amount.setsize()
