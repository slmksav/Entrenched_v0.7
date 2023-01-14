extends "res://BehaviorTree/bt_base.gd"

export var from_memory:String
export var to_memory:String

func tick(memory, body):
	var nodes:Array = memory[from_memory]
	
	var closest_distance = (nodes[0] as Node2D).global_position.distance_squared_to(body.global_position)
	var closest_node = nodes[0]
	
	for node in nodes:
		var distance = (node as Node2D).global_position.distance_squared_to(body.global_position)
		if (distance < closest_distance):
			closest_distance = distance
			closest_node = node
	
	memory[to_memory] = closest_node
	
	return SUCCESS
