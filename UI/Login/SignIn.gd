tool
extends Node


export(NodePath) var email_path: NodePath = "" setget set_email_path
export(NodePath) var password_path: NodePath = "" setget set_password_path
export(NodePath) var signin_btn_path: NodePath = "" setget set_signin_btn_path

onready var email: LineEdit = get_node_or_null(email_path)
onready var password: LineEdit = get_node_or_null(password_path)
onready var signin_btn: Button = get_node_or_null(signin_btn_path)


func set_email_path(new_path: NodePath):
	if not get_node(new_path) is LineEdit:
		printerr("The node must be of type LineEdit")
		return
	
	email_path = new_path


func set_password_path(new_path: NodePath):
	if not get_node(new_path) is LineEdit:
		printerr("The node must be of type LineEdit")
		return
	
	password_path = new_path


func set_signin_btn_path(new_path: NodePath):
	if not get_node(new_path) is LineEdit:
		printerr("The node must be of type LineEdit")
		return
	
	signin_btn_path = new_path


func _get_configuration_warning() -> String:
	if email_path == "":
		return "You must assign a LineEdit for the mail"
	if password_path == "":
		return "You must assign a LineEdit for the password"
	if signin_btn_path == "":
		return "You must assign a Button for the SignIn"
	
	return ""


func _ready():
	if Engine.is_editor_hint(): return
	
	assert(email != null)
	assert(password != null)
	assert(signin_btn != null)
	
	signin_btn.connect("pressed", self, "_on_signin_pressed")
	UserData.connect("login_ok", self, "_on_login_ok")
	UserData.connect("login_fail", self, "_on_login_fail")
	



func _on_signin_pressed():
	pass


func go_singup():
	get_tree().call_deferred("change_scene", "res://UI/Login/SignUp.tscn")
	queue_free()



