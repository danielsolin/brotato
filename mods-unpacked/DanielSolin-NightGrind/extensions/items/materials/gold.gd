extends "res://items/materials/gold.gd"


func _physics_process(delta: float) -> void:
	if is_instance_valid(attracted_by):
		if attracted_by is Player or attracted_by is Lootworm:
			attracted_by = null
	._physics_process(delta)
