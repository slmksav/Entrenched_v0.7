extends AnimationPlayer

func _input(event):
	if event.is_action_pressed("attack") and not is_playing():
		play("wave")
