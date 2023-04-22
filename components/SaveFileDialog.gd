extends FileDialog


var data := ""


# Called when the node enters the scene tree for the first time.
func _ready():
	get_cancel().connect("pressed", self, "_on_SaveFileDialog_canceled")


func save(data_save):
	data = data_save


func _on_SaveFileDialog_canceled():
	data = ""


func _on_SaveFileDialog_file_selected(path):
	if data == "":
		printerr("SAVE ERROR empty data")
		return
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_string(data)
	file.close()
