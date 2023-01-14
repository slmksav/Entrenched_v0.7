extends damager
class_name Projectile,"res://weapons/projectiles/projectileclass.png"

signal hit(target, node_hit)

export(float) var speed: float = 30
export(float, 0, 1000) var life_time: float = 15

var speedvec: Vector2

var owner_bullet: Node
var object_col: PhysicsBody2D


func set_params(dmg: int, owner_bullet: Node, torotation: float, pos: Vector2):
	global_position = pos
	owner_bullet = owner_bullet
	damage = dmg
	rotation=torotation-90
	speedvec=Vector2(0,speed).rotated(torotation)


func _ready():
# warning-ignore:return_value_discarded
	var timer: Timer = Timer.new()
	timer.wait_time = life_time
# warning-ignore:return_value_discarded
	timer.connect("timeout", self, "_on_timeout")
	add_child(timer, true)
	timer.start()


func _process(delta: float):
	position += speedvec * delta

func _on_timeout():
	globals.iprint("timeouted")
	queue_free()




func damaged():
	queue_free()
