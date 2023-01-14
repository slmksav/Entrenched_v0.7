tool
extends Node2D

export var color := Color.yellow
export var gui := true setget set_gui

func _physics_process(_delta: float) -> void:
	if (gui && Engine.editor_hint):
		update()

func _draw() -> void:
	if (!gui || !Engine.editor_hint): return
	var children = get_children()
	for i in children.size():
		draw_line(children[i].position, children[(i+1)%children.size()].position, color)

func set_gui(value:bool):
	gui = value
	update()
