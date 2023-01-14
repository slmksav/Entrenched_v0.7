extends Button
"""
func _pressed():
	var error=server.startserv(41205)
	if error==OK:
		get_parent().get_parent().go()
	else:
		globals.iprint(["couldnt host, error",error])
"""

func _pressed():
	var error: int = Multiplayer.start_multiplayer_server(3000, 10)
	if error == OK:
		globals.logger("Start Server")
		get_parent().get_parent().go()
	else: globals.iprint(["couldnt host, error",error])
