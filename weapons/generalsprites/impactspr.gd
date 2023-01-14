extends Sprite
export(float)var vanishspeed=1
func _ready():
	modulate.a=0
func show():
	modulate.a=1
func _process(delta):
	modulate.a-=vanishspeed*delta
