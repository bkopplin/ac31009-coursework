extends Control

onready var available_players = get_node("AvailablePlayers")

func _ready() -> void:
	Services.fetch_available_players()


func _on_InviteButton_pressed() -> void:
	var selected: String = ""
	if available_players.is_anything_selected():
		var selected_items: PoolIntArray = available_players.get_selected_items()
		selected = available_players.get_item_text(selected_items[0]) if selected_items.size() == 1 else ""
	print(selected)


func update_available_players(players: Array):
	#players.erase(Global.username)
	available_players.clear()
	for player in players:
		available_players.add_item(player)

