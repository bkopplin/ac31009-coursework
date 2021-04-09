extends Node

var token_list: Dictionary

func add_token(token: String, username: String) -> void:
	token_list[username] = token

func verify(token: String, username: String) -> bool:
	var verified = false
	while OS.get_unix_time() - int(token.right(64)) <= 30 and not verified:
		if token_list.has(username) and token_list[username] == token:
			verified = true
		else:
			yield(get_tree().create_timer(2), "timeout")
	return true if verified else false
