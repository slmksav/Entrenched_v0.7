extends "res://BehaviorTree/bt_base.gd"

func tick(memory, body):
	for child in get_children():
		var result = child.tick(memory, body)
		
		if result == SUCCESS or result == RUNNING:
			return SUCCESS
	
	return FAILURE
