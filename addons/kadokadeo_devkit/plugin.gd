@tool
extends EditorPlugin

func _enter_tree():
	add_autoload_singleton("KadokadeoManager", "res://addons/kadokadeo_devkit/core/kadokadeo_manager.gd")
	#add_custom_type("StartButton", "Button", preload("scenes/start.gd"), preload("scenes/start.svg"))
	print("KadoKadeo DevKit plugin activated")

func _exit_tree():
	remove_autoload_singleton("KadokadeoManager")
	#remove_custom_type("StartButton")
	print("KadoKadeo DevKit plugin deactivated")

func get_plugin_name():
	return "KadoKadeo DevKit"
