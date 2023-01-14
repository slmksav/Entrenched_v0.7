extends "res://UI/debug/blockbase.gd"
var enabled=false
var of:Object
func _ready():
	print(rect_size)
func customsave(dict):
	dict["property"]=$varname.text
func customload(dict):
	$varname.text=dict["property"]
func _process(_delta):
	if enabled:
		$value.text=str(of.get($varname.text))
		if $value.text.length()>14:
			$value.get("custom_fonts/normal_font").size=16
func _on_start_pressed():
	if $executer.target!=null:
		$executer.target.emit_signal("needsfill")
		if $executer.target.value!=null and typeof($executer.target.value)==TYPE_OBJECT:
			if $executer.target.value.get($varname.text)!=null:
				enabled=true
				$varname.editable=false
				of=$executer.target.value
				$getval.value=of.get($varname.text)
			else:
				globals.iprint([$varname.text,"isnt a variable of that object"],"consolecode",true)
		else:
			globals.iprint("couldnt get object","consolecode",true)
	else:
		globals.iprint("you need to connect an object","consolecode")


func _on_getval_needsfill():
	_on_start_pressed()
