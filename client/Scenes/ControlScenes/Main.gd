extends Node

onready var menu = get_node("Menu")
onready var game_manager = get_node("GameManager")

func _ready() -> void:
	print("starting game")
	set_physics_process(false)
	game_manager.visible = false
	
	set_physics_process(true)
	game_manager._on_pre_configure_game(1, 1)

func start_game():
	menu.visible = false
	game_manager.visible = true
	Global.in_game = true
