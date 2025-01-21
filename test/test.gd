@tool
extends EditorScript


func _run() -> void:
	var bytes : PackedByteArray = FileUtil.read_as_bytes("res://nircmd.exe")
	var path : String = FileUtil.get_project_real_path().path_join("nircmd.exe")
	FileUtil.write_as_bytes(path, bytes)
