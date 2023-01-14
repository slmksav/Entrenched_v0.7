extends onhandrep
class_name Melee
export(bool) var needsattack
"""if false, the weapon produces damage even
without clicking"""
export(int) var damage = 10
export(float, 0, 1000, 0.1) var durability: float = 100
export(NodePath) onready var anim = get_node(anim) # as AnimationPlayer
export(String) var anim_deploy_weapon: String = ""
export(NodePath) var _hit_box: NodePath="body/damager"
onready var hit_box: damager = get_node(_hit_box) as Area2D
export(float) var attackspeed=12
export(float) var attackcool=0.5
onready var max_durability: float = durability
var lowered: bool = false
export(AudioStream) var thrustsound
export(Array,NodePath) var hitboxs
func _ready():
	#check for requiered parameters
	if visual!=null:
		connect("visibility_changed",self,"vis")
	$body/damager.set_deferred("monitoring",false)
	set_process(false)
	hitboxdisable(true)
	assert(anim_deploy_weapon != "", "you must set the name of the animation to deploy it")
	assert(hit_box != null, "")
	$stopattack.connect("timeout",self,"attacktimed")
	anim.connect("animation_finished",self,"animfinish")
	$body/tween.connect("tween_completed",self,"tweenend")
	if user!=null:
		hit_box.exeptions.append(user)
var attacking=false
#the position of the body before starting the attack
var defpos:Vector2
var canattack=true

func animfinish(animname:String):
	if animname=="getready" and lowered:
		hitboxdisable(false)
func hitboxdisable(disabled:bool):
	for i in hitboxs:
		get_node(i).disabled=disabled
var targetrot=0
export(float) var maxdistance
#the maximum distnace before the attack is considered
#impossible
func _physics_process(_delta):
	if attacking:
		var bodies:Array=$body/front.get_overlapping_bodies()
		if $body.position.distance_to(defpos)<maxdistance and bodies.size()==0:
			var rot=$body.rotation
			var viscale=1
			if visual!=null:
				viscale=visual.scale.x
			var vec=Vector2(-attackspeed,0).rotated(rot)
			vec.x*=sign(viscale)
			$body.move_and_slide(vec)
		else:
			$stopattack.emit_signal("timeout")
			$stopattack.stop()
			if bodies.size()>0:
				$body.dosound(bodies[0])
func aim(to):
	if visual!=null and visual.scale.x<1:
		to.x=global_position.x-(math.getabsdif(global_position.x,to.x))
	$body.targetrot=clamp(global_position.angle_to_point(to),$body.minrot,$body.maxrot)

func tooglelower():
	lowered = not lowered
	set_process(lowered)
	if not needsattack:
		$body/damager.set_deferred("monitoring",lowered)
	if lowered:
		anim.play(anim_deploy_weapon)
		if visual!=null:
			visual.dovertical = false
		if globals.player!=null and user==globals.player:
			globals.player.movespeed = globals.player.defmovespeed / 1.5
	else:
		$body.rotation=0
		targetrot=0
		if attacking:
			$body.position=defpos
		hitboxdisable(true)
		anim.play_backwards(anim_deploy_weapon)
		if visual!=null:
			visual.dovertical = true
		if user==globals.player:
			globals.player.movespeed = globals.player.defmovespeed
func vis():
	if visible:
		visual.dovertical=not lowered
		if lowered:
			if globals.player!=null and user==globals.player:
				globals.player.movespeed = globals.player.defmovespeed / 1.5
	else:
		visual.dovertical=true
		globals.player.movespeed = globals.player.defmovespeed
func attack():
	if lowered and canattack and $anims.current_animation=="":
		if needsattack:
			hit_box.set_deferred("monitoring", true)
		defpos=$body.position
		attacking=true
		canattack=false
		$stopattack.start()
		$sfx.setaudio(thrustsound)
		$sfx.play()
func attacktimed():
	$stopattack.stop()
	if needsattack:
		hit_box.set_deferred("monitoring", false)
	attacking=false
	$body/tween.interpolate_property($body,"position",$body.position,defpos,attackcool)
	$body/tween.set_active(true)
func tweenend(object:Object,property:NodePath):
	if object==$body and property==":position":
		canattack=true
func set_hand(pos: Vector2):
	get_parent().position = pos
func customout():
	visual.dovertical = true


