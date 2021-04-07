extends Control

onready var username_box = get_node("SignupForm/Username")
onready var password_box = get_node("SignupForm/Password")
onready var password_repeat_box = get_node("SignupForm/PasswordRepeat")
onready var error_dialog = get_node("ErrorDialog")
onready var error_message = get_node("ErrorDialog/ErrorMessage")
onready var menu = get_node("/root/Menu")

var username 
var password
var password2

func _on_LinkButton_pressed() -> void:
	menu.changeto_login_screen()


func _on_ButtonLogin_pressed() -> void:

	username = username_box.text
	password = password_box.text
	password2 = password_repeat_box.text

	if not error_check():
		var params = {}
		params.username = username
		params.password = password
		Gateway.signup_request(params)

func error_check() -> bool:
	error_message.text = ""
	var error = false
	var message = ""
	if username == "":
		message += "Username may not be empty\n"
		error = true
	if password == "":
		message += "Password may not be empty\n"
		error = true
	if password2 == "":
		message += "repeated Password may not be empty\n"
		error = true
	if password != password2:
		message += "Passwords do not match\n"
		error = true
	
	if error:
		error_message.text = message
		error_dialog.show()
		return true
	else:
		error_dialog.hide()
		return false

func request_failed() -> void:
	error_message.text = "couldn't create account"
	error_dialog.show()
