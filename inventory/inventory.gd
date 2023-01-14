extends Resource
class_name Inventory,"res://inventory/bagicon.png"
signal updated
#if true, max_weight is obeyed.
export(bool) var doescap=true
export var max_weight:float = 20
signal succesfultrade
export(Array,Resource) var items:Array setget setitems
export var balance:int=5
func add_item(new_item:Item):
	if not new_item is Item: 
		globals.iprint("provided wrong item") 
		return
	if (get_weight() + new_item.get_weight() > max_weight) and doescap:
		globals.iprint("too heavy")
		return
	for item in items:
		if new_item.name == item.name:
			(item as Item).amount += new_item.amount
			emit_signal("updated")
			return
	new_item.index=items.size()
	items.append(new_item)
	setitems(items)
	emit_signal("updated")
func setitems(value):
	if globals!=null:
		globals.iprint("setting item´s parent inventory")
	items=value
	for i in items.size():
		items[i]=items[i].duplicate()
		items[i].parentinventory=self
		items[i].index=i
func delete_item(index,amount):
	if items.size()>index:
		var tradeitem=items[index] as Item
		tradeitem.amount-=amount
		emit_signal("updated")
func removeindex(index):
	items.remove(index)
func get_weight() -> float:
	var weight = 0.0
	for item in items:
		weight += item.amount * item.weight
	return weight
func tradeout(to:Inventory,itemindex:int,amount):
	var togive=items[itemindex].duplicate() as Item
	var transactionweight=togive.weight*amount
	if transactionweight+to.get_weight()<=to.max_weight or not to.doescap:
		if to.balance>togive.cost*amount:
			if amount<=togive.amount:
				to.balance-=togive.cost*amount
				balance+=togive.cost*amount
				delete_item(itemindex,amount)
				togive.amount=amount
				to.add_item(togive)
				#report the transaction
				globals.iprint("succesful trade")
				emit_signal("succesfultrade")
				to.emit_signal("succesfultrade")
			else:
				print("not enough of that resource")
		else:
			prints(to,"doesnt have enough money")
	else:
		prints("too heavy for",to)
