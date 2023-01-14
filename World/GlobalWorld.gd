tool
extends Node
class_name GlobalWorld

signal spawn_player(player, is_client)
signal spawn_enemy(enemy)

signal rain(is_active)

export(String) var world_name: String = ""
export(Array, NodePath) var players_spawn_points: Array = []
export(bool) var rain_active: bool = true setget set_rain_active
export(bool) var day_cycle_active: bool = true setget set_day_cycle_active
export(Dictionary) var enemies: Dictionary = {}
export(Array, NodePath) var spaw_enemy_points: Array = []
export(PackedScene) var player: PackedScene = null setget set_player
export(NodePath) var _node_to_instance: NodePath
export(NodePath) var fog_manager setget set_fog_manager

var _fog_manager: Node2D
var fogs: Array = []
var rain: Node = null
var day_cycle: CanvasModulate
var send_multiplayer_data: bool = false
var players_in_world: Array = []

onready var node_to_instance: Node = get_node_or_null(_node_to_instance)


func set_rain_active(value: bool):
	rain_active = value
	emit_signal("rain", rain_active)
	
	if rain != null:
		globals.logger("setting the rain on %s" % value, true)
		rain.raining = value
	else: globals.logger("Rain turns on or off when you start the game", true)



func set_day_cycle_active(value: bool):
	day_cycle_active = value



func set_player(new_scene: PackedScene):
	player = new_scene
	update_configuration_warning()



func set_fog_manager(new_manager: NodePath):
	fog_manager = new_manager
	_fog_manager = get_node_or_null(new_manager)
	
	if _fog_manager != null: print_debug("New Fog Manager: %s" % _fog_manager.name)
	else: print_debug("Fog Manager is empty")
	property_list_changed_notify()



func _get_configuration_warning() -> String:
	if player == null:
		return "You must assign the player scene in the world properties"
	return ""



func _get_property_list() -> Array:
	var properties: Array = []
	
	if fog_manager != "":
		properties.append({
			"name": "fog_visibility",
			"type": TYPE_REAL,
			"hint": PROPERTY_HINT_RANGE,
			"usage": PROPERTY_USAGE_EDITOR
		})
	
	
	return properties



func _get(property: String):
	match property:
		"fog_visibility":
			return _fog_manager.modulate.a
	
	return null



func _set(property: String, value) -> bool:
	match property:
		"fog_visibility":
			_fog_manager.modulate.a = value
			property_list_changed_notify()
			return true
	return false



func _init():
	globals.new_world(self)



func _ready():
	if Engine.is_editor_hint(): return
	
	globals.logger("Start %s" % world_name, true)
	
	
	add_to_group("global_world")
	
	Multiplayer.connect("player_connected", self, "_on_player_connected")
	Multiplayer.connect("player_disconnected", self, "_on_player_disconnected")
	Multiplayer.connect("update_multiplayer_mode", self, "_on_update_multiplayer_mode")
	Multiplayer.connect("update_status", self, "_on_udpate_status")
	connect("rain", self, "_on_rain")
	
	
	
	fogs = get_tree().get_nodes_in_group("fog")
	
	if get_tree().get_nodes_in_group("rain").size() > 0:
		rain = get_tree().get_nodes_in_group("rain")[0]
	
	if get_tree().get_nodes_in_group("day_cycle").size() > 0:
		day_cycle = get_tree().get_nodes_in_group("day_cycle")[0]
	
	if Multiplayer.is_dedicated_server:
		if (not Multiplayer.is_online_mode() or Multiplayer.is_host()) and get_tree().get_nodes_in_group("player").size() == 0:
			spawn_player(Vector2.ZERO)
			globals.iprint("added own player")



func _process(delta: float):
	pass



func destroy_node_with_timer(node: Node, time: float):
	yield(get_tree().create_timer(time), "timeout")
	node.queue_free()



func spawn_player(spawn_position: Vector2, name_player: String = "", instance_in_node: Node = null, network_master: bool = false) -> int:
	if player == null: return ERR_INVALID_PARAMETER
	
	var p: Entity = player.instance()
	p.global_position = spawn_position
	if name_player != "" and not Multiplayer.is_online_mode():
		p.set_name("player_" + name_player)
	else:
		p.set_network_master(Multiplayer.local_network_peer, true)
		p.set_name(str(Multiplayer.local_network_peer))
	
	_instance_node(p, instance_in_node)
	
	#globals.camera.relative = p
	
	globals.logger("New Player: " + name_player)
	globals.set_player(p)
	emit_signal("spawn_player", p, false)
	
	return OK



func spawn_new_client(spawn_position: Vector2, client_peer: int, instance_in_node: Node = null) -> int:
	if Multiplayer.multiplayer_mode == Multiplayer.NOT_MULTIPLAYER: return ERR_UNAUTHORIZED
	
	if player == null: return ERR_INVALID_PARAMETER
	
	var p: Entity = player.instance()
	p.global_position = spawn_position
	p.is_client = true
	p.set_network_master(client_peer, true)
	p.set_name("player_" + str(client_peer))
	p.set_process_input(false)
	p.set_process_unhandled_input(false)
	p.set_process_unhandled_key_input(false)
	
	_instance_node(p, instance_in_node)
	
	
	Multiplayer.players[str(client_peer)]["master_node"] = p
	
	if Multiplayer.is_host():
		var instance_in_node_path: String = ""
		if instance_in_node != null: instance_in_node_path = instance_in_node.get_path()
		rpc("_spawn_new_client", client_peer, spawn_position, instance_in_node_path)
	
	globals.logger("New Client in world: %s" % client_peer)
	emit_signal("spawn_player", p, true)
	
	return OK



func spawn_enemy(enemy: String, spawn_position: Vector2, instance_in_node: Node = null, name_use: String = "") -> int:
	if not enemies.has(enemy): return ERR_INVALID_PARAMETER
	
	var e: Entity = enemies[enemy].instance()
	e.global_position = spawn_position
	
	if name_use != "" and Multiplayer.is_online_mode():
		e.set_name(name_use)
	elif Multiplayer.is_host():
		name_use = str(e.get_instance_id())
		e.set_name(name_use)
	
	_instance_node(e, instance_in_node)
	
	emit_signal("spawn_enemy", e)
	
	if Multiplayer.is_host():
		var instance_in_node_path: String = ""
		if instance_in_node != null: instance_in_node_path = instance_in_node.get_path()
		rpc("_remote_spawn_enemy", enemy, spawn_position, name_use, instance_in_node_path)
	
	return OK



func _instance_node(node: Node, in_node: Node):
	if in_node != null: in_node.add_child(node, true)
	else:
		if node_to_instance != null: node_to_instance.add_child(node, true)
		else: add_child(node, true)



func _on_rain(value: bool):
	if Engine.is_editor_hint(): return
	if Multiplayer.is_host():
		rpc("_remote_update_rain", value)



func _on_update_multiplayer_mode(new_mode: int):
	pass



func _on_udpate_status(new_status: int):
	pass



remote func _remote_update_rain(new_value: bool):
	set_rain_active(new_value)



remote func _spawn_new_client(peer: int, spawn_in_position: Vector2, instance_in_node_path: String):
	var instance_in_node: Node = get_node_or_null(instance_in_node_path)
	spawn_new_client(spawn_in_position, peer, instance_in_node)



remote func _remote_spawn_enemy(enemy: String, spawn_position: Vector2, name_use: String, instance_in_node_path: String = ""):
	var instance_in_node: Node = get_node_or_null(instance_in_node_path)
	spawn_enemy(enemy, spawn_position, instance_in_node, name_use)



func _on_player_disconnected(peer: int):
	node_to_instance.get_node("player_" + str(peer)).queue_free()



func _on_player_connected(peer: int):
	return
	if Multiplayer.local_network_peer == peer:
		spawn_player(Vector2.ZERO)
	else:
		spawn_new_client(Vector2.ZERO, peer)

