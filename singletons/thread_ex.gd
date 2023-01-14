extends Thread
class_name ThreadEx,"res://singletons/threadexspr.png"

signal thread_finish(thread_instance)

var destroy_inactivity: bool = true setget set_detroy_inactivity, is_detroy_inactivity


var _instance: Object
var _method: String
var _userdata
var _priority: int setget set_priority


func execute() -> int:
	return start(self, "_worker", _userdata, _priority)


func create_thread(instance: Object, method: String, userdata = null, priority: int = 1) -> int:
	_instance = _instance
	_method = method
	_userdata = userdata
	_priority = _priority
	return execute()


func _worker(data):
	_instance.call(_method, data)
	emit_signal("thread_finish", self)


func set_priority(value: int):
	_priority = value

func set_detroy_inactivity(value: bool):
	destroy_inactivity = value


func is_detroy_inactivity() -> bool:
	return destroy_inactivity



