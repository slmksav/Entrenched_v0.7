extends Node
class_name switcher,"res://Player/visual/switcher.png"
# a class for making a bunch of buttons, from where you can only select one.
signal selected(button)
#the name used to be saved in the visual preferences dictionary
export(String) var selectionname
export(bool) var connectonready
export(int,1,100) var default
export(bool) var is2false
var selected:Button
var hasordered:bool
func onload():
	if visualprefs.preferences.has(selectionname):
		var val=visualprefs.preferences[selectionname]["Value"]
		if not is2false:
			#add 1 because index 0 is the swithcher.
			if get_parent().get_child(int(val)+1) is Button:
				get_parent().get_child(int(val)+1).pressed=true
			else:
				globals.iprint([selectionname,"doesnt have",val],"skin",true)
		else:
			if math.strtobool(str(val)):
				get_parent().get_child(1).pressed=true
			else:
				get_parent().get_child(2).pressed=true
	else:
		setdefault()
func _ready():
	visualprefs.connect("loaded",self,"onload")
	if connectonready:
		connects()
func connects():
	for child in get_parent().get_children():
		if child is Button:
			child.connect("toggled",self,"toogle",[child])
			child.toggle_mode=true
	get_parent().call_deferred("move_child",self,0)
func setdefault():
	if get_parent().get_children()[default] is Button:
		get_parent().get_children()[default].pressed=true
	else:
		globals.iprint(["invalid default",default],"skin")
func toogle(button_pressed:bool,button:Button):
	if button_pressed:
		var before=selected
		selected=button
		if is_instance_valid(before) and before!=selected:
			before.pressed=false
		emit_signal("selected",button)
		if not is2false:
			#i substract 1 because index 1 is the switcher
			var index=button.get_index()-1
			visualprefs.preferences[selectionname]=index
			prints("saved",index,"in",selectionname)
			
		else:
			visualprefs.preferences[selectionname]=button.get_index()!=2
	else:
		if button==selected:
			button.pressed=true
