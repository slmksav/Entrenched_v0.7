extends Control
export(PackedScene) var option
signal answer
var displaying:bool=false
func _ready():
	visible=false
func talk(talkname:String,diag:String,options:Array)->void:
	if displaying:
		close()
	visible=true
	$name.text=talkname
	$diag.text=diag
	var buttons=options.size()
	var done=0
	while done<buttons:
		var new=option.instance() as Button
		$optioncenter.add_child(new)
		new.text=options[done]
		new.order=done
		new.connect("answer",self,"answer")
		done+=1
	displaying=true
func close()->void:
	var deleted=0
	while deleted<$optioncenter.get_child_count():
		$optioncenter.get_child(deleted).queue_free()
		deleted+=1
	displaying=false
	visible=false
func answer(order)->void:
	emit_signal("answer",order)
