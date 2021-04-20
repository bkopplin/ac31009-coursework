extends Node

var level: = 1 setget set_level

func set_level(_level: int) -> void:
	if _level < 0 or _level > 4:
		return
	level = _level

func debug(text: String) -> void:
	if level >= 4:
		print(text)

func info(text: String) -> void:
	if level >= 3:
		print(text)

func warning(text: String) -> void:
	if level >= 2:
		print(text)

func error(text: String) -> void:
	if level >= 1:
		print(text)
