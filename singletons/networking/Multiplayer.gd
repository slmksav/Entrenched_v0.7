extends Node

signal http_get_request(result, response_code, headers, json_result)

# Multiplayer Signal

signal chat_message(message, from, to, message_type)
# Multiplayer Server signal
signal multiplayer_server_starter(port, max_players, compression_mode)
signal multiplayer_server_stoped
signal player_connected(peer)
signal player_disconnected(peer)
signal client_sync(peer)
# Multiplayer Client signal
signal multiplayer_client_starter(ip, port)
signal multiplayer_client_stoped
signal disconnected_server
signal connection_success
signal connection_failed
signal client_auth_success(extra_data)
signal client_auth_failed(reason, reason_failed)

signal update_status(new_status)
signal update_multiplayer_mode(new_mode)

enum {
	NOT_MULTIPLAYER
	CLIENT,
	SERVER
}

enum {
	NIL,
	AWAITING_CONNECTION,
	AWAITING_AUTH,
	CONNECTED,
	ERR_CONNECTED
	LISTENING_CONNECTION
}

enum MESSAGE_TYPE {
	GLOBAL,
	PRIVATE
}


var args: Dictionary

var _http_request: HTTPRequest = HTTPRequest.new()
var _web_socket: WebSocketMultiplayerPeer
var _enet: NetworkedMultiplayerENet = NetworkedMultiplayerENet.new()
var port: int setget, get_port
var max_players: int setget, get_max_players
var compression_mode: int = NetworkedMultiplayerENet.COMPRESS_ZSTD
var local_network_peer: int setget, get_local_network_peer
var multiplayer_mode: int = NOT_MULTIPLAYER setget set_multiplayer_mode, get_multiplayer_mode; func get_multiplayer_mode() -> int: return multiplayer_mode
var status: int = NIL setget set_status

sync var players: Dictionary = {}
var player_collections: Dictionary = {}
var chat_history: PoolStringArray = []
var ping: int
var ping_node: PingNet = PingNet.new()
var is_dedicated_server: bool = false

var anti_cheat: Node = preload("res://singletons/networking/anti_cheat.gd").new()
var player_verify: Node = preload("res://singletons/networking/player_verification.gd").new()
var sync_player_server: Node = preload("res://singletons/networking/sync_player_server.gd").new()



func get_port() -> int:
	return port



func get_max_players() -> int:
	return max_players



func get_local_network_peer() -> int:
	return local_network_peer



func set_multiplayer_mode(new_multiplayer_mode: int):
	multiplayer_mode = new_multiplayer_mode
	set_status(NIL)
	emit_signal("update_multiplayer_mode", multiplayer_mode)



func set_status(new_status: int):
	status = new_status
	emit_signal("update_status", new_status)



func get_players_connected() -> int:
	return players.size()


func _ready():
	args = math.get_args()
	if (args.has("dedicated_server") and math.is_arg(args["dedicated_server"])) or OS.has_feature("Server"):
		is_dedicated_server = true
	
	set_pause_mode(PAUSE_MODE_PROCESS)
	
	_http_request.connect("request_completed", self, "_on_request_completed")
	_http_request.set_name("multiplayer_http_request")
	add_child(_http_request, true)
	
	ping_node.connect("ping_update", self, "_on_ping_update")
	add_child(ping_node, true)
	
	_enet.connect("peer_connected", self, "_on_peer_connected")
	_enet.connect("peer_disconnected", self, "_on_peer_disconnected")
	_enet.connect("connection_succeeded", self, "_on_connection_success")
	_enet.connect("connection_failed", self, "_on_connection_failed")
	_enet.connect("server_disconnected", self, "_on_server_disconnected")
	
	add_child(anti_cheat, true)
	add_child(sync_player_server, true)




# Custom Fuctions


func optimize_server():
	Engine.set_target_fps(20)
	VisualServer.set_render_loop_enabled(false)



func is_host() -> bool:
	return bool(multiplayer_mode == SERVER)



func is_client() -> bool:
	return bool(multiplayer_mode == CLIENT)



func is_online_mode() -> bool:
	return bool(multiplayer_mode != NOT_MULTIPLAYER)



# Server

func start_multiplayer_server(_port: int = 3000, _max_players: int = 10) -> int:
	if _max_players > 4095:
		globals.logger_err("max_players exceeded the maximum number of simultaneous connections that Enet supports (4095), therefore the number of players will be reduced to 4095")
		_max_players = 4095
	
	var err: int = _enet.create_server(_port, _max_players)
	
	if err != OK:
		globals.logger_err("The server could not be initialized. Error code: %s" % err)
		return err
	
	_enet.set_compression_mode(compression_mode)
	
	port = _port
	max_players = _max_players
	
	get_tree().set_network_peer(_enet)
	local_network_peer = get_tree().get_network_unique_id()
	
	emit_signal("multiplayer_server_starter", port, max_players, compression_mode)
	
	var error=ping_node.start_server(578)
	if error!=OK:
		prints("error creating server",error)
	
	set_status(LISTENING_CONNECTION)
	set_multiplayer_mode(SERVER)
	
	return OK



func stop_multiplayer_server(wait_sec: int = 60):
	_enet.close_connection(wait_sec)
	ping_node.close()
	emit_signal("multiplayer_server_stoped")



# Client

func start_multiplayer_client(ip: String, port: int) -> int:
	var err: int = _enet.create_client(ip, port)
	
	if err != OK:
		globals.logger_err("The client could not be initialized. Error code: %s" % err)
		return err
	
	_enet.set_compression_mode(compression_mode)
	
	get_tree().set_network_peer(_enet)
	local_network_peer = get_tree().get_network_unique_id()
	
	set_status(AWAITING_CONNECTION)
	set_multiplayer_mode(CLIENT)
	
	return OK

# 

func chat_message(message: String, to: int = 0):
	if multiplayer_mode == CLIENT:
		rpc_id(1, "chat_message_recived_server", message, to)
	elif multiplayer_mode == SERVER:
		if to == 0:
			rpc("chat_message_recived", message)
		else: rpc_id(to, "chat_message_recived", message)



remote func chat_message_recived_server(message: String, to: int):
	var from: int = get_tree().get_rpc_sender_id()
	var message_type: int
	var message_history: String = ""
	
	if to != 0:
		message_history += "[PRIVATE] - from:%s to:%s " % [from, to]
		message_type = MESSAGE_TYPE.PRIVATE
		rpc_id(to, "chat_message_recived", message, from, MESSAGE_TYPE.PRIVATE)
	else:
		message_history += "[GLOBAL] - from:%s" % [from]
		message_type = MESSAGE_TYPE.GLOBAL
		rpc("chat_message_recived", message, MESSAGE_TYPE.GLOBAL)
	
	emit_signal("chat_message", message, from, to, message_type)
	
	chat_history.append(message_history)



remote func chat_message_recived(message: String, from: int, message_type: int):
	emit_signal("chat_message", message, from, 0, message_type)




# Signals


func _on_peer_connected(new_player: int):
	globals.logger("New Peer Connected: %s" % new_player)
	players[str(new_player)] = {}
	emit_signal("player_connected", new_player)



func _on_peer_disconnected(left_player: int):
	emit_signal("player_disconnected", left_player)
	players.erase(str(left_player))
	
	if not is_host(): player_collections.erase(str(left_player))



func _on_connection_success():
	ping_node.start_ping(_enet.get_peer_address(1), 578)
	set_status(CONNECTED)
	emit_signal("connection_success")
	
	var data_send: Dictionary = {
		"username": UserData.user_name,
		"player_id": UserData.player_id
		# other data
	}
	
	sync_player_server.rpc_id(1, "remote_sync_player_data_server", data_send)


func _on_connection_failed():
	set_status(ERR_CONNECTED)
	set_multiplayer_mode(NOT_MULTIPLAYER)
	_enet.close_connection(0)
	emit_signal("connection_failed")


func _on_server_disconnected():
	ping_node.close()
	local_network_peer = 0
	set_status(NIL)
	set_multiplayer_mode(NOT_MULTIPLAYER)
	emit_signal("disconnected_server")



#

func send_player_state(state: Dictionary):
	state["T"] = OS.get_system_time_msecs()
	
	if not is_host():
		rpc_id(1, "server_update_player_state", state)
	else:
		rpc("server_update_player_state", state)



remote func server_update_player_state(state: Dictionary):
	pass








