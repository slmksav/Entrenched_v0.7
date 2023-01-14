extends "res://BehaviorTree/bt_base.gd"

export var target_group:String
export var to_memory:String

func tick(memory, body):
	var nodes = get_tree().get_nodes_in_group(target_group)
	
	if (nodes):
		memory[to_memory] = nodes
		return SUCCESS
	
	return FAILURE
