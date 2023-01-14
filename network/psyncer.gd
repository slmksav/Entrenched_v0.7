extends Node
onready var serverman=get_node("/root/GlobalWorld/world/serverman")
func _ready():
	pass
func _process(_delta):
	if server.type==server.types.client:
		serverman.rpc("callonbot","setpos",[get_parent().position])
	else:
		queue_free()
