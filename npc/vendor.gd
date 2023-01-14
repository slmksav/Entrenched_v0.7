extends StaticBody2D

onready var player: Player = get_node("/root/GlobalWorld/world/player")
onready var diag: Control = globals.camera.get_node("UI/bottom/dialoguer")
onready var inventory: Inventory = load("res://inventory/inventory.gd").new()
onready var comparer = player.get_node("UI/lefty/comparer")

var stage:int = 0


func _ready():
	randomize()
	inventory.balance = round(rand_range(6,9))


func _on_selectarea_interact():
	stage=0
	diag.talk("vendor","hey my fellow traveler, can i make you interested in these?",["travel","buy","not interested"])
	diag.connect("answer",self,"onanswer")

func onanswer(order):
	match stage:
		0:
			match order:
				0:
					stage+=1
					diag.talk("vendor","no i cant help with that",["ok bye"])
				1:
					comparer.starttrade(inventory)
					enddiag()
				2:
					enddiag()
		1:
			match order:
				0:
					enddiag()
func enddiag():
	stage=0
	$selectarea.enabled = true
	diag.disconnect("answer",self,"onanswer")
	diag.close()
