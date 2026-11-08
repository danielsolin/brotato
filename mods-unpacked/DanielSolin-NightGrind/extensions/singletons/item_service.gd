extends "res://singletons/item_service.gd"

const NIGHTGRIND_BLOCKED_ITEMS = [
	"item_baby_gecko",
	"item_sifds_relic",
	"item_lootworm"
]

var _nightgrind_shop_generation = false


func _nightgrind_blocked_item(item) -> bool:
	return item != null and item.my_id in NIGHTGRIND_BLOCKED_ITEMS


func get_pool(item_tier: int, type: int) -> Array:
	var pool: Array = .get_pool(item_tier, type)
	if _nightgrind_shop_generation and type == TierData.ITEMS:
		for index in range(pool.size() - 1, -1, -1):
			if _nightgrind_blocked_item(pool[index]):
				pool.remove(index)
	return pool


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
		for item_id in NIGHTGRIND_BLOCKED_ITEMS:
			if guarantees[index][0] == Keys.generate_hash(item_id):
				guarantees.remove(index)
				break

	_nightgrind_shop_generation = true
	var offers: Array = .get_player_shop_items(wave, player_index, args)
	_nightgrind_shop_generation = false
	guarantees.clear()
	guarantees.append_array(original_guarantees)
	for index in range(offers.size() - 1, -1, -1):
		if _nightgrind_blocked_item(offers[index][0]):
			offers.remove(index)
	return offers
