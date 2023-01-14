extends Button


func _ready():
	Multiplayer.connect("connection_success", self, "_on_connection_success")
	Multiplayer.connect("connection_failed", self, "_on_connection_failed")


func _pressed():
	$port.suffix=""
	$port.prefix=""
	var err: int = Multiplayer.start_multiplayer_client($ip.text, $port.value)
	if err == OK:
		disabled = true
	else: globals.iprint(["error creating client", err], "network", true)

func _on_connection_success():
	globals.iprint(["connnected!"],"network")
	get_parent().get_parent().go()

func _on_connection_failed():
	globals.iprint(["error connecting"],"network",true)
	disabled=false
