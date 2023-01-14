extends Button
var valname:String
var index:int
var target:output
class_name input,"res://UI/debug/input.png"
export(String) var savename
var line:Line2D
func _ready():
	focus_mode=FOCUS_NONE
	line=Line2D.new()
	add_child(line)
	line.points=[Vector2(),Vector2()]
	index=get_parent().inputs.size()
	get_parent().inputs.append(self)
	set_process(false)
	globals.console.connect("visibility_changed",self,"consolevis")
func _process(_delta):
	syncline()
func _pressed():
	if globals.console.selectedout==null:
		globals.console.selectedin=self
	else:
		setout(globals.console.selectedout)
		globals.console.selectedin=null
		globals.console.selectedout=null
		set_process(true)
func setout(with:Button):
	if get_parent()!=with.get_parent():
		target=with
		with.target=self
		syncline()
		set_process(true)
	else:
		globals.console.printsline(["you cant connect stuff in the same block"])
func postoconsole(to:Control):
	if to==null:
		globals.iprint(["error in block",get_parent().name])
		get_parent().queue_free()
	return ((to.rect_global_position+(to.rect_size/2))-globals.console.global_position)
func syncline():
	if globals.console.is_inside_tree():
		line.points.resize(2)
		line.points[0]=rect_size/2
		line.points[1]=((postoconsole(target)-postoconsole(self))*Vector2(math.getantiscale(globals.console.scale.x),math.getantiscale(globals.console.scale.y)))+target.rect_size/2
	else:
		print("error: console is orphan")
		get_parent().queue_free()
func consolevis():
	line.visible=globals.console.visible
	if target!=null:
		set_process(globals.console.visible)
func discon():
	if target!=null:
		line.visible=false
		target.target=null
		target=null
		set_process(false)
		globals.console.disconnect("visibility_changed",self,"consolevis")
