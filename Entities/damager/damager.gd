extends Area2D
class_name damager,"res://Entities/damager/classicon.png"

enum types{
	punch
	shot
	cut
	other
}

export (types) var type
export(int) var damage: int
export(bool) var manage_bits = true
export(float) var damage_downtime: float = 0.4

var exeptions=[]
var timer=Timer.new()
var candamage=true


func _ready():
	add_child(timer)
	monitorable=false
	timer.connect("timeout",self,"timeout")
	connect("area_entered",self,"area_entered")
	if manage_bits:
		set_collision_layer_bit(4,true)
		set_collision_mask_bit(4,true)
		set_collision_layer_bit(1,false)
		#set_collision_mask_bit(1,false)


func timeout():
	candamage=true
	timer.stop()


func area_entered(area):
	if candamage and area is HitBox:
		if not exeptions.has(area.target):
			timer.start(damage_downtime)
			area.damage(damage,type)
			if has_method("damage"):
				call("damage")
			candamage=false


