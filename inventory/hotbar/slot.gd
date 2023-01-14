tool
extends NinePatchRect

signal removeditem(item)
signal select
signal addeditem(item)

export(Texture) var left
export(Texture) var right
export(Texture) var middle
export(Array,NodePath) var syncrect=["drag","icon","select"]
export(Array,Vector2) var marginsl
export(Array,Vector2) var marginm
export(Array,Vector2) var marginr 
export(int,0,2) var place setget setrectedit
export(bool) var update_children setget updatechilds

var wasready: bool = false
var item:Item=null
var selected=false setget select

var player: Entity


func _ready():
	wasready = true
	setrectbytree()
	$select.visible = false
	globals.connect("new_player", self, "_on_new_player")
func _on_new_player(new_player: Entity):
	player = new_player


func setrectbytree():
	if wasready:
		if get_index() == 0:
			setrect(0)
		elif get_index() == get_parent().get_child_count() - 1:
			setrect(2)
		else:
			setrect(1)


func setrectedit(value):
	place = value
	setrect(place)


func setrect(value):
	var pair: Array
	match value:
		0:
			pair = marginsl
			texture = left
		1:
			pair = marginm
			texture = middle
		2:
			pair = marginr
			texture = right
	set_patch_margin(MARGIN_LEFT,pair[0].x)
	set_patch_margin(MARGIN_RIGHT,pair[0].y)
	set_patch_margin(MARGIN_TOP,pair[1].x)
	set_patch_margin(MARGIN_BOTTOM,pair[1].y)
	property_list_changed_notify()
	region_rect.size = Vector2(0,0)
	updatechilds()


func updatechilds(_value=0):
	for i in syncrect.size():
		var sizing=get_node_or_null(syncrect[i]) as Control
		if sizing!=null:
			sizing.rect_position.y = patch_margin_top
			sizing.rect_position.x = patch_margin_left
			sizing.rect_size.y = rect_size.y - (patch_margin_bottom+patch_margin_top)
			sizing.rect_size.x = rect_size.x - (patch_margin_right+patch_margin_left)


func select(value):
	if globals.player==null:
		queue_free()
		return
	selected = value
	$select.visible = selected
	$select/toup.visible=globals.player.inventory.visible
	emit_signal("select")
	if has_method("setselect"):
		call("setselect")

func setsize():
	region_rect.size.x=texture.get_size().x


func changeitem(newitem: Item):
	if newitem != null:
		if item != null:
			changeitem(null)
		item = newitem
		player.inventory.excludeditems.append(item)
		$icon.texture=item.icon
		if item.parentinventory != null:
			item.parentinventory.connect("updated",self,"updatecounter")
		else:
			globals.iprint(["item",item,"with name",item.name,"doesnt have its inventory"],"inventory",true)
		updatecounter()
		emit_signal("addeditem",item)
		get_parent().select(self)
	else:
		emit_signal("removeditem",item)
		item.parentinventory.disconnect("updated",self,"updatecounter")
		player.inventory.excludeditems.erase(item)
		$icon.texture = null
		item = null
		$counter.visible = false
		player.inventory.display_items()
		$select/toup.visible=false

func _on_drag_pressed():
	get_parent().select(self)


func updatecounter():
	if item != null and item.amount > 0:
		$counter.visible = item.amount>1
		$counter.text = str(item.amount)
	else:
		globals.iprint("item has either ceased to exist or has amount 0","inventory")
		$counter.visible = false
		changeitem(null)
