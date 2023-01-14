extends "res://inventory/inventory_display.gd"

signal closetrade

onready var backbutton: Button = globals.camera.get_node("UI/topleft/back") as Button
var player: Entity
var sider: aligner
func closetrade():
	player.inventory.visible=false
	player.inventory.ontrade=false
	player.canmove=true
	visible=false
	get_parent().get_parent().get_node("bottom/list").visible=true
	inventory.disconnect("updated",self,"display_items")
	sider.scaleview.x=0.5
	backbutton.visible=false
	emit_signal("closetrade")
	backbutton.disconnect("pressed",self,"closetrade")

# Called when the node enters the scene tree for the first time.
func _ready():
	backbutton.connect("pressed",self,"onback")
	ontrade=true
	
	globals.connect("new_player", self, "_on_new_player")
	


func _on_new_player(new_player: Entity):
	player = new_player
	sider = player.get_node("UI/center")


func starttrade(newinventory:Inventory):
	ontrade=true
	player.inventory.ontrade=true
	player.canmove=false
	inventory=newinventory
	player.inventory.visible=true
	player.inventory.normalexcluded=player.inventory.excludeditems
	player.inventory.excludeditems=[]
	player.inventory.display_items()
	inventory.connect("updated",self,"display_items")
	visible=true
	sider.scaleview.x=0.8
	sider.setgui()
	backbutton.visible=true
	get_parent().get_parent().get_node("bottom/list").visible=false
	display_items()
	backbutton.visible=true
	backbutton.connect("pressed",self,"closetrade")

func onback():
	closetrade()


func action():
	takeaction(player.inventory)
