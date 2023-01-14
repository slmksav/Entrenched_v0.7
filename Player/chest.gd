extends Sprite
#manages adding and setting sprites.
func set_armor(armor:Armor):
	if armor.helmet!=null:
		$head/helmet.frames=armor.helmet
		$head/hair.visible=armor.hairwithhelmet
func unset_armor(armor:Armor):
	if armor.helmet!=null:
		$head/hair.visible=true
		$head/helmet.frames=null
func eyecolor(color:Color):
	$head/eyeleft.modulate=color
	$head/eyeright.modulate=color
func waitforskin():
	visualprefs.fetch()
	visualprefs.connect("loaded",self,"applyskin")
func applyskin():
	print("got skin")
	if visualprefs.preferences.has("chests"):
		get_parent().frames=visualprefs.getframe("chests")
	if visualprefs.preferences.has("heads"):
		$head.setframes(int(visualprefs.getpref("heads")),visualprefs.getframe("heads"))
	if visualprefs.preferences.has("eyecolor"):
		eyecolor(visualprefs.preferences["eyecolor"]["Value"])
	if visualprefs.preferences.has("hair"):
		$head.sethair(visualprefs.getframe("hair"))
	if visualprefs.preferences.has("facialhair"):
		$head/facialhair.frames=visualprefs.getframe("facialhair")
