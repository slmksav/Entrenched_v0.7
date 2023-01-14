extends Node


var save_interval: float = 0 setget new_time_interval
var path_use: String
var world_data: Dictionary = {}
var players_data: Dictionary = {}
var game_data: Dictionary = {}

var timer: Timer = Timer.new()



func new_time_interval(new_time: float):
	if new_time < 0: new_time = 0
	save_interval = new_time
	timer.wait_time = save_interval
	if save_interval < 1:
		timer.stop()
	else:
		if timer.paused: timer.start()



func _ready():
	if not OS.has_feature("Server"): return
	
	var args: Dictionary = math.get_args()
	if args.has("save_data_path"):
		path_use = args["save_data_path"]
	
	add_child(timer, true)
	timer.wait_time = save_interval
	if save_interval > 1: timer.start()
	timer.connect("timeout", self, "_on_timeout")



func set_world_data(key: String, value):
	world_data[key] = value
	if save_interval < 1: save_data(world_data, path_use + "/world_data.json")



func get_world_data(keys: PoolStringArray = []) -> Dictionary:
	if keys.size() > 0:
		var data: Dictionary
		for k in keys:
			if world_data.has(k):
				data[k] = world_data[k]
		return data
	return world_data



func set_player_data(playfab_id: String, key: String, value):
	players_data[playfab_id][key] = value
	if save_interval < 1: save_data(players_data, path_use + "/players_data.json")



func get_player_data(playfab_id: String, keys: PoolStringArray = []) -> Dictionary:
	if players_data.has(playfab_id):
		if keys.size() > 0:
			var data: Dictionary = {}
			for k in keys:
				if players_data[playfab_id].has(k):
					data[k] = players_data[playfab_id][k]
			return data
		else: return players_data[playfab_id]
	return {}



func set_game_data(key: String, value):
	game_data[key] = value
	if save_interval < 1: save_data(game_data, path_use + "/game_data.json")



func get_game_data(keys: PoolStringArray = []) -> Dictionary:
	if keys.size() > 0:
		var data: Dictionary
		for k in keys:
			if game_data.has(k):
				data[k] = game_data[k]
		return data
	return game_data



func save_all():
	save_data(game_data, path_use + "/game_data.json")
	save_data(world_data, path_use + "/world_data.json")
	save_data(players_data, path_use + "/players_data.json")



func save_data(data: Dictionary, path: String):
	var file: File = File.new()
	file.open(path, File.WRITE)
	file.store_string(JSON.print(data, "\t"))
	file.close()
	file.free()



func load_data(path: String) -> Dictionary:
	var file: File = File.new()
	if not file.file_exists(path): return {}
	file.open(path, File.READ)
	var data_json: JSONParseResult = JSON.parse(file.get_as_text())
	
	if data_json.error != OK:
		globals.logger_err("Error loading JSON file '" + str(path) + "'.")
		globals.logger_err("\tError: %s" % data_json.error)
		globals.logger_err("\tError Line: %s" % data_json.error_line)
		globals.logger_err("\tError String: %s" % data_json.error_string)
		return {}
	
	file.free()
	return data_json.get_result()



func _on_timeout():
	save_all()



