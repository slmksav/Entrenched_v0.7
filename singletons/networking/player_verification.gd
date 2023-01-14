extends Node

signal auth_success(peer)
signal auth_failed(peer, reason, reason_failed)
signal ignore_auth_control(auth_control_name)

var _auth_control_funcs: Array = []
var _auth_controls: Dictionary = {}

var verify_controls: GDScript = preload("res://singletons/networking/utils/verify_controls.gd")


func _ready():
	add_auth_control("player_exist", get_ref("verify_user_exist"))



func get_ref(function: String) -> FuncRef:
	return funcref(verify_controls, function)


func add_auth_control(name_auth: String, auth_control: FuncRef, reason_failed: String = "") -> int:
	if _auth_controls.has(name_auth): return ERR_ALREADY_EXISTS
	_auth_control_funcs.append(auth_control)
	var idx: int = _auth_control_funcs.find(auth_control)
	_auth_controls[name_auth] = {
		"auth_func_idx": idx,
		"reason_failed": reason_failed
	}
	return OK



func remove_auth_control(name_auth: String):
	if not _auth_controls.has(name_auth): return
	_auth_control_funcs.remove(_auth_controls["auth_func_idx"])
	_auth_controls.erase(name_auth)


func auth_player(peer: int, data_use: Dictionary):
	var is_auth: bool = true
	var control_failed: String
	var reason_failed: String
	
	for control_func in _auth_controls.keys():
		var control: FuncRef = _auth_control_funcs[_auth_controls["auth_func_idx"]]
		var passed = control.call_func(peer, data_use)
		if typeof(passed) != TYPE_BOOL: 
			emit_signal("ignore_auth_control", control_func)
			continue
		
		if not passed:
			emit_signal("auth_failed", peer, control_func, _auth_controls[control_func]["reason_failed"])
			control_failed = control_func
			reason_failed = _auth_controls[control_func]["reason_failed"]
			is_auth = false
			break
	
	if not is_auth:
		_auth_failed_notify(peer, control_failed, reason_failed)
		return
	
	
	emit_signal("auth_success", peer)



func _auth_success_notify(peer: int):
	pass



func _auth_failed_notify(peer: int, auth_control_name: String, reason: String):
	rpc_id(peer, "_remote_auth_failed_notify", auth_control_name, reason)
	Multiplayer._enet.disconnect_peer(peer)



remote func _remote_auth_success_notify(extra_data: Dictionary = {}):
	Multiplayer.set_status(Multiplayer.CONNECTED)
	emit_signal("client_auth_success", extra_data)



remote func _remote_auth_failed_notify(auth_control_name: String, reason: String):
	emit_signal("_client_auth_failed", auth_control_name, reason)
	Multiplayer.set_status(Multiplayer.NIL)
