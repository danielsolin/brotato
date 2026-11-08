extends "res://singletons/run_data.gd"


func get_stat_gain(stat_hash: int, player_index: int) -> float:
	if stat_hash == Keys.stat_harvesting_hash:
		return 0.0
	return .get_stat_gain(stat_hash, player_index)
