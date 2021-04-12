extends Node2D

var player_state_buffer: Dictionary
var players_done_preconfiguring: Array
var world_state: Dictionary

func _ready() -> void:
	self.set_physics_process(false)

func _on_done_preconfiguring(client_id: int) -> void:
	print("in Game: _on_done_preconfiguring: " + str(client_id))
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
		print("player state buffer empty")
		return
	
	world_state.t = OS.get_system_time_msecs()
	world_state.positions = {}
	for player in player_state_buffer:
		world_state.positions[player] = player_state_buffer[player].position
		
	for client_id in players_done_preconfiguring:
		Services.send_world_state(client_id, world_state)