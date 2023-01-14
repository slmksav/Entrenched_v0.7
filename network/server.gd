extends Node
signal updated(change)
var maxattempts:int=100
enum types {host,client,notstarted}
var type=types.notstarted
var port:int
var ids=[]
onready var multman:NetworkedMultiplayerENet=NetworkedMultiplayerENet.new()
func startserv(nport)->int:
	var attempts=0
	var error
	while attempts<maxattempts:
		error=multman.create_server(nport,20)
		if error==OK:
			prints("server created succesfully in port",nport)
			type=types.host
			get_tree().network_peer=multman
			port=nport
			get_tree().connect("network_peer_connected",self,"newplayer")
			return OK
		else:
			globals.iprint(["server creation failed, changing port from port",port,"with error",error],"network",true)
			nport+=1
		attempts+=1
	globals.iprint("server creation had enough errors for today","network",true)
	return error
	
func refresh():
	multman.close_connection()
	type=types.notstarted
func connectto(ip:String,toport:int)->int:
	var error=multman.create_client(ip,toport)
	type=types.client
	get_tree().network_peer=multman
	return error
func newplayer(id):
	ids.append(id)
	if type==types.host:
		rpc("playerupdate",ids)
	emit_signal("updated")
remote func playerupdate(newids):
	ids=newids
	emit_signal("updated")
