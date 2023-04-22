extends VBoxContainer

signal property_changed(key, value)


onready var text_edit = $TextEdit


func set_up(text : String, left_slot : bool, right_slot : bool, comment : bool):
	text_edit.text = text
	$LeftSlotCheckButton.pressed = left_slot
	$RightSlotCheckButton.pressed = right_slot
	$CommentCheckButton.pressed = comment


func _on_TextEdit_text_changed():
	emit_signal("property_changed", "text", text_edit.text)


func _on_LeftSlotCheckButton_toggled(button_pressed):
	emit_signal("property_changed", "left_slot", button_pressed)


func _on_RightSlotCheckButton_toggled(button_pressed):
	emit_signal("property_changed", "right_slot", button_pressed)


func _on_CommentCheckButton_toggled(button_pressed):
	emit_signal("property_changed", "comment", button_pressed)
