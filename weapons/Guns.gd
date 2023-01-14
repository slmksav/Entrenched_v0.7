extends onhandrep
class_name Gun

signal changed_lowered_state(value)
signal no_ammo
signal firing
signal realoading

export(PackedScene) var bullet: PackedScene
export(int, 0, 10000, 1) var damage: int = 10
export(float, 0, 1000) var fire_rate: float = 1 setget set_fire_rate
var can_fire: bool = true
var lowered: bool = false
var reload: bool = false

export(int, 0, 1000) var ammo: int = 1
var max_ammo: int

export(NodePath) var _spawn_bullet_position: NodePath
onready var spawn_bullet_position: Node2D = get_node_or_null(_spawn_bullet_position)

export(Array, AudioStream) var fire_sounds: Array = []
export(NodePath) var _sounds_player: NodePath
onready var sounds_player: AudioStreamPlayer2D = get_node_or_null(_sounds_player)

export(AudioStream) var reload_sounds: AudioStream = null
export(NodePath) var _reload_sound_player: NodePath
onready var reload_sound_player: AudioStreamPlayer2D = get_node_or_null(_reload_sound_player)

export(NodePath) var _burning_clothes_ray: NodePath
onready var burning_clothes_ray: RayCast2D = get_node_or_null(_burning_clothes_ray)
export(float, 0, 100, 0.1) var bonus_burns_clothes: float = 50

var fire_timer: Timer = Timer.new()


func set_fire_rate(new_fire_rate: float):
	fire_rate = new_fire_rate
	fire_timer.wait_time = new_fire_rate


func _ready():
	connect("tree_exited", self, "_tree_exited")
	connect("tree_entered", self, "_tree_entered")
	fire_timer.connect("timeout", self, "_on_timeout")
	fire_timer.wait_time = fire_rate
	fire_timer.one_shot = true
	fire_timer.autostart = false
	add_child(fire_timer, true)
	max_ammo = ammo
	
	if reload_sounds != null: 
		reload_sound_player.bus = "SFX"
		reload_sound_player.stream = reload_sounds
	
	if sounds_player != null: sounds_player.bus = "SFX"
	
	math.disableloop(reload_sounds)
	
	for i in fire_sounds:
		math.disableloop(i)


func spawn_bullet(owner_bullet: Node, in_pos: Vector2, to_rot: float):
	if can_fire == false or lowered == false or reload: return
	if ammo <= 0: return
	if not is_inside_tree(): return
	var b = bullet.instance() as Projectile
	if burning_clothes_ray != null:
		if burning_clothes_ray.is_colliding(): damage += int(math.percent(bonus_burns_clothes, float(damage)))
	
	b.set_params(damage, owner_bullet, to_rot, in_pos)
	get_tree().get_root().add_child(b, true)
	can_fire = false
	fire_timer.start()
	
	if not (fire_sounds.size() > 0) and sounds_player != null: return
	
	randomize()
	sounds_player.stream = fire_sounds[randi() % fire_sounds.size()]
	sounds_player.play(0)
	ammo -= 1
	emit_signal("firing")
	if ammo <= 0:
		reload = true
		emit_signal("no_ammo")


func reload_sound(start_pos: float = 0):
	if start_pos < 0: 
		yield(get_tree().create_timer(abs(start_pos)), "timeout")
		start_pos = 0
	
	if reload_sound_player == null or reload_sounds == null: return
	reload_sound_player.play(start_pos)


func reloading():
	if ammo == max_ammo: return
	ammo = max_ammo
	reload = false


func _on_timeout():
	can_fire = true


func _tree_entered():
	can_fire = true


func _tree_exited():
	lowered = false


