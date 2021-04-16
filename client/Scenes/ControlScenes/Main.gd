extends Node

onready var menu = get_node("Menu")
onready var game_manager = get_node("GameManager")

func _ready() -> void:
	print("starting game")
	set_physics_process(false)
	game_manager.visible = false
	
	#set_physics_process(true)
	#var temp = {}
	#temp.game_id = "3434234324"
	#temp.players = [{"username": "player1", "id": "11111d1111", "colour": "green"}, {"username": "player2", "id": "222222222222222", "colour": "blue"}]
	#temp.selected_level = "2"
	#Global.username = "player1"
	#game_manager._on_pre_configure_game(temp)
	Services.connect_to_services()

func start_game():
	menu.visible = false
	game_manager.visible = true
	Global.in_game = true
