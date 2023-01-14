extends Sprite
export(NodePath) onready var animator=get_node(animator) as AnimationPlayer
func _ready():
	if visible:
		get_parent().connect("frame_changed",self,"newanim")
		animator.connect("animation_changed",self,"newanim")
func newanim():
	visible=get_parent().animation!="back"
