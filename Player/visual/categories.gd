extends VBoxContainer
export(NodePath) var toplayer
onready var player:AnimationPlayer=get_node(toplayer)
onready var options=get_parent().get_parent().get_node("topright/options")

func _on_head_pressed():
	player.play("focushead")
	options.select("head")


func _on_body_pressed():
	player.play("focusbody")
	options.select("body")

func _on_hair_pressed():
	player.play("focushead")
	options.select("hair")


func _on_acessories_pressed():
	player.play("focusall")
	options.select("extra")
