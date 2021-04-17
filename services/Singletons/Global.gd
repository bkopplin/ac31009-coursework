extends Node

var levels: = {
		"1": {"name": "Beginner level", "next_level": "2"}, 
		"2": {"name": "Second Level", "next_level": "3"},
		"3": {"name": "Through the canyon", "next_level": "last_level"},
}

func get_next_level(level: String) -> String:
	if levels.has(level):
		return levels[level].next_level
	else:
		return ""
