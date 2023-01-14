tool
extends Node

export(NodePath) var server_name_path: NodePath = ""
export(NodePath) var players_path: NodePath = ""
export(NodePath) var ping_path: NodePath = ""
export(NodePath) var lock_path: NodePath = ""
#export(NodePath) var region_path: NodePath = ""
export(NodePath) var join_server_path: NodePath = ""

var server_ip: String
var server_port: int
var server_name: String
var players_server: int
var max_players: int
var has_password: bool
var region: String
var ping: float

var game_info: Dictionary = {}

var ping_node: PingNet = PingNet.new()

onready var server_name_label: Label = get_node_or_null(server_name_path)
onready var players_label: Label = get_node_or_null(players_path)
onready var ping_label: AnimatedSprite = get_node_or_null(ping_path)
onready var lock_label: AnimatedSprite = get_node_or_null(lock_path)
#onready var region_label: Label = get_node_or_null(region_path)
onready var join_server: Button = get_node_or_null(join_server_path)


func set_server_info(_server_name: String, _players_server: int, _max_players: int, _has_password: bool, _region: String, ip: String, port: int, _game_info: Dictionary):
	server_name = _server_name
	players_server = _players_server
	max_players = _max_players
	region = _region
	has_password = _has_password
	server_ip = ip
	server_port = port
	game_info = _game_info
	
	if not is_inside_tree(): return



func get_ping() -> float:
	return ping


func set_ping(ping: float):
	ping_label.text = "%ms" % ping


func _get_configuration_warning() -> String:
	return ""


func _ready():
	assert(server_name_label != null)
	assert(players_label != null)
	assert(ping_label != null)
	#assert(region_label != null)
	assert(join_server != null)
	
	add_to_group("servers_information")
	
	add_child(ping_node, true)
	ping_node.connect("ping_update", self, "_on_ping_updated")
	ping_node.start_ping(server_ip, 578)
	
	server_name_label.text = server_name
	players_label.text = "%s/%s" % [players_server, max_players]
	if players_server == max_players: players_label.text += " FULL"
	#region_label.text = region
	
	Multiplayer.connect("connection_success", self, "_on_connect_succes")
	Multiplayer.connect("connection_failed", self, "_on_connection_failed")


func disabled_join():
	join_server.disabled = true


func enabled_join():
	join_server.disabled = false


func joint_to_server():
	return
	
	Multiplayer.start_multiplayer_client(server_ip, server_port)
	get_parent().notify_joint(self)




func _on_ping_updated(new_ping: int):
	if new_ping <= 80: ping_label.animation = "ping1"
	elif new_ping > 80 and new_ping <= 120: ping_label.animation = "ping2"
	elif new_ping > 120 and new_ping <= 200: ping_label.animation = "ping3"
	elif new_ping > 200 and new_ping <= 300: ping_label.animation = "ping4"
	else: ping_label.animation = "ping5"



