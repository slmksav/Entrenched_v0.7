extends "res://BehaviorTree/bt_base.gd"

export var from_memory:String

func tick(memory, body):
	var node = memory[from_memory]
	body.move_to(node.global_position)
	return SUCCESS
