@tool
extends EditorScript


func _run() -> void:
	if DisplayServer.is_dark_mode_supported() and DisplayServer.is_dark_mode():
		pass
	else:
		pass
