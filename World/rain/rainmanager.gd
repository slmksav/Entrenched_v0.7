tool
extends Node2D
export(float) var movespeed
export(bool) var raining setget allrain
onready var left=$a
onready var center=$b
onready var right=$c
export(float) var fadespeed
export(float) var normalvol
export(float, 0, 100, 0.1) var rain_chance
var wasready=false
var rain_timer = 600
func _ready():
	wasready=true
	allrain(raining)
func _on_player_updatesprite(input:Vector2):
	var size=get_viewport_rect().size.x*globals.camera.zoom.x
	if abs(input.x)>0:
		position.x-=movespeed*get_process_delta_time()*sign(input.x)
		$a.process_material.gravity.x=10*sign(input.x)
		if position.x>size:
			position.x=0
			globals.iprint("reseting rain","environment")
			var oldcenter=center
			center=left
			var oldright=right
			right=oldcenter
			left=oldright
			setpos(size)
		elif position.x<-size:
			position.x=0
			var oldleft=left
			left=center
			center=right
			right=oldleft
			globals.iprint("reseting rain","environment")
			setpos(size)
	else:
		$a.process_material.gravity.x=0
func setpos(size:float):
	right.position.x=size
	left.position.x=-size
	center.position.x=0
func allrain(emitting):
	raining=emitting
	var setted=0
	while setted<get_children().size():
		if get_child(setted).get_class()=="Particles2D":
			get_child(setted).emitting=emitting
		setted+=1
	if wasready and not Engine.editor_hint:
		if raining:
			$audio.play()
			$audio/tween.interpolate_property($audio,"volume_db",-50,normalvol,fadespeed)
		else:
			globals.iprint($audio/tween.interpolate_property($audio,"volume_db",normalvol,-50,fadespeed))
		$audio/tween.set_active(true)

func _on_tween_tween_completed(_object,_key):
	if not raining:
		$audio.stop()

func _process(delta):
	rain_timer += delta
	if rain_timer >= 600:
		rain_timer = 0
		var rain_roll = rand_range(0, 100)
		if rain_roll <= rain_chance:
			allrain(true)
		else:
			allrain(false)
