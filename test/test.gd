@tool
extends EditorScript


func _run() -> void:
	pass
	var time = FileAccess.get_modified_time(r"C:\Users\z\Documents\Godot\projects\4.x\godot-project-manager")
	print( Time.get_datetime_string_from_unix_time(time) )
	
