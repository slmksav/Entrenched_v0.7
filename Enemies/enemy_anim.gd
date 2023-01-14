extends AnimatedSprite

func _on_Dummy_anim_update(input:Vector2) -> void:
	if abs(input.y)<abs(input.x):
		if input.x!=0:
			playing=true
			animation="side"
			if input.x>0:
				flip_h=true
			elif input.x<0:
				flip_h=false
	else:
		playing=true
		if input.y>0:
			animation="front"
		elif input.y<0:
			animation="back"
	
	if animation=="side":
		if input.x==0:
			playing=false
			frame=0
	if animation=="front" or animation=="back":
		if input.y==0:
			playing=false
	
	
	$Blood.animation = animation
	$Blood.frame = frame
	$Blood.playing = playing
	$Blood.flip_h = flip_h
