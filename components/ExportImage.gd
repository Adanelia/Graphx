extends ConfirmationDialog


onready var viewport = $Viewport
onready var texture_rect = $HSplitContainer/TextureRect
onready var format_option_button = $HSplitContainer/VBoxContainer/FormatOptionButton
onready var file_path_line_edit = $HSplitContainer/VBoxContainer/HBoxContainer/FilePathLineEdit
onready var file_path_dialog = $FileDialog


# Called when the node enters the scene tree for the first time.
func _ready():
	get_cancel().connect("pressed", self, "_on_ExportImage_canceled")
	get_close_button().hide()
	
	viewport.get_texture().flags = Texture.FLAG_FILTER
	
#	popup_centered()


func _on_ExportImage_confirmed():
	yield(VisualServer, "frame_post_draw")
	var image = viewport.get_texture().get_data()
	match format_option_button.selected:
		0:
			image.save_png(file_path_line_edit.text)
		1:
			image.save_exr(file_path_line_edit.text)
	
	# Clean up
	_on_ExportImage_canceled()


func _on_ExportImage_canceled():
	for child in viewport.get_children():
		child.queue_free()


func _on_WidthSpinBox_value_changed(value):
	viewport.size.x = value
	if viewport.get_child_count() > 0:
		viewport.get_child(0).rect_size.x = value
	texture_rect.update()


func _on_HeightSpinBox_value_changed(value):
	viewport.size.y = value
	if viewport.get_child_count() > 0:
		viewport.get_child(0).rect_size.y = value
	texture_rect.update()


func _on_FilePathButton_pressed():
	file_path_dialog.popup_centered()


func _on_FileDialog_file_selected(path):
	file_path_line_edit.text = path
