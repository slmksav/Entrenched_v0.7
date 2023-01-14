extends AnimationPlayer

var on = true

func _ready():
	play("light")
	$"../fire".play()
	$"../sprite".play("on")

func _unhandled_key_input(event):
	if Input.is_action_just_pressed("interact"):
		on = not on
		if on:
			play("light")
			$"../fire".play()
			$"../sprite".play("on")
		elif not on:
			play("off")
			$"../sprite".play("off")
