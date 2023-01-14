tool
extends CanvasModulate


export(bool) var active: bool = true setget, is_active
export(int, 0, 23) var hour_start: int = 12 setget set_hour

onready var anim: AnimationPlayer = get_node("anim")

func _ready():
	visible=true
	anim.seek(float(hour_start))
	
	globals.set_day_cycle_node(self)
	
	if active:
		anim.play("day_cycle")
		set_hour(hour_start)

func is_active() -> bool:
	return active

func enable_cycle(value: bool):
	active = value
	
	if value == true: anim.play("day_cycle")
	else: anim.stop()

func set_hour(hour: int):
	if hour > 23: hour = 23
	hour_start = hour
	anim.seek(hour)


func get_current_hour() -> int:
	return int(anim.get_current_animation_position())
