extends Button

var fileman=File.new()
func _ready():
	$scroll.visible=false
func _pressed():
	for i in $scroll/vbox.get_children():
		if i is Button:i.queue_free()
	$scroll.visible=not $scroll.visible
	var dict:Dictionary=openfile(File.READ)
	for i in dict.keys():
		var button=Button.new()
		button.text=i
		$scroll/vbox.add_child(button)
		button.connect("pressed",self,"onslot",[i])
func onslot(slot):
	var dict=openfile(File.WRITE_READ)
	dict.erase(slot)
	fileman.store_string(JSON.print(dict))
	fileman.close()
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
