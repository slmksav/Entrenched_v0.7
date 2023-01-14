tool
extends Node

const ServerInfo: PackedScene = preload("res://UI/ServerBrowser/ServerInfo.tscn")

export(NodePath) var add_to_node: NodePath = ""
export(float, 10, 1000, 0.1) var scaner_time: float = 20 setget set_scaner_time

var scaner: Timer = Timer.new()


func set_scaner_time(new_time: float):
	if scaner_time < 10: return
	scaner_time = new_time
	
	if not Engine.is_editor_hint(): scaner.wait_time = scaner_time


func notify_joint(server_info: Node):
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, "servers_information", "disabled_join")



func notify_failed_joint():
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, "servers_information", "enabled_join")



func add_new_server(server_data: Dictionary):
	var s_info: Node = ServerInfo.instance()
	s_info.set_server_info(server_data["server_name"], server_data["players_connected"], server_data["max_players"], 
	server_data["region"], server_data["ip"], server_data["port"])
	
	if get_node_or_null(add_to_node) != null: get_node(add_to_node).add_child(s_info)
	else: add_child(s_info)



func _ready():
	scaner.wait_time = scaner_time
	scaner.autostart = true
	scaner.connect("timeout", self, "_on_timeout")



func _on_timeout():
	pass


