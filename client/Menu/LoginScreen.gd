extends Control

var signupScreen = preload("res://Menu/SignupScreen.tscn")
onready var usernameBox = get_node("VBoxContainer/Username")
onready var passwordBox = get_node("VBoxContainer/Password")

func _on_LinkButton_pressed() -> void:
	get_tree().change_scene_to(signupScreen)


func _on_ButtonLogin_pressed() -> void:
	var username = usernameBox.text()
	var password = passwordBox.text()
	password = password.sha256_text()
	Gateway.login_request(username, password)
