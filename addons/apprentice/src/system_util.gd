#============================================================
#    System Util
#============================================================
# - author: zhangxuetu
# - datetime: 2024-12-01 15:35:25
# - version: 4.3.0.stable
#============================================================
## 系统工具
class_name SystemUtil

enum ThemeType {
	DARK,
	LIGHT,
}

## 获取主题类型
static func get_theme_type() -> ThemeType:
	if DisplayServer.is_dark_mode_supported():
		return ThemeType.LIGHT if not DisplayServer.is_dark_mode() else ThemeType.DARK
	return ThemeType.DARK


## 执行CMD命令
static func execute_command(params: Array) -> String:
	var p = ["/C"]
	p.append_array(params)
	var output: Array = []
	var error = OS.execute("CMD.exe", p, output, true)
	return output[0]

## 查找系统配置程序的可执行文件位置
static func find_program(program_name: String) -> PackedStringArray:
	var output = SystemUtil.execute_command(["where", "ffmpeg"])
	return output.replace("\\", "/").strip_edges(false, true).split("\r\n")

## 名称区分大小写
static func find_running_program(program_name_or_id) -> Array[Dictionary]:
	var result: String
	const CMD_CODE = 'wmic process where "%s" get name,processid,executablepath /format:csv'
	if program_name_or_id is String:
		result = execute_command([CMD_CODE % ('name like "%' + program_name_or_id + '%"')])
	elif program_name_or_id is int:
		result = execute_command([CMD_CODE % 'processid="' + program_name_or_id + '"'])
	result = str(result).strip_edges().replace("\\", "/")
	# 转换为字典格式数据
	var lines = result.split("\r\n")
	if lines.size() == 1:
		return []
	var list : Array[Dictionary] = []
	var keys = lines[0].replace("\r", "").split(",")
	for idx in range(1, lines.size()):
		var items = lines[idx].replace("\r", "").split(",")
		var data = {}
		for kid in keys.size():
			data[keys[kid]] = items[kid]
		list.append(data)
	return list


## 是否有这个相同的程序正在运行
static func current_is_running() -> bool:
	var path = OS.get_executable_path().replace("/", "\\\\")
	var code = 'wmic process where "executablepath LIKE \'%' + path + '%\'" get name,processid,executablepath /format:csv'
	var output = execute_command([code])
	var result : String = str(output).strip_edges()
	var items = result.split("\r\n")
	print(items)
	return items.size() > 2 # 只能有一个这样


## 这个线程的程序是否正在执行
static func is_running(pid: int) -> bool:
	return not find_running_program(pid).is_empty()

static var _confirmation_dialog_list : Array[ConfirmationDialog] = []
## 弹出确认框
static func popup_confirmation_dialog(message: String, callback: Callable, title:="请确认...", rect:=Rect2()):
	if _confirmation_dialog_list.is_empty():
		var dialog := ConfirmationDialog.new()
		dialog.visibility_changed.connect(
			func():
				# 隐藏后断开所有连接
				if not dialog.visible:
					for item in dialog.confirmed.get_connections():
						dialog.confirmed.disconnect(item["callable"])
				_confirmation_dialog_list.append(dialog)
		, Object.CONNECT_DEFERRED)
		_confirmation_dialog_list.append(dialog)
		Engine.get_main_loop().current_scene.add_child(dialog)
	var confir_dialog := _confirmation_dialog_list.pop_back() as ConfirmationDialog
	confir_dialog.size = Vector2()
	if rect == Rect2():
		confir_dialog.popup_centered()
	else:
		confir_dialog.popup(rect)
	confir_dialog.title = title
	confir_dialog.dialog_text = message
	confir_dialog.confirmed.connect(callback, Object.CONNECT_ONE_SHOT)

static var _file_dialog_list : Array[FileDialog] = []
static func popup_file_dialog(file_mode: FileDialog.FileMode, filters: PackedStringArray, callback: Callable, global:bool=true, current_path: String = "", rect:=Rect2()) -> FileDialog:
	if _file_dialog_list.is_empty():
		var dialog := FileDialog.new()
		dialog.size = Vector2(700, 400)
		dialog.visibility_changed.connect(
			func():
				# 隐藏后断开所有连接
				if not dialog.visible:
					for item in dialog.file_selected.get_connections():
						dialog.file_selected.disconnect(item["callable"])
					for item in dialog.dir_selected.get_connections():
						dialog.dir_selected.disconnect(item["callable"])
					for item in dialog.files_selected.get_connections():
						dialog.files_selected.disconnect(item["callable"])
				_file_dialog_list.append(dialog)
		, Object.CONNECT_DEFERRED)
		_file_dialog_list.append(dialog)
		Engine.get_main_loop().current_scene.add_child(dialog)
	# 开始处理
	var file_dialog := _file_dialog_list.pop_back() as FileDialog
	if global:
		file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	else:
		file_dialog.access = FileDialog.ACCESS_RESOURCES
	file_dialog.file_mode = file_mode
	file_dialog.filters = filters
	file_dialog.current_file = ""
	file_dialog.current_dir = ""
	file_dialog.current_path = current_path
	if rect == Rect2():
		file_dialog.popup_centered.call_deferred()
	else:
		file_dialog.popup.call_deferred(rect)
	# 信号执行方式
	match file_mode:
		FileDialog.FILE_MODE_OPEN_FILE, FileDialog.FILE_MODE_SAVE_FILE, FileDialog.FILE_MODE_OPEN_ANY:
			file_dialog.file_selected.connect(callback, Object.CONNECT_ONE_SHOT)
		FileDialog.FILE_MODE_OPEN_DIR:
			file_dialog.dir_selected.connect(callback, Object.CONNECT_ONE_SHOT)
		FileDialog.FILE_MODE_OPEN_FILES:
			file_dialog.files_selected.connect(callback, Object.CONNECT_ONE_SHOT)
	return file_dialog
