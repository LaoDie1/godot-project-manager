#============================================================
#    Godot Running Program
#============================================================
# - author: zhangxuetu
# - datetime: 2024-11-20 16:45:19
# - version: 4.3.0.stable
#============================================================
extends Control


@onready var window : Window = get_viewport()
@onready var godot_runner_item_list: ItemList = %GodotRunnerItemList
@onready var update_data_timer: Timer = $UpdateDataTimer
@onready var select_projects_dir_file_dialog: FileDialog = $SelectProjectsDirFileDialog
@onready var projects_dir_line_edit: LineEdit = %ProjectsDirLineEdit
@onready var select_init_plugin_dir_dialog: FileDialog = $SelectInitPluginDirDialog
@onready var init_plugin_dir_line_edit: LineEdit = %InitPluginDirLineEdit


func _ready() -> void:
	godot_runner_item_list.clear()
	window.files_dropped.connect(drop_files)
	update_data_timer.stop()
	
	# 配置的数据
	for file in Config.Run.godot_runner_files.get_value([]):
		if file is String:
			add_file(file)
	if Config.Run.godot_runner.get_value():
		for i in godot_runner_item_list.item_count:
			if godot_runner_item_list.get_item_metadata(i) == Config.Run.godot_runner.get_value():
				godot_runner_item_list.select(i, true)
				break
	Config.Project.project_dir.bind_property(projects_dir_line_edit, "text", true)
	Config.Project.project_dir.bind_property(select_projects_dir_file_dialog, "current_path", true)
	Config.Project.init_plugin_dir.bind_property(init_plugin_dir_line_edit, "text", true)


func drop_files(files):
	if get_viewport_rect().has_point(godot_runner_item_list.get_global_mouse_position()):
		var godot_runner_files := Array( Config.Run.godot_runner_files.get_value([]) )
		for file:String in files:
			if file.get_extension() == "exe":
				add_file(file)


const APP_ICON = preload("res://src/assets/app_icon.png")
var tmp := {}
func add_file(file: String):
	if not tmp.has(file) and FileUtil.file_exists(file):
		godot_runner_item_list.add_item(file.get_file().get_basename(), APP_ICON)
		godot_runner_item_list.set_item_tooltip(godot_runner_item_list.item_count-1, file)
		godot_runner_item_list.set_item_metadata(godot_runner_item_list.item_count-1, file)
	update_data_timer.start()


func _on_update_data_timer_timeout() -> void:
	var list := []
	for i in godot_runner_item_list.item_count:
		list.append(godot_runner_item_list.get_item_metadata(i))
	if hash(list) != hash( Config.Run.godot_runner_files.get_value([]) ):
		Config.Run.godot_runner_files.update(list)

func _on_item_list_item_selected(index: int) -> void:
	Config.Run.godot_runner.update( godot_runner_item_list.get_item_metadata(index) )

func _on_item_list_item_activated(index: int) -> void:
	_on_close_button_pressed()

func _on_close_button_pressed() -> void:
	var w : Window = get_viewport()
	if w:
		w.hide()
		Config.Project.project_dir.update(projects_dir_line_edit.text)
		Config.Project.init_plugin_dir.update(init_plugin_dir_line_edit.text)

func _on_select_project_dir_button_pressed() -> void:
	if DirAccess.dir_exists_absolute(projects_dir_line_edit.text):
		select_projects_dir_file_dialog.current_dir = projects_dir_line_edit.text
	else:
		select_projects_dir_file_dialog.current_dir = projects_dir_line_edit.text.get_base_dir()
	select_projects_dir_file_dialog.popup_centered()

func _on_select_projects_dir_file_dialog_dir_selected(dir: String) -> void:
	Config.Project.project_dir.update(dir)

func _on_select_init_plugin_dir_button_pressed() -> void:
	select_init_plugin_dir_dialog.current_dir = Config.Project.init_plugin_dir.get_value("")
	select_init_plugin_dir_dialog.popup_centered()

func _on_select_init_plugin_dir_dialog_dir_selected(dir: String) -> void:
	Config.Project.init_plugin_dir.update(dir)
