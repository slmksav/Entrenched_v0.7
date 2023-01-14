extends onhandrep
func _ready():
	hand=self
func docolor(color:Color):
	print(color.to_html(false))
	$sprite.modulate=color
