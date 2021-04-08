extends Control

onready var usernameBox = get_node("LoginForm/Username")
onready var passwordBox = get_node("LoginForm/Password")
onready var menu = get_node("/root/Menu")
onready var error_dialog = get_node("ErrorDialog")
onready var error_message = get_node("ErrorDialog/ErrorMessage")
var username
var password


func _on_LinkButton_pressed() -> void:
	menu.changeto_signup_screen()


func _on_ButtonLogin_pressed() -> void:
	username = usernameBox.text
	password = passwordBox.text

	if not error_check():
		Gateway.login_request(username, password)
		Global.username = username

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

	if error:
		error_message.text = message
		error_dialog.show()
		return true
	else:
		error_dialog.hide()
		return false

func error_message(message: String) -> void:
	error_message.text = message
	error_dialog.show()

func _on_login_result_received(token, result):
	print("LoginScreen: in _on_login_results_received: results: " + str(result))
	if result:
		Global.token = token
		Services.connect_to_services()
	else:
		error_message("login failed")
