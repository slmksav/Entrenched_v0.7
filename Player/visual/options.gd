extends Panel


export(NodePath) var toplayer
onready var player:AnimationPlayer=get_node(toplayer)
var selected=""
func _ready():
	visible=false
	get_viewport().connect("size_changed",self,"resize")
	for i in get_children():
		if i is ScrollContainer:
			i.visible=false
func resize():
	rect_size.y=get_viewport_rect().size.y
	if selected!="":
		get_node(selected).rect_size.y=get_viewport_rect().size.y-60
func _on_back_pressed():
	visible=false
	player.play("focusall")
func select(which:String):
	visible=true
	if selected!="":
		get_node(selected).visible=false
	get_node(which).visible=true
	selected=which
