extends Node

signal create_account(data, request_data)
signal login(data, response_data)


func login_with_email(data: Dictionary):
	"""
	data structure:
		Email: String
		Password: String
		CustomTags: Object (JSON)
		InfoRequestparameters: PlayFab API REST doc
		
	
	"""
	data = UserData.add_title_id_to_dict(data)
	data["InfoRequestparameters"] = {
			"GetUserAccountInfo": true
		}
	PlayFab.Client.LoginWithEmailAddress(data, funcref(self, "_request_login_completed"))


func login_with_steam(data: Dictionary):
	return
	
	"""
	data stucture:
		CreateAccount: bool
		CustomTags: Object (JSON)
		InfoRequestparameters: PlayFab API REST doc
	"""
	
	data["SteamTicket"] = UserData.steam_ticket
	PlayFab.Client.LoginWithSteam(data, funcref(self, "_request_login_completed"))


func create_account(data: Dictionary):
	"""
	data structure:
		Username: String
		Email: String
		Password: String
		DisplayName: String
		CustomTags: Object (JSON)
		InfoRequestparameters: PlayFab API REST doc
		RequireBothUsernameAndEmail: boolean
	"""
	
	data = UserData.add_title_id_to_dict(data)
	PlayFab.Client.RegisterPlayFabUser(data, funcref(self, "_request_create_account_completed"))


func _request_login_completed(h_request: int, response_code: int, headers, json_result: JSONParseResult):
	var json: Dictionary = json_result.get_result()
	var code: int = json.code
	
	if code == 400 and UserData.auto_login:
		print("\n\nAutomatic authentication in development mode")
		print(json)
		print("\n\n")
		OS.alert("An error occurred when logging in automatically with the administrator account. Please check the console and report the error!", 
		"Auto Login Error")
	
	UserData.player_id = json["data"]["InfoResultPayload"]["AccountInfo"]["PlayFabId"]
	UserData.email = json["data"]["InfoResultPayload"]["AccountInfo"]["PrivateInfo"]["Email"]
	UserData.user_name = json["data"]["InfoResultPayload"]["AccountInfo"]["Username"]
	UserData.login = true
	
	emit_signal("login", json["data"]["InfoResultPayload"], {
		"h_request": h_request,
		"response_code": response_code,
		"headers": headers,
		"json": json
		})


func _request_create_account_completed(h_request: int, response_code: int, headers, json_result: JSONParseResult):
	var json: Dictionary = json_result.get_result()
	
	emit_signal("create_account", json, {
		"h_request": h_request,
		"response_code": response_code,
		"headers": headers,
		"json": json
		})

