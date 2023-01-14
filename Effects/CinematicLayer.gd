extends CanvasLayer

signal cinematic_animation
signal cinematic_mode
signal normal_mode

onready var anim: AnimationPlayer = $anim

var is_cinematic_mode: bool = false

func cinematic_mode():
	is_cinematic_mode = true
	anim.play("cinematic_mode")
	emit_signal("cinematic_mode")


func cinematic_animation():
	anim.play("cinematic_animation")
	emit_signal("cinematic_animation")


func normal_mode():
	is_cinematic_mode = false
	anim.play_backwards(anim.current_animation)
	emit_signal("normal_mode")
