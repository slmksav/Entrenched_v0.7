extends Node2D
#the weapon scene, not to be confused with
#onhanditem
class_name onhandrep,"res://inventory/hotbar/holdable.png"
var visual:AnimatedSprite
var user:Entity
#optional extra script used in a child Node when the item is controlled by the player
#should extend Node
#should manage input
export(bool) var dorecolor=true
export(Script) var onplayer
export(Array,NodePath) var shapes=[]
export(NodePath) var hand
var visbefore=[]
func _ready():
	if hand!=null:
		hand=get_node_or_null(hand) as onhandrep
	connect("visibility_changed",self,"disable")
	visbefore.resize(shapes.size())
	if get_parent().get_parent() is AnimatedSprite:
		visual=get_parent().get_parent()
	recolor()
func recolor():
	if hand!=null and visual!=null:
		hand.docolor(get_parent().handcolor)
func disable():
	for i in shapes.size():
		var who=get_node(shapes[i])
		if visible:
			if visbefore[i]!=null:
				who.set_deferred("disabled",visbefore[i])
		else:
			if who!=null:
				visbefore[i]=who.disabled
				who.set_deferred("disabled",true)
			else:
				globals.iprint(["null shape",i],"combat",true)
