extends Node


func _ready():
	if  not globals.is_release():
		UserData.auto_login()
		yield(Auth, "login")
	
	var args: Dictionary = globals.args
	var force_dedicated_server: bool = false
	
	for a in OS.get_cmdline_args():
		if a == "force_dedicate_server_mode":
			force_dedicated_server = false
			break
	
	if OS.has_feature("Server") or force_dedicated_server:
		OS.set_window_title("Dedicated Server Mode")
		
		print("Start Server Mode")
		
		if (args.has("optimize_server") and math.is_arg(args["optimize_server"])) or (globals.is_release() and OS.has_feature("Server")):
			Multiplayer.optimize_server()
		
		if args.has("server_command_port"): ServerComand.port = args["server_command_port"].to_int()
		
		ServerComand.start()
		
		get_tree().call_deferred("change_scene", globals.maps[0])
		queue_free()
	else:
		get_tree().call_deferred("change_scene", "res://MainMenu.tscn")
		queue_free()
