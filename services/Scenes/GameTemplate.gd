extends Node2D

var current_level_id: String
var players: Array
var player_state_buffer: Dictionary
var players_done_preconfiguring: Array
var world_state: Dictionary
var in_exit_area: Array

func _ready() -> void:
	self.set_physics_process(false)

func _on_done_preconfiguring(client_id: int) -> void:
	Logger.debug("in Game: _on_done_preconfiguring: " + str(client_id))
	players_done_preconfiguring.append(client_id)
	if players_done_preconfiguring.size() == 2:
		for client_id in players_done_preconfiguring:
			Services.post_configure_game(client_id)
		self.set_physics_process(true)

func _on_receive_player_state(client_id: int, player_state):
	if player_state_buffer.has(client_id):
		if player_state_buffer[client_id].t < player_state.t:
			player_state_buffer[client_id] = player_state
	else:
		player_state_buffer[client_id] = player_state

func _physics_process(delta: float):
	if player_state_buffer.empty():
		Logger.debug("player state buffer empty")
		return
	
	world_state.t = OS.get_system_time_msecs()
	world_state.positions = {}
	for player in player_state_buffer:
		world_state.positions[player] = player_state_buffer[player].position
		
	for client_id in players_done_preconfiguring:
		Services.send_world_state(client_id, world_state)

func _on_exit_area_entered(client_id: int) -> void:
	if not in_exit_area.has(client_id):
		in_exit_area.append(client_id)
	if in_exit_area.size() == players.size():
		current_level_id = Global.get_next_level(current_level_id)
		for player_id in in_exit_area:
			Services.load_next_level(player_id, current_level_id)
		
		in_exit_area.clear()


func _on_exit_area_left(client_id: int) -> void:
	if in_exit_area.has(client_id):
		in_exit_area.erase(client_id)

func _on_player_left_game(client_id: String) -> void:
	Logger.info("player " + str(client_id) + "disconnected")
