extends Node
#a place to store all functions that could
#be useful in different contexts

#absolute difference, the distance between 2 numbers in the
#numeric line, 9 and -9 for example its 18, when its normaly 0.
static func getabsdif(numa:float,numb:float) -> float:
	if sign(numa) == sign(numb):
		return abs(abs(numa) - abs(numb))
	else:
		return abs(numa) + abs(numb)


func getangdist(anglea,angleb) -> float:
	if anglea >= (3*PI)/2 and angleb < PI/2:
		return ((2*PI) - anglea) + angleb
	elif angleb >= (3*PI)/2 and anglea < PI/2:
		return ((2*PI) - angleb) + anglea
	return getabsdif(anglea, angleb)


#returns the angle of something looking in that vector
#for example, 1,0 is looking right -1,0 left 0,1 down and so on.
static func getlookatfromvec(vec:Vector2) -> float:
	var newvec: Vector2 = Vector2(sign(vec.x), sign(vec.y))
	return Vector2.ZERO.angle_to_point(newvec) + PI / 2



static func disableloop(audio:AudioStream):
	match audio.get_class():
		"AudioStreamMP3","AudioStreamOGGVorbis":
			audio.loop = false
		"AudioStreamSample":
			audio.loop_mode = AudioStreamSample.LOOP_DISABLED


static func roundvector(vec:Vector2) -> Vector2:
	return Vector2(round(vec.x),round(vec.y))


static func absvector(vec:Vector2) -> Vector2:
	return Vector2(abs(vec.x), abs(vec.y))


static func getantiscale(num:float) -> float:
	return 1*(1/num)


static func percent(fraction: float, num: float) -> float:
	return (num/fraction) * 100.0


#chooses a random option from an array
static func choose(options: Array):
	if options.size() == 0:
		return
	var base: int = int(round(rand_range(0, options.size()-1)))
	return options[base]


func signdifference(num1, num2):
	if num1 == num2:
		return 0
	if num1 > num2:
		return 1
	if num1 < num2:
		return -1


static func keys_null(dictionary: Dictionary) -> bool:
	for k in dictionary.keys():
		if typeof(dictionary[k]) == TYPE_DICTIONARY:
			if not keys_null(dictionary[k]): return true
		if dictionary[k] == null: return true
	return false


static func get_keys_null(dictionary: Dictionary) -> Dictionary:
	var dict2: Dictionary = {}
	for k in dictionary.keys():
		if dictionary[k] != null: dict2[k] = dictionary[k]
	return dict2



static func get_args() -> Dictionary:
	var args: Dictionary = {}
	for argument in OS.get_cmdline_args():
		var key_value: PoolStringArray = argument.split("=")
		if key_value.empty() or key_value.size() == 1: continue
		args[key_value[0].lstrip("--")] = key_value[1]
	return args



static func is_arg(arg: String) -> bool:
	arg = arg.to_lower()
	return bool(arg == "yes" or arg == "y" or arg == "ok" or arg == "true")



static func bool_string(boolean: bool, mode: int = 0) -> String:
	if mode <= 0:
		if boolean: return "yes"
		else: return "no"
	else:
		if boolean: return "OK"
		else: return "FAIL"


#assigns a new texture to a spriteframe
func texturetoframe(default: SpriteFrames, texture: Texture, divisionsh = 0,animorder: Array = []) -> SpriteFrames:
	"""divisionsh can be used if all sprites arent the same size, but
	they are divided in equal parts.if provided, then animorder is requiered
	to know the order of the frame in the texture"""
	if texture==null: return null
	

	var newframes: SpriteFrames = SpriteFrames.new()

	for anim in default.get_animation_names():
		newframes.add_animation(anim)
		for l in default.get_frame_count(anim):
			var region: Rect2
			if divisionsh == 0:
				region = default.get_frame(anim,l).region
			else:
				var width = texture.get_width()/divisionsh
				region = Rect2(Vector2(width*animorder.find(anim),0),Vector2(width,texture.get_height()))
			var atlas: AtlasTexture = AtlasTexture.new()
			atlas.atlas = texture
			atlas.region = region
			newframes.add_frame(anim, atlas, l)
		newframes.set_animation_loop(anim, default.get_animation_loop(anim))
	return newframes


#by default a non empty string is true and the other way around
func strtobool(value:String)->bool:
	match value.to_lower():
		"true":
			return true
		"false":
			return false
		_:
			globals.iprint("invalid bool, returning false","logic",true)
			return false

