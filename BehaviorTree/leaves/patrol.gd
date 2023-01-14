extends "res://BehaviorTree/bt_base.gd"

func tick(memory, body):
	if (!memory.has("patrol_route")): return FAILURE
	
	if (!memory.has("patrol_index")):
		memory["patrol_index"] = 0
	
	var distance_to_next = (body as Node2D).global_position.distance_to(memory.patrol_route[memory.patrol_index])
	if (distance_to_next < 5):
		memory.patrol_index += 1
		memory.patrol_index = memory.patrol_index % memory.patrol_route.size()
	
	body.move_to(memory.patrol_route[memory.patrol_index])
	
	return SUCCESS
