extends "res://inventory/item.gd"
class_name Armor

export(SpriteFrames) var chest
export(SpriteFrames) var helmet
export(AudioStream) var hit_sound
export(float) var maxhp:int=12
export(int) var standarddamage=10
var hp=maxhp setget sethp
export(bool) var hairwithhelmet=true
export var defense := 0.0
func sethp(value):
	hp=value
	if hp<=0:
		parentinventory.delete_item(index,1)
	parentinventory.emit_signal("updated")

func get_protected_damage(amount:int):
	return amount-(amount*defense)
