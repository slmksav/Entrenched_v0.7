extends "res://inventory/item.gd"
class_name Ammo,"res://weapons/projectiles/ammosimbol.png"

export(int) var Damage: int = 10
export(float, 0, 1000, 0.1) var Speed: float = 750
export(float, 0) var LifeTime: float = 15 

export(PackedScene) var bullet_scene


func spawn_bullet(owner_bullet: Node) -> Projectile:
	var p: Projectile = bullet_scene.instance()
	p.set_params(owner_bullet, Speed, owner_bullet.global_rotation, Damage, LifeTime)
	return p

