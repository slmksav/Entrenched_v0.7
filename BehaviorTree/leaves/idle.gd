extends "res://BehaviorTree/bt_base.gd"

export var wait_time:int
export var wait_chance:float
export var to_memory:String

func tick(memory:Dictionary, body):
	if memory.has(to_memory) and memory[to_memory] > 0:
		memory[to_memory] -= 1
		body.move_to(Vector2.ZERO)
		return RUNNING
	
	var roll = randf()
	if roll < wait_chance:
		memory[to_memory] = wait_time
		return RUNNING
	
	return SUCCESS
