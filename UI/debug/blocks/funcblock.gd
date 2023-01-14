extends "res://UI/debug/blockbase.gd"

export(PackedScene) var argument
var argbuttons=[]
func _on_argcount_value_changed(value):
	if argbuttons.size()<value:
		var new=argument.instance() as input
		argbuttons.append(new)
		new.savename="argument"+str(argbuttons.size())
		new.rect_position=$args.rect_position
		new.rect_position.x+=new.rect_size.x*2*(argbuttons.size()-1)
		add_child(new)
	if argbuttons.size()>value:
		inputs.remove(argbuttons[value].index)
		argbuttons[value].queue_free()
		argbuttons.resize(value)
var runonsave=false
func customsave(dict:Dictionary):
	dict["argcount"]=$argcount.value
	dict["funcname"]=$funcname.text
	dict["torun"]=runonsave
	runonsave=false
func customload(dict:Dictionary):
	if dict.has("argcount"):
		$argcount.value=dict["argcount"]
		_on_argcount_value_changed(dict["argcount"])
	$funcname.text=dict["funcname"]
	if dict.has("torun") and dict["torun"]:
		var error=globals.console.connect("loaded",self,"run",[true],CONNECT_ONESHOT)
		if error!=OK:
			globals.iprint(["cant check if console loaded the blocks, error",error,"consolecode",true])
func run(initial:bool):
	var executer:Object
	if initial:
		globals.console.printsline(["#######"],false,"consolecode")
	if $from.target==null:
		executer=get_parent()
	else:
		$from.target.emit_signal("needsfill")
		if $from.target.value!=null:
			if typeof($from.target.value)==TYPE_OBJECT:
				executer=$from.target.value
			else:
				get_parent().canexecute=false
				get_parent().printsline(["invalid executer on",$funcname.text])
		else:
			get_parent().canexecute=false
			get_parent().printsline(["cant get executer on",$funcname.text])
	var argumentsfilled=0
	var arguments=[]
	while argumentsfilled<argbuttons.size():
		var button:Button=argbuttons[argumentsfilled]
		if button.target==null:
			executer=get_parent()
		else:
			button.target.emit_signal("needsfill")
			if $debugprint.pressed:
				get_parent().printsline(["argument",argumentsfilled,"request ended"],false,"consolecode")
			if button.target.value!=null:
				arguments.append(button.target.value)
			else:
				get_parent().canexecute=false
				get_parent().printsline(["cant fill argument",argumentsfilled,"on",$funcname.text],true,"consolecode")
		argumentsfilled+=1
	if globals.console.canexecute:
		if executer!=null and executer.has_method($funcname.text):
			$return.value=executer.callv($funcname.text,arguments)
			if $debugprint.pressed:
				get_parent().printsline([$funcname.text,"returned",$return.value],false,"consolecode")
			get_parent().printsline([$funcname.text,"called correctly"],false,"consolecode")
			if initial:
				get_parent().emit_signal("executed")
		else:
			if not initial:
				get_parent().canexecute=false
			globals.console.printsline([executer,executer.name,"doesnt have",$funcname.text],false,"consolecode")
	else:
		globals.console.printsline(["something failed"],true,"consolecode")
		if initial:
			get_parent().canexecute=true
func _on_return_needsfill():
	run(false)

func _ready():
	if server.type!=server.types.host:
		$clients.queue_free()
		$sync.queue_free()
func _on_funcname_text_entered(_new_text):
	$funcname.release_focus()


func doremote():
	runonsave=true
	globals.rpc("callonconsole","loadtext",[globals.console.getsavetext(),true])
