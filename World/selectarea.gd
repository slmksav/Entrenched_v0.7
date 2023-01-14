extends Area2D
signal interact
var enabled:bool=true
var money:int=10
var conected=false
func _ready():
	visible=false
	connect("body_entered",self,"bodyentered")
	connect("body_exited",self,"bodyout")
func bodyentered(_body):
	if enabled:
		conected=true
		visible=true
		interacter.enteredselector(self)
func bodyout(_body):
	visible=false
	interacter.outofselector()
func changed():
	if enabled:
		visible=interacter.actual==self
func _unhandled_input(event):
	if interacter.actual==self and event.is_action_pressed("interact"):
		emit_signal("interact")
		visible=false
		enabled=false
