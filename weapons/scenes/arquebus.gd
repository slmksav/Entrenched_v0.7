extends Gun

onready var player: Entity = globals.player

export(PackedScene) var shoot_smooke_effect: PackedScene

export(float, 100) var range_aim: float = 20 

enum {
	IDLE,
	DEPLOY,
	RELOAD,
	NO_AMMO
}
var state: int = IDLE setget set_state
var prev_state: int

var can_fire_view: PoolColorArray = [Color("ff0000"), Color("2af500")]
var cant_fire_view: PoolColorArray = [Color("6b6b6b")]

onready var fire_effect_spr: AnimatedSprite = $fire_effect
onready var line: Line2D = $body/spr/Position2D/Line2D
onready var cosmetics : AnimatedSprite = player.get_node("visual")


func set_state(new_state: int):
	prev_state = state
	state = new_state
	if new_state!=RELOAD:
		$AdioReload.stop()

func _ready():
	if visual!=null:
		connect("visibility_changed",self,"vis")
	$anim.current_animation = "idle"
	$anim.connect("animation_finished", self, "animation_finished")
	connect("firing", self, "_on_fire")
	$body/spr/Position2D/Light2D.visible = false
	$body/spr/Position2D/Light2D2.visible = false
	line.visible = false
	line.gradient.colors = can_fire_view



func aim(to:Vector2) -> bool:
	if state==RELOAD:return false
	line.look_at(to)
	var rad: float = rad2deg(line.rotation)
	if rad > 10:
		rad = 10
	
	if rad < -10:
		rad = -10
	line.rotation = deg2rad(rad)
	return true


func deploy(): 
	lowered = !lowered
	visual.dovertical= not lowered
	if lowered:
		$anim.play("deploy")
		set_state(DEPLOY)
	else:
		set_state(IDLE)
		$anim.play_backwards("deploy")
		player.canmove = true
	$anim.clear_queue()

func vis():
	visual.dovertical=not lowered


func attack():
	if lowered:
		spawn_bullet(player, spawn_bullet_position.global_position, math.getlookatfromvec(Vector2(visual.scale.x*-1,0)))


func reload():
	set_state(RELOAD)
	reload_sound(-4)
	player.canmove = false
	if not lowered:
		$anim.play("reload")
	else:
		$anim.play_backwards("deploy")


func close_eye():
	cosmetics.player_cosmetics["aimingeye"] = true


func open_eye():
	cosmetics.player_cosmetics["aimingeye"] = false


func animation_finished(animation: String):
	if animation == "deploy":
		if state == RELOAD:
			$anim.play("reload")
		elif lowered:
			set_state(DEPLOY)
			player.canmove = false
			line.visible = true
		else:
			$anim.current_animation = "idle"
			set_state(IDLE)
	
	if animation == "reload":
		reloading()
		line.gradient.colors = can_fire_view
		player.canmove = true
		if prev_state == IDLE:
			state = IDLE
			prev_state = -1
			$anim.current_animation = "idle"
		if prev_state == DEPLOY:
			state = DEPLOY
			prev_state = IDLE
			$anim.current_animation = "deploy"



func _exit_tree():
	player.canmove = true
	fire_effect_spr.stop()
	fire_effect_spr.frame = 0
	$anim.current_animation = "idle"
	lowered = false


func _on_fire():
	if shoot_smooke_effect != null:
		var s: CPUParticles2D = shoot_smooke_effect.instance()
		s.global_position = $body/spr/Position2D.global_position
		s.global_rotation = $body/spr/Position2D.global_rotation
		get_tree().get_root().add_child(s)
		$body/spr/Position2D/rmt_shootsmoke.remote_path = s.get_path()
	fire_effect_spr.frame = 0
	$anim.play("fire")
	fire_effect_spr.play("fire")
	line.gradient.colors = cant_fire_view
	$body/spr/Position2D/Light2D.visible = true
	$body/spr/Position2D/Light2D2.visible = true
	yield(get_tree().create_timer(0.2), "timeout")
	$body/spr/Position2D/Light2D.visible = false
	$body/spr/Position2D/Light2D2.visible = false

