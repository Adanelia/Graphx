extends Control


#const VERSION = "0.0.1-alpha"
#const MENU_SIZE = Vector2(160, 16)
#const GRAPH_NODE_MIN_SIZE = Vector2(120, 32)
const ItemProperty = preload("res://components/ItemProperty.tscn")

var file_path = "" # path to save
var current_graph_node : GraphNode = null
var item_property_list = [] # Store current property

onready var graph_edit = $VBoxContainer/HSplitContainer/GraphEdit
onready var inspector = $VBoxContainer/HSplitContainer/TabContainer
onready var property_container = $VBoxContainer/HSplitContainer/TabContainer/Property/VBoxContainer
onready var overview_itemlist = $VBoxContainer/HSplitContainer/TabContainer/Overview/ItemList
onready var open_file_dialog = $OpenFileDialog
onready var save_file_dialog = $SaveFileDialog
onready var settings_dialog = $SettingsDialog
onready var about_dialog = $AboutDialog
onready var export_image_dialog = $ExportImage

onready var window_popup_menu = $VBoxContainer/MenuContainer/WindowsMenu.get_popup()

onready var default_theme = theme


func _ready():
	# Remove placeholder
	$VBoxContainer/HSplitContainer/TabContainer/Property/VBoxContainer/ItemProperty.queue_free()
	
	# Set up menus
	# Connect menu signal
	$VBoxContainer/MenuContainer/FileMenu.get_popup().connect("id_pressed", self, "_on_Menu_id_pressed", [0])
	$VBoxContainer/MenuContainer/EditMenu.get_popup().connect("id_pressed", self, "_on_Menu_id_pressed", [1])
	$VBoxContainer/MenuContainer/SettingsMenu.get_popup().connect("id_pressed", self, "_on_Menu_id_pressed", [2])
	$VBoxContainer/MenuContainer/WindowsMenu.get_popup().connect("id_pressed", self, "_on_Menu_id_pressed", [3])
	$VBoxContainer/MenuContainer/HelpMenu.get_popup().connect("id_pressed", self, "_on_Menu_id_pressed", [4])
	
	# Set submenu
	var submenu_export = preload("res://components/SubMenuExport.tscn").instance()
	$VBoxContainer/MenuContainer/FileMenu.get_popup().add_child(submenu_export, true)
	$VBoxContainer/MenuContainer/FileMenu.get_popup().set_item_submenu(4, "SubMenuExport")
	submenu_export.connect("id_pressed", self, "_on_Menu_id_pressed", [10])
	window_popup_menu.hide_on_checkable_item_selection = false
	
	# Set shortcut
	# New: Ctrl + N
	var shortcut_new = ShortCut.new()
	var input_event_new = InputEventKey.new()
	input_event_new.scancode = 78
	input_event_new.control = true
	shortcut_new.shortcut = input_event_new
	$VBoxContainer/MenuContainer/FileMenu.get_popup().set_item_shortcut(0, shortcut_new, true)
	# Open: Ctrl + O
	var shortcut_open = ShortCut.new()
	var input_event_open = InputEventKey.new()
	input_event_open.scancode = 79
	input_event_open.control = true
	shortcut_open.shortcut = input_event_open
	$VBoxContainer/MenuContainer/FileMenu.get_popup().set_item_shortcut(1, shortcut_open, true)
	# Save: Ctrl + S
	var shortcut_save = ShortCut.new()
	var input_event_save = InputEventKey.new()
	input_event_save.scancode = 83
	input_event_save.control = true
	shortcut_save.shortcut = input_event_save
	$VBoxContainer/MenuContainer/FileMenu.get_popup().set_item_shortcut(2, shortcut_save, true)
	# Save As: Ctrl + Shift + S
	var shortcut_save_as = ShortCut.new()
	var input_event_save_as = InputEventKey.new()
	input_event_save_as.scancode = 83
	input_event_save_as.control = true
	input_event_save_as.shift = true
	shortcut_save_as.shortcut = input_event_save_as
	$VBoxContainer/MenuContainer/FileMenu.get_popup().set_item_shortcut(3, shortcut_save_as, true)
	# Exit: Ctrl + Q
	var shortcut_exit = ShortCut.new()
	var input_event_exit = InputEventKey.new()
	input_event_exit.scancode = 81
	input_event_exit.control = true
	shortcut_exit.shortcut = input_event_exit
	$VBoxContainer/MenuContainer/FileMenu.get_popup().set_item_shortcut(6, shortcut_exit, true)
	# Add: Ctrl + A
	var shortcut_add = ShortCut.new()
	var input_event_add = InputEventKey.new()
	input_event_add.scancode = 65
	input_event_add.control = true
	shortcut_add.shortcut = input_event_add
	$VBoxContainer/MenuContainer/EditMenu.get_popup().set_item_shortcut(0, shortcut_add, true)
	# Add Left: Alt + ←
	var shortcut_add_left = ShortCut.new()
	var input_event_add_left = InputEventKey.new()
	input_event_add_left.scancode = 16777231
	input_event_add_left.alt = true
	shortcut_add_left.shortcut = input_event_add_left
	$VBoxContainer/MenuContainer/EditMenu.get_popup().set_item_shortcut(1, shortcut_add_left, true)
	# Add Right: Alt + →
	var shortcut_add_right = ShortCut.new()
	var input_event_add_right = InputEventKey.new()
	input_event_add_right.scancode = 16777233
	input_event_add_right.alt = true
	shortcut_add_right.shortcut = input_event_add_right
	$VBoxContainer/MenuContainer/EditMenu.get_popup().set_item_shortcut(2, shortcut_add_right, true)
	# Expand: Alt + →
	var shortcut_expand = ShortCut.new()
	var input_event_expand = InputEventKey.new()
	input_event_expand.scancode = 16777234
	input_event_expand.alt = true
	shortcut_expand.shortcut = input_event_expand
	$VBoxContainer/MenuContainer/EditMenu.get_popup().set_item_shortcut(3, shortcut_expand, true)
	# Delete: Alt + D
	var shortcut_delete = ShortCut.new()
	var input_event_delete = InputEventKey.new()
	input_event_delete.scancode = 68
	input_event_delete.alt = true
	shortcut_delete.shortcut = input_event_delete
	$VBoxContainer/MenuContainer/EditMenu.get_popup().set_item_shortcut(4, shortcut_delete, true)
	
	# Settings
	graph_edit.show_zoom_label = Settings.settings["show_zoom_label"]
	graph_edit.minimap_enabled = Settings.settings["minimap_enabled_by_default"]
	graph_edit.use_snap = Settings.settings["use_snap_by_default"]
	graph_edit.snap_distance = Settings.settings["default_snap_distance"]
	graph_edit.zoom_min = Settings.settings["zoom_min"]
	graph_edit.zoom_max = Settings.settings["zoom_max"]
	graph_edit.zoom_step = Settings.settings["zoom_step"]
	# Theme
	if Settings.settings["theme"] != 0:
		var new_theme : Theme = ResourceLoader.load(Settings.ThemeMap[Settings.settings["theme"]], "Theme")
		VisualServer.set_default_clear_color(new_theme.get_color("dark_color_2", "Editor"))
		theme = default_theme.duplicate()
		theme.merge_with(new_theme)
	
	
	# Check start up args
	var arguments = OS.get_cmdline_args()
	if arguments.size() > 0:
		# Open file
		_on_OpenFileDialog_file_selected(arguments[0])


func add_graph_node(
	comment = false, 
	offset = null,
	size = null,
	data_array = [], #text = "", left_slot_enabled = true, right_slot_enabled = true,
	node_name = null
):
	# New graph node
	var new_graph_node = GraphNode.new()
	
	if data_array.empty():
		# Add a empty node
		# Label on graph node
		var new_graph_node_text = RichTextLabel.new()
		# Set up label
		new_graph_node_text.bbcode_enabled = true
		new_graph_node_text.rect_min_size = Vector2(Settings.settings["graph_node_min_size_x"], Settings.settings["graph_node_min_size_y"])
		new_graph_node_text.fit_content_height = true
		new_graph_node_text.mouse_filter = Control.MOUSE_FILTER_PASS
		new_graph_node_text.connect("meta_clicked", self, "_on_RichTextLabel_meta_clicked")
		new_graph_node_text.connect("meta_hover_started", self, "_on_RichTextLabel_meta_hover_started", [new_graph_node_text])
		new_graph_node_text.connect("meta_hover_ended", self, "_on_RichTextLabel_meta_hover_ended", [new_graph_node_text])
		# Set up graph node
		new_graph_node.add_child(new_graph_node_text)
		new_graph_node.set_slot_enabled_left(0, true)
		new_graph_node.set_slot_enabled_right(0, true)
	else:
		# From data
		var idx = 0
		for i in data_array:
			# Label on graph node
			var new_graph_node_text = RichTextLabel.new()
			# Set up label
			new_graph_node_text.bbcode_enabled = true
			new_graph_node_text.bbcode_text = i["text"]
			new_graph_node_text.rect_min_size = Vector2(Settings.settings["graph_node_min_size_x"], Settings.settings["graph_node_min_size_y"])
			new_graph_node_text.fit_content_height = true
			new_graph_node_text.mouse_filter = Control.MOUSE_FILTER_PASS
			new_graph_node_text.connect("meta_clicked", self, "_on_RichTextLabel_meta_clicked")
			new_graph_node_text.connect("meta_hover_started", self, "_on_RichTextLabel_meta_hover_started", [new_graph_node_text])
			new_graph_node_text.connect("meta_hover_ended", self, "_on_RichTextLabel_meta_hover_ended", [new_graph_node_text])
			# Set up graph node
			new_graph_node.add_child(new_graph_node_text)
			new_graph_node.set_slot_enabled_left(idx, i["left_slot_enabled"])
			new_graph_node.set_slot_enabled_right(idx, i["right_slot_enabled"])
			idx += 1
	new_graph_node.comment = comment
	if node_name != null:
		new_graph_node.name = node_name
	# Add to canvas
	graph_edit.add_child(new_graph_node, true)
	# Set position
	if offset == null:# Use mouse position
		var pos = get_viewport().get_mouse_position()
		pos = pos - graph_edit.rect_position + graph_edit.scroll_offset
		new_graph_node.offset = pos
	else:
		new_graph_node.offset = offset
	# Set size
	if size != null:
		new_graph_node.rect_size = size
	# Connect resize_request signal
	new_graph_node.connect("resize_request", self, "_on_GraphNode_resize_request", [new_graph_node])
	# Resizable or not
	new_graph_node.resizable = Settings.settings["resizable"]
	# Select
	graph_edit.set_selected(new_graph_node)
	_on_GraphEdit_node_selected(new_graph_node)# Call it manually


func delete_graph_node():
	# Iterate all child nodes
	for child in graph_edit.get_children():
		if child is GraphNode and child.selected:
			# Remove connections, a bit of complex
			for conn in graph_edit.get_connection_list():
				if conn.from == child.name or conn.to == child.name:
					graph_edit.disconnect_node(conn.from, conn.from_port, conn.to, conn.to_port)
			# Remove node
			child.queue_free()
	
	current_graph_node = null
	
	# Clear property_container
	for child in item_property_list:
		child.queue_free()
	item_property_list.clear()


func clear_graph_node():
	# Reset file_path first
	file_path = ""
	# Same as above
	# Iterate all child nodes
	for child in graph_edit.get_children():
		if child is GraphNode: #and child.selected:
			# Remove connections, a bit of complex
			for conn in graph_edit.get_connection_list():
				if conn.from == child.name or conn.to == child.name:
					graph_edit.disconnect_node(conn.from, conn.from_port, conn.to, conn.to_port)
			# Remove node
			child.queue_free()
	
	current_graph_node = null
	
	# Clear property_container
	for child in item_property_list:
		child.queue_free()
	item_property_list.clear()


func load_from_json(json_text):
	var dic = parse_json(json_text)
	# Check name field
	if dic["name"] != ProjectSettings.get_setting("application/config/name"):
		printerr("PARSE FILE ERROR on: name\t", dic["name"])
		return
	
	# Add nodes
	for i in dic["nodes"]:
		add_graph_node(i["comment"], Vector2(i["offset_x"], i["offset_y"]), Vector2(i["size_x"], i["size_y"]), i["data"], i["name"])
	
	# Connect
	for i in dic["connections"]:
		graph_edit.connect_node(i["from"], i["from_port"], i["to"], i["to_port"])


func save_to_json() -> String :
	# Template
	var dic = {
		"name": ProjectSettings.get_setting("application/config/name"),
		"version": Settings.VERSION,
		"nodes": [
#			{ "name": "node_name", "comment": false, "offset_x": 0, "offset_y": 0, "size_x": 0, "size_y": 0, "data": [{"text": "text", "left_slot_enabled": true, "right_slot_enabled": true}] },
		],
		"connections": [
#			{ "from_port": 0, "from": "GraphNode name 0", "to_port": 1, "to": "GraphNode name 1" },
		],
	}
	
	# Get data
	for child in graph_edit.get_children():
		if child is GraphNode:
			var node_save = {
				"name": child.name,
				"comment": child.comment,
				"offset_x": child.offset.x,
				"offset_y": child.offset.y,
				"size_x": child.rect_size.x,
				"size_y": child.rect_size.y,
				"data": []
			}
			var idx = 0
			for child_child in child.get_children():
				if child_child is RichTextLabel:
					var node_data = {
						"text": child_child.bbcode_text,
						"left_slot_enabled": child.is_slot_enabled_left(idx),
						"right_slot_enabled": child.is_slot_enabled_right(idx),
					}
					node_save["data"].append(node_data)
					idx += 1
			dic["nodes"].append(node_save)
	
	dic["connections"] = graph_edit.get_connection_list()
	
	return to_json(dic)


func _on_GraphEdit_connection_request(from, from_slot, to, to_slot):
	var err = graph_edit.connect_node(from, from_slot, to, to_slot)
#	print("connect: ", from, from_slot, to, to_slot, "\treturn: ", err)


func _on_GraphEdit_disconnection_request(from, from_slot, to, to_slot):
	var err = graph_edit.disconnect_node(from, from_slot, to, to_slot)
#	print("disconnect: ", from, from_slot, to, to_slot, "\treturn: ", err)


func _on_GraphEdit_node_selected(node):
	# Original _on_GraphEdit_node_unselected(), here to avoid conflicts
	for i in item_property_list:
		i.queue_free()
	item_property_list.clear()
	
	current_graph_node = node
	# Show property
	for i in node.get_child_count():# May have more than one label
		var new_item_property = ItemProperty.instance()
		item_property_list.append(new_item_property)
		property_container.add_child(new_item_property)
#		new_item_property.text_edit.text = node.get_child(i).bbcode_text
		new_item_property.set_up(
			node.get_child(i).bbcode_text,
			node.is_slot_enabled_left(i),
			node.is_slot_enabled_right(i),
			node.comment
		)
		new_item_property.connect("property_changed", self, "_on_ItemProperty_property_changed", [i])
		new_item_property.text_edit.grab_focus()


func _on_GraphEdit_node_unselected(node):
	pass
#	current_graph_node = null
	# Remove property
	# Have some bugs here, move to _on_GraphEdit_node_selected()
#	for i in item_property_list:
#		i.queue_free()
#	item_property_list.clear()


func _on_GraphEdit_popup_request(position):
	$VBoxContainer/MenuContainer/EditMenu.get_popup().popup(Rect2(position, Vector2(2, 2)))


func _on_GraphNode_resize_request(new_minsize, node):
	node.rect_size = new_minsize


func _on_RichTextLabel_meta_clicked(meta):
	OS.shell_open(str(meta))


func _on_RichTextLabel_meta_hover_ended(meta, rich_text_label):
	rich_text_label.hint_tooltip = ""


func _on_RichTextLabel_meta_hover_started(meta, rich_text_label):
	rich_text_label.hint_tooltip = meta


func _on_ItemProperty_property_changed(key, value, idx):
	if current_graph_node == null:
		printerr("No graph node selected!")
		return
	
#	print("property ", idx, " changed: ", key, "\t", value)
	match key:
		"text":
			current_graph_node.get_child(idx).bbcode_text = value
		"left_slot":
			current_graph_node.set_slot_enabled_left(idx, value)
		"right_slot":
			current_graph_node.set_slot_enabled_right(idx, value)
		"comment":
			current_graph_node.comment = value
		_:
			printerr("Unknown Property: ", key, "\t", value)


func _on_TabContainer_tab_changed(tab):
	# Update overview_itemlist
	if tab == 1:
		overview_itemlist.clear()
		for child in graph_edit.get_children():
			if child is GraphNode:
				var text = ""
				for child_child in child.get_children():
					if child_child is RichTextLabel:
						text += child_child.text
						text += "  "
				overview_itemlist.add_item(text)


func _on_Menu_id_pressed(id, index):
	match index:
		# File
		0:
			match id:
				# New
				0:
					clear_graph_node()
				# Open
				1:
					open_file_dialog.popup_centered()
				# Save
				2:
					# Haven't save
					if file_path == "":
						save_file_dialog.save(save_to_json())
						save_file_dialog.popup_centered()
					# Save to file_path
					else:
						save_file_dialog.save(save_to_json())
						save_file_dialog._on_SaveFileDialog_file_selected(file_path)
				# Save As
				3:
					save_file_dialog.save(save_to_json())
					save_file_dialog.popup_centered()
				# Export
				4:
					pass
				# Separator
				5:
					pass
				# Exit
				6:
					get_tree().quit()
		
		# Edit
		1:
			match id:
				# Add
				0:
					add_graph_node()
				# Add Left
				1:
					if current_graph_node == null:
						return
					var new_offset = current_graph_node.offset
					new_offset.x -= current_graph_node.rect_size.x * 1.2
					var right_node = current_graph_node
					add_graph_node(false, new_offset)
					# current_graph_node becomes left node after adding
					graph_edit.connect_node(current_graph_node.name, 0, right_node.name, 0)# To be improved
				# Add Right
				2:
					if current_graph_node == null:
						return
					var new_offset = current_graph_node.offset
					new_offset.x += current_graph_node.rect_size.x * 1.2
					var left_node = current_graph_node
					add_graph_node(false, new_offset)
					# current_graph_node becomes right node after adding
					graph_edit.connect_node(left_node.name, 0, current_graph_node.name, 0)
				# Expand
				3:
					if current_graph_node == null:
						return
					# Index of last label
					var idx = current_graph_node.get_child_count() - 1
					current_graph_node.add_child(current_graph_node.get_child(idx).duplicate())
					current_graph_node.get_child(idx + 1).bbcode_text = ""
					current_graph_node.set_slot_enabled_left(idx + 1, true)
					current_graph_node.set_slot_enabled_right(idx + 1, true)
					_on_GraphEdit_node_selected(current_graph_node)# Call it manually
				# Delete
				4:
					delete_graph_node()
		
		# Settings
		2:
			match id:
				# Settings
				0:
					settings_dialog.popup_centered()
		
		# Windows
		3:
			match id:
				# Canvas
				0:
					var checked = window_popup_menu.is_item_checked(0)
					# Show or hide
					graph_edit.visible = !checked
					window_popup_menu.set_item_checked(0, !checked)
				# Inspector
				1:
					var checked = window_popup_menu.is_item_checked(1)
					# Show or hide
					inspector.visible = !checked
					window_popup_menu.set_item_checked(1, !checked)
		
		# Help
		4:
			match id:
				# About
				0:
					about_dialog.popup_centered()
		
		# Submenu Export
		10:
			match id:
				# Image
				0:
					export_image_dialog.popup_centered()
					var graph_edit_duplicate = graph_edit.duplicate()
					export_image_dialog.viewport.add_child(graph_edit_duplicate)
					# Set theme
					graph_edit_duplicate.theme = theme
					# Set size
					graph_edit_duplicate.rect_size = export_image_dialog.viewport.size
					# Graph nodes won't connect each other after duplication
					# We have to do it ourselves
					for conn in graph_edit.get_connection_list():
						graph_edit_duplicate.connect_node(conn.from, conn.from_port, conn.to, conn.to_port)
					# Hide tool bar
					for child in graph_edit_duplicate.get_children():
#						if child is GraphEditFilter:
						if not child is GraphNode and child.name != "CLAYER":
							child.hide()
					graph_edit_duplicate.update()
		


func _on_OpenFileDialog_file_selected(path):
	# Read file
	var file = File.new()
	file.open(path, File.READ)
	var content = file.get_as_text()
	file.close()
	# Clear canvas
	clear_graph_node()
	# Ensure canvas is clear
	yield(VisualServer, "frame_post_draw")
	# Parse file
	load_from_json(content)
	# Remember file path
	file_path = path


func _on_SaveFileDialog_file_selected(path):
	# Remember file path
	# I forgot it before
	file_path = path


func _on_SettingsDialog_settings_changed(key):
	match key:
		# Graph connection color
		"colorful":# TODO
			pass
		# Graph node resizable
		"resizable":
			for child in graph_edit.get_children():
				if child is GraphNode:
					child.resizable = Settings.settings["resizable"]
		# Show zoom label
		"show_zoom_label":
			graph_edit.show_zoom_label = Settings.settings["show_zoom_label"]
		# Zoom min
		"zoom_min":
			graph_edit.zoom = 1
			graph_edit.zoom_min = Settings.settings["zoom_min"]
		# Zoom max
		"zoom_max":
			graph_edit.zoom = 1
			graph_edit.zoom_max = Settings.settings["zoom_max"]
		# Zoom step
		"zoom_step":
			graph_edit.zoom = 1
			graph_edit.zoom_step = Settings.settings["zoom_step"]
		# Change theme
		"theme":
			var new_theme = ResourceLoader.load(Settings.ThemeMap[Settings.settings["theme"]], "Theme")
			VisualServer.set_default_clear_color(new_theme.get_color("dark_color_2", "Editor"))
			theme = default_theme.duplicate()
			theme.merge_with(new_theme)
