extends Button

var fileman=File.new()
func _ready():
	$scroll.visible=false
func _pressed():
	for i in $scroll/vbox.get_children():
		if i is Button:i.queue_free()
	$scroll.visible=not $scroll.visible
	var dict=getfile()
	if dict.error==OK:
		dict=dict.result as Dictionary
		for i in dict.keys():
			var button=Button.new()
			button.text=i
			$scroll/vbox.add_child(button)
			button.connect("pressed",self,"onslot",[i])
	else:
		globals.iprint("error partsing","consolecode",true)
func onslot(set):
	globals.console.loadtext(getfile().result[set],true)
	$scroll.visible=false
func getfile():
	fileman.open("user://allsets.json",File.READ)
	var dict=JSON.parse(fileman.get_as_text())
	fileman.close()
	return dict
