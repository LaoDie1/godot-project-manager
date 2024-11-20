#============================================================
#    Create New Project
#============================================================
# - author: zhangxuetu
# - datetime: 2024-11-20 15:35:29
# - version: 4.3.0.stable
#============================================================
extends Control


@onready var project_name_line_edit: LineEdit = %ProjectNameLineEdit
@onready var project_path_line_edit: LineEdit = %ProjectPathLineEdit
@onready var select_projects_dir_dialog: FileDialog = %SelectProjectsDirDialog
@onready var create_button: Button = %CreateButton
@onready var exists_error_label: Label = %ExistsErrorLabel
@onready var exists_container: HBoxContainer = %ExistsContainer
@onready var re_create_button: CheckButton = %ReCreateButton


func _ready() -> void:
	var w : Window = get_viewport()
	w.visibility_changed.connect(
		func():
			if w.visible and project_name_line_edit.text == "":
				project_path_line_edit.text = Config.Project.project_dir.get_value("")
				if project_path_line_edit.text.strip_edges() != "":
					project_path_line_edit.text += "/"
	)
	project_path_line_edit.text = Config.Project.project_dir.get_value("")
	if project_path_line_edit.text.strip_edges() != "":
		project_path_line_edit.text += "/"
	refresh_disable_status()


func refresh_disable_status():
	create_button.disabled = (FileUtil.dir_exists(project_path_line_edit.text) 
		and not re_create_button.button_pressed
	) or project_path_line_edit.text.get_file().strip_edges() == ""
	exists_container.visible = FileUtil.dir_exists(project_path_line_edit.text)


func _on_project_name_line_edit_text_changed(new_text: String) -> void:
	var file = project_path_line_edit.text.get_file()
	if new_text.begins_with(file) or file.begins_with(new_text):
		project_path_line_edit.text = project_path_line_edit.text.get_base_dir().path_join(new_text)
		refresh_disable_status()


func _on_projects_path_button_pressed() -> void:
	select_projects_dir_dialog.current_path = Config.Project.project_dir.get_value("")
	select_projects_dir_dialog.popup_centered()


func _on_select_projects_dir_dialog_dir_selected(dir: String) -> void:
	if not dir.ends_with("/"):
		dir += "/"
	project_path_line_edit.text = dir


func _on_project_path_line_edit_text_changed(new_text: String) -> void:
	refresh_disable_status()


func _on_create_button_pressed() -> void:
	var dir_path = project_path_line_edit.text
	if dir_path.get_file().strip_edges() == "":
		push_error("不能创建空项目")
		return
	
	var godot_runner = Config.Run.godot_runner.get_value("")
	if FileUtil.file_exists(godot_runner):
		# 项目配置
		if DirAccess.dir_exists_absolute(dir_path):
			OS.move_to_trash(dir_path)
		FileUtil.make_dir_if_not_exists(dir_path)
		var project = ConfigFile.new()
		project.set_value("", "config_version", 5)
		var project_name = project_name_line_edit.text.strip_edges()
		project.set_value("application", "config/name", project_name)
		project.set_value("application", "config/icon", "res://icon.svg")
		var projcet_file_path = dir_path.path_join("project.godot")
		project.save(projcet_file_path)
		# 图标文件
		DirAccess.copy_absolute("res://src/assets/icon.svg", dir_path.path_join("icon.svg"))
		# 初始化插件
		if Config.Project.init_plugin_dir.get_value():
			var addons_dir_path = dir_path.path_join("addons")
			DirAccess.make_dir_absolute(addons_dir_path)
			# 复制到插件里
			var init_plugin_dir := str(Config.Project.init_plugin_dir.get_value(""))
			print("插件目录：", init_plugin_dir, DirAccess.get_directories_at(init_plugin_dir))
			for dir_name in DirAccess.get_directories_at(init_plugin_dir):
				var plugin_dir_path = init_plugin_dir.path_join(dir_name)
				print("  复制到：", addons_dir_path.path_join(dir_name))
				FileUtil.copy_directory_and_file(plugin_dir_path, addons_dir_path.path_join(dir_name))
		
		# 创建项目
		Global.edit_godot_project(godot_runner, dir_path)
		Engine.get_main_loop().quit()
		
	else:
		push_error("没有设置项目保存的路径")
	
	var w : Window = get_viewport()
	w.hide()


func _on_close_button_pressed() -> void:
	var w : Window = get_viewport()
	w.hide()
