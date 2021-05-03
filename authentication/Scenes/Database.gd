extends Node

var example_db = '[]'
var db: File
var db_path = "user://userdb.json"

func _ready() -> void:
	db = File.new()
	if not db.file_exists(db_path):
		db.open(db_path, File.WRITE)
		db.store_string(example_db)
		db.close()

func get_user(username: String) -> Directory:
	"""
	return user data for a user with user name username
	return null if operation failed
	"""
	db.open(db_path, File.READ)
	var users = JSON.parse(db.get_as_text())
	if users.error != OK:
		Logger.error("in get_user(): Error while parsing JSON: " + str(users.error))
		db.close()
		return null
	users = users.result
	for user in users:
		if username == user.username:
			db.close()
			return user
	db.close()
	return null

func get_password(username: String) -> String:
	var user = get_user(username)
	if user == null or not user.has("password"):
		return ""
	return user.password

func add_user(userparams: Dictionary) -> bool:
	"""
	adds a user to the user database
	"""
	db.open(db_path, File.READ_WRITE)
	var users = JSON.parse(db.get_as_text())
	if users.error != OK:
		Logger.error("in add_user(): error while parsing JSON: " + users.error)
		db.close()
		return false
	users = users.result
	print(users)
	for user in users:
		if userparams.username == user.username:
			Logger.error("in add_user(): user " + userparams.username + " already exists")
			db.close()
			return false 
	var new_user: Dictionary
	new_user.username = userparams.username
	new_user.password = userparams.password.sha256_text()
	users.append(new_user)
	db.store_string(JSON.print(users))
	db.close()
	return true
