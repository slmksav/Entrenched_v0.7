tool
extends Node

export(NodePath) var username_path: NodePath = "" setget set_username_path
export(NodePath) var email_path: NodePath = "" setget set_email_path
export(NodePath) var password_path: NodePath = "" setget set_password_path
export(NodePath) var confirm_password_path: NodePath = "" setget set_confirm_password_path
export(NodePath) var sign_up_btn_path: NodePath

onready var username: LineEdit = get_node_or_null(username_path)
onready var email: LineEdit = get_node_or_null(email_path)
onready var password: LineEdit = get_node_or_null(password_path)
onready var confirm_password: LineEdit = get_node_or_null(confirm_password_path)
onready var sign_up_btn: Button = get_node_or_null(sign_up_btn_path)


func set_username_path(new_path: NodePath):
	if not get_node(new_path) is LineEdit:
		printerr("The node must be of type LineEdit")
		return
	
	username_path = new_path
	update_configuration_warning()


func set_email_path(new_path: NodePath):
	if not get_node(new_path) is LineEdit:
		printerr("The node must be of type LineEdit")
		return
	
	email_path = new_path
	update_configuration_warning()


func set_password_path(new_path: NodePath):
	if not get_node(new_path) is LineEdit:
		printerr("The node must be of type LineEdit")
		return
	
	password_path = new_path
	update_configuration_warning()


func set_confirm_password_path(new_path: NodePath):
	if not get_node(new_path) is LineEdit:
		printerr("The node must be of type LineEdit")
		return
	
	confirm_password_path = new_path
	update_configuration_warning()


func _get_configuration_warning() -> String:
	if username_path == "":
		return "You must assign a LineEdit for the username"
	if email_path == "":
		return "You must assign a LineEdit for the mail"
	if password_path == "":
		return "You must assign a LineEdit for the password"
	if confirm_password_path == "":
		return "You must assign a LineEdit for the confirm password"
	if sign_up_btn_path == "":
		return "You must assign a Button for the SignUp"
	
	return ""



func _ready():
	if Engine.is_editor_hint(): return
	
	assert(username != null)
	assert(email != null)
	assert(password != null)
	assert(confirm_password != null)
	assert(sign_up_btn != null)
	
	confirm_password.connect("text_changed", self, "_on_text_changed")
	sign_up_btn.connect("pressed", self, "_on_sign_up_pressed")
	UserData.connect("create_account_ok", self, "_on_create_account_ok")
	UserData.connect("create_account_fail", self, "_on_create_account_fail")
	
	sign_up_btn.disabled = true


func _on_text_changed(new_text: String):
	var target_password: String = password.get_text()
	
	if target_password == new_text: sign_up_btn.disabled = false
	else: sign_up_btn.disabled = true


func _on_sign_up_pressed():
	pass


func go_singin():
	get_tree().call_deferred("change_scene", "res://UI/Login/SignIn.tscn")
	queue_free()



