extends Entity

func setpos(newposition:Vector2):
	$visual.updatesprite(newposition-position)
	position=newposition
