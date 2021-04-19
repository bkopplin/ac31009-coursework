extends MenuScreen

onready var username_box = get_node("SignupForm/Username")
onready var password_box = get_node("SignupForm/Password")
onready var password_repeat_box = get_node("SignupForm/PasswordRepeat")
onready var menu = get_node("/root/Main/Menu")

var username 
var password
var password2

func _on_LinkButton_pressed() -> void:
	menu.changeto_login_screen()


func _on_ButtonLogin_pressed() -> void:

	username = username_box.text.to_lower()
	password = password_box.text
	password2 = password_repeat_box.text

	if not error_check():
		var params = {}
		params.username = username
		params.password = password
		Gateway.signup_request(params)
		Global.username = username

func error_check() -> bool:
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
		show_error(message)
		return true
	else:
		hide_error()
		return false

func _on_signup_result_received(token, result):
	print("SignupScreen: in _on_signup_result_received: results: " + str(result))
	if result:
		Global.token = token
		Services.connect_to_services()
	else:
		show_error("Signup failed")
