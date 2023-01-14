extends Area2D
class_name HitBox,"res://Entities/damager/hitbox.png"

enum armorparts{
	helmet
	chest
	boots
}

export(NodePath) var totarget
onready var target=get_node_or_null(totarget)
export(armorparts) var protectedby
export(float) var damagemultiplier: int=1


func _ready():
	if target==null:
		monitorable=false


func damage(dmg:int,type:int,by:Node=null,bleed=true):
	dmg *= damagemultiplier
	var armor = target.armorbypos[protectedby]
	if armor != null:
		dmg -= armor.get_protected_damage(dmg)
	if dmg > 0:
		globals.iprint("redirecting damage","entities")
		target.damage(dmg,type,by,bleed)
