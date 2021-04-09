extends Node
class_name Level

onready var spawnpoint_blue: Node2D = get_node("SpawnPoints/SpawnBlue")
onready var spawnpoint_green: Node2D = get_node("SpawnPoints/SpawnGreen")

func get_spawnpoint(colour: String) -> Vector2:
	if colour == "blue":
		return spawnpoint_blue.position
	else:
		return spawnpoint_green.position
	
