extends Node

func authenticate(username: String, password: String) -> bool:
	var stored_password = Database.get_password(username)
	if stored_password == "":
		return false
	return true if stored_password == password.sha256_text() else false

func create_account(params: Dictionary) -> bool:
	return Database.add_user(params)
	

func generate_random_token() -> String:
	randomize()
	return str(randi()).sha256_text() + str(OS.get_system_time_secs())
