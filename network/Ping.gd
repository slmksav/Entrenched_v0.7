extends Node
class_name PingNet


signal ping_update(ping)

enum {
	SERVER,
	CLIENT
}

var ping: float setget, get_ping
var mode: int = -1 setget, get_mode

var time: int
var prev_time: int

var peer: PacketPeerUDP = PacketPeerUDP.new()


func get_ping() -> float:
	return ping


func get_mode() -> int:
	return mode


func _ready():
	set_physics_process(false)
	set_process_input(false)
	set_process_unhandled_input(false)
	set_process_unhandled_key_input(false)


func _process(delta: float):
	if not is_work(): return
	match mode:
		SERVER: _server_ping()
		CLIENT: _client_ping()


func close():
	peer.close()
	mode = -1


func is_work():
	return peer.is_connected_to_host() or peer.is_listening() 


func start_server(port: int) -> int:
	var err: int = peer.listen(port)
	if err == OK:
		mode = SERVER
	return err


func _server_ping():
	if not peer.get_available_packet_count() > 0: return
	
	var ip: String = peer.get_packet_ip()
	var port: int = peer.get_packet_port()
	var data: String = peer.get_packet().get_string_from_ascii()
	if data != "ping": return
	
	peer.set_dest_address(ip, port)
	peer.put_packet("pong".to_ascii())


func start_ping(ip: String, port: int) -> int:
	var err: int = peer.connect_to_host(ip, port)
	if err == OK:
		mode = CLIENT
	
	peer.put_packet("ping".to_ascii())
	return err



func _client_ping():
	while peer.wait() == OK:
		var data: String = peer.get_packet().get_string_from_ascii()
		if data == "pong":
			ping = OS.get_ticks_msec() - time
			time = OS.get_ticks_msec()
			emit_signal("ping_update", ping)
			var error=peer.put_packet("ping".to_ascii())
			if error!=OK:
				globals.iprint(["cant send raw packet, error",error],"network",true)
	ping = OS.get_ticks_msec() - time
	
	if ping >= 999: ping = 999








