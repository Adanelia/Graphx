extends AcceptDialog

signal settings_changed(key)


# Settings
onready var colorful_checkbox = $TabContainer/Config/VBoxContainer/HBoxContainer/ColorfulCheckButton
onready var resizable_checkbox = $TabContainer/Config/VBoxContainer/HBoxContainer2/ResizableCheckButton
onready var show_zoom_label_checkbox = $TabContainer/Config/VBoxContainer/HBoxContainer3/ShowZoomLabelCheckButton
onready var minimap_enabled_by_default_checkbox = $TabContainer/Config/VBoxContainer/HBoxContainer4/MinimapEnabledByDefaultCheckButton
onready var use_snap_by_default_checkbox = $TabContainer/Config/VBoxContainer/HBoxContainer5/UseSnapByDefaultCheckButton
onready var default_snap_distance_spinbox = $TabContainer/Config/VBoxContainer/HBoxContainer6/DefaultSnapDistanceSpinBox
onready var zoom_min_spinbox = $TabContainer/Config/VBoxContainer/HBoxContainer7/ZoomMinSpinBox
onready var zoom_max_spinbox = $TabContainer/Config/VBoxContainer/HBoxContainer8/ZoomMaxSpinBox
onready var zoom_step_spinbox = $TabContainer/Config/VBoxContainer/HBoxContainer9/ZoomStepSpinBox
onready var graph_node_min_size_x_spinbox = $TabContainer/Config/VBoxContainer/HBoxContainer10/GraphNodeMinSizeXSpinBox
onready var graph_node_min_size_y_spinbox = $TabContainer/Config/VBoxContainer/HBoxContainer10/GraphNodeMinSizeYSpinBox
# Theme
onready var theme_option_button = $TabContainer/Themes/VBoxContainer/HBoxContainer/ThemeOptionButton


func update_config():
	colorful_checkbox.pressed = Settings.settings["colorful"]
	resizable_checkbox.pressed = Settings.settings["resizable"]
	show_zoom_label_checkbox.pressed = Settings.settings["show_zoom_label"]
	minimap_enabled_by_default_checkbox.pressed = Settings.settings["minimap_enabled_by_default"]
	use_snap_by_default_checkbox.pressed = Settings.settings["use_snap_by_default"]
	default_snap_distance_spinbox.value = Settings.settings["default_snap_distance"]
	zoom_min_spinbox.value = Settings.settings["zoom_min"]
	zoom_max_spinbox.value = Settings.settings["zoom_max"]
	zoom_step_spinbox.value = Settings.settings["zoom_step"]
	graph_node_min_size_x_spinbox.value = Settings.settings["graph_node_min_size_x"]
	graph_node_min_size_y_spinbox.value = Settings.settings["graph_node_min_size_y"]
	
	theme_option_button.selected = Settings.settings["theme"]


# Called when the node enters the scene tree for the first time.
func _ready():
	Settings.load_from_file()
	update_config()
	
	colorful_checkbox.connect("toggled", self, "_on_ColorfulCheckButton_toggled")
	resizable_checkbox.connect("toggled", self, "_on_ResizableCheckButton_toggled")
	show_zoom_label_checkbox.connect("toggled", self, "_on_ShowZoomLabelCheckButton_toggled")
	minimap_enabled_by_default_checkbox.connect("toggled", self, "_on_MinimapEnabledByDefaultCheckButton_toggled")
	use_snap_by_default_checkbox.connect("toggled", self, "_on_UseSnapByDefaultCheckButton_toggled")
	default_snap_distance_spinbox.connect("value_changed", self, "_on_DefaultSnapDistanceSpinBox_value_changed")
	zoom_min_spinbox.connect("value_changed", self, "_on_ZoomMaxSpinBox_value_changed")
	zoom_max_spinbox.connect("value_changed", self, "_on_ZoomMaxSpinBox_value_changed")
	zoom_step_spinbox.connect("value_changed", self, "_on_ZoomStepSpinBox_value_changed")
	graph_node_min_size_x_spinbox.connect("value_changed", self, "_on_GraphNodeMinSizeXSpinBox_value_changed")
	graph_node_min_size_y_spinbox.connect("value_changed", self, "_on_GraphNodeMinSizeYSpinBox_value_changed")
	
	theme_option_button.connect("item_selected", self, "_on_ThemeOptionButton_item_selected")


func _on_SettingsDialog_about_to_show():
	Settings.load_from_file()
	update_config()


func _on_SettingsDialog_popup_hide():
	Settings.save_to_file()


func _on_ResetButton_pressed():
	Settings.reset_to_default()
	update_config()


func _on_ColorfulCheckButton_toggled(button_pressed):
	Settings.settings["colorful"] = button_pressed
	emit_signal("settings_changed", "colorful")


func _on_ResizableCheckButton_toggled(button_pressed):
	Settings.settings["resizable"] = button_pressed
	emit_signal("settings_changed", "resizable")


func _on_ShowZoomLabelCheckButton_toggled(button_pressed):
	Settings.settings["show_zoom_label"] = button_pressed
	emit_signal("settings_changed", "show_zoom_label")


func _on_MinimapEnabledByDefaultCheckButton_toggled(button_pressed):
	Settings.settings["minimap_enabled_by_default"] = button_pressed
	emit_signal("settings_changed", "minimap_enabled_by_default")


func _on_UseSnapByDefaultCheckButton_toggled(button_pressed):
	Settings.settings["use_snap_by_default"] = button_pressed
	emit_signal("settings_changed", "use_snap_by_default")


func _on_DefaultSnapDistanceSpinBox_value_changed(value):
	Settings.settings["default_snap_distance"] = value
	emit_signal("settings_changed", "default_snap_distance")


func _on_ZoomMinSpinBox_value_changed(value):
	Settings.settings["zoom_min"] = value
	emit_signal("settings_changed", "zoom_min")


func _on_ZoomMaxSpinBox_value_changed(value):
	Settings.settings["zoom_max"] = value
	emit_signal("settings_changed", "zoom_max")


func _on_ZoomStepSpinBox_value_changed(value):
	Settings.settings["zoom_step"] = value
	emit_signal("settings_changed", "zoom_step")


func _on_GraphNodeMinSizeXSpinBox_value_changed(value):
	Settings.settings["graph_node_min_size_x"] = value
	emit_signal("settings_changed", "graph_node_min_size_x")


func _on_GraphNodeMinSizeYSpinBox_value_changed(value):
	Settings.settings["graph_node_min_size_y"] = value
	emit_signal("settings_changed", "graph_node_min_size_y")


func _on_ThemeOptionButton_item_selected(index):
	Settings.settings["theme"] = index
	emit_signal("settings_changed", "theme")
