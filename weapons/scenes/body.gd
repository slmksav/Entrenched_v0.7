extends KinematicBody2D
export(bool) var impactscape
"""if an impact seems to be going in a
direction that allows the body to move then
it will be ignored.
"""
func _ready():
	$impacttimer.connect("timeout",self,"canattack")
	for i in metal:
		math.disableloop(i)
	for i in wood:
		math.disableloop(i)
	for i in torightrays:
		rightrays.append(get_node(i))
	for i in toleftrays:
		leftrays.append(get_node(i))
#impact sounds
export(Array,NodePath) var torightrays
export(Array,NodePath) var toleftrays
var rightrays=[]
var leftrays=[]
export(Array,AudioStream) var metal
export(Array,AudioStream) var wood
export(float) var rotspeed
#the distance of a ray to turn a radian
export(float) var rayperrot=20
export(float) var maxrot
export(float) var minrot
export(float) var diftolerance
#what % of the original impact is bounced
export(float,0,100) var bounciness
var canimpact=true
func canattack():
	canimpact=true
func askforrot(torot:float,canmax:bool=true)->bool:
	if canmax:
		torot=clamp(torot,minrot,maxrot)
	else:
		if torot>maxrot or torot<minrot:
			return false
	var checkdist=math.getabsdif(torot,rotation)*rayperrot
	var rays:Array
	if math.getabsdif(rotation,torot)<diftolerance:
		rotation=torot
		return true
	if torot>rotation:
		rays=rightrays
		for i in rays:
			i.cast_to.y=checkdist+5
	if torot<rotation:
		rays=leftrays
		for i in rays:
			i.cast_to.y=-checkdist-5
	for ray in rays:
		ray.force_raycast_update()
		if ray.is_colliding():
			var body=ray.get_collider() as KinematicBody2D
			if is_instance_valid(body) and canimpact:
				var force=defaultimpact*(abs(inersia)/defaultinersia)
				var side=math.signdifference($front.global_position.x,body.get_node("masscenter").global_position.x)
				var up=math.signdifference($front.global_position.y,ray.get_collision_point().y)
				if impactscape and ((up==1 and rotation>torot) or (up==-1 and rotation<torot)):
					rotation=torot+(math.signdifference(rotation,torot)+0.1)
					globals.iprint("scaping from the impact, its in the wrong direction","combat")
					return true
				var move=-force*side*up
				if abs(move)>0:
					print(move)
					countdown()
					body.countdown()
					body.askforrot(body.rotation+move)
					askforrot(rotation+(move*(bounciness/100)))
					if not is_instance_valid(body):return false
					#effects area
					if torot>rotation:
						$upimpact.show()
					else:
						$downimpact.show()
					dosound(body)
					inersia=0
			return false
	rotation=torot
	return true
func countdown():
	canimpact=false
	$impacttimer.start()
var aimto:Vector2=Vector2()
var inersia=0
export(float) var defaultimpact
export(float) var defaultinersia
export(float) var inersiaperframe
func _process(delta):
	if get_parent().lowered and get_parent().visible:
		if aimto!=Vector2.ZERO:
			var pos=aimto
			if get_parent().visual!=null:
				pos.x*=-sign(get_parent().visual.scale.x)
			var angle=-pos.angle_to_point(global_position)
			if sign(math.signdifference(rotation,angle))!=sign(inersia):
				inersia=0
			inersia+=inersiaperframe*delta*math.signdifference(rotation,angle)
			movetorot(angle,delta,1)
		else:
			if canimpact:
				movetorot(0,delta,0.5)
			inersia=0
#moves a little in the direction to a rotation, and blocks in place if close enough
func movetorot(target:float,delta:float,speedmult:float=1):
	var defspeed=rotspeed*delta
	if math.getabsdif(target,rotation)>defspeed:
		askforrot(rotation+(rotspeed*speedmult*delta*-math.signdifference(rotation,target)))
	else:
		rotation=target
export(float) var rotfix
#the amount to rotate in case 2 objects completely
#overlap, kinda a last resource.
func _on_internalpike_body_entered(body):
	if body!=self:
		globals.iprint("forcing body separation!","combat",true)
		var dir=math.signdifference($internalpike.global_position,body.get_node("internalpike").global_position)
		body.rotation+=rotfix*dir
		rotation-=rotfix*dir
func dosound(body:KinematicBody2D):
	var sfx=get_parent().get_node("sfx")
	if $pikeend.get_overlapping_areas().has(body.get_node("wood")):
		sfx.stream=math.choose(wood)
	if $pikeend.get_overlapping_areas().has(body.get_node("metal")):
		sfx.stream=math.choose(metal)
	sfx.smartplay()
