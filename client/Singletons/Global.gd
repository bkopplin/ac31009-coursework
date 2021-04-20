extends Node

#var gateway_ip: = "192.168.178.73"
var gateway_ip: = "194.182.205.125"
var gateway_port: = 2000
#var services_ip: = "192.168.178.73"
var services_ip: = "194.182.205.125"
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

