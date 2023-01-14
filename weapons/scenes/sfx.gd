extends AudioStreamPlayer2D
export(bool) var loop
export(Dictionary) var volumebyaudio
export(float) var cooldown
#minimum time betwen playing the same sound
class_name sfxer
var lastplayed:AudioStream
var timer=Timer.new()
func _ready():
	add_child(timer)
func setaudio(audio:AudioStream):
	if volumebyaudio.has(audio):
		math.disableloop(audio)
		volume_db=volumebyaudio[audio]
		stream=audio
func smartplay(onplay:bool=false,toplay:AudioStream=stream):
	setaudio(toplay)
	if (onplay or not playing) and (stream!=lastplayed or timer.is_stopped()):
		play()
		lastplayed=stream
		timer.start(cooldown)
