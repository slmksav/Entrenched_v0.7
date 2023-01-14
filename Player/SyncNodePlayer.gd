tool
extends SyncNode

export(Array, NodePath) var delete_nodes_is_clients: Array = []

func _ready():
	
	if target.is_client:
		globals.logger("Delete Nodes")
		for i in delete_nodes_is_clients:
			get_node(i).queue_free()
	
