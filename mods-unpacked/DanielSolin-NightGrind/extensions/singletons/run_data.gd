extends "res://singletons/run_data.gd"


func get_stat_gain(stat_hash: int, player_index: int) -> float:
	if stat_hash == Keys.stat_harvesting_hash:
		return 0.0
	return .get_stat_gain(stat_hash, player_index)


func get_player_effect(key: int, player_index: int):
	if key == Keys.instant_gold_attracting_hash:
		return 0
	if key == Keys.pickup_range_hash:
		return 0
	return .get_player_effect(key, player_index)
