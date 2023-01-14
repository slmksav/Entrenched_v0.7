extends Button
var fileman=File.new()
func _ready():
	$scroll.visible=false
	$setname.visible=false
func _pressed():
	for i in $scroll/vbox.get_children():
		if i is Button and i.text!="+":i.queue_free()
	$scroll.visible=not $scroll.visible
	var dict:Dictionary=openfile(File.READ)
	for i in dict.keys():
		var button=Button.new()
		button.text=i
		$scroll/vbox.add_child(button)
		button.connect("pressed",self,"onslot",[i])
	if dict.keys().size()>0:
		fileman.store_string(JSON.print(dict))
	fileman.close()
func onslot(set):
	var dict=openfile(File.READ_WRITE)
	dict[set]=globals.console.getsavetext()
	$scroll.visible=false
	fileman.store_string(JSON.print(dict))
	fileman.close()
func _on_plus_pressed():
	$setname.visible=true
func openfile(type:int):
	var error=fileman.open("user://allsets.json",type)
	if error==OK:
		if fileman.get_as_text()!="":
			var parsed=JSON.parse(fileman.get_as_text())
			if parsed.error==OK:
				return parsed.result
			else:
				globals.iprint(["error",parsed.error,"parsing"],"consolecode")
				return {}
		else:
			return {}
	else:
		globals.iprint(["error",error,"loading"],"consolecode")
		return {}
func _on_setname_text_entered(new_text):
	var dict=openfile(File.READ_WRITE)
	dict[new_text]=globals.console.getsavetext()
	fileman.store_string(JSON.print(dict))
	fileman.close()
	$setname.visible=false
