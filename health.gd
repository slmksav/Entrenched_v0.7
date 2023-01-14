extends Resource
class_name Health

signal updated
signal death

var current_health:int = 100

func damage(amount:int):
	current_health -= amount
	current_health = clamp(current_health, 0, 100)
	if (current_health <= 0):
		emit_signal("death")
	emit_signal("updated")
