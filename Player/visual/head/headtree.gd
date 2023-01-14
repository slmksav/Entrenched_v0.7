tool
extends AnimatedSprite
export(PackedScene) var defaulthead
onready var headreference=defaulthead.instance() as Node
func setframes(index,new:SpriteFrames):
	frames=new
	if visualprefs.scenebyhead.size()>index and visualprefs.scenebyhead[index]!=null:
		addheadref(visualprefs.scenebyhead[index].instance())
#sets the position of stuff based in a head template
func _ready():
	addheadref(headreference)
func updatechilds():
	if Engine.editor_hint: return
	if not is_instance_valid(headreference):
		addheadref(defaulthead.instance())
	if headreference.get_node_or_null(animation)!=null:	
		for i in headreference.get_node(animation).get_children():
			if i is AnimatedSprite or i is Sprite:
				var original=get_node(i.name)
				original.position=i.position
		$aligner.doalign()
func sethair(new:SpriteFrames):
	$hair.frames=new
	if $hair.frames!=null:
		$hair.animation=animation
	$aligner.doalign()



func _on_animator_animation_changed(_old_name,_new_name):
	updatechilds()
func addheadref(new):
	if Engine.editor_hint: return
	if is_instance_valid(headreference):
		headreference.queue_free()
	headreference=new
	add_child(headreference)
	for i in headreference.get_children():
		i.visible=false
