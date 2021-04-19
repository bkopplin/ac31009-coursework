extends MenuScreen

"""
lobby = {
	id
	players = [username, id, colour]
	levels
	selected_level
}
"""

export(Texture) var avatar_blue
export(Texture) var avatar_green
onready var level_list = get_node("LevelList")
onready var start_button = get_node("ControlContainer/StartGameButton")
onready var start_button_label = get_node("ControlContainer/StartGameButton/Label")
onready var player_local_name: = get_node("PlayerArea/PlayerLocalContainer/PlayerLocalName")
onready var character_local: = get_node("PlayerArea/PlayerLocalContainer/CharacterLocal")
onready var player_guest_name: = get_node("PlayerArea/PlayerGuestContainer/PlayerGuestName")
onready var character_guest: = get_node("PlayerArea/PlayerGuestContainer/CharacterGuest")

var lobby_state: Dictionary

var ready: bool = false

func _on_Services_start_lobby(lobby: Dictionary) -> void:
	lobby_state = lobby
	#for level in lobby.levels:
	#	level_list.add_item(level.name)
	for player in lobby.players:
		if player.id == Global.unique_game_id:
			player_local_name.text = player.username
			character_local.texture = avatar_blue if player.colour == "blue" else avatar_green
		else:
			player_guest_name.text = player.username
			character_guest.texture = avatar_blue if player.colour == "blue" else avatar_green

func _on_StartGameButton_pressed() -> void:
	ready = not ready
	start_button_label.text = "waiting ..." if ready else "ready?" 
	Services.ready_button_pressed(lobby_state.id, ready)

func _on_GoBackButton_pressed() -> void:
	pass # Replace with function body.

func _on_Services_lobby_update_selected(index: int) -> void:
	level_list.select(index)
	var level_id: = ""
	Services.lobby_change_level(lobby_state.lobby_id, level_id)

func _on_LevelList_item_selected(index: int) -> void:
	print("item selected")
	# TODO send selected item accross

func get_level_id(index: int) -> String:
	return ""
	
