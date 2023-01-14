extends Control
onready var skin=$visual
func _ready():
	_on_down_pressed()
func _on_right_pressed():
	skin.updatesprite(Vector2(1,0))
	skin.updatesprite(Vector2(0,0))
func _on_left_pressed():
	skin.updatesprite(Vector2(-1,0))
	skin.updatesprite(Vector2(0,0))
func _on_down_pressed():
	skin.updatesprite(Vector2(0,1))
	skin.updatesprite(Vector2(0,0))
func _on_up_pressed():
	skin.updatesprite(Vector2(0,-1))
	skin.updatesprite(Vector2(0,0))

