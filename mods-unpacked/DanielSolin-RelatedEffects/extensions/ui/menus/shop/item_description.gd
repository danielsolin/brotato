extends "res://ui/menus/shop/item_description.gd"

const EFFECT_SCRIPT_PATH := "res://items/global/effect.gd"

var _related_effect_lines := []


func set_item(
	item_data: ItemParentData,
	player_index: int,
	item_count: int = 1
) -> void:
	_clear_related_effect_lines()
	.set_item(item_data, player_index, item_count)

	if player_index < 0 or item_data == null:
		return
	if hide_description_if_locked_in_codex and item_data._is_locked_in_codex():
		return

	var player_effects = RunData.get_player_effects(player_index)
	var stat_links = player_effects.get(Keys.stat_links_hash, [])
	if not stat_links is Array or stat_links.empty():
		return

	for item_effect in item_data.effects:
		if not _is_standard_effect(item_effect):
			continue
		if item_effect.key == "" or item_effect.value == 0:
			continue

		var source_text: String = item_effect.get_text(player_index, false)
		if source_text == "" or source_text == "[EMPTY]":
			continue

		var changed_stat_hash: int = Keys.generate_hash(item_effect.key)
		for stat_link in stat_links:
			if not stat_link is Array or stat_link.size() < 5:
				continue
			if int(stat_link[2]) != changed_stat_hash:
				continue

			var step_size: int = int(stat_link[3])
			if step_size == 0:
				continue
			if bool(stat_link[4]) and item_effect.custom_key != "":
				continue

			var output_delta: float = (
				float(stat_link[1]) * float(item_effect.value) / float(step_size)
			)
			var rounded_delta: float = round(output_delta)
			if abs(output_delta - rounded_delta) > 0.001:
				continue
			if rounded_delta == 0.0:
				continue

			_add_related_effect(
				player_index,
				int(stat_link[0]),
				int(rounded_delta),
				source_text
			)


func _clear_related_effect_lines() -> void:
	for related_line in _related_effect_lines:
		if not is_instance_valid(related_line):
			continue

		var parent = related_line.get_parent()
		if parent != null:
			parent.remove_child(related_line)
		related_line.free()

	_related_effect_lines.clear()


func _is_standard_effect(effect: Resource) -> bool:
	if not effect is Effect:
		return false

	var effect_script: Script = effect.get_script()
	return effect_script != null and effect_script.resource_path == EFFECT_SCRIPT_PATH


func _add_related_effect(
	player_index: int,
	output_stat_hash: int,
	output_delta: int,
	source_text: String
) -> void:
	var output_key: String = Keys.hash_to_string.get(output_stat_hash, "")
	if output_key == "":
		return

	var preview_effect: Effect = Effect.new()
	preview_effect.key = output_key
	preview_effect.key_hash = output_stat_hash
	preview_effect.value = output_delta
	preview_effect.custom_args = []

	var preview_text: String = preview_effect.get_text(player_index, true)
	if preview_text == "":
		return

	var related_line = effect_line.instance()
	_related_effect_lines.append(related_line)
	get_effects().add_child(related_line)
	related_line._display_special_text(
		preview_text + "  ← " + source_text,
		preview_effect.get_icon(player_index)
	)
