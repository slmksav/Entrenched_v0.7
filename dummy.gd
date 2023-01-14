extends StaticBody2D

var health = Health.new()

func _ready() -> void:
	health.connect("death", self, "death")
	$Timer.connect("timeout", self, "attack")

func attack():
	var bodies = $AttackArea.get_overlapping_bodies()
	for body in bodies:
		if (body.has_method("damage") && body != self):
			body.damage(10)

func damage(amount:int):
	health.damage(amount)

func death():
	print(name + " has died")
	queue_free()
