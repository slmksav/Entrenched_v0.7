extends "res://UI/debug/blockbase.gd"

func customsave(dict):
	dict["code"]=$text.text
func customload(dict):
	$text.text=dict["code"]

func _on_run_pressed():
	var newscript=$executer.script
	newscript.source_code=$text.text
	var error=newscript.reload(true)
	if error==OK:
		$executer.set_script(newscript)
		$return.value=$executer.onrun()
		globals.iprint(["returned",$return.value],"consolecode")
	else:
		globals.iprint(["error compiling:",error],"consolecode",true)
		globals.console.canexecute=false

func _on_return_needsfill():
	_on_run_pressed()
