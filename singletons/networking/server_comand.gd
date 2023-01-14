extends Node

var command_server: WebSocketServer = WebSocketServer.new()
var command_hostory: PoolStringArray = []
var password: String = ""

var port: int = 2233

var commands: Dictionary = {
	"players_connected": funcref(Multiplayer, "get_players_connected"),
	"port": funcref(Multiplayer, "get_port")
}


func _ready():
	command_server.connect("data_received", self, "_on_data_recived")


func start() -> int:
	var err: int = command_server.listen(port)
	if err == OK: globals.logger("Adm Starter - Error code: %s" % err, false)
	else: globals.logger_err("Adm Starter error- Error code: %s" % err, false)
	return err


func execute_commands(commands: PoolStringArray, id: int):
	var commands_result: String
	
	for c in commands:
		pass
		
	



func _on_data_recived(id: int):
	var data: Dictionary = JSON.parse(command_server.get_peer(id).get_packet().get_string_from_ascii()).get_result()
	execute_commands(data["commands"], id)
	
	
	
	




