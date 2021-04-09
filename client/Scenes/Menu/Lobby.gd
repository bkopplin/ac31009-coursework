extends Control

onready var level_list = get_node("LevelList")
onready var start_button = get_node("ControlContainer/StartGameButton")
onready var start_button_label = get_node("ControlContainer/StartGameButton/Label")
onready var error_label = get_node("ErrorLabel")

var lobby_state: Dictionary

var ready: bool = false

func _on_Services_start_lobby(lobby: Dictionary) -> void:
	lobby_state = lobby
	for level in lobby.levels:
		level_list.add_item(level.name)


func _on_StartGameButton_pressed() -> void:
	ready = not ready
	start_button_label.text = "waiting ..." if ready else "ready?" 
	Services.ready_button_pressed(lobby_state.id, ready)

func _on_GoBackButton_pressed() -> void:
	pass # Replace with function body.

func _on_Services_lobby_update_selected(index: int) -> void:
	level_list.select(index)

func _on_LevelList_item_selected(index: int) -> void:
	print("item selected")

func error_message(message: String) -> void:
	error_label.text = message
