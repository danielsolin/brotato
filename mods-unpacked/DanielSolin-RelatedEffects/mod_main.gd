extends Node

const MOD_ID := "DanielSolin-RelatedEffects"
const MOD_DIR_NAME := MOD_ID


func _init() -> void:
	ModLoaderLog.info("Initialized.", MOD_ID)
	var mod_dir_path = ModLoaderMod.get_unpacked_dir().plus_file(MOD_DIR_NAME)
	var extension_path = mod_dir_path.plus_file(
		"extensions/ui/menus/shop/item_description.gd"
	)
	ModLoaderMod.install_script_extension(extension_path)
