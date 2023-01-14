extends weaponcontrol
func _process(_delta):
	if get_parent().lowered:
		if Input.is_action_pressed("aim") and recieve:
			body.aimto=get_parent().get_global_mouse_position()
		else:
			body.aimto=Vector2.ZERO
func _ready():
	smartinput.waitfor(self,"deploy",2)
	smartinput.waitfor(self,"attack",2)
	globals.player.connect("canmove",self,"movereq")
func newinput(event):
	if recieve:
		if event.is_action_pressed("deploy"):
			get_parent().tooglelower()
			return true
		elif event.is_action_pressed("attack") and get_parent().lowered:
			get_parent().attack()
			return true
onready var up=get_parent().get_node("body/uparea") as Area2D
onready var down=get_parent().get_node("body/downarea") as Area2D
onready var body=get_parent().get_node("body")
onready var front=get_parent().get_node("body/front") as Area2D
func movereq(vec:Vector2):
	if get_parent().lowered:
		if vec.y>0:
			var bodies=down.get_overlapping_bodies()
			if bodies.size()>0:
				var possible=body.askforrot(body.rotation+0.1,false)
				if possible==false:
					body.dosound(bodies[0])
					globals.player.moveonframe=false
		if vec.y<0:
			var bodies=up.get_overlapping_bodies()
			if bodies.size()>0:
				var possible=body.askforrot(body.rotation-0.1,false)
				if possible==false:
					body.dosound(bodies[0])
					globals.player.moveonframe=false
		if abs(vec.x)>0:
			if front.get_overlapping_bodies().size()>0:
				body.dosound(front.get_overlapping_bodies()[0])
				globals.player.moveonframe=false
