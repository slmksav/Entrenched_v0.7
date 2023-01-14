extends "res://BehaviorTree/bt_base.gd"

export var enabled := false
onready var child := get_child(0)
onready var body := get_parent()

var memory := {}

func tick(_memory = null, _body = null):
	if (enabled):
		child.tick(memory, body)
