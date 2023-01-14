extends GridContainer
export(NodePath) var tovisual
onready var visual=get_node(tovisual)
export(PackedScene) var optionscn
export(String) var optionsname
export(SpriteFrames) var default
export(Array,String) var animorder
export(bool) var bydivission
func _ready():
	setchild()
func setchild():
	for i in get_children():
		if i is Button:
			i.queue_free()
	var selectedbutton:Button
	for i in visualprefs.alloptions[optionsname]:
		var new:Button=optionscn.instance()
		add_child(new)
		new.owner=get_tree().edited_scene_root
		var newframe:SpriteFrames
		if bydivission:
			newframe=math.texturetoframe(default,i,3,animorder)
		else:
			newframe=math.texturetoframe(default,i)
		new.get_node("texture").frames=newframe
	$switcher.connects()
