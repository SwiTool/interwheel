@tool
extends EditorPlugin

func _enter_tree():
	add_autoload_singleton("KadokadeoManager", "res://addons/kadokadeo_devkit/core/kadokadeo_manager.gd")
	print("KadoKadeo DevKit plugin activated")

func _exit_tree():
	remove_autoload_singleton("KadokadeoManager")
	print("KadoKadeo DevKit plugin deactivated")

func get_plugin_name():
	return "KadoKadeo DevKit"
