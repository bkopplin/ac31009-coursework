extends Node

func _ready() -> void:
	Logger.level = 4
	Services.start_services()
	TokenTransfer.connect_to_token_transfer()
