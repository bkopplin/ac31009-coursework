extends Node

func _ready() -> void:
	Logger.level = 4
	Gateway.start_gateway()
	Authenticate.connect_to_authserver()
