extends Node
#a key for each action waited, containing an array
#that array contains each level of input priority
#each level has an array of objects waiting in it.
#the bigger the priority number the lower the priority
var recievers: Dictionary = {}
#sometimes big UI nodes requiere your attention
#and weapons need to stop working, so you can set this
#as the max layer to recieve inputs, if -1, not enforced.
var blockagelayer=-1
#actions avaliable for use in is_pressed
export(Array,String) var keeptrackof
var ispressed={}
var force={}
func getforce(action:String,priority:int):
	if blockagelayer>priority or blockagelayer==-1:
		return force[action]
	else:
		return 0
func _ready():
	for i in keeptrackof:
		ispressed[i]=false
		force[i]=0
func waitfor(who:Node,action:String,priority:int):
	if not InputMap.get_actions().has(action):
		globals.iprint(["action",action,"doesnt exist"],"input",true)
	else:
		#add the element
		#if no one is waiting for that
		if not recievers.has(action):
			recievers[action]=[[]]
		#if theres no array of that priority level
		if recievers[action].size()<priority+1:
			recievers[action].resize(priority+1)
			for i in recievers[action].size():
				if recievers[action][i]==null:
					recievers[action][i]=[]
		recievers[action][priority].append(who)
var lastinput:InputEvent
func _unhandled_input(event:InputEvent):
	for i in recievers.keys().size():
		#see if someone is waiting for that action
		if event.is_action(recievers.keys()[i]):
			var levels=recievers[recievers.keys()[i]] as Array
			#browse through the priority list
			for j in levels.size():
				if blockagelayer!=-1 and j>blockagelayer:
					return
				#browse through the wating list
				for l in levels[j].size():
					var who=levels[j][l]
					if who!=null and is_instance_valid(who) and who.has_method("newinput"):
						if who.call("newinput",event)==true:
							get_tree().set_input_as_handled()
							return
			break
	for i in keeptrackof:
		if event.is_action_pressed(i):
			ispressed[i]=true
			force[i]=event.get_action_strength(i)
		if event.is_action_released(i):
			ispressed[i]=false
			force[i]=0
