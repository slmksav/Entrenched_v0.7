extends Node
var preferences={}
signal loaded
export(bool) var reportreqdata
export(Dictionary) var alloptions
#holds the default tres to use in math.texturetoframe, as a reference
#on how the sprite is divided
export(Dictionary) var defaulttres
export(Dictionary) var divisionsh_byoption
export(Dictionary) var animorder_byoption
export(Array,PackedScene) var scenebyhead
#skin color of heads, used in hand.
export(Array,Color) var racebyhead
#extra keys needed,that are not a key in alloptions.
export(PoolStringArray) var keystoload
func fetch():
	var toget=alloptions.keys() as Array
	toget.append_array(keystoload)
	UserData.get_player_data(PoolStringArray(toget))
	var request=yield(UserData,"get_player_data")
	if request[1]["response_code"]==200:
		preferences=request[0]
		if reportreqdata:
			print(request[1])
		emit_signal("loaded")
	else:
		prints("error getting data",request[0]["response_code"])
func update():
	print("requested to update the data")
	UserData.update_player_data(preferences,"Public")

func getprefvalue(selectname:String):
	var pref=int(getpref(selectname))
	if alloptions[selectname].size()>pref:
		return alloptions[selectname][pref]
	else:
		globals.iprint(["selection",selectname,"doesnt have index",pref],"skin",true)
		return alloptions[selectname][0]
func getpref(selectname):
	return preferences[selectname]["Value"]
func getframe(selectname):
	var divs=0
	var order=[]
	if divisionsh_byoption.has(selectname):
		divs=divisionsh_byoption[selectname]
		order=animorder_byoption[selectname]
	return math.texturetoframe(defaulttres[selectname],getprefvalue(selectname),divs,order)
