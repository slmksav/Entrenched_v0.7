extends CollisionShape2D
class_name syncedshape,"res://Player/physics/colsimbol.png"
export(String) var target
var clone=CollisionShape2D.new()
export var clonedisable:bool setget setclone
func setclone(value:bool):
	clonedisable=value
	clone.disabled=value
func start(): 
	if target==null or target=="":
		target=globals.player
	else:
		target=get_node(target) as PhysicsBody2D
	clone.shape=shape
	target.add_child(clone)
	set_process(true)
func _init():
	set_process(false)
	disabled=true
func _process(_delta):
	clone.global_position=global_position
	clone.global_rotation=global_rotation
