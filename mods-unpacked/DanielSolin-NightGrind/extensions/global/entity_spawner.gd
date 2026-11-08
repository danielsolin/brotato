extends "res://global/entity_spawner.gd"


func spawn(queue_from: Array, player_index := -1) -> void:
	for index in range(queue_from.size() - 1, -1, -1):
		if queue_from[index].data is LootwormEffect:
			queue_from.remove(index)
	.spawn(queue_from, player_index)
