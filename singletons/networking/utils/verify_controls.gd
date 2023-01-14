extends Node

signal req_completed(h_request, response_code, headers, json_result)


func request_completed(h_request: int, response_code: int, headers, json_result: JSONParseResult):
	emit_signal("req_completed", h_request, response_code, headers, json_result)



func verify_user_exist(data: Dictionary):
	var playfab_id: String = data["player_id"]
	
	if ServerData.players_data.has(playfab_id):
		return true
	
	# verify PlayFab ID Exist
	var result: Dictionary = yield(self, "req_completed")[3].get_result()
	


