extends KinematicBody2D
class_name Entity, "res://Entities/spr.png"

signal bled_out(value)
signal updated_health(new_health)
signal death(by, cause)
signal attacked(dmg,type,bybleeding)
signal killed(target)
signal hit(dmg, target)
signal follow_target(target)
signal changed_state(new_state, old_state)
signal changed_navigation(new_nav, old_nav)


enum {
	IDLE,
	MOVEMENT,
	DEATH
}

var state: int = IDLE setget set_state

export(int) var health: int = 100 setget set_health
export(bool) var god_mode: bool = false # In this mode the player can take damage, but his life will not be reduced or he will not be able to die.

export(Array, AudioStream) var PunchSounds: Array
export(Array, AudioStream) var CutSounds: Array
export(Array, AudioStream) var ShotSounds: Array
export(Array, AudioStream) var DeadSounds: Array

export(Array,NodePath) var hitboxes: Array
export(float, 0, 60, 0.1) var time_blood_drops: float = 1 setget change_time_blood_drops
var bled_out: bool = false

var max_health: int

var timer_blood_drops: Timer = Timer.new()

var nav: Navigation2D setget set_nav

var target_follow: Node2D setget set_target_follow
var path: PoolVector2Array = []

var move: Vector2 = Vector2.ZERO
var lookingto: float
var hit_sound_player: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
var dead_sound_player: AudioStreamPlayer2D = AudioStreamPlayer2D.new()

var armorbypos=[null,null,null]
var blood_pool: PackedScene = load("res://Effects/Blood.tscn")
var blood_drops_scene: PackedScene = load("res://Effects/BloodDrops.tscn")
var blood_drops: CPUParticles2D


func restore_health(new_health: int):
	if health >= max_health: new_health = max_health
	set_health(new_health)
	if bled_out: bled_out = false


func setentityarmor(armor:Armor):
	if armor.chest!=null:
		armorbypos[1]=armor
	if armor.helmet!=null:
		armorbypos[0]=armor


func unsetentityarmor(armor:Armor):
	if armor.chest!=null:
		armorbypos[1]=null
	if armor.helmet!=null:
		armorbypos[0]=null


func set_state(new_state: int):
	emit_signal("changed_state", new_state, state)
	state = new_state


remotesync func set_health(new_health: int):
	var oldhealth: int = health
	health = new_health
	emit_signal("updated_health",new_health)
	if has_method("newhealth"):
		call("newhealth", oldhealth, new_health)


func set_nav(new_nav: Navigation2D):
	emit_signal("changed_navigation", new_nav, nav)
	nav = new_nav


func set_target_follow(new_target_follow: Node2D):
	emit_signal("follow_target", new_target_follow)
	target_follow = new_target_follow


func change_time_blood_drops(new_time: float):
	if new_time <= 0:
		time_blood_drops = 0.1
	elif new_time >= 60:
		time_blood_drops = 60
	else:
		time_blood_drops = new_time
	
	timer_blood_drops.wait_time = time_blood_drops


func _ready():
	add_child(hit_sound_player, true)
	
	if PunchSounds.size() > 0:
		for s in PunchSounds:
			if s == null: continue
			math.disableloop(s)
	if CutSounds.size() > 0:
		for s in CutSounds:
			if s == null: continue
			math.disableloop(s)
	if ShotSounds.size() > 0:
		for s in ShotSounds:
			if s == null: continue
			math.disableloop(s)
	if DeadSounds.size() > 0:
		add_child(dead_sound_player, true)
		for s in DeadSounds:
			if s == null: continue
			math.disableloop(s)
	
	timer_blood_drops.wait_time = time_blood_drops
	timer_blood_drops.one_shot = true
	timer_blood_drops.connect("timeout", self, "_on_timeout_blood_drops")
	add_child(timer_blood_drops, true)
	
	blood_drops = blood_drops_scene.instance()
	add_child(blood_drops, true)
	blood_drops.position.y = -8.3
	
	connect("bled_out", self, "_on_bled_out")
	
	add_to_group("entity")
	
	max_health = health

#returns if was killed

func damage(dmg: int, type: int = damager.types.punch, by: Node = null, bledding: bool = false):
	"""
	 This says if its a comfirmed damage, if not real,only
	 esthetic things will work, if real, health and stuff will
	 actually decrease, real happens when the server sended the
	 order
	"""
	
	globals.logger("has Damage")
	
	# var real:bool= byserver or server.type==server.types.host or server.type==server.types.notstarted
	
	var real: bool = true
	
	if Multiplayer.is_online_mode():
		# Confirm if the one who sent the signal is the server
		if get_tree().get_rpc_sender_id() == 1 or Multiplayer.is_host():
			real = true
		else: real = false
	
	
	globals.iprint(["damage real:",real],"entities")
	if real and not god_mode:
		health -= dmg
		health = clamp(health, 0, max_health)
		emit_signal("updated_health", health)
	
	if (type == damager.types.shot or type == damager.types.cut) or bledding:
		randomize()
		add_blood(by)
		match type:
			damager.types.shot: 
				if real:
					bled_out = int(rand_range(0, 100)) >= 80
				else:
					_play_audio(hit_sound_player, ShotSounds)
			damager.types.cut:
				if real:
					bled_out= int(rand_range(0, 100)) >= 40
				else:
					_play_audio(hit_sound_player, CutSounds)
		if real:
			if bledding: bled_out = bledding
			if bled_out: emit_signal("bled_out", bled_out)
	elif not real: _play_audio(hit_sound_player, PunchSounds)
	if real:
		emit_signal("attacked",dmg,type,by,bledding)
	if health <= 0:
		if real:
			emit_signal("death", by)
			set_state(DEATH)
		else:
			_play_audio(dead_sound_player, DeadSounds)
		return true
	if has_method("customdamage"):
		call("customdamage", dmg, real)
	if Multiplayer.is_host():
		rpc("damage", dmg, type)
		rpc("set_health", health)
	return false


remotesync func attack(dmg: int, target: Node, type: int = damager.types.punch):
	if target.has_method("damage"):
		var is_killed: bool = target.damage(dmg, type, self)
		emit_signal("hit", dmg, target)
		if is_killed:
			emit_signal("killed", target)


func force_death():
	health = 0
	emit_signal("death", null, "forced")
	set_state(DEATH)


func navigation() -> Vector2:
	var move_to: Vector2 = Vector2.ZERO
	if path.size() > 0:
		move_to = global_position.direction_to(path[1])
		if global_position == path[0]: path.remove(0)
	return move_to


func add_blood(to_node: Node2D):
	globals.iprint("add blood","entities")
	var b: Node2D = blood_pool.instance()
	get_tree().current_scene.add_child(b, true)
	b.global_position = self.global_position
	
	if to_node != null:
		b.global_rotation = global_position.angle_to(to_node.global_position)
	else:
		randomize()
		b.global_rotation = rand_range(-360, 360)


func generate_path(target_pos: Vector2, optimize: bool = true) -> PoolVector2Array:
	if nav != null and target_follow != null:
		path = nav.get_simple_path(self.global_position, target_pos, optimize)
		return path
	return PoolVector2Array()


func _play_audio(player: AudioStreamPlayer2D, stream_arr: Array):
	if stream_arr.size() == 0:
		globals.logger("There are no sounds to play")
		return
	player.stream = math.choose(stream_arr)
	player.play()


func _on_timeout_blood_drops():
	if bled_out:
		damage(5, damager.types.other)
		blood_drops.emitting = true
		timer_blood_drops.start()


func _on_bled_out(value: bool):
	if not value: return
	
	damage(false,5, damager.types.other)
	
	blood_drops.emitting = true
	timer_blood_drops.start()

