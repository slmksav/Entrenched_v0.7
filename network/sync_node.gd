tool
extends Node
class_name SyncNode,"res://network/syncerclass.png"

signal update_property(from, target, property, value)
signal error_to_update_property(from, path, property, value)

export(NodePath) var _target: NodePath = "" setget set_target
export(bool) var sync_global_position: bool = false setget set_sync_global_position
export(bool) var sync_global_rotation: bool = false setget set_sync_global_rotation
export(PoolStringArray) var sync_data_array: PoolStringArray = []
export(Array, Dictionary) var sync_data_childs: Array = []

var is_master: bool = false
var target: Node


func set_target(new_target: NodePath):
	_target = new_target
	target = get_node_or_null(new_target)
	property_list_changed_notify()


func set_sync_global_rotation(value: bool):
	sync_global_rotation = value
	_desactivated_process()


func set_sync_global_position(value: bool):
	sync_global_position = value
	_desactivated_process()



func _get_configuration_warning():
	if _target == "":
		return "You must assign an async node target"
	return ""




func _ready():
	if Engine.is_editor_hint(): return
	
	target = get_node_or_null(_target)
	
	set_pause_mode(PAUSE_MODE_PROCESS)
	
	assert(target != null)
	
	if sync_data_childs.size() > 0:
		for i in range(sync_data_childs.size()):
			assert(sync_data_childs[i].size() == 2, "It can only have 2 values, 1 path (NodePath), and one values ​​(PoolStringArray)")
			assert(sync_data_childs[i].has("path"), "must have an argument that is called path and that is of type NodePath")
			assert(typeof(sync_data_childs[i]["path"]) == TYPE_NODE_PATH and sync_data_childs[i]["path"].is_empty(), "path must be of type NodePath or cannot be empty")
			assert(_target != sync_data_childs[i]["path"], "path must be different from the target path")
			
			assert(sync_data_childs[i].has("values"), "must have a values ​​key")
			assert(typeof(sync_data_childs[i]["values"]) == TYPE_STRING_ARRAY, "values ​​must be of type PoolStringArray")
			assert(sync_data_childs[i]["values"].size() > 0 and sync_data_childs[i]["values"].size() < 4, "the size of values ​​must be greater than 1 and less than 4")
			
			for v in sync_data_childs[i]["values"]:
				var value = get_node(sync_data_childs[i]["path"]).get(v)
				assert(typeof(value) != TYPE_OBJECT, "the value cannot be of type Object")
				assert(typeof(value) != TYPE_NODE_PATH, "the value cannot be of type NodePath")
				assert(typeof(value) != TYPE_RID, "the value cannot be of type RID")
				assert(typeof(value) != TYPE_NIL, "the value cannot be of type Nil")
			
	
	Multiplayer.connect("update_status", self, "_on_multiplayer_update_status")
	
	_desactivated_process()
	
	if not Multiplayer.is_online_mode():
		set_process(false)
	elif Multiplayer.status == Multiplayer.AWAITING_CONNECTION or Multiplayer.status == Multiplayer.AWAITING_AUTH:
		set_process(false)
		yield(Multiplayer, "update_status")
		if Multiplayer.status == Multiplayer.CONNECTED:
			set_process(true)
			if not target.is_network_master():
				target.set_process_input(false)
				target.set_process_unhandled_input(false)
				target.set_process_unhandled_key_input(false)
	
	set_process_input(false)
	set_process_unhandled_input(false)
	set_process_unhandled_key_input(false)
	set_physics_process(false)


func _physics_process(delta: float):
	if Engine.is_editor_hint(): return
	
	var data_send: Dictionary = {}
	var data_childs: Array = []
	
	#if sync_global_position: data_send["global_position"] = target.global_position
	#if sync_global_rotation: data_send["global_rotation"] = target.global_rotation
	
	# will be sent through a different rpc call
	if sync_global_position or sync_global_rotation:
		var data_rot_pos: Dictionary = {}
		if sync_global_position: data_rot_pos["global_position"] = target.global_position
		if sync_global_rotation: data_rot_pos["global_rotation"] = target.global_rotation
		rpc_unreliable("_remote_update_pos_rot", data_rot_pos)
	
	var target_data_size: int = sync_data_array.size() 
	var childs_data_size: int = sync_data_childs.size()
	
	if childs_data_size > 0 or target_data_size > 0:
		if target_data_size > 0:
			for i in sync_data_array:
				data_send["target"][i] = target.get(i)
		
		
		if childs_data_size > 0:
			for i in sync_data_childs:
				var data_child: Dictionary = {}
				var child_target: Node = get_node(i["path"])
				
				data_child["path"] = i["path"]
				for v in i["values"]: data_child[v] = child_target.get(v)
				data_childs.append(data_child)
			data_send["childs"] = data_childs
		
		rpc_unreliable("_remote_sync_data", data_send)
	


func set_value(target: Node, property: String, value, deferred: bool = false):
	if Engine.is_editor_hint(): return
	var target_path: NodePath = target.get_path()
	rpc("_updated_value", target_path, property, value, deferred)


remote func _updated_value(target_path: NodePath, property: String, value, deferred: bool = false):
	var target: Node = get_node_or_null(target_path)
	var from: int = get_tree().get_rpc_sender_id()
	
	if target == null:
		emit_signal("error_to_update_property", from, target_path, property, value)
		return
	
	if deferred: target.set_deferred(property, value)
	else: target.set(property, value)
	
	emit_signal("update_property", from, target, property, value)


remote func _remote_sync_data(sync_data: Dictionary):
	if sync_data.has("target"):
		for i in sync_data["target"].keys():
			target.set(i, sync_data["target"][i])
	
	if sync_data.has("childs"):
		for d in sync_data["childs"]:
			var targetchild: Node = get_node_or_null(d["path"])
			if targetchild == null: continue
			for v in d["values"].keys():
				targetchild.set(v, d["values"][v])


remote func _remote_update_pos_rot(data: Dictionary):
	for v in data.keys():
		target.set(v, data[v])


func _desactivated_process():
	if Engine.is_editor_hint(): return
	if (sync_data_array.size() == 0 and not sync_global_position and not sync_global_rotation) and Multiplayer.is_online_mode():
		set_process(false)
	else: set_process(true)


func _on_multiplayer_update_status(new_status: int):
	if new_status != Multiplayer.CONNECTED:
		set_process(false)
	else: set_process(true)

