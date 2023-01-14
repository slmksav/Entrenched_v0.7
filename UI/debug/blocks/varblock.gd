extends "res://UI/debug/blockbase.gd"
func customready():
	$type.get_popup().connect("index_pressed",self,"idxselected")
	$type.add_item("string",0)
	$type.add_item("float",1)
	$type.add_item("bool",2)
	$type.add_item("valshort",3)
	$type.add_item("get node",4)
func _on_return_needsfill():
	match $type.selected:
		0:
			$return.value=$value.text
		1:
			$return.value=float($value.text)
		2:
			match $value.text:
				"true":
					$return.value=true
				"false":
					$return.value=false
				_:
					get_parent().printsline([$value.text,"not a bolean, returning false"])
		3:
			if globals.consoleshorts.has($value.text):
				$return.value=globals.consoleshorts[$value.text]
			else:
				get_parent().canexecute=false
				get_parent().printsline([$value.text,"is not a valid short key"])
		4:
			if get_node_or_null($value.text)!=null:
				$return.value=get_node_or_null($value.text)
			else:
				globals.iprint("couldnt get node","consolecode",true)
				globals.console.canexecute=false
func customsave(dict:Dictionary):
	dict["varname"]=$value.text
	dict["vartype"]=$type.selected
func customload(dict:Dictionary):
	$value.text=dict["varname"]
	$type.selected=dict["vartype"]
func _on_type_pressed():
	$type.get_popup().rect_scale=Vector2(1,1)
	$type.get_popup().set_as_toplevel(false)
	$type.disabled=true
	$type.get_popup().rect_global_position=rect_global_position
func idxselected(_idx):
	$type.disabled=false
	$type.get_popup().set_as_toplevel(true)

func _on_value_text_entered(_new_text):
	$value.release_focus()
