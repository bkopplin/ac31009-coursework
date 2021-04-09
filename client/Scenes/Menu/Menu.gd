extends Control

onready var login_screen = get_node("LoginScreen")
onready var signup_screen = get_node("SignupScreen")
onready var playerList_screen = get_node("PlayerList")
onready var lobby_screen = get_node("Lobby")

onready var current_screen = login_screen
onready var inital_screen = login_screen # for debugging purposes

func _ready() -> void:
	login_screen.visible = true
	signup_screen.visible = false
	playerList_screen.visible = false
	lobby_screen.visible = false
	current_screen = inital_screen
	current_screen.visible = true
	
	if is_login_required():
		change_current_screen(login_screen)
	else:
		change_current_screen(playerList_screen)
	if inital_screen != null:
		change_current_screen(inital_screen)


func change_current_screen(new_screen: Control) -> void:
	current_screen.visible = false
	current_screen = new_screen
	current_screen.visible = true

func changeto_playerList_screen() -> void:
	change_current_screen(playerList_screen)	

func changeto_signup_screen() -> void:
	change_current_screen(signup_screen)

func changeto_login_screen() -> void:
	change_current_screen(login_screen)

func is_login_required() -> bool:
	# TODO: Check if Authentication tokens are stored on disk
	return true


func _on_Services_return_verification_result(result) -> void:
	if result:
		changeto_playerList_screen()
	else:
		current_screen.error_message("cannot connect to Services")

func _on_Services_start_lobby(_lobby_state) -> void:
	change_current_screen(lobby_screen)
