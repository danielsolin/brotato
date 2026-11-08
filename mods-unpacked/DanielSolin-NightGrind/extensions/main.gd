extends "res://main.gd"

const MATERIAL_DROP_FACTOR: float = 1.0 / 5.0


func spawn_gold(value: float, pos: Vector2, spread: int) -> void:
	.spawn_gold(value * MATERIAL_DROP_FACTOR, pos, spread)
