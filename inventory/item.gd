extends Resource
class_name Item
var parentinventory
var index:int
export(int) var cost
export(Texture) var icon
export var name := "unnamed"
export var weight:float
export var amount:int = 1 setget setamount
export var maxamount:int=5
export(bool) var sellable
func get_weight() -> float:
	return amount * weight
func setamount(value):
	amount=value
	if amount<1:
		parentinventory.removeindex(index)
