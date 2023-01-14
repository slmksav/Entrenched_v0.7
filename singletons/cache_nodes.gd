extends Node

signal node_found(node)

var cache: Dictionary = {}
var t: Thread = Thread.new()


func _exit_tree():
	if t.is_active(): t.wait_to_finish()


func get_node_by_name(node_name: String, use_threads: bool = false) -> Node:
	if cache.has(node_name): return cache[node_name].get_ref()
	
	var node: Node = null
	
	if use_threads:
		t.start(self, "_find_node", {"node_name": node_name, "owner": get_tree().get_root()})
		node = yield(self, "node_found")
	else: node = _find_node({"node_name": node_name, "owner": get_tree().get_root()})
	
	if node != null:
		cache[node_name] = weakref(node)
		return node
	else: return null



func clear_chache():
	cache.clear()



func remove_node_by_name(node_name: String) -> bool:
	return cache.erase(node_name)



func _find_node(data: Dictionary) -> Node:
	if data["node_name"] == data["owner"].name: 
		emit_signal("node_found", data["owner"])
		return data["owner"]
	for c in data["owner"].get_children():
		var res: Node = _find_node({"node_name": data["node_name"], "owner": data["owner"]})
		if res != null: return res
	
	if data["owner"] == get_tree().get_root():
		emit_signal("node_found", null)
	return null

