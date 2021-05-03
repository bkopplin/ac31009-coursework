extends Node

var gateway_ip: = "127.0.0.1"
var gateway_port: = 2000
var services_ip: = "127.0.0.1"
var services_port: = 2001

var token: String setget set_token
var username: String setget set_username
var game_id: String
var in_game: bool setget set_in_game
var unique_game_id: int 

func set_token(_token: String):
	token = _token

func set_username(_username: String):
	username = _username

func set_in_game(_in_game: bool) -> void:
	in_game = _in_game

func load_config() -> void:
	var default_config: = "res://Resources/Config/config.json"
	var config_file: = "user://config.json"
	var f: = File.new()
	if not f.file_exists(config_file):
		var d: = Directory.new()
		d.copy(default_config, config_file)
	f.open(config_file, File.READ)
	var config = JSON.parse(f.get_as_text())
	if config.error != OK:
		print("Error while parsing JSON: " + str(config.error))
		f.close()
		return
	config = config.result
	if config.has("gateway"):
		gateway_ip = config.gateway.ip if config.gateway.has("ip") else "194.182.205.125"
		gateway_port = int(config.gateway.port) if config.gateway.has("port") else 2000
	
	if config.has("services"):
		services_ip = config.services.ip if config.services.has("ip") else "194.182.205.125"
		services_port = int(config.services.port) if config.services.has("port") else 2001
	
