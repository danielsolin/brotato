extends "res://singletons/item_service.gd"

func _nightgrind_blocked_item(item) -> bool:
	if item == null or not item is ItemData:
		return false
	return _nightgrind_has_blocked_effect(item)


func _nightgrind_blocked_upgrade(upgrade) -> bool:
	if upgrade == null or not upgrade is UpgradeData:
		return false
	return _nightgrind_has_blocked_effect(upgrade)


func _nightgrind_has_blocked_effect(data) -> bool:
	for effect in data.effects:
		if effect != null and effect.key in [
				"stat_harvesting", "harvesting_growth", "pickup_range",
				"instant_gold_attracting"
			]:
			return true
	return false


func get_upgrades(level: int, number: int, old_upgrades: Array, player_index: int) -> Array:
	_nightgrind_filter_level_upgrades()
	return .get_upgrades(level, number, old_upgrades, player_index)


func _nightgrind_filter_level_upgrades() -> void:
	for tier_data in _tiers_data:
		var upgrades: Array = tier_data[TierData.UPGRADES]
		for index in range(upgrades.size() - 1, -1, -1):
			if _nightgrind_blocked_upgrade(upgrades[index]):
				upgrades.remove(index)


func get_pool(item_tier: int, type: int) -> Array:
	var pool: Array = .get_pool(item_tier, type)
	if type == TierData.ITEMS:
		for index in range(pool.size() - 1, -1, -1):
			if _nightgrind_blocked_item(pool[index]):
				pool.remove(index)
	return pool


func update_pools(
		pool: Array, backup_pool: Array, player_index: int, item_tier: int, type: int
	) -> void:
	.update_pools(pool, backup_pool, player_index, item_tier, type)
	if type == TierData.ITEMS:
		for items in [pool, backup_pool]:
			for index in range(items.size() - 1, -1, -1):
				if _nightgrind_blocked_item(items[index]):
					items.remove(index)


func get_player_shop_items(
		wave: int,
		player_index: int,
		args: ItemServiceGetShopItemsArgs
	) -> Array:
	var guarantees: Array = RunData.get_player_effect(
		Keys.guaranteed_shop_items_hash,
		player_index
	)
	var original_guarantees = guarantees.duplicate()
	for index in range(guarantees.size() - 1, -1, -1):
		var item = get_element(get_items(), guarantees[index][0])
		if _nightgrind_blocked_item(item):
			guarantees.remove(index)

	var offers: Array = .get_player_shop_items(wave, player_index, args)
	guarantees.clear()
	guarantees.append_array(original_guarantees)
	for index in range(offers.size() - 1, -1, -1):
		if _nightgrind_blocked_item(offers[index][0]):
			offers.remove(index)
	return offers
