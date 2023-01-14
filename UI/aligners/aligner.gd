extends Node2D
class_name aligner , "res://UI/aligners/extendericon.png"
export(bool) var sety
export(bool) var setx
export(bool) var getcamera=true
export(bool) var camerarelative
export var scaleview=Vector2(1,1)
export(bool) var invisiblestart
export var offset:Vector2
onready var initscale=scale
export(bool) var useglobal
export(bool) var takeoffset
export(bool) var scaleonmin=true
#scales property changes weather the node stays the same in a big window
#or if it scales so that it is easy to read
export(bool) var scales
onready var defres=Vector2(ProjectSettings.get("display/window/size/width"),ProjectSettings.get("display/window/size/height"))
var initz=z_index
func _ready():
	if globals.camera!=null:
		scale=initscale
		if camerarelative:
			globals.camera.connect("setposition",self,"makelocal")
		if getcamera:
			globals.camera.connect("updategui",self,"setgui")
	else:
		print("camera not found")
	if invisiblestart:
		visible=false
	var rooterror=get_tree().root.connect("size_changed", self, "setgui")
	if rooterror!=OK:
		globals.iprint(["connecting sider to root with error",rooterror],"UI")
	setgui()
var pos:Vector2=Vector2()
func makelocal():
	z_as_relative=false
	scale*=globals.camera.scale
	global_position=globals.camera.position+pos
func setgui():
	var zoom=Vector2(1,1)
	if globals.camera!=null and getcamera:
		zoom=globals.camera.zoom
	var base=get_viewport_rect()
	var total=Vector2(base.size*scaleview*zoom)
	if sety:
		pos.y=total.y
	if setx:
		pos.x=total.x
	pos+=offset
	if scales:
		var vews=get_viewport_rect().size/defres
		var minvews
		if (vews.x>vews.y and scaleonmin) or (vews.x<vews.y and not scaleonmin):
			minvews=vews.y
		else:
			minvews=vews.x
		scale=initscale*minvews
	if takeoffset:
		pos+=globals.camera.offset
	if not camerarelative:
		if not useglobal:
			position=pos
		else:
			global_position=get_parent().global_position+pos
