extends "res://UI/debug/blockbase.gd"
var argbuttons=[]
func _on_size_value_changed(value):
	while argbuttons.size()<value:
		var new=input.new()
		argbuttons.append(new)
		new.rect_position=$args.rect_position
		new.savename="argument"+str(argbuttons.size())
		new.rect_position.x+=(new.rect_size.x+15)*(argbuttons.size()-1)
		if rect_size.x-6<new.rect_position.x:
			rect_size.x=new.rect_position.x+(new.rect_size.x*2)
		add_child(new)
	while argbuttons.size()>value:
		argbuttons[argbuttons.size()-1].queue_free()
		argbuttons.resize(argbuttons.size()-1)

func customsave(dict:Dictionary):
	dict["argcount"]=argbuttons.size()
func customload(dict:Dictionary):
	$size.value=dict["argcount"]
	_on_size_value_changed(dict["argcount"])
func _on_return_needsfill():
	var array=[]
	while array.size()<argbuttons.size():
		var button=argbuttons[array.size()]
		if button.target.value==null:
			button.target.emit_signal("needsfill")
		array.append(button.target.value)
	$return.value=array
