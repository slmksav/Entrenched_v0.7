tool
extends Camera2D

signal updategui
signal setposition

export var relativeto: NodePath
export(bool) var active
export(float) var distance
export(bool) var updaterect setget updterect
export(String,"max","min") var useresaxis
export(float) var transitionspeed
export var initresolution: Vector2
export var smoothonshake: bool
export(String,"stretched","smart") var resmode
var inintsmoothing = smoothing_enabled
var shakeintensity: int
var shaking: bool
var angle: float

onready var relative: Entity = get_node_or_null(relativeto) as Entity
onready var basezoom:Vector2 = zoom


func _init():
	globals.camera = self

func _ready():
	
	if Multiplayer.is_dedicated_server:
		queue_free()
		return
	
	globals.world.connect("spawn_player", self, "_on_spawn_player")
	
	if relative == null:
		set_process(false)
	
	if not Engine.editor_hint:
		var error = get_viewport().connect("size_changed",self,"setreszoom")
		if error!=OK:
			globals.iprint("camera cant get updated")
		match resmode:
			"stretched":
				get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D,SceneTree.STRETCH_ASPECT_KEEP,Vector2(1024,600))
			"smart":
				get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_DISABLED,SceneTree.STRETCH_ASPECT_DISABLED,Vector2(1024,600))
	else:
		$rect.visible = false
	setreszoom()


func _process(delta: float):
	if not Engine.editor_hint:
		$UI/topleft/label_fps.text = "FPS:%s" % Performance.get_monitor(Performance.TIME_FPS)
		if Input.is_action_just_pressed("cinematic_mode") and $rect.get_focus_owner()==null:
			if $CinematicLayer.is_cinematic_mode:
				$CinematicLayer.normal_mode()
				globals.presentation_mode(false)
			else:
				$CinematicLayer.cinematic_mode()
				globals.presentation_mode(true)
	
		if math.getangdist(angle, relative.lookingto) > transitionspeed * delta:
			if angle>=(3*PI)/2 and relative.lookingto<PI/2:
				angle+=transitionspeed*delta
			elif relative.lookingto>=(3*PI)/2 and angle<PI/2:
				angle-=transitionspeed*delta
			else:
				angle-=(transitionspeed*delta)*sign(angle-relative.lookingto)
			if angle>PI*2:
				angle=(PI*2)-(angle-(PI*2))
			if angle<0:
				angle=(PI*2)-abs(angle)
		else:
			angle=relative.lookingto
		if active and relative!=null:
			position=relative.position+(Vector2(0,distance).rotated(angle))
		if shaking:
			position+=Vector2(rand_range(0,shakeintensity),rand_range(0,shakeintensity))
			emit_signal("updategui")
		emit_signal("setposition")


func shake(seconds,intensity):
	shakeintensity=intensity
	shaking=true
	smoothing_enabled=smoothonshake
	$shaketimer.start(seconds)


func _on_shaketimer_timeout():
	shaking=false
	smoothing_enabled=inintsmoothing
	position=Vector2()


func setreszoom():
	if resmode=="smart" and not Engine.editor_hint:
		var size: Vector2 = basezoom * (initresolution / get_viewport_rect().size)
		if (size.x < size.y and useresaxis == "min"):
			zoom = Vector2(size.x,size.x)
		else:
			zoom = Vector2(size.y,size.y)
	emit_signal("updategui")
	updterect(0)


func updterect(_value):
	if Engine.editor_hint:
		$rect.visible = true
	$rect.rect_size=initresolution


func _on_spawn_player(new_player: Entity, is_client: bool = false):
	set_process(true)
	relative = new_player
	position = Vector2.ZERO

