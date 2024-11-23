#============================================================
#    Config
#============================================================
# - author: zhangxuetu
# - datetime: 2024-11-20 16:50:12
# - version: 4.3.0.stable
#============================================================
## 配置数据
class_name Config


static var default_data : Dictionary = {
	"/Run/godot_runner_files": [],
	"/Run/godot_runner": "",
	
	"/Project/project_dir": OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS),
	"/Project/init_plugin_dir": OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS),
	"/Project/project_template_dir": OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS),
	"/Project/projects_dir_list": [],
	
	"/Misc/last_scan_projects_path": OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS),
	"/Misc/sort_mode": 0,
	"/Misc/project_split_offset": 0,
	"/Misc/theme_color": 0,
}

class Run:
	static var godot_runner_files: BindPropertyItem
	static var godot_runner: BindPropertyItem

class Project:
	static var project_dir: BindPropertyItem
	static var init_plugin_dir: BindPropertyItem
	static var project_template_dir : BindPropertyItem
	static var projects_dir_list : BindPropertyItem

class Misc:
	static var main_win_size : BindPropertyItem
	static var main_win_position : BindPropertyItem
	static var sort_mode : BindPropertyItem
	static var last_scan_projects_path : BindPropertyItem
	static var project_split_offset : BindPropertyItem
	static var theme_color : BindPropertyItem
