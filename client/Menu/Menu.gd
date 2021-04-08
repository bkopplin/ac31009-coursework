extends Control

var login_screen = preload("res://Menu/LoginScreen.tscn").instance()
var signup_screen = preload("res://Menu/SignupScreen.tscn").instance()
var playerList_screen = preload("res://Menu/PlayerList.tscn").instance()
var lobby_screen = preload("res://Menu/Lobby.tscn").instance()

var tree: SceneTree
var current_screen: Node = login_screen
var inital_screen: Node = login_screen # for debugging purposes

func _ready() -> void:
	if is_login_required():
		change_current_screen(login_screen)
	else:
		change_current_screen(playerList_screen)
	if inital_screen != null:
		change_current_screen(inital_screen)


func change_current_screen(new_screen: Node) -> void:
	remove_child(current_screen)
	current_screen = new_screen
	add_child(current_screen)

func changeto_playerList_screen() -> void:
	change_current_screen(playerList_screen)	

func changeto_signup_screen() -> void:
	change_current_screen(signup_screen)

func changeto_login_screen() -> void:
	change_current_screen(login_screen)

func is_login_required() -> bool:
	return true

func return_auth_results(token: String, result: bool) -> void:
	if result:
		Global.token = token
		Services.connect_to_services()
	else:
		current_screen.error_message("login failed")


func return_service_connection_result(result) -> void:
	if result:
		changeto_playerList_screen()
	else:
		current_screen.error_message("cannot connect to Services")

func update_available_players(players) -> void:
	if current_screen == playerList_screen:
		current_screen.update_available_players(players)

func _on_login_results_received():
	print("login results in menu received with signals")
