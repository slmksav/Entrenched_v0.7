tool
extends AnimatedSprite

signal animupdate
signal walking
var walking=false
export(Vector2) var inputtest
export(bool) var reportanims=false
export(bool) var reportvectors=false
export(bool) var active setget actived
export(bool) var dovertical
export(bool) var roundvec = true
export(bool) var bloody setget doblood
export(Array,NodePath) var blood
export(Array,NodePath) var syncs
export(float, 0, 2) var inputtreshhold
export(Dictionary) var player_cosmetics
export(NodePath) var cosmetics
"""a direction used by default, 1,0 will result in
the entity looking to the left when the game runs, 0,0 means
keep whatever the scene says."""
export var onstart:Vector2
var lastvector: Vector2 = Vector2()
var puke_particles

func doblood(value: bool):
	bloody = value
	var synced = 0
	while synced < blood.size():
		get_node(blood[synced]).visible = value
		synced += 1

func _init():
	set_process(false)


func _ready():
	set_process(false)
	if onstart!=Vector2.ZERO:
		updatesprite(onstart)
		updatesprite(Vector2(0,0))
	puke_particles = get_parent().get_node("PukeParticles")

func _process(_delta):
	if Engine.editor_hint:
		updatesprite(inputtest)
	else:
		set_process(false)

func _physics_process(_delta):
	for cosmetic in player_cosmetics.keys():
		get_node(cosmetics).get_node(cosmetic).visible = player_cosmetics[cosmetic]
		# Sync sickness
		if cosmetic == "diseased" and get_parent().get_name() == "player":
			var a = get_parent().sick/50
			if a > 1:
				a = 1
			get_node(cosmetics).get_node(cosmetic).modulate = Color(1, 1, 1, a)

func actived(value: bool):
	active = value
	set_process(active)


func updatesprite(input: Vector2):
	if not dovertical:
		if input.y != 0:
			if scale.x > 0:
				input.x = -1
			else:
				input.x = 1
		input.y = 0
	
	if roundvec:
		input.x = round(input.x)
		input.y = round(input.y)
	
	if lastvector != input and reportvectors:
		lastvector = input
		globals.iprint(input)
	
	walking=abs(input.x) > inputtreshhold or abs(input.y) > inputtreshhold
	if walking:
		if not Engine.editor_hint:
			emit_signal("walking")
		if abs(input.y) < abs(input.x):#if we are facing the sides
			animation = "side"
			if input.x > inputtreshhold:
				scale.x = -abs(scale.x)
				playanim("side", true, true, true, "right")
				if puke_particles != null:
					puke_particles.position.x = 1.5
					puke_particles.show_behind_parent = false
			elif input.x < -inputtreshhold:
				scale.x = abs(scale.x)
				playanim("side", true, true, true, "left")
				if puke_particles != null:
					puke_particles.position.x = -1.5
					puke_particles.show_behind_parent = false
		else:
			scale.x=abs(scale.x)
			if input.y > inputtreshhold:
				playanim("front")
				if puke_particles != null:
					puke_particles.position.x = 0.5
					puke_particles.show_behind_parent = false
			if input.y < -inputtreshhold:
				playanim("back")
				if puke_particles != null:
					puke_particles.position.x = 0.5
					puke_particles.show_behind_parent = true
	match getcurrent():
		"side":
			if abs(input.x) < inputtreshhold:
				playanim("idleside",false)
		"front":
			if abs(input.y) < inputtreshhold:
				playanim("idlefront",false)
		"back":
			if abs(input.y) < inputtreshhold:
				playanim("idleback",false)
	var synced=0
	while synced < syncs.size():
		var spr=get_node(syncs[synced])
		if spr!=null:
			if spr.get("frames") != null and spr.frames.has_animation(animation):
				spr.animation = animation
				if spr.get_name() == "blink":
					spr.playing = true
				else:
					spr.playing = playing
					spr.frame = frame
			spr.flip_h = flip_h
		else:
			prints("couldnt find", spr)
		synced+=1
func getcurrent():
	if $animator.is_playing():
		return $animator.current_animation
	elif playing:
		return animation
func allstop(ifplaying: bool = true):
	if ifplaying == false or ($animator.is_playing() == true or playing == true or frame != 0):
		$animator.stop()
		stop()
		if reportanims:
			globals.iprint(["stopping"],"animation")
		playing = false
		frame=0

func isplaying(anim:String):
	return $animator.current_animation == anim or (animation==anim and (playing and (frames.get_animation_loop(anim) or frame!=frames.get_frame_count(anim)-1)))
func playanim(animname:String ,playself: bool = true, checknotrunning: bool = true, reset: bool = true, direction: String = ""):
	if checknotrunning == false or not isplaying(animname):
		if reset:
			allstop()
		if playself:
			play(animname)
		if $animator.has_animation(animname):
			$animator.play(animname)
		emit_signal("animupdate")
		if reportanims:
			globals.iprint(["animchange:",animname],"animation")
		# Set direction of cosmetics
		for cosmetic in player_cosmetics.keys():
			var sprite = get_node(cosmetics).get_node(cosmetic)
			if sprite.frames!=null:
				if cosmetic == "aimingeye" and animname == "side":
					if sprite.frames.has_animation(direction):
						sprite.play(direction)
				else:
					if sprite.frames.has_animation(animname):
						sprite.play(animname)
