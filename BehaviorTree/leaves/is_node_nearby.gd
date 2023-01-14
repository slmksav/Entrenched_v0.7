extends "res://BehaviorTree/bt_base.gd"

export var from_memory:String
export var nearby_distance := 100

func tick(memory, body):
	var node = memory[from_memory]
	var distance = node.position.distance_to(body.position)
	if (distance < nearby_distance):
		return SUCCESS
	
	return FAILURE
