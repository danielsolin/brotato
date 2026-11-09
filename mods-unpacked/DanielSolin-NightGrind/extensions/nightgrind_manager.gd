extends Node

var _shop_actions = {}
var _replay_buttons = []


func _process(_delta: float) -> void:
	for entry in _replay_buttons.duplicate():
		var button = entry[0]
		if not is_instance_valid(button):
			_replay_buttons.erase(entry)
			continue
		var affordable = RunData.get_player_gold(entry[1]) >= RunData.current_wave * 2
		button.modulate = Color.white if affordable else Color(0.45, 0.45, 0.45, 1.0)


func _ready() -> void:
	var tree = get_tree()
	if not tree.is_connected("node_added", self, "_on_node_added"):
		tree.connect("node_added", self, "_on_node_added")
	call_deferred("_nightgrind_setup_current_scene")


func _on_node_added(node: Node) -> void:
	if node.name in ["HarvestingContainer", "PickupRangeContainer"]:
		call_deferred("_nightgrind_dim_stat", node)
	if node.name == "Shop" or node.name == "CoopShop":
		call_deferred("_nightgrind_setup_shop", node)


func _nightgrind_dim_stat(node: Node) -> void:
	if not is_instance_valid(node):
		return
	if not node.get("key") in ["STAT_HARVESTING", "PICKUP_RANGE"]:
		return
	var control: Control = node as Control
	if control != null:
		control.modulate = Color(0.65, 0.65, 0.65, 0.65)


func _nightgrind_setup_current_scene() -> void:
	var scene: Node = get_tree().current_scene
	if scene != null:
		_nightgrind_setup_shop(scene)


func _nightgrind_setup_shop(shop: Node) -> void:
	if not is_instance_valid(shop):
		return
	if shop.name != "Shop" and shop.name != "CoopShop":
		return
	if shop.has_meta("nightgrind_buttons_added"):
		return
	shop.set_meta("nightgrind_buttons_added", true)

	var shop_id: int = shop.get_instance_id()
	_shop_actions[shop_id] = ""
	shop.connect("tree_exiting", self, "_nightgrind_forget_shop", [shop_id])
	_nightgrind_filter_shop_offers(shop)

	for player_index in RunData.get_player_count():
		var reroll_button: Button = shop.call("_get_reroll_button", player_index)
		if reroll_button != null:
			reroll_button.connect("pressed", self, "_nightgrind_on_reroll", [shop])
		var next_button: Button = shop.call(
			"_get_go_button",
			player_index
		) as Button
		if next_button == null:
			continue
		_nightgrind_add_replay_button(shop, next_button, player_index)


func _nightgrind_on_reroll(shop: Node) -> void:
	call_deferred("_nightgrind_filter_shop_offers", shop)


func _nightgrind_filter_shop_offers(shop: Node) -> void:
	if not is_instance_valid(shop):
		return
	var shop_items: Array = shop.get("_shop_items")
	var locks_changed = false
	for player_index in RunData.get_player_count():
		var locked: Array = RunData.locked_shop_items[player_index]
		for index in range(locked.size() - 1, -1, -1):
			if ItemService.call("_nightgrind_blocked_item", locked[index][0]):
				locked.remove(index)
				locks_changed = true

		var offers: Array = shop_items[player_index]
		var removed = 0
		for index in range(offers.size() - 1, -1, -1):
			if ItemService.call("_nightgrind_blocked_item", offers[index][0]):
				offers.remove(index)
				removed += 1
		if removed == 0:
			continue

		var args = ItemServiceGetShopItemsArgs.new(shop_items, player_index)
		args.count = removed
		args.prev_items = offers.duplicate()
		args.locked_items = RunData.get_player_locked_shop_items(player_index)
		offers.append_array(ItemService.get_player_shop_items(
			RunData.current_wave,
			player_index,
			args
		))
		var container: Control = shop.call("_get_shop_items_container", player_index)
		if container != null:
			container.call("set_shop_items", offers)
		locks_changed = true
	if locks_changed:
		shop.call("_update_visual_locks")


func _nightgrind_add_replay_button(
		shop: Node,
		next_button: Button,
		player_index: int
	) -> void:
	var parent = next_button.get_parent()
	var original_index = next_button.get_index()
	var button_height = max(next_button.rect_size.y, next_button.rect_min_size.y)
	if button_height <= 0:
		button_height = 65
	var scene_owner = next_button.owner
	var next_min_size = next_button.rect_min_size
	next_min_size.y = button_height
	next_button.rect_min_size = next_min_size

	var action_row = HBoxContainer.new()
	action_row.name = "NightGrindActions" + str(player_index)
	action_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	action_row.size_flags_vertical = Control.SIZE_SHRINK_END
	action_row.rect_min_size = Vector2(0, button_height)
	action_row.add_constant_override("separation", 8)

	parent.add_child(action_row)
	parent.move_child(action_row, original_index)
	if scene_owner != null:
		action_row.owner = scene_owner

	var visible_next_button: Button = next_button.duplicate(0) as Button
	visible_next_button.name = "NightGrindNextButton" + str(player_index)
	if next_button.get_script() != null:
		visible_next_button.set_script(next_button.get_script())
	var visible_next_min_size = visible_next_button.rect_min_size
	visible_next_min_size.y = button_height
	visible_next_button.rect_min_size = visible_next_min_size
	visible_next_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	visible_next_button.visible = true
	if scene_owner != null:
		visible_next_button.owner = scene_owner
	action_row.add_child(visible_next_button)

	var replay_button: Button = next_button.duplicate(0) as Button
	replay_button.name = "NightGrindReplayButton" + str(player_index)
	replay_button.icon = null
	replay_button.set_script(next_button.get_script())
	var replay_min_size = replay_button.rect_min_size
	replay_min_size.y = button_height
	replay_button.rect_min_size = replay_min_size
	replay_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if scene_owner != null:
		replay_button.owner = scene_owner
	action_row.add_child(replay_button)
	action_row.move_child(replay_button, 0)

	# Keep the original GoButton where vanilla Shop and StatsContainer expect it.
	next_button.hide()
	next_button.focus_mode = Control.FOCUS_NONE
	visible_next_button.connect(
		"pressed",
		self,
		"_nightgrind_on_next_pressed",
		[shop, player_index]
	)
	visible_next_button.connect(
		"focus_exited",
		shop,
		"_on_GoButton_focus_exited",
		[player_index]
	)
	replay_button.connect(
		"pressed",
		self,
		"_nightgrind_on_replay_pressed",
		[shop, player_index]
	)
	replay_button.connect(
		"focus_exited",
		shop,
		"_on_GoButton_focus_exited",
		[player_index]
	)

	var replay_cost = RunData.current_wave * 2
	_nightgrind_button_content(
		visible_next_button, "Wave " + str(RunData.get_next_wave()), "(Continue)", null
	)
	var reroll = shop.call("_get_reroll_button", player_index)
	var gold_icon = reroll.find_node("GoldIcon", true, false) if reroll != null else null
	_nightgrind_button_content(replay_button, "Wave " + str(RunData.current_wave),
		str(replay_cost), gold_icon)
	replay_button.hint_tooltip = ""
	_replay_buttons.append([replay_button, player_index])
	_nightgrind_sync_focus(
		shop,
		visible_next_button,
		replay_button,
		player_index,
		next_button
	)


func _nightgrind_button_content(button: Button, title: String, detail: String, icon: Node) -> void:
	button.text = ""
	var font = button.get_font("font").duplicate()
	if font is DynamicFont:
		font.size = 22
	var rows = VBoxContainer.new()
	rows.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rows.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	rows.alignment = BoxContainer.ALIGN_CENTER
	rows.add_constant_override("separation", 0)
	button.add_child(rows)
	var heading = Label.new()
	heading.text = title
	heading.align = Label.ALIGN_CENTER
	heading.add_font_override("font", font)
	rows.add_child(heading)
	var line = HBoxContainer.new()
	line.alignment = BoxContainer.ALIGN_CENTER
	rows.add_child(line)
	var value = Label.new()
	value.text = detail
	value.add_font_override("font", font)
	line.add_child(value)
	button.connect("mouse_entered", self, "_nightgrind_button_colors", [button, heading, value])
	button.connect("mouse_exited", self, "_nightgrind_button_colors", [button, heading, value])
	button.connect("focus_entered", self, "_nightgrind_button_colors", [button, heading, value])
	button.connect("focus_exited", self, "_nightgrind_button_colors", [button, heading, value])
	_nightgrind_button_colors(button, heading, value)
	if icon != null:
		var copy = icon.duplicate()
		copy.rect_min_size = Vector2(24, 24)
		copy.mouse_filter = Control.MOUSE_FILTER_IGNORE
		line.add_child(copy)


func _nightgrind_button_colors(button: Button, heading: Label, value: Label) -> void:
	var active = button.is_hovered() or button.has_focus()
	var color = button.get_color("font_color_hover" if active else "font_color")
	heading.add_color_override("font_color", color)
	value.add_color_override("font_color", color)


func _nightgrind_sync_focus(
		shop: Node,
		next_button: Control,
		replay_button: Control,
		player_index: int,
		source_button: Control
	) -> void:
	next_button.focus_neighbour_left = next_button.get_path_to(replay_button)
	next_button.focus_neighbour_right = next_button.get_path_to(replay_button)
	replay_button.focus_neighbour_left = replay_button.get_path_to(next_button)
	replay_button.focus_neighbour_right = replay_button.get_path_to(next_button)

	for direction in ["top", "bottom"]:
		var property = "focus_neighbour_" + direction
		var path = source_button.get(property)
		if str(path).empty():
			continue
		var target: Node = source_button.get_node_or_null(path)
		if target != null:
			next_button.set(property, next_button.get_path_to(target))
			replay_button.set(property, replay_button.get_path_to(target))

	var stat_popup: Control = shop.call("_get_stat_popup", player_index)
	if stat_popup != null:
		stat_popup.focus_neighbour_right = stat_popup.get_path_to(replay_button)
		stat_popup.focus_neighbour_bottom = stat_popup.get_path_to(replay_button)

	var action_parent = next_button.get_parent().get_parent()
	var endless_button: Control = action_parent.get_node_or_null("EndlessButton")
	if endless_button != null:
		endless_button.focus_neighbour_bottom = endless_button.get_path_to(replay_button)


func _nightgrind_prepare_action(shop: Node, action: String) -> void:
	var shop_id: int = shop.get_instance_id()
	if _shop_actions.get(shop_id, "") == action:
		return

	for player_index in RunData.get_player_count():
		shop.call("_clear_go_button_pressed", player_index)
	_shop_actions[shop_id] = action


func _nightgrind_on_next_pressed(shop: Node, player_index: int) -> void:
	if get_tree().paused:
		return
	_nightgrind_prepare_action(shop, "next")
	var replay_available = true
	for index in RunData.get_player_count():
		if RunData.get_player_gold(index) < RunData.current_wave * 2:
			replay_available = false
			break
	if not replay_available:
		shop.call("_on_GoButton_pressed", player_index)
		return
	var source_button: Button = shop.call("_get_go_button", player_index) as Button
	if source_button == null:
		return

	var popup: PopupPanel = PopupPanel.new()
	popup.name = "NightGrindNextConfirmation"
	popup.rect_min_size = Vector2(700, 220)
	popup.popup_exclusive = true
	popup.connect("popup_hide", popup, "queue_free")

	var margins = MarginContainer.new()
	for side in ["left", "top", "right", "bottom"]:
		margins.add_constant_override("margin_" + side, 20)
	popup.add_child(margins)

	var content = VBoxContainer.new()
	content.add_constant_override("separation", 12)
	margins.add_child(content)

	var message = Label.new()
	message.text = (
		"Are you sure you want to go to Wave "
		+ str(RunData.get_next_wave())
		+ "?"
	)
	message.autowrap = true
	message.align = Label.ALIGN_CENTER
	message.valign = Label.VALIGN_CENTER
	message.rect_min_size = Vector2(620, 96)
	message.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	message.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(message)

	var buttons = HBoxContainer.new()
	buttons.alignment = HBoxContainer.ALIGN_CENTER
	buttons.add_constant_override("separation", 24)
	content.add_child(buttons)

	var yes_button = _nightgrind_create_confirmation_button(
		source_button,
		"Yes",
		"NightGrindConfirmYes"
	)
	var no_button = _nightgrind_create_confirmation_button(
		source_button,
		"No",
		"NightGrindConfirmNo"
	)
	buttons.add_child(yes_button)
	buttons.add_child(no_button)
	yes_button.focus_neighbour_right = yes_button.get_path_to(no_button)
	no_button.focus_neighbour_left = no_button.get_path_to(yes_button)
	yes_button.connect(
		"pressed",
		self,
		"_nightgrind_on_next_confirmed",
		[shop, player_index, popup]
	)
	no_button.connect("pressed", popup, "hide")

	shop.add_child(popup)
	popup.popup_centered(Vector2(700, 220))
	yes_button.grab_focus()



func _nightgrind_create_confirmation_button(
		source: Button,
		text: String,
		node_name: String
	) -> Button:
	var button: Button = source.duplicate(0) as Button
	button.name = node_name
	if source.get_script() != null:
		button.set_script(source.get_script())
	button.text = text
	button.icon = null
	button.expand_icon = false
	button.visible = true
	button.disabled = false
	button.hint_tooltip = ""
	button.focus_mode = Control.FOCUS_ALL
	button.rect_min_size = Vector2(140, 52)
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	return button


func _nightgrind_on_next_confirmed(
		shop: Node,
		player_index: int,
		popup: PopupPanel
	) -> void:
	if is_instance_valid(popup):
		popup.hide()
	if get_tree().paused or not is_instance_valid(shop):
		return
	shop.call("_on_GoButton_pressed", player_index)


func _nightgrind_on_replay_pressed(shop: Node, player_index: int) -> void:
	if get_tree().paused:
		return
	_nightgrind_prepare_action(shop, "replay")

	var pressed_players: Array = shop.get("_player_pressed_go_button")
	if pressed_players[player_index]:
		shop.call("_clear_go_button_pressed", player_index)
		return
	var replay_cost = RunData.current_wave * 2
	if RunData.get_player_gold(player_index) < replay_cost:
		UIService._reached_max_shake(shop.call("_get_gold_label", player_index).get_parent())
		return

	pressed_players[player_index] = true
	var checkmark: Control = shop.call("_get_checkmark", player_index)
	if checkmark != null:
		checkmark.show()

	for other_player_index in RunData.get_player_count():
		if not pressed_players[other_player_index]:
			return
		if RunData.get_player_gold(other_player_index) < replay_cost:
			shop.call("_clear_go_button_pressed", other_player_index)
			return

	for other_player_index in RunData.get_player_count():
		RunData.remove_gold(replay_cost, other_player_index)

	ProgressData.save_run_state(
		shop.get("_shop_items"),
		shop.get("_reroll_count"),
		shop.get("_paid_reroll_count"),
		shop.get("_initial_free_rerolls"),
		shop.get("_free_rerolls"),
		shop.get("_item_steals")
	)
	_nightgrind_apply_shop_exit_effects(shop)
	get_tree().change_scene(MenuData.game_scene)


func _nightgrind_apply_shop_exit_effects(shop: Node) -> void:
	for player_index in RunData.get_player_count():
		var effects = RunData.get_player_effects(player_index)
		if not effects.has(Keys.used_item_locking_hash):
			continue
		if ChallengeService.is_challenge_completed(ChallengeService.chal_candy_bag_hash):
			continue
		if RunData.get_player_effect_bool(Keys.used_item_locking_hash, player_index):
			continue

		var shop_container: Control = shop.call(
			"_get_shop_items_container",
			player_index
		)
		var shop_items: Array = shop_container.get("_shop_items")
		for shop_item in shop_items:
			if shop_item != null and shop_item.active and shop_item.locked:
				effects[Keys.used_item_locking_hash] = 1
				break


func _nightgrind_forget_shop(shop_id: int) -> void:
	_shop_actions.erase(shop_id)
