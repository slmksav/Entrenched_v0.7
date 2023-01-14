extends "res://BehaviorTree/bt_base.gd"

func tick(memory, body):
	for child in get_children():
		if child.tick(memory, body) == FAILURE:
			return FAILURE
	
	return SUCCESS
