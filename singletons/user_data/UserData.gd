tool
extends Node


signal get_account_info(data, request_data)
signal get_player_data(data, request_data)
signal update_player_data(data, request_data)
signal delete_player_data(data, request_data)


export(String) var title_id: String = "" setget set_title_id
export(String) var secret_key: String = "" setget set_secret_key
export(String) var steam_ticket = "" setget set_steam_ticket
export(bool) var auto_login: bool = false

var player_id: String
var user_name: String
var email: String
var avatar: Image
var login: bool = false


func set_title_id(new_title_id: String):
	title_id = new_title_id
	update_configuration_warning()


func set_secret_key(new_secret_key: String):
	secret_key = new_secret_key
	update_configuration_warning()


func set_steam_ticket(new_ticket: String):
	steam_ticket = new_ticket
	update_configuration_warning()


func _get_configuration_warning() -> String:
	if title_id == "":
		return "You must set the valid Title ID"
	if secret_key == "":
		return "You must set the valid Secret Key"
	return ""


func add_title_id_to_dict(dict: Dictionary) -> Dictionary:
	dict["TitleId"] = title_id
	return dict


func _ready():
	if Engine.is_editor_hint(): return
	
	assert(title_id != "")
	assert(secret_key != "")
	
	PlayFabSettings.TitleId = title_id
	PlayFabSettings.DeveloperSecretKey = secret_key


func auto_login():
	if auto_login:
		Auth.login_with_email({
		"TitleId": title_id,
		"Email": "administrator@test.com",
		"Password": "123456",
		"InfoRequestparameters": {
			"GetUserAccountInfo": true
		}
		})


func get_account_info(data: Dictionary):
	PlayFab.Client.GetAccountInfo(data, funcref(self, "_request_get_info_completed"))


func get_player_data(get_keys: PoolStringArray):
	if not login:
		auto_login()
		yield(Auth, "login")
	
	var data: Dictionary = {
		"Keys": get_keys
	}
	PlayFab.Client.GetUserData(data, funcref(self, "_request_get_data"))


func update_player_data(data: Dictionary, Permission: String, CustomTags: Dictionary = {}):
	if not login:
		auto_login()
		yield(Auth, "login")
	
	var data_update: Dictionary = {
		"Data": data,
		"Permission": Permission,
		"CustomTags": CustomTags
	}
	PlayFab.Client.UpdateUserData(data_update, funcref(self, "_request_update_data"))


func delete_data(keys_remove: PoolStringArray, Customtags: Dictionary = {}):
	if not login:
		auto_login()
		yield(Auth, "login")
	
	var data: Dictionary = {
		"Customtags": Customtags,
		"KeysToRemove": keys_remove
	}
	PlayFab.Client.UpdateUserData(data, funcref(self, "_request_delete_data"))





func _request_get_info_completed(h_request: int, response_code: int, headers, json_result: JSONParseResult):
	var json: Dictionary = json_result.get_result()
	
	emit_signal("get_account_info", json, {
		"h_request": h_request,
		"response_code": response_code,
		"headers": headers,
		"json": json
		})


func _request_get_data(h_request: int, response_code: int, headers, json_result: JSONParseResult):
	var json: Dictionary = json_result.get_result()
	emit_signal("get_player_data", json["data"]["Data"], {
		"h_request": h_request,
		"response_code": response_code,
		"headers": headers,
		"json": json
		})


func _request_update_data(h_request: int, response_code: int, headers, json_result: JSONParseResult):
	var json: Dictionary = json_result.get_result()
	emit_signal("update_player_data", json, {
		"h_request": h_request,
		"response_code": response_code,
		"headers": headers,
		"json": json
		})


func _request_delete_data(h_request: int, response_code: int, headers, json_result: JSONParseResult):
	var json: Dictionary = json_result.get_result()
	
	emit_signal("delete_player_data", json, {
		"h_request": h_request,
		"response_code": response_code,
		"headers": headers,
		"json": json
		})



