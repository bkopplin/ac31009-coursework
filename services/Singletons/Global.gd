extends Node

var levels: = {
		"1": {"name": "First Level", "next_level": "2"}, 
		"2": {"name": "Up and Down", "next_level": "3"},
		"3": {"name": "Flat Earth", "next_level": "last_level"},
}

func get_next_level(level: String) -> String:
	if levels.has(level):
		return levels[level].next_level
	else:
		return ""
