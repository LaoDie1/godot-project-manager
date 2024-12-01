#============================================================
#    Global
#============================================================
# - author: zhangxuetu
# - datetime: 2024-11-20 16:50:39
# - version: 4.3.0.stable
#============================================================
extends Node


signal quit_program


var last_data_hash := 0
var config_path := OS.get_data_dir().path_join("godot/godot-project-manager/config.data")
var propertys := {}


func _enter_tree() -> void:
	if not Engine.get_main_loop().resume:
		return
	Engine.get_main_loop().auto_accept_quit = false # 不会自动退出
	FileUtil.make_dir_if_not_exists(config_path.get_base_dir())
	var last_data := {} 
	if FileUtil.file_exists(config_path):
		last_data = FileUtil.read_as_var(config_path)
	print("加载数据:", config_path)
	ScriptUtil.init_class_static_value(
		Config,
		func(script: GDScript, path:String, property: String):
			if path:
				var property_path = path.path_join(property)
				var value = ( last_data.get(property_path) if last_data.has(property_path) else Config.default_data.get(property_path) )
				var bind_property := BindPropertyItem.new(property_path, value)
				script.set(property, bind_property)
				propertys[property_path] = bind_property
	)
	OS.set_thread_name("Godot Engine - 项目管理器")
	last_data_hash = hash(last_data)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		self.quit_program.emit()
		var window : Window = Engine.get_main_loop().root
		window.mode = Window.MODE_MINIMIZED

## 保存配置数据
func save_config_data():
	var data := {}
	for bind_property:BindPropertyItem in propertys.values():
		data[bind_property.get_name()] = bind_property.get_value()
	if last_data_hash != hash(data):
		FileUtil.write_as_var(config_path, data)
		print("数据已发生改变，保存数据")
		print(data)

func quit():
	save_config_data()
	Engine.get_main_loop().quit.call_deferred()


## 编辑godot项目。godot_runner 为 godot.exe 文件
func edit_godot_project(project_dir: String):
	var godot_runner = Config.Run.godot_runner.get_value("")
	if godot_runner and FileAccess.file_exists(godot_runner):
		OS.execute_with_pipe(godot_runner, ["-e", "--path ", project_dir])
		_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	else:
		push_error("没有执行的 Godot 程序")

func run_godot_project(project_dir: String):
	if DirAccess.dir_exists_absolute(project_dir):
		var godot_runner = Config.Run.godot_runner.get_value("")
		if godot_runner and FileAccess.file_exists(godot_runner):
			OS.execute_with_pipe(godot_runner, ["--path ", project_dir])
		else:
			push_error("没有执行的 Godot 程序")
	else:
		push_error("没有这个项目 ", project_dir)
