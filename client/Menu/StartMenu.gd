extends Control

var loginScreen = preload("res://Menu/LoginScreen.tscn")
var playerList = preload("res://Menu/PlayerList.tscn")

func _ready() -> void:
	if is_login_required():
		get_tree().change_scene_to(loginScreen)
	else:
		get_tree().change_scene_to(playerList)	
	
	
func is_login_required() -> bool:
	return true
