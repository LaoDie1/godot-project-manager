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
@onready var projects_item_container : ProjectItemContainer = %ProjectsItemContainer
@onready var filter_timer: Timer = $FilterTimer
@onready var filter_line_edit: LineEdit = %FilterLineEdit
@onready var sort_item_button: OptionButton = %SortItemButton
@onready var project_items_split_container: HSplitContainer = %ProjectItemsSplitContainer

@onready var default_clear_color: Color = RenderingServer.get_default_clear_color()


func _ready() -> void:
	var window : Window = get_viewport()
	if Config.Misc.main_win_size.get_value():
		window.size = Config.Misc.main_win_size.get_value()
		window.position = Config.Misc.main_win_position.get_value(Vector2(50,20))
	var update_window_data_method := func():
		if window.mode == Window.MODE_WINDOWED:
			Config.Misc.main_win_size.update(window.size)
			Config.Misc.main_win_position.update(window.position)
	window.size_changed.connect(update_window_data_method)
	Global.quit_program.connect(update_window_data_method)
	for w:Window in [
		create_new_project_window,
		godot_running_program_window,
	]:
		w.close_requested.connect(w.hide)
	
	Config.Misc.last_scan_projects_path.bind_property(scan_projects_dialog, "current_path", true)
	Config.Misc.sort_mode.bind_method(sort_item_button.select, true)
	Config.Misc.project_split_offset.bind_property(project_items_split_container, "split_offset", true)
	Config.Misc.theme_color.bind_method(
		func(value):
			self.update_program_theme()
			,
		true
	)
	
	sort_items(sort_item_button.selected)
	projects_item_container.select(0)


func update_program_theme() -> void:
	if DisplayServer.is_dark_mode_supported():
		var window : Window = get_viewport()
		var type
		if Config.Misc.theme_color.get_value(0) == 0:
			type = "light" if not DisplayServer.is_dark_mode() else "dark"
		else:
			type = "light" if Config.Misc.theme_color.get_value(0) == 1 else "dark"
		
		if type == "dark":
			window.theme = null
			RenderingServer.set_default_clear_color(default_clear_color)
		elif type == "light":
			window.theme = preload("res://src/assets/custom_theme.tres")
			RenderingServer.set_default_clear_color(Color.WHITE)
		else:
			push_error("错误的主题类型：", type)


func sort_items(index: int) -> void:
	var type = sort_item_button.get_item_text(index)
	match type:
		"修改时间":
			projects_item_container.sort_item(
				func(a:ProjectItem, b:ProjectItem):
					return a.modified_time > b.modified_time
			)
		"项目名称":
			projects_item_container.sort_item(
				func(a:ProjectItem, b:ProjectItem):
					return a.project_name.to_lower() < b.project_name.to_lower()
			)
		"路径":
			projects_item_container.sort_item(
				func(a:ProjectItem, b:ProjectItem):
					return a.path < b.path
			)
	Config.Misc.sort_mode.update(index)

func scan_projects(dir: String) -> void:
	Config.Misc.last_scan_projects_path.update(scan_projects_dialog.current_path)
	var paths = FileUtil.scan_directory(dir, false)
	for path in paths:
		if DirAccess.dir_exists_absolute(path):
			if FileAccess.file_exists(path.path_join("project.godot")):
				projects_item_container.add_item(path)
	sort_items(sort_item_button.selected)

func edit_project(project_dir: String) -> void:
	Global.edit_godot_project(project_dir)
	Engine.get_main_loop().quit()

func show_selected_project_directory() -> void:
	var item = projects_item_container.get_first_selected_item()
	if item and item.visible:
		FileUtil.shell_open(item.path)

func edit_selected_project() -> void:
	var item = projects_item_container.get_first_selected_item()
	if item and item.visible:
		edit_project(item.path)

func remove_selected_items() -> void:
	var idx = projects_item_container.get_item_count()
	for i in projects_item_container.get_selected_items():
		if i.get_index() < idx:
			idx = i.get_index()
		projects_item_container.remove_item(i.path)
	projects_item_container.select(idx-1)

func run_selected_project() -> void:
	var item = projects_item_container.get_first_selected_item()
	if item and item.visible:
		Global.run_godot_project(item.path)

func update_filter_items() -> void:
	var filter_text = filter_line_edit.text.strip_edges().to_lower()
	if filter_text == "":
		for item in projects_item_container.get_items():
			item.visible = true
		return
	for item in projects_item_container.get_items():
		item.visible = item.project_name.to_lower().contains(filter_text) or item.path.contains(filter_text)

func delete_selected_items() -> void:
	var idx : int = -1
	for item in projects_item_container.get_selected_items():
		OS.move_to_trash(item.path)
		projects_item_container.remove_item(item.path)
		idx = item.get_index()
	projects_item_container.select(idx)


#============================================================
#  连接信号
#============================================================
func _on_add_project_button_pressed() -> void:
	create_new_project_window.popup_centered()

func _on_select_version_button_pressed() -> void:
	godot_running_program_window.popup_centered()

func _on_scan_button_pressed() -> void:
	scan_projects_dialog.popup_centered()

func _on_filter_line_edit_text_changed(new_text: String) -> void:
	filter_timer.start()

func _on_create_new_project_created_project(dir_path: Variant) -> void:
	projects_item_container.add_item(dir_path)
	Global.save_config_data()
	Engine.get_main_loop().quit.call_deferred()

func _on_project_items_split_container_dragged(offset: int) -> void:
	Config.Misc.project_split_offset.update(offset)
