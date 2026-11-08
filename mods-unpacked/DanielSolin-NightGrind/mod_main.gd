extends Node

const MOD_ID := "DanielSolin-NightGrind"
const MOD_DIR_NAME := MOD_ID


func _init() -> void:
	ModLoaderLog.info("Initialized.", MOD_ID)
	var mod_dir_path = ModLoaderMod.get_unpacked_dir().plus_file(MOD_DIR_NAME)
	var extensions_dir = mod_dir_path.plus_file("extensions")
	for extension in [
		"main.gd",
		"effects/items/lootworm_effect.gd",
		"global/entity_spawner.gd",
		"items/materials/gold.gd",
		"singletons/item_service.gd",
		"singletons/run_data.gd",
		"ui/menus/run/difficulty_selection/difficulty_selection.gd"
	]:
		ModLoaderMod.install_script_extension(extensions_dir.plus_file(extension))


func _ready() -> void:
	var mod_dir_path = ModLoaderMod.get_unpacked_dir().plus_file(MOD_DIR_NAME)
	var manager_path = mod_dir_path.plus_file("extensions/nightgrind_manager.gd")
	var manager: Node = load(manager_path).new()
	manager.name = "NightGrindManager"
	add_child(manager)
