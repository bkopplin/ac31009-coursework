extends Node

var example_db = '[{"username":"bjarne", "password":"Sdsfc34D234sDf3"}]'
var db: File
var db_path = "user://userdb.json"

func _ready() -> void:
	db = File.new()
	if not db.file_exists(db_path):
		db.open(db_path, File.WRITE)
		db.store_string(example_db)
		db.close()
	get_user("bjarne")

func get_user(username: String) -> Directory:
	db.open(db_path, File.READ)
	var content = db.get_as_text()
	var users = JSON.parse(db.get_as_text())
	if users.error != OK:
		print("Error while reading from database")
		return null
	users = users.result
	for user in users:
		if username == user.username:
			return user
	return null

func add_user(params: Directory) -> bool:
	pass
