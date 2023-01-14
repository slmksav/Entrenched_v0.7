tool
extends Node

signal new_player(player)

signal new_logger(message, type)

signal changed_global_navigation(new_navigation)
signal new_world(new_world)
signal thread_finish(thread)



enum LOGGER_TYPE {
	MESSAGE,
	WARNING,
	ERROR
}

export(PoolStringArray) var presentation_groups: PoolStringArray
export(Texture) var game_cursor: Texture
export(Texture) var menu_cursor: Texture
export(Dictionary) var consoleshorts
export(Array, String, FILE, "*.tscn, *.scn, *res") var maps: Array = []

var console:Node2D
var player: Player setget set_player
var camera: Camera2D
var day_cycle_node: Node setget set_day_cycle_node, get_day_cycle_node
var global_navigation: Navigation2D setget set_global_navigation, get_global_navigation
var logger_history: PoolStringArray = []
var world: GlobalWorld setget new_world

var _threads: Array = []

var args: Dictionary = {}


func set_player(new_player: Player):
	player = new_player
	emit_signal("new_player", player)


func new_world(_new_world: GlobalWorld):
	world = _new_world
	emit_signal("new_world", world)
	yield(_new_world, "tree_entered")
	consoleshorts["world"] = world.get_path()


func _ready():
	set_pause_mode(PAUSE_MODE_PROCESS)
	set_menu_cursor()
	
	args = math.get_args()
	
	connect("new_logger", self, "_on_new_logger")


func _process(delta: float):
	if _threads.size() > 0:
		for t in _threads:
			if not t.is_destroy_inactivity() or t.is_active():
				continue
			else: 
				_threads.erase(t)
				t.free()


func _exit_tree():
	if _threads.size() > 0:
		for t in _threads:
			t.wait_to_finish()


func set_day_cycle_node(new_node: Node):
	day_cycle_node = new_node


func get_day_cycle_node() -> Node:
	return day_cycle_node


func set_global_navigation(new_global_navigation: Navigation2D):
	global_navigation = new_global_navigation


func get_global_navigation() -> Navigation2D:
	return global_navigation



func iprint(text,category="default",iserror=false):
	if console==null or Engine.editor_hint:
			prints(text)
	else:
		if text is Array:
			console.printsline(text,iserror,category)
		else:
			console.printsline([text],iserror,category)


func set_game_cursor():
	if game_cursor == null:
		printerr("Game Cursor not assigned")
		return
	Input.set_custom_mouse_cursor(game_cursor, Input.CURSOR_ARROW)


func set_menu_cursor():
	if menu_cursor == null:
		printerr("Menu Cursor not assigned")
		return
	Input.set_custom_mouse_cursor(menu_cursor, Input.CURSOR_ARROW)


func create_thread(instance: Object, method: String, userdata = null, priority: int = 1) -> Dictionary:
	var t: ThreadEx = ThreadEx.new()
	_threads.append(t)
	return {
		"thread": t,
		"err": t.create_thread(instance, method, userdata, priority)
	}


func presentation_mode(value: bool):
	for i in presentation_groups:
		get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, i, "set", "visible", not value)


func logger(message: String, debug: bool = true):
	if debug: print_debug(message)
	else: print(message)
	emit_signal("new_logger", message, LOGGER_TYPE.MESSAGE)

func logger_war(message: String):
	push_warning(message)
	emit_signal("new_logger", message, LOGGER_TYPE.WARNING)


func logger_err(message: String, debug: bool = true):
	if debug: 
		push_error(message)
	else: printerr(message)
	emit_signal("new_logger", message, LOGGER_TYPE.ERROR)


func _on_new_logger(message: String, type: int):
	var is_error: bool = false
	if type == LOGGER_TYPE.ERROR: is_error = true
	iprint(message,"log", is_error)
	var time: Dictionary = OS.get_time()
	logger_history.append("(" + str(time.hour) + ":" + str(time.minute) + ":" + str(time.second) + "): " + message)


func is_release() -> bool:
	return OS.has_feature("release")


remote func callonconsole(function:String,args:Array):
	iprint("got console command","consolecode")
	console.callv(function,args)
