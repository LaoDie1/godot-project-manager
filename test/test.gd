@tool
extends EditorScript


func _run() -> void:
	pass
	
	var list = []
	var path = OS.get_data_dir().path_join("godot-init-plugin/apprentice")
	check_diff("res://addons/apprentice", path, list)
	JsonUtil.print_stringify(list)


static func check_diff(from_path: String, to_path: String, list:Array) -> void:
	FileUtil.make_dir_if_not_exists(to_path)
	if DirAccess.dir_exists_absolute(from_path):
		for dir in DirAccess.get_directories_at(from_path):
			FileUtil.make_dir_if_not_exists(to_path.path_join(dir))
			check_diff(from_path.path_join(dir), to_path.path_join(dir), list)
		# 当前文件替换到另一个目录里
		var files = DirAccess.get_files_at(from_path)
		for file in files:
			if FileAccess.get_md5(from_path.path_join(file)) != FileAccess.get_md5(to_path.path_join(file)):
				# 不同的文件则进行替换
				list.append({
					"from": from_path.path_join(file), 
					"to": to_path.path_join(file),
				})
