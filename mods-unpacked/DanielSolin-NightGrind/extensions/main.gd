extends "res://main.gd"

const MATERIAL_DROP_FACTOR: float = 1.0 / 5.0


func spawn_gold(value: float, pos: Vector2, spread: int) -> void:
	.spawn_gold(value * MATERIAL_DROP_FACTOR, pos, spread)


func clean_up_room() -> void:
	for gold in _active_golds:
		if is_instance_valid(gold):
			gold.hide()
			gold.set_deferred("monitorable", false)
			gold.queue_free()
	_active_golds.clear()
	.clean_up_room()
