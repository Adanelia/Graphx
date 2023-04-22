extends Node


const VERSION = "0.0.1-alpha"
const DEFAULT_FILE_PATH = "user://config.json"
const ThemeMap = [
	"res://themes/default_theme.theme",
	"res://themes/alien_theme.theme",
	"res://themes/arc_theme.theme",
	"res://themes/godot2_theme.theme",
	"res://themes/godot3_theme.theme",
	"res://themes/grey_theme.theme",
	"res://themes/light_theme.theme",
	"res://themes/solarized_dark_theme.theme",
	"res://themes/solarized_light_theme.theme",
]

var settings = {
	"colorful": false,
	"resizable": false,
	"show_zoom_label": true,
	"minimap_enabled_by_default": true,
	"use_snap_by_default": true,
	"default_snap_distance": 20,
	"zoom_min": 0.149,
	"zoom_max": 2.144,
	"zoom_step": 1.1,
	"graph_node_min_size_x": 120,
	"graph_node_min_size_y": 32,
	
	"theme": 0,
}


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func reset_to_default():
	settings["colorful"] = false
	settings["resizable"] = false
	settings["show_zoom_label"] = true
	settings["minimap_enabled_by_default"] = true
	settings["use_snap_by_default"] = true
	settings["default_snap_distance"] = 20
	settings["zoom_min"] = 0.149
	settings["zoom_max"] = 2.144
	settings["zoom_step"] = 1.1
	settings["graph_node_min_size_x"] = 120
	settings["graph_node_min_size_y"] = 32


func load_from_json(json_text):
	var new_settings = parse_json(json_text)
	for key in settings.keys():
		settings[key] = new_settings[key]


func load_from_file(path = DEFAULT_FILE_PATH):
	var file = File.new()
	# No config file found
	if not file.file_exists(path):
		return
	
	# Read file
	file.open(path, File.READ)
	var content = file.get_as_text()
	file.close()
	load_from_json(content)


func save_to_json() -> String :
	return to_json(settings)


func save_to_file(path = DEFAULT_FILE_PATH):
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_string(save_to_json())
	file.close()
