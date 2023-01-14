extends Node
onready var player=get_parent().get_node("player")
var botbyid={}
var bots=0
export(NodePath) var toconsole
export(PackedScene) var playerrep
func _ready():
	serverupdate()
	globals.iprint(["connecting to server events with error",server.connect("updated",self,"serverupdate")],"network")
func serverupdate():
	if bots<server.ids.size():
		globals.iprint("server update")
		var newbot=playerrep.instance() as Entity
		if server.type==server.types.host:
			globals.iprint(["connecting to bot with error:",newbot.connect("attacked",self,"onattack",[server.ids[bots]])],"network bots")
			globals.iprint(["connecting to bot with error:",newbot.connect("updated_health",self,"health",[server.ids[bots]])],"network bots")
		get_parent().add_child(newbot)
		newbot.name=str(server.ids[bots])
		botbyid[server.ids[bots]]=newbot
		bots+=1
		globals.iprint(["new bot",newbot])
#this is meant to be called by the server
remote func callonplayer(funcname:String,funcargs:Array,id:int):
	var called:Entity
	if id==get_tree().get_network_unique_id():
		called=globals.player
	else:
		called=botbyid[id]
	globals.iprint(["server called",funcname,"on",called.name],"network")
	called.callv(funcname,funcargs)
#this is meant to be called by clients
remote func callonbot(funcname:String,funcargs:Array):
	if botbyid.has(get_tree().get_rpc_sender_id()):
		botbyid[get_tree().get_rpc_sender_id()].callv(funcname,funcargs)
	else:
		serverupdate()
func onattack(dmg,type,by,bleeding,id):
	globals.iprint("bot was damaged")
	if server.type==server.types.host:
		rpc("callonplayer","damage",[true,dmg,type,by,bleeding],id)
		rpc("callonplayer","set",["health",botbyid[id].health],id)
func health(new_health,id):
	rpc("callonplayer","set",["health",new_health],id)
