extends weaponcontrol
func _ready():
	smartinput.waitfor(self,"attack",2)
	smartinput.waitfor(self,"deploy",2)
	smartinput.waitfor(self,"reload",2)
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		get_parent().aim(get_parent().get_global_mouse_position())
		get_tree().set_input_as_handled()
func newinput(event):
	if recieve:
		if event.is_action_pressed("deploy"):
			get_parent().deploy()
			return true
		if event.is_action_pressed("reload"):
			get_parent().reload()
			return true
		if event.is_action_pressed("attack") and get_parent().lowered:
			get_parent().attack()
			return true
