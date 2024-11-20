#============================================================
#    Plugin
#============================================================
# - datetime: 2022-08-28 23:28:30
#============================================================
@tool
extends EditorPlugin

const DOWNLOAD_TOOL_NAME = "Download Plug-in"
const UPLOAD_TOOL_NAME = "Upload Plug-in"


func _enter_tree() -> void:
	var path = OS.get_data_dir().path_join("godot-init-plugin/apprentice")
	# 上传
	add_tool_menu_item(UPLOAD_TOOL_NAME, func():
		#FileUtil.remove(path)
		var current_path = str(get_script().resource_path).get_base_dir()
		print("<从 %s 上传到 %s >" % [current_path, path])
		copy_directory_and_file(current_path, path)
		print_debug("<完成>")
	)
	# 下载
	add_tool_menu_item(DOWNLOAD_TOOL_NAME, func():
		var current_path = str(get_script().resource_path).get_base_dir()
		print("<从 %s 下载到 %s >", [path, current_path])
		copy_directory_and_file(path, current_path)
		print_debug("<完成>")
	)


func _exit_tree() -> void:
	remove_tool_menu_item(DOWNLOAD_TOOL_NAME)
	remove_tool_menu_item(UPLOAD_TOOL_NAME)



## 复制目录和文件
static func copy_directory_and_file(path: String, new_path: String):
	FileUtil.make_dir_if_not_exists(new_path)
	if DirAccess.dir_exists_absolute(path):
		for dir in DirAccess.get_directories_at(path):
			FileUtil.make_dir_if_not_exists(new_path.path_join(dir))
			copy_directory_and_file(path.path_join(dir), new_path.path_join(dir))
			new_path.path_join(new_path.path_join(dir))
		for file in DirAccess.get_files_at(path):
			#printt("%-80s %-100s %-50s %-50s" % [ path.path_join(file), new_path.path_join(file), FileAccess.get_md5(path.path_join(file)), FileAccess.get_md5(new_path.path_join(file)) ])
			if FileAccess.get_md5(path.path_join(file)) != FileAccess.get_md5(new_path.path_join(file)):
				# 不同的文件则进行替换
				DirAccess.copy_absolute(path.path_join(file), new_path.path_join(file))
				print("  ", new_path.path_join(file))
