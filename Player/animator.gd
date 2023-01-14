class_name animer,"res://Player/visual/animer.png"
extends Node
export(String) var onanimation
export(String) var targetname
export(Array,Vector2) var posbyframe:Array
func setpos(value):
	if sprite==null or not Engine.editor_hint:return
	value.resize(sprite.frames.get_frame_count(onanimation))
	if value.size()==posbyframe.size():
		for i in value.size():
			if value[i]!=posbyframe[i]:
				sprite.frame=i
				sprite.playing=false
				sprite.animation=onanimation
				break
	posbyframe=value
	animupdate()
onready var target:Node2D
onready var sprite:AnimatedSprite
func _ready():
	sets()
func animupdate():
	if sprite.animation==onanimation:
		if posbyframe.size()>sprite.frame:
			target.position=posbyframe[sprite.frame]
func sets():
	if not is_inside_tree():return
	sprite=get_parent().get_parent()
	if not sprite.is_connected("frame_changed",self,"animupdate"):
		sprite.connect("frame_changed",self,"animupdate")
		sprite.connect("animation_finished",self,"animupdate")
	print(sprite)
	target=get_parent().get_parent().get_node(targetname)
	print(target)
