extends Node2D
signal needcons
signal clear
signal executed
signal needsave
signal needssave
signal categorychange
export(PackedScene) var funcblock
export(PackedScene) var varblock
export(PackedScene) var arrayblock
export(PackedScene) var monitor
export(PackedScene) var scriptblock
export(String) var savedir
export(bool) var bypress
export(PackedScene) var message
var categories={"default":true}
var blocks: Array = []
var fileman: File = File.new()
var canexecute: bool = true
var selectedout: Button
var selectedin: Button

onready var buttonbycategory={"default":$back/scroll/categorytick/default}
func _ready():
	$back/output.get_v_scrollbar().connect("changed",self,"scrollchange")
func scrollchange():
	var scroller=$back/output.get_v_scrollbar()
	scroller.value=scroller.max_value
func _on_add_pressed():
	var new:Panel=funcblock.instance()
	add_child(new)
	new.rect_position=$newblocks.rect_position

func _input(event):
	if bypress and event.is_action_pressed("console"):
		visible=not visible
		get_tree().set_input_as_handled()


func _on_var_pressed():
	var new:Panel=varblock.instance()
	add_child(new)
	new.rect_position=$newblocks.rect_position
func categorychange(category,who):
	categories[category]=who.pressed
	emit_signal("categorychange")
func printsline(text:Array,aserror=false,category="default"):
	var printed=0
	var newtext=""
	if buttonbycategory!=null and not categories.has(category):
		categories[category] = true
		var new:CheckBox = CheckBox.new()
		new.text = str(category)
		buttonbycategory[category]=new
		new.pressed=true
		new.focus_mode=Control.FOCUS_NONE
		new.connect("pressed",self,"categorychange",[category,new])
		$back/scroll/categorytick.add_child(new)
	var newmessage=message.instance() as RichTextLabel
	if aserror:
		newtext+="[color=red]"
	while printed<text.size():
		newtext+=str(text[printed])+" "
		printed+=1
	if aserror:
		newtext+="[/color]"
	newmessage.bbcode_text=newtext
	newmessage.category=category
	newmessage.iserror=aserror
	$back/output/box.add_child(newmessage)
func _init():
	globals.console=self


func _on_array_pressed():
	var new: Panel = arrayblock.instance()
	add_child(new)
	new.rect_position = $newblocks.rect_position


func savetofile(dir):
	var error: int = OK
	if fileman.file_exists(dir):
		error=Directory.new().remove(dir)
		if error!=OK:
			globals.iprint(["couldnt remove your old save, error",error])
	if error==OK:
		error=fileman.open(dir,fileman.WRITE)
		if error==OK:
			fileman.store_string(getsavetext())
			fileman.close()
		else:
			globals.iprint(["couldnt open dir",dir,error])

func loadfromfile(dir):
	if fileman.file_exists(dir):
		fileman.open(dir,fileman.READ)
		loadtext(fileman.get_as_text(),true)
		fileman.close()
	else:
		printsline([savedir,"does not exist"],false,"consolecode")


func addloadblock(scene:PackedScene):
	var new=scene.instance()
	blocks.append(new)
	add_child(new)


func clearwork():
	emit_signal("clear")

func _on_clearcons_pressed():
	for i in $back/output/box.get_children():
		i.queue_free()
signal loaded
func loadtext(text:String,clear):
	globals.iprint(["loading",text],"consolecode")
	if clear:
		emit_signal("clear")
	var result: JSONParseResult = JSON.parse(text)
	if result.error == OK:
		var dict = result.result as Array
		for i in dict.size():
			globals.iprint(["creating,",i,"of",dict.size()],"consolecode")
			match dict[i]["type"]:
				"func":
					addloadblock(funcblock)
				"var":
					addloadblock(varblock)
				"array":
					addloadblock(arrayblock)
				"monitor":
					addloadblock(monitor)
				"script":
					addloadblock(scriptblock)
				_:
					printsline(["invalid block type on file",dict[i]["type"]])
		for i in dict.size():
			blocks[i].loadfile(dict[i])
		blocks.clear()
	else:
		printsline(["couldnt load",result.error_string],true,"consolecode")
		return
	emit_signal("loaded")
	globals.iprint("loading ended","consolecode")
func getsavetext() -> String:
	emit_signal("needsave")
	emit_signal("needcons")
	var ontext: String = JSON.print(blocks)
	blocks.clear()
	return ontext


func _on_fromclip_pressed():
	loadtext(OS.clipboard,false)


func _on_toclip_pressed():
	OS.clipboard=getsavetext()


func _on_monitor_pressed():
	var new:Panel=monitor.instance()
	add_child(new)
	new.rect_position=$newblocks.rect_position


func _on_script_pressed():
	var new:Panel=scriptblock.instance()
	add_child(new)
	new.rect_position=$newblocks.rect_position

