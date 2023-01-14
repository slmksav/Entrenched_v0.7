extends "res://BehaviorTree/bt_base.gd"

func tick(memory, body):
	body.move_to(Vector2.ZERO)
	return SUCCESS
