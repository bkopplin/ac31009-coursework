extends Node

var token: String setget set_token
var username: String setget set_username
var in_game: bool setget set_in_game
var unique_game_id: int 

func set_token(_token: String):
	token = _token

func set_username(_username: String):
	username = _username

func set_in_game(_in_game: bool) -> void:
	in_game = _in_game

