extends MenuScreen

onready var usernameBox = get_node("LoginForm/Username")
onready var passwordBox = get_node("LoginForm/Password")
onready var menu = get_node("/root/Main/Menu")
#onready var error_dialog = get_node("ErrorDialog")
var username
var password


func _on_LinkButton_pressed() -> void:
	menu.changeto_signup_screen()


func _on_ButtonLogin_pressed() -> void:
	username = usernameBox.text.to_lower()
	password = passwordBox.text

	if not error_check():
		Gateway.login_request(username, password)
		Global.username = username

func error_check() -> bool:
	var error_message = ""
	var error = false
	var message = ""
	if username == "":
		message += "Username may not be empty\n"
		error = true
	if password == "":
		message += "Password may not be empty\n"
		error = true

	if error:
		show_error(error_message)
		return true
	else:
		hide_error()
		return false

func _on_login_result_received(token, result: bool):
	if result == true:
		Global.token = token
		Services.connect_to_services()
	else:
		show_error("login failed")
