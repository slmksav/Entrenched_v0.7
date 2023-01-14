extends Node

export(Array, AudioStreamMP3) var wind_list = []
var fading = false

func _ready():
	play_wind_1(wind_list[randi() % 4])
	fade_players($wind_player1, $wind_player2)

func _process(_delta):
	if not fading:
		if $wind_player1.is_playing() and $wind_player1.get_playback_position() >= $wind_player1.stream.get_length() - 4:
			play_wind_2(wind_list[randi() % 4])
			fade_players($wind_player2, $wind_player1)
		elif $wind_player2.is_playing() and $wind_player2.get_playback_position() >= $wind_player2.stream.get_length() - 4:
			play_wind_1(wind_list[randi() % 4])
			fade_players($wind_player1, $wind_player2)

func play_wind_1(clip : AudioStreamMP3):
	$wind_player1.stream = clip
	$wind_player1.play()

func play_wind_2(clip : AudioStreamMP3):
	$wind_player2.stream = clip
	$wind_player2.play()

func fade_players(player1 : AudioStreamPlayer, player2 : AudioStreamPlayer):
	fading = true
	$volume1.interpolate_property(player1, "volume_db", -30, -5, 4, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$volume1.start()
	$volume2.interpolate_property(player2, "volume_db", -5, -30, 4, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$volume2.start()
	yield($volume1, "tween_completed")
	fading = false
