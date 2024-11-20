#============================================================
#    Main
#============================================================
# - author: zhangxuetu
# - datetime: 2024-11-20 13:22:10
# - version: 4.3.0.stable
#============================================================
# 运行命令：https://docs.godotengine.org/zh-cn/4.x/tutorials/editor/command_line_tutorial.html
extends Control


@onready var create_new_project_window: Window = %CreateNewProjectWindow
@onready var godot_running_program_window: Window = %GodotRunningProgramWindow
@onready var scan_projects_dialog: FileDialog = %ScanProjectsDialog
@onready var projects_item_container = %ProjectsItemContainer


func _ready() -> void:
	for window:Window in [
		create_new_project_window,
		godot_running_program_window,
	]:
		window.close_requested.connect(window.hide)
	
	var w : Window = get_viewport()
	if Config.Hide.main_win_size.get_value():
		w.size = Config.Hide.main_win_size.get_value()
		w.position = Config.Hide.main_win_position.get_value(Vector2(50,20))
	w.size_changed.connect(
		func():
			Config.Hide.main_win_size.update(w.size)
			Config.Hide.main_win_position.update(w.position)
	)
	Config.Hide.last_scan_projects_path.bind_property(scan_projects_dialog, "current_path", true)


func _on_add_project_button_pressed() -> void:
	create_new_project_window.popup_centered()

func _on_select_version_button_pressed() -> void:
	godot_running_program_window.popup_centered()


func _on_scan_button_pressed() -> void:
	scan_projects_dialog.popup_centered()


func _on_scan_projects_dialog_files_selected(paths: PackedStringArray) -> void:
	Config.Hide.last_scan_projects_path.update(scan_projects_dialog.current_dir)
	for path in paths:
		if DirAccess.dir_exists_absolute(path):
			if FileAccess.file_exists(path.path_join("project.godot")):
				projects_item_container.add_file(path)


func _on_scan_projects_dialog_dir_selected(dir: String) -> void:
	Config.Hide.last_scan_projects_path.update(scan_projects_dialog.current_path)
	var paths = FileUtil.scan_directory(dir, false)
	for path in paths:
		if DirAccess.dir_exists_absolute(path):
			if FileAccess.file_exists(path.path_join("project.godot")):
				projects_item_container.add_file(path)


func _on_projects_item_container_edit_project(project_dir: String) -> void:
	var godot_runner = Config.Run.godot_runner.get_value("")
	Global.edit_godot_project(godot_runner, project_dir)
	Engine.get_main_loop().quit()


func _on_show_project_dir_button_pressed() -> void:
	var item = projects_item_container.last_selected_item
	FileUtil.shell_open(item.path)
