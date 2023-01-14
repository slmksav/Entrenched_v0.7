extends Entity
class_name movingentity,"res://Entities/moving.png"
#entity with a visualtree body, kinda a human.

# Constants
const ACCELERATION = 500
const FRICTION = 500

signal canmove(vector)
signal updatesprite(input)

#default moving speeds
export(float) var defmovespeed
#current moving speed
onready var movespeed: float = defmovespeed
var canmove:bool=true
var velocity = Vector2.ZERO
#changed when the signal is emitted, sets if allowed to walk
#in the current frame
var moveonframe:bool=true

func _physics_process(delta):
	var input_vector:Vector2=Vector2()
	if canmove:
		#ask for directions to the parent script
		if has_method("setmove"):
			input_vector=call("setmove")
			input_vector=input_vector.normalized()
		var willmove=input_vector * movespeed
		emit_signal("canmove",willmove)
		if moveonframe:
			#selecting a "looking" position so camera can follow
			if input_vector!=Vector2.ZERO:
				var look: float
				if not $visual.dovertical:
					if input_vector.x > 0:
						look = (3*PI)/2
					elif input_vector.x < 0:
						look = PI/2
					else:
						look = lookingto
				else:
					look = math.getlookatfromvec(input_vector)
				if look != null:
					lookingto = look
				input_vector = input_vector.normalized()
			if input_vector != Vector2.ZERO:
				velocity = velocity.move_toward(willmove,ACCELERATION * delta)
			else:
				velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		else:
			velocity=Vector2.ZERO
		moveonframe = true
	velocity = move_and_slide(velocity)
	emit_signal("updatesprite",input_vector)
	
	if has_method("aftermove"):
		call("aftermove")
