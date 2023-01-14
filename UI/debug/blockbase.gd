extends Panel
var inputs=[]
var outputbyname={}
export(String) var typename
var saveid:int
func _process(_delta):
	if $move.pressed:
		rect_global_position=get_global_mouse_position()

func _ready():
	globals.console.connect("clear",self,"delete")
	globals.console.connect("needsave",self,"onsave")
	globals.console.connect("needcons",self,"syncons")
	if has_method("customready"):
		call("customready")
func onsave():
	saveid=globals.console.blocks.size()
	globals.console.blocks.append({"type":typename})
	globals.console.blocks[saveid]["position"]=vec2tostr(Vector2(round(rect_position.x),round(rect_position.y)))
func syncons():
	var dict=globals.console.blocks[saveid] as Dictionary
	dict["connections"]=[]
	var cons=dict["connections"]
	var regd=0
	while regd<inputs.size():
		var now=inputs[regd]
		if now.target!=null:
			cons.append([now.target.savename,now.target.get_parent().saveid])
		else:
			cons.append(null)
		regd+=1
	if has_method("customsave"):
		call("customsave",dict)
func loadfile(dict:Dictionary):
	rect_position=strtovec2(dict["position"])
	if has_method("customload"):
		call("customload",dict)
	var cons=dict["connections"]
	var loaded=0
	while loaded<inputs.size():
		var data=cons[loaded]
		if data!=null:
			var block=globals.console.blocks[data[1]]
			if block.outputbyname.has(data[0]):
				inputs[loaded].setout(block.outputbyname[data[0]])
			else:
				globals.console.printsline(["block",block.name,"doesnt have output",data[0]])
		loaded+=1
func vec2tostr(from:Vector2):
	var result=""
	result+=str(from.x)
	result+=","
	result+=str(from.y)
	return result
func strtovec2(from:String):
	var result=Vector2()
	var rnchar=0
	var xresult=""
	while rnchar<from.length():
		if from[rnchar]!=",":
			xresult+=from[rnchar]
			rnchar+=1
		else:
			result.x=float(xresult)
			break
	var yresult=""
	while rnchar<from.length()-1:
		rnchar+=1
		yresult+=from[rnchar]
	result.y=float(yresult)
	return result
func delete():
	queue_free()
func quit():
	var discon=0
	while discon<inputs.size():
		inputs[discon].discon()
		discon+=1
	var outs=0
	while outs<outputbyname.keys().size():
		var now=outputbyname[outputbyname.keys()[outs]] as output
		if now.target!=null:
			now.target.discon()
		outs+=1
	queue_free()
