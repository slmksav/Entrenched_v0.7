extends GridContainer
export(NodePath) var tovisual
onready var visual=get_node(tovisual)
export(PackedScene) var optionscn
export(Array,Texture) var options
export(SpriteFrames) var default
func _ready():
	setchild()
func setchild():
	for i in get_children():
		if i is Button:
			i.queue_free()
	for i in options:
		var new:Button=optionscn.instance()
		add_child(new)
		new.owner=get_tree().edited_scene_root
		new.get_node("texture").frames=math.texturetoframe(default,i)
	$switcher._ready()
