extends "res://ui/menus/run/difficulty_selection/difficulty_selection.gd"

const NIGHTMARE_DIFFICULTY := 6


func _get_all_possible_elements(player_index: int) -> Array:
	var nightmare = _get_nightmare_difficulty()
	if nightmare == null:
		return ._get_all_possible_elements(player_index)
	return [nightmare]


func _get_unlocked_elements(player_index: int) -> Array:
	var nightmare = _get_nightmare_difficulty()
	if nightmare == null:
		return ._get_unlocked_elements(player_index)
	return [nightmare.my_id_hash]


func _get_nightmare_difficulty():
	return ItemService.get_element(
		ItemService.difficulties,
		Keys.empty_hash,
		NIGHTMARE_DIFFICULTY
	)
