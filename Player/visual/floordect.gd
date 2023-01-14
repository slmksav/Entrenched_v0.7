extends Area2D
export(NodePath) var tofeet
export(float) var step_interval = 0.8

var step=0
var lastchild:Particles2D
var lastoriginal:Particles2D
var step_timer = 0

onready var feet=get_node(tofeet) as Node2D

func removepartics():
	if lastchild!=null:
		lastchild.queue_free()
		lastchild=null
		lastoriginal=null

func _process(delta):
	step_timer += delta
	# Darken player when over trench
	var bodys = get_overlapping_bodies() as Array
	var in_trench = false
	for body in bodys:
		if body.get_parent().get_name() == "trench":
			$fade.interpolate_property(get_parent(), "modulate", get_parent().modulate, Color(0.5,0.5,0.5), 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
			$fade.start()
			in_trench = true
			break
	if not in_trench:
		$fade.interpolate_property(get_parent(), "modulate", get_parent().modulate, Color(1,1,1), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$fade.start()

func walking():
	if get_parent().walking and not $steps.is_playing() and step_timer >= step_interval:
		step_timer = 0
		var bodys=get_overlapping_bodies() as Array
		if bodys.size()>0:
			var maxz=-120
			var checked=0
			var body:TileMap
			while checked<bodys.size():
				var bodyi:TileMap=bodys[checked].get_parent()
				if bodyi.z_index>maxz and bodyi.tile_set!=null:
					body=bodyi
					maxz=bodyi.z_index
				checked+=1
			if body.has_method("getsound") and body.audios.size()>0:
				var resp=body.getsound(step)
				if resp!=null:
					step=resp[1]
					$steps.stream=resp[0]
					math.disableloop($steps.stream)
					$steps.play()
				else:
					globals.iprint(["body",body.name,"answered null wen asked for sounds"],"environment")
			if body.useparticles:
				var particles=body.get_node("walkpartics") as Particles2D
				if particles!=null and particles!=lastoriginal:
					if lastchild!=null:
						lastchild.queue_free()
					var duplicated=particles.duplicate()
					feet.add_child(duplicated)
					lastchild=duplicated
					lastoriginal=particles
					lastchild.position=Vector2()
			else:
				removepartics()
		else:
			removepartics()
	if lastchild!=null:
		lastchild.emitting=true

